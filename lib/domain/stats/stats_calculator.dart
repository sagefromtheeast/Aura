// lib/domain/stats/stats_calculator.dart
// Aura — Statistics engine.
// Architecture §4.5 / PRD §6.5: Statistics & Wrapped.
//
// ═══════════════════════════════════════════════════════════════════════════
// HOW THIS WORKS
// ═══════════════════════════════════════════════════════════════════════════
//
// Every aggregation is derived from raw playback_history rows for the period,
// fetched once and grouped in memory. A dozen breakdowns — hour of day, day of
// week, top artists, streaks, personality — come out of the same scan rather
// than a dozen SQL round trips.
//
// Two rules run through all of it:
//
//   • Listening TIME counts only completed plays. A track you skipped after
//     ten seconds contributed ten seconds of audio, but counting it would
//     make "time listened" reward abandoning music.
//   • Play COUNTS likewise mean completed plays; skips are counted separately
//     and reported as [WeeklyStats.skipRate].
//
// Everything is local. No network, no identifiers leave the device.

import '../entities/track.dart';
import '../repositories/behavior_repository.dart';
import '../repositories/music_repository.dart';
import 'stats_models.dart';

/// Fraction of unique artists among plays that earns "Eclectic Explorer".
const double kEclecticArtistRatio = 0.40;

/// Share of plays from one genre that earns "Genre Specialist".
const double kGenreSpecialistShare = 0.50;

/// Share of plays from one album that earns "Album Loyalist".
const double kAlbumLoyalistShare = 0.30;

/// Share of plays after 9 PM / before 9 AM that earns the time-of-day badges.
const double kTimeOfDayShare = 0.60;

/// Hour at or after which listening counts as "night".
const int kNightStartHour = 21;

/// Hour before which listening counts as "morning".
const int kMorningEndHour = 9;

/// Weekend-to-weekday ratio of daily listening that earns "Binge Listener".
const double kBingeWeekendRatio = 2.0;

/// Minimum star rating that counts as a "like".
const int kLikeRatingThreshold = 4;

/// Below this many plays, personality detection has nothing to go on.
const int kMinPlaysForPersonality = 10;

class StatsCalculator {
  StatsCalculator({
    required this.historyRepository,
    required this.trackRepository,
  });

  final BehaviorRepository historyRepository;
  final MusicRepository trackRepository;

  // ── Period summaries ───────────────────────────────────────────────────────

  /// Aggregates the week containing [weekStart] (Monday-based).
  ///
  /// Defaults to the current week. Any time within the week works — it is
  /// snapped back to local midnight on that Monday.
  Future<WeeklyStats> getWeeklyStats({DateTime? weekStart}) async {
    final start = startOfWeek(weekStart ?? DateTime.now());
    final end = start.add(const Duration(days: 7));

    final period = await _load(start, end);

    // Seven buckets, Monday first. Built from local dates rather than by
    // dividing elapsed time, so a DST change does not shift a day's plays.
    final daily = List<double>.filled(7, 0);
    for (final play in period.completed) {
      final index = play.at.weekday - DateTime.monday;
      daily[index] += play.event.durationPlayedMs / 60000.0;
    }

    return WeeklyStats(
      totalListeningTime: period.totalListeningTime,
      tracksPlayed: period.completed.length,
      uniqueTracks: period.uniqueTrackIds.length,
      artistsPlayed: period.uniqueArtists.length,
      albumsPlayed: period.uniqueAlbums.length,
      skips: period.skips.length,
      likes: period.likes,
      newDiscoveries: await _countDiscoveries(start, end),
      weekStart: start,
      weekEnd: end,
      dailyMinutes: daily,
    );
  }

  /// Aggregates the calendar month containing [monthStart].
  Future<MonthlyStats> getMonthlyStats({DateTime? monthStart}) async {
    final anchor = monthStart ?? DateTime.now();
    final start = DateTime(anchor.year, anchor.month, 1);
    final end = DateTime(anchor.year, anchor.month + 1, 1);

    final period = await _load(start, end);

    return MonthlyStats(
      totalListeningTime: period.totalListeningTime,
      tracksPlayed: period.completed.length,
      uniqueTracks: period.uniqueTrackIds.length,
      artistsPlayed: period.uniqueArtists.length,
      albumsPlayed: period.uniqueAlbums.length,
      skips: period.skips.length,
      likes: period.likes,
      newDiscoveries: await _countDiscoveries(start, end),
      monthStart: start,
      monthEnd: end,
      topArtists: _rankArtists(period, limit: 10),
      topTracks: _rankTracks(period, limit: 10),
      topAlbums: _rankAlbums(period, limit: 10),
      personality: _personalityFrom(period),
    );
  }

  /// Aggregates a calendar year, defaulting to the current one.
  Future<YearlyStats> getYearlyStats({int? year}) async {
    final resolved = year ?? DateTime.now().year;
    final start = DateTime(resolved, 1, 1);
    final end = DateTime(resolved + 1, 1, 1);

    final period = await _load(start, end);

    final monthly = List<double>.filled(12, 0);
    for (final play in period.completed) {
      monthly[play.at.month - 1] += play.event.durationPlayedMs / 60000.0;
    }

    return YearlyStats(
      year: resolved,
      totalListeningTime: period.totalListeningTime,
      tracksPlayed: period.completed.length,
      uniqueTracks: period.uniqueTrackIds.length,
      artistsPlayed: period.uniqueArtists.length,
      albumsPlayed: period.uniqueAlbums.length,
      skips: period.skips.length,
      newDiscoveries: await _countDiscoveries(start, end),
      topArtists: _rankArtists(period, limit: 10),
      topTracks: _rankTracks(period, limit: 10),
      topAlbums: _rankAlbums(period, limit: 10),
      monthlyMinutes: monthly,
      personality: _personalityFrom(period),
    );
  }

  // ── Breakdowns ─────────────────────────────────────────────────────────────

  /// One [DailyStat] per day for the last [days] days, oldest first.
  ///
  /// Days with no listening are present with zero values, so a chart can plot
  /// the series directly without filling gaps itself.
  Future<List<DailyStat>> getDailyListeningHistory({int days = 30}) async {
    final today = startOfDay(DateTime.now());
    final start = today.subtract(Duration(days: days - 1));
    final end = today.add(const Duration(days: 1));

    final period = await _load(start, end);

    final byDay = <DateTime, List<_Play>>{};
    for (final play in period.plays) {
      byDay.putIfAbsent(startOfDay(play.at), () => <_Play>[]).add(play);
    }

    return [
      for (var i = 0; i < days; i++)
        () {
          // Add days to the local date rather than adding 24h, so a DST
          // transition does not slide the bucket onto the wrong day.
          final date = DateTime(start.year, start.month, start.day + i);
          final plays = byDay[date] ?? const <_Play>[];
          var listenedMs = 0;
          var completed = 0;
          var skipped = 0;
          for (final play in plays) {
            if (play.event.completed) {
              listenedMs += play.event.durationPlayedMs;
              completed++;
            }
            if (play.event.skipped) skipped++;
          }
          return DailyStat(
            date: date,
            listeningTime: Duration(milliseconds: listenedMs),
            tracksPlayed: completed,
            skips: skipped,
          );
        }(),
    ];
  }

  /// Completed plays per hour of day over the last [days] days.
  ///
  /// Keys are zero-padded 24-hour strings, `'00'` through `'23'`, and all 24
  /// are always present so a heatmap never has to guess at a missing hour.
  Future<Map<String, int>> getListeningByHourOfDay({int days = 30}) async {
    final period = await _loadTrailing(days);

    final counts = <String, int>{
      for (var hour = 0; hour < 24; hour++)
        hour.toString().padLeft(2, '0'): 0,
    };
    for (final play in period.completed) {
      final key = play.at.hour.toString().padLeft(2, '0');
      counts[key] = counts[key]! + 1;
    }
    return counts;
  }

  /// Completed plays per day of week over the last [days] days.
  ///
  /// Keys are `'Mon'` through `'Sun'`, in that order, all always present.
  Future<Map<String, int>> getListeningByDayOfWeek({int days = 30}) async {
    final period = await _loadTrailing(days);

    final counts = <String, int>{for (final name in _weekdayNames) name: 0};
    for (final play in period.completed) {
      final key = _weekdayNames[play.at.weekday - DateTime.monday];
      counts[key] = counts[key]! + 1;
    }
    return counts;
  }

  // ── Rankings ───────────────────────────────────────────────────────────────

  Future<List<TopArtist>> getTopArtists({int limit = 10, int days = 30}) async =>
      _rankArtists(await _loadTrailing(days), limit: limit);

  Future<List<TopTrack>> getTopTracks({int limit = 10, int days = 30}) async =>
      _rankTracks(await _loadTrailing(days), limit: limit);

  Future<List<TopAlbum>> getTopAlbums({int limit = 10, int days = 30}) async =>
      _rankAlbums(await _loadTrailing(days), limit: limit);

  /// Rankings over an exact `[start, end)` range.
  ///
  /// The trailing-window variants above answer "the last 30 days"; these
  /// answer "this calendar week", which is not the same thing on a Thursday.
  Future<List<TopArtist>> getTopArtistsBetween(
    DateTime start,
    DateTime end, {
    int limit = 10,
  }) async =>
      _rankArtists(await _load(start, end), limit: limit);

  Future<List<TopTrack>> getTopTracksBetween(
    DateTime start,
    DateTime end, {
    int limit = 10,
  }) async =>
      _rankTracks(await _load(start, end), limit: limit);

  Future<List<TopAlbum>> getTopAlbumsBetween(
    DateTime start,
    DateTime end, {
    int limit = 10,
  }) async =>
      _rankAlbums(await _load(start, end), limit: limit);

  // ── Streak ─────────────────────────────────────────────────────────────────

  /// Consecutive days ending today on which at least one track was completed.
  ///
  /// Today not having any listening *yet* does not break a streak — it is
  /// still early. In that case the count runs back from yesterday, so a streak
  /// only ends once a whole day passes with nothing played.
  Future<int> getCurrentStreak({DateTime? now}) async {
    final today = startOfDay(now ?? DateTime.now());

    final firstEventMs = await historyRepository.getFirstEventMs();
    if (firstEventMs == null) return 0;

    final firstDay =
        startOfDay(DateTime.fromMillisecondsSinceEpoch(firstEventMs));
    final events = await historyRepository.getEventsInRange(
      firstDay.millisecondsSinceEpoch,
      today.add(const Duration(days: 1)).millisecondsSinceEpoch,
    );

    final listenedDays = <DateTime>{};
    for (final event in events) {
      if (!event.completed) continue;
      listenedDays.add(
          startOfDay(DateTime.fromMillisecondsSinceEpoch(event.playedAtMs)));
    }
    if (listenedDays.isEmpty) return 0;

    // Start at today, or yesterday when today is still silent.
    var cursor = today;
    if (!listenedDays.contains(cursor)) {
      cursor = DateTime(today.year, today.month, today.day - 1);
      if (!listenedDays.contains(cursor)) return 0;
    }

    var streak = 0;
    while (listenedDays.contains(cursor)) {
      streak++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return streak;
  }

  // ── Personality ────────────────────────────────────────────────────────────

  /// The user's listening personality over the last [days] days, as a label.
  Future<String> getListeningPersonality({int days = 30}) async =>
      (await getPersonality(days: days)).label;

  /// The same, as the enum — the Wrapped card needs its emoji and blurb too.
  Future<ListeningPersonality> getPersonality({int days = 30}) async =>
      _personalityFrom(await _loadTrailing(days));

  /// Picks a personality from an already-loaded period.
  ///
  /// Several rules can hold at once, so they are tested in the order the spec
  /// lists them and the first match wins.
  ListeningPersonality _personalityFrom(_Period period) {
    final plays = period.completed;
    // Percentages over a handful of plays say nothing; three late-night songs
    // in a quiet week would otherwise crown a Night Owl.
    if (plays.length < kMinPlaysForPersonality) {
      return ListeningPersonality.balanced;
    }
    final total = plays.length;

    var night = 0;
    var morning = 0;
    final byGenre = <String, int>{};
    final byAlbum = <String, int>{};
    var weekendPlays = 0;
    final weekendDays = <DateTime>{};
    final weekdayDays = <DateTime>{};
    var weekdayPlays = 0;

    for (final play in plays) {
      final hour = play.at.hour;
      if (hour >= kNightStartHour) night++;
      if (hour < kMorningEndHour) morning++;

      final track = play.track;
      if (track != null) {
        if (track.genre.isNotEmpty) {
          byGenre[track.genre] = (byGenre[track.genre] ?? 0) + 1;
        }
        byAlbum[track.albumId] = (byAlbum[track.albumId] ?? 0) + 1;
      }

      final day = startOfDay(play.at);
      final isWeekend = play.at.weekday == DateTime.saturday ||
          play.at.weekday == DateTime.sunday;
      if (isWeekend) {
        weekendPlays++;
        weekendDays.add(day);
      } else {
        weekdayPlays++;
        weekdayDays.add(day);
      }
    }

    if (night / total > kTimeOfDayShare) return ListeningPersonality.nightOwl;
    if (morning / total > kTimeOfDayShare) {
      return ListeningPersonality.morningPerson;
    }

    if (period.uniqueArtists.length / total > kEclecticArtistRatio) {
      return ListeningPersonality.eclecticExplorer;
    }

    // Genre share is measured against plays that actually have a genre — a
    // library of untagged files would otherwise never reach 50%.
    final genrePlays = byGenre.values.fold<int>(0, (a, b) => a + b);
    if (genrePlays > 0) {
      final topGenre = byGenre.values.reduce((a, b) => a > b ? a : b);
      if (topGenre / genrePlays > kGenreSpecialistShare) {
        return ListeningPersonality.genreSpecialist;
      }
    }

    if (byAlbum.isNotEmpty) {
      final topAlbum = byAlbum.values.reduce((a, b) => a > b ? a : b);
      if (topAlbum / total > kAlbumLoyalistShare) {
        return ListeningPersonality.albumLoyalist;
      }
    }

    // Per-day averages, not totals: there are only two weekend days in five
    // weekdays, so comparing raw counts would never find a binge listener.
    if (weekendDays.isNotEmpty && weekdayDays.isNotEmpty) {
      final weekendRate = weekendPlays / weekendDays.length;
      final weekdayRate = weekdayPlays / weekdayDays.length;
      if (weekdayRate > 0 && weekendRate / weekdayRate > kBingeWeekendRatio) {
        return ListeningPersonality.bingeListener;
      }
    }

    return ListeningPersonality.balanced;
  }

  // ── CSV export ─────────────────────────────────────────────────────────────

  /// Play history as CSV, newest last.
  ///
  /// Written for a spreadsheet, not for re-import: timestamps are ISO-8601
  /// local time, and every field is quoted and escaped so a comma in a title
  /// cannot shift the columns.
  Future<String> exportPlayHistoryToCsv({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final start = startDate ?? DateTime.fromMillisecondsSinceEpoch(0);
    final end = endDate ?? DateTime.now().add(const Duration(days: 1));

    final period = await _load(start, end);

    final buffer = StringBuffer()
      ..writeln('track_title,artist,album,played_at,duration_ms,completed,'
          'skipped');

    for (final play in period.plays) {
      final track = play.track;
      buffer.writeln([
        _csvField(track?.title ?? 'Unknown'),
        _csvField(track?.artistName ?? 'Unknown Artist'),
        _csvField(track?.albumTitle ?? 'Unknown Album'),
        _csvField(play.at.toIso8601String()),
        _csvField('${play.event.durationPlayedMs}'),
        _csvField(play.event.completed ? 'true' : 'false'),
        _csvField(play.event.skipped ? 'true' : 'false'),
      ].join(','));
    }

    return buffer.toString();
  }

  // ── Loading and grouping ───────────────────────────────────────────────────

  Future<_Period> _loadTrailing(int days) {
    final today = startOfDay(DateTime.now());
    return _load(
      today.subtract(Duration(days: days - 1)),
      today.add(const Duration(days: 1)),
    );
  }

  /// Fetches `[start, end)` once and resolves each event to its track.
  Future<_Period> _load(DateTime start, DateTime end) async {
    final events = await historyRepository.getEventsInRange(
      start.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
    );

    // History can outlive the library: a track removed from disk still has
    // plays. getAllTracks() hides soft-deleted rows, so anything missing is
    // looked up individually and rendered as best we can.
    final tracks = <String, Track>{
      for (final t in await trackRepository.getAllTracks()) t.id: t,
    };
    final missing = <String>{
      for (final e in events)
        if (!tracks.containsKey(e.trackId)) e.trackId,
    };
    for (final id in missing) {
      final track = await trackRepository.getTrackById(id);
      if (track != null) tracks[id] = track;
    }

    return _Period([
      for (final event in events)
        _Play(
          event: event,
          at: DateTime.fromMillisecondsSinceEpoch(event.playedAtMs),
          track: tracks[event.trackId],
        ),
    ]);
  }

  /// Tracks whose first ever play falls inside `[start, end)`.
  Future<int> _countDiscoveries(DateTime start, DateTime end) async {
    final firstPlays = await historyRepository.getFirstPlayMsPerTrack();
    final startMs = start.millisecondsSinceEpoch;
    final endMs = end.millisecondsSinceEpoch;
    return firstPlays.values
        .where((ms) => ms >= startMs && ms < endMs)
        .length;
  }

  // ── Ranking ────────────────────────────────────────────────────────────────

  List<TopArtist> _rankArtists(_Period period, {required int limit}) {
    final plays = <String, int>{};
    final time = <String, int>{};
    final art = <String, String?>{};

    for (final play in period.completed) {
      final track = play.track;
      if (track == null) continue;
      final name = track.artistName;
      plays[name] = (plays[name] ?? 0) + 1;
      time[name] = (time[name] ?? 0) + play.event.durationPlayedMs;
      art[name] ??= track.coverArtPath;
    }

    final ranked = plays.keys.toList()
      ..sort((a, b) => _compareRank(
          plays[a]!, plays[b]!, time[a]!, time[b]!, a, b));

    return [
      for (final name in ranked.take(limit))
        TopArtist(
          name: name,
          playCount: plays[name]!,
          totalTime: Duration(milliseconds: time[name]!),
          imagePath: art[name],
        ),
    ];
  }

  List<TopTrack> _rankTracks(_Period period, {required int limit}) {
    final plays = <String, int>{};
    final time = <String, int>{};
    final skips = <String, int>{};
    final tracks = <String, Track>{};

    for (final play in period.plays) {
      final track = play.track;
      if (track == null) continue;
      tracks[track.id] = track;
      if (play.event.completed) {
        plays[track.id] = (plays[track.id] ?? 0) + 1;
        time[track.id] = (time[track.id] ?? 0) + play.event.durationPlayedMs;
      }
      if (play.event.skipped) {
        skips[track.id] = (skips[track.id] ?? 0) + 1;
      }
    }

    // A track that was only ever skipped does not belong in "top tracks".
    final ranked = plays.keys.toList()
      ..sort((a, b) => _compareRank(
          plays[a]!, plays[b]!, time[a] ?? 0, time[b] ?? 0, a, b));

    return [
      for (final id in ranked.take(limit))
        TopTrack(
          track: tracks[id]!,
          playCount: plays[id]!,
          totalTime: Duration(milliseconds: time[id] ?? 0),
          skipCount: skips[id] ?? 0,
        ),
    ];
  }

  List<TopAlbum> _rankAlbums(_Period period, {required int limit}) {
    final plays = <String, int>{};
    final time = <String, int>{};
    final titles = <String, String>{};
    final artists = <String, String>{};
    final art = <String, String?>{};

    for (final play in period.completed) {
      final track = play.track;
      if (track == null) continue;
      final id = track.albumId;
      plays[id] = (plays[id] ?? 0) + 1;
      time[id] = (time[id] ?? 0) + play.event.durationPlayedMs;
      titles[id] ??= track.albumTitle;
      artists[id] ??= track.artistName;
      art[id] ??= track.coverArtPath;
    }

    final ranked = plays.keys.toList()
      ..sort((a, b) => _compareRank(
          plays[a]!, plays[b]!, time[a]!, time[b]!, a, b));

    return [
      for (final id in ranked.take(limit))
        TopAlbum(
          title: titles[id]!,
          artistName: artists[id]!,
          playCount: plays[id]!,
          totalTime: Duration(milliseconds: time[id]!),
          coverArtPath: art[id],
        ),
    ];
  }

  /// Play count descending, then listening time, then key — so a tie never
  /// depends on map iteration order and a chart does not reshuffle on refresh.
  static int _compareRank(
      int playsA, int playsB, int timeA, int timeB, String keyA, String keyB) {
    if (playsA != playsB) return playsB.compareTo(playsA);
    if (timeA != timeB) return timeB.compareTo(timeA);
    return keyA.compareTo(keyB);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internals
// ─────────────────────────────────────────────────────────────────────────────

const List<String> _weekdayNames = [
  'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
];

/// One history row with its local timestamp and resolved track.
class _Play {
  const _Play({required this.event, required this.at, required this.track});

  final PlayEvent event;
  final DateTime at;

  /// Null when the track is no longer in the library.
  final Track? track;
}

/// A period's events, with the groupings every aggregation needs.
class _Period {
  _Period(this.plays);

  final List<_Play> plays;

  late final List<_Play> completed =
      plays.where((p) => p.event.completed).toList(growable: false);

  late final List<_Play> skips =
      plays.where((p) => p.event.skipped).toList(growable: false);

  late final Duration totalListeningTime = Duration(
    milliseconds:
        completed.fold(0, (sum, p) => sum + p.event.durationPlayedMs),
  );

  late final Set<String> uniqueTrackIds = {
    for (final p in completed) p.event.trackId,
  };

  late final Set<String> uniqueArtists = {
    for (final p in completed)
      if (p.track != null) p.track!.artistName,
  };

  late final Set<String> uniqueAlbums = {
    for (final p in completed)
      if (p.track != null) p.track!.albumId,
  };

  /// Distinct tracks played this period that the user rates 4+.
  late final int likes = {
    for (final p in completed)
      if (p.track != null && p.track!.rating >= kLikeRatingThreshold)
        p.track!.id,
  }.length;
}

// ─────────────────────────────────────────────────────────────────────────────
// Date helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Local midnight on [date]'s day.
DateTime startOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);

/// Local midnight on the Monday of [date]'s week.
DateTime startOfWeek(DateTime date) {
  final day = startOfDay(date);
  // DateTime.monday == 1, so this is 0 on a Monday and 6 on a Sunday.
  return DateTime(day.year, day.month, day.day - (day.weekday - DateTime.monday));
}

/// Quotes and escapes one CSV field per RFC 4180.
String _csvField(String value) => '"${value.replaceAll('"', '""')}"';
