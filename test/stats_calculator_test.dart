// test/stats_calculator_test.dart
// Aura — Step 2.7 statistics engine.
//
//   flutter test test/stats_calculator_test.dart

import 'package:flutter_test/flutter_test.dart';

import 'package:aura/domain/entities/album.dart';
import 'package:aura/domain/entities/artist.dart';
import 'package:aura/domain/entities/track.dart';
import 'package:aura/domain/repositories/behavior_repository.dart';
import 'package:aura/domain/repositories/music_repository.dart';
import 'package:aura/domain/stats/stats_calculator.dart';
import 'package:aura/domain/stats/stats_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fakes
// ─────────────────────────────────────────────────────────────────────────────

class FakeHistoryRepository implements BehaviorRepository {
  FakeHistoryRepository(this.events);

  final List<PlayEvent> events;

  @override
  Future<List<PlayEvent>> getEventsInRange(int startMs, int endMs) async {
    final hits = events
        .where((e) => e.playedAtMs >= startMs && e.playedAtMs < endMs)
        .toList()
      ..sort((a, b) => a.playedAtMs.compareTo(b.playedAtMs));
    return hits;
  }

  @override
  Future<Map<String, int>> getFirstPlayMsPerTrack() async {
    final first = <String, int>{};
    for (final e in events) {
      final existing = first[e.trackId];
      if (existing == null || e.playedAtMs < existing) {
        first[e.trackId] = e.playedAtMs;
      }
    }
    return first;
  }

  @override
  Future<int?> getFirstEventMs() async {
    if (events.isEmpty) return null;
    return events.map((e) => e.playedAtMs).reduce((a, b) => a < b ? a : b);
  }

  // ── Unused ────────────────────────────────────────────────────────────────
  @override
  Future<void> recordEvent(PlayEvent event) async => events.add(event);
  @override
  Future<Map<String, TrackBehaviorStats>> getBehaviorStats(
          List<String> trackIds) async =>
      const {};
  @override
  Future<List<PlayEvent>> getPlayHistory(String trackId,
          {int limit = 100}) async =>
      events.where((e) => e.trackId == trackId).toList();
  @override
  Future<List<String>> getTopPlayedTrackIds(
          {int topN = 20, int days = 30}) async =>
      const [];
  @override
  Future<void> pruneHistory(Duration retainDuration) async {}
  @override
  Future<List<String>> getRecentlyPlayedTrackIds({int limit = 200}) async =>
      const [];
}

class FakeTrackRepository implements MusicRepository {
  FakeTrackRepository(List<Track> tracks)
      : _tracks = {for (final t in tracks) t.id: t};

  final Map<String, Track> _tracks;

  @override
  Future<List<Track>> getAllTracks() async =>
      _tracks.values.where((t) => !t.isDeleted).toList();

  @override
  Future<Track?> getTrackById(String id) async => _tracks[id];

  // ── Unused ────────────────────────────────────────────────────────────────
  @override
  Future<List<Track>> getTracksByAlbum(String albumId) async => const [];
  @override
  Future<List<Track>> getTracksByArtist(String artistId) async => const [];
  @override
  Future<List<Album>> getAllAlbums() async => const [];
  @override
  Future<List<Artist>> getAllArtists() async => const [];
  @override
  Stream<int> scanLibrary() => const Stream.empty();
  @override
  Future<void> upsertTracks(List<Track> tracks) async {}
  @override
  Future<void> deleteTrack(String trackId) async {}
  @override
  Future<void> recordPlay(String trackId,
      {required int durationPlayedMs}) async {}
  @override
  Future<void> recordSkip(String trackId) async {}
  @override
  Future<void> setRating(String trackId, int rating) async {}
  @override
  Future<List<Track>> getFavouriteTracks() async => const [];
  @override
  Future<List<Track>> getTracksByIds(List<String> ids) async => const [];
  @override
  Future<List<GenreSummary>> getGenres() async => const [];
  @override
  Future<List<Track>> findTracksByGenre(String genre) async => const [];
  @override
  Future<List<Track>> getRecentlyAddedTracks({int limit = 200}) async => const [];
  @override
  Future<List<Track>> getNeverPlayedTracks() async => const [];
  @override
  Future<void> setFavourite(String trackId, bool favourite) async {}
  @override
  Future<Track?> getTrackByPath(String filePath) async => null;
  @override
  Future<void> applyBackupStats(String trackId,
      {int? rating, int? playCount, int? skipCount, int? lastPlayedMs}) async {}
  @override
  Future<List<double>?> getAudioFeatures(String trackId) async => null;
  @override
  Future<void> upsertAudioFeatures(
      String trackId, List<double> features) async {}
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Track track(
  String id, {
  String title = 'Song',
  String artist = 'Artist',
  String album = 'Album',
  String? albumId,
  String genre = 'Rock',
  int durationMs = 240000,
  int rating = 0,
  bool isDeleted = false,
}) {
  return Track(
    id: id,
    title: title,
    artistName: artist,
    albumTitle: album,
    artistId: 'artist_$artist',
    albumId: albumId ?? 'album_$album',
    durationMs: durationMs,
    filePath: '/music/$id.flac',
    fileSizeBytes: 1000,
    genre: genre,
    rating: rating,
    dateAddedMs: 0,
    isDeleted: isDeleted,
  );
}

PlayEvent play(
  String trackId,
  DateTime at, {
  int durationPlayedMs = 200000,
  bool completed = true,
  bool skipped = false,
}) {
  return PlayEvent(
    trackId: trackId,
    playedAtMs: at.millisecondsSinceEpoch,
    durationPlayedMs: durationPlayedMs,
    skipped: skipped,
    completed: completed,
  );
}

PlayEvent skip(String trackId, DateTime at) =>
    play(trackId, at, durationPlayedMs: 5000, completed: false, skipped: true);

StatsCalculator calculatorFor(List<PlayEvent> events, List<Track> tracks) =>
    StatsCalculator(
      historyRepository: FakeHistoryRepository(List.of(events)),
      trackRepository: FakeTrackRepository(tracks),
    );

/// Local midnight today, so tests line up with the calculator's day buckets.
DateTime get today {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime daysAgo(int n, {int hour = 12}) {
  final d = today;
  return DateTime(d.year, d.month, d.day - n, hour);
}

void main() {
  // ───────────────────────────────────────────────────────────────────────────
  group('Total listening time', () {
    test('sums completed plays only', () async {
      final monday = startOfWeek(DateTime.now()).add(const Duration(hours: 10));
      final calc = calculatorFor(
        [
          play('a', monday, durationPlayedMs: 200000),
          play('b', monday.add(const Duration(hours: 1)),
              durationPlayedMs: 100000),
          // Skipped: its 5 seconds must not count as listening.
          skip('c', monday.add(const Duration(hours: 2))),
          // Neither completed nor skipped — playback simply stopped.
          play('d', monday.add(const Duration(hours: 3)),
              durationPlayedMs: 60000, completed: false),
        ],
        [track('a'), track('b'), track('c'), track('d')],
      );

      final stats = await calc.getWeeklyStats();

      expect(stats.totalListeningTime, const Duration(milliseconds: 300000));
      expect(stats.tracksPlayed, 2);
      expect(stats.skips, 1);
    });

    test('an empty history yields a zeroed week, not an error', () async {
      final calc = calculatorFor([], []);
      final stats = await calc.getWeeklyStats();

      expect(stats.totalListeningTime, Duration.zero);
      expect(stats.tracksPlayed, 0);
      expect(stats.skipRate, 0.0);
      expect(stats.hasData, isFalse);
      expect(stats.dailyMinutes, hasLength(7));
      expect(stats.dailyMinutes.every((m) => m == 0), isTrue);
    });

    test('skip rate is a percentage of all started plays', () async {
      final monday = startOfWeek(DateTime.now()).add(const Duration(hours: 9));
      final calc = calculatorFor(
        [
          play('a', monday),
          play('a', monday.add(const Duration(hours: 1))),
          play('a', monday.add(const Duration(hours: 2))),
          skip('a', monday.add(const Duration(hours: 3))),
        ],
        [track('a')],
      );

      final stats = await calc.getWeeklyStats();
      expect(stats.skipRate, 25.0);
    });

    test('the week is Monday-based and excludes the next Monday', () async {
      final monday = startOfWeek(DateTime.now());
      final calc = calculatorFor(
        [
          play('a', monday.add(const Duration(hours: 1))),
          play('a', monday.add(const Duration(days: 6, hours: 23))),
          // Next Monday, 00:00 — the exclusive end of the range.
          play('a', monday.add(const Duration(days: 7))),
        ],
        [track('a')],
      );

      final stats = await calc.getWeeklyStats();
      expect(stats.tracksPlayed, 2);
      expect(stats.weekEnd, monday.add(const Duration(days: 7)));
      expect(stats.weekStart.weekday, DateTime.monday);
    });

    test('unique tracks, artists and albums are counted distinctly', () async {
      final monday = startOfWeek(DateTime.now()).add(const Duration(hours: 8));
      final calc = calculatorFor(
        [
          play('a', monday),
          play('a', monday.add(const Duration(hours: 1))),
          play('b', monday.add(const Duration(hours: 2))),
          play('c', monday.add(const Duration(hours: 3))),
        ],
        [
          track('a', artist: 'One', album: 'X'),
          track('b', artist: 'One', album: 'X'),
          track('c', artist: 'Two', album: 'Y'),
        ],
      );

      final stats = await calc.getWeeklyStats();
      expect(stats.tracksPlayed, 4);
      expect(stats.uniqueTracks, 3);
      expect(stats.artistsPlayed, 2);
      expect(stats.albumsPlayed, 2);
    });

    test('likes count distinct 4+ star tracks played', () async {
      final monday = startOfWeek(DateTime.now()).add(const Duration(hours: 8));
      final calc = calculatorFor(
        [
          play('loved', monday),
          play('loved', monday.add(const Duration(hours: 1))),
          play('good', monday.add(const Duration(hours: 2))),
          play('meh', monday.add(const Duration(hours: 3))),
        ],
        [
          track('loved', rating: 5),
          track('good', rating: 4),
          track('meh', rating: 3),
        ],
      );

      final stats = await calc.getWeeklyStats();
      // Two distinct liked tracks, despite three plays of them.
      expect(stats.likes, 2);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('New discoveries', () {
    test('counts tracks whose first ever play falls in the period', () async {
      final monday = startOfWeek(DateTime.now()).add(const Duration(hours: 8));
      final calc = calculatorFor(
        [
          // 'old' was first played long before this week.
          play('old', monday.subtract(const Duration(days: 40))),
          play('old', monday),
          // 'new' is heard for the first time this week.
          play('new', monday.add(const Duration(hours: 1))),
        ],
        [track('old'), track('new')],
      );

      final stats = await calc.getWeeklyStats();
      expect(stats.newDiscoveries, 1);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('Streak', () {
    test('counts consecutive days ending today', () async {
      final calc = calculatorFor(
        [
          play('a', daysAgo(0)),
          play('a', daysAgo(1)),
          play('a', daysAgo(2)),
          // Gap at 3 days ago breaks it.
          play('a', daysAgo(4)),
        ],
        [track('a')],
      );

      expect(await calc.getCurrentStreak(), 3);
    });

    test('a streak that starts today is one day', () async {
      final calc = calculatorFor([play('a', daysAgo(0))], [track('a')]);
      expect(await calc.getCurrentStreak(), 1);
    });

    test('silence today does not break yesterday\'s streak', () async {
      // It may simply be early. The streak only ends once a full day passes.
      final calc = calculatorFor(
        [play('a', daysAgo(1)), play('a', daysAgo(2))],
        [track('a')],
      );

      expect(await calc.getCurrentStreak(), 2);
    });

    test('two silent days do break it', () async {
      final calc = calculatorFor(
        [play('a', daysAgo(2)), play('a', daysAgo(3))],
        [track('a')],
      );

      expect(await calc.getCurrentStreak(), 0);
    });

    test('empty history has no streak', () async {
      expect(await calculatorFor([], []).getCurrentStreak(), 0);
    });

    test('skips alone do not sustain a streak', () async {
      final calc = calculatorFor(
        [play('a', daysAgo(0)), skip('a', daysAgo(1)), play('a', daysAgo(2))],
        [track('a')],
      );

      // Yesterday was only ever skipped, so the streak is today alone.
      expect(await calc.getCurrentStreak(), 1);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('Rankings', () {
    test('top artists rank by play count, with listening time', () async {
      final calc = calculatorFor(
        [
          play('a1', daysAgo(1), durationPlayedMs: 200000),
          play('a1', daysAgo(2), durationPlayedMs: 200000),
          play('a2', daysAgo(3), durationPlayedMs: 200000),
          play('b1', daysAgo(1), durationPlayedMs: 300000),
        ],
        [
          track('a1', artist: 'Alpha'),
          track('a2', artist: 'Alpha'),
          track('b1', artist: 'Beta'),
        ],
      );

      final top = await calc.getTopArtists(days: 30);

      expect(top.map((a) => a.name), ['Alpha', 'Beta']);
      expect(top.first.playCount, 3);
      expect(top.first.totalTime, const Duration(milliseconds: 600000));
    });

    test('a tie is broken by listening time, then name', () async {
      final calc = calculatorFor(
        [
          play('a', daysAgo(1), durationPlayedMs: 100000),
          play('b', daysAgo(1), durationPlayedMs: 300000),
        ],
        [track('a', artist: 'Alpha'), track('b', artist: 'Beta')],
      );

      final top = await calc.getTopArtists(days: 30);
      // Equal play counts; Beta listened to longer, so Beta leads.
      expect(top.map((a) => a.name), ['Beta', 'Alpha']);
    });

    test('top tracks carry their skip count', () async {
      final calc = calculatorFor(
        [
          play('a', daysAgo(1)),
          play('a', daysAgo(2)),
          skip('a', daysAgo(3)),
          play('b', daysAgo(1)),
        ],
        [track('a', title: 'First'), track('b', title: 'Second')],
      );

      final top = await calc.getTopTracks(days: 30);
      expect(top.first.track.title, 'First');
      expect(top.first.playCount, 2);
      expect(top.first.skipCount, 1);
    });

    test('a track that was only ever skipped is not a top track', () async {
      final calc = calculatorFor(
        [play('a', daysAgo(1)), skip('b', daysAgo(1))],
        [track('a'), track('b')],
      );

      final top = await calc.getTopTracks(days: 30);
      expect(top.map((t) => t.track.id), ['a']);
    });

    test('top albums group by album id, not title', () async {
      final calc = calculatorFor(
        [
          play('a', daysAgo(1)),
          play('b', daysAgo(1)),
          play('c', daysAgo(1)),
        ],
        [
          // Two different albums that happen to share a name.
          track('a', album: 'Greatest Hits', albumId: 'alb_1'),
          track('b', album: 'Greatest Hits', albumId: 'alb_1'),
          track('c', album: 'Greatest Hits', albumId: 'alb_2'),
        ],
      );

      final top = await calc.getTopAlbums(days: 30);
      expect(top, hasLength(2));
      expect(top.first.playCount, 2);
    });

    test('the limit is respected', () async {
      final calc = calculatorFor(
        [
          for (var i = 0; i < 20; i++) play('t$i', daysAgo(1)),
        ],
        [for (var i = 0; i < 20; i++) track('t$i', artist: 'Artist $i')],
      );

      expect(await calc.getTopArtists(limit: 5, days: 30), hasLength(5));
    });

    test('plays of a track missing from the library are skipped over',
        () async {
      // History outlives the library; a purged track must not crash ranking.
      final calc = calculatorFor(
        [play('gone', daysAgo(1)), play('here', daysAgo(1))],
        [track('here', artist: 'Present')],
      );

      final top = await calc.getTopArtists(days: 30);
      expect(top.map((a) => a.name), ['Present']);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('Breakdowns', () {
    test('daily history covers every requested day, gaps included', () async {
      final calc = calculatorFor(
        [play('a', daysAgo(0)), play('a', daysAgo(4))],
        [track('a')],
      );

      final daily = await calc.getDailyListeningHistory(days: 7);

      expect(daily, hasLength(7));
      // Oldest first, ending today.
      expect(daily.first.date.isBefore(daily.last.date), isTrue);
      expect(daily.last.date, today);
      expect(daily.where((d) => d.hasListening), hasLength(2));
    });

    test('hour-of-day has all 24 keys, zero-padded', () async {
      final calc = calculatorFor(
        [
          play('a', daysAgo(1, hour: 23)),
          play('a', daysAgo(2, hour: 23)),
          play('a', daysAgo(3, hour: 7)),
        ],
        [track('a')],
      );

      final byHour = await calc.getListeningByHourOfDay(days: 30);

      expect(byHour, hasLength(24));
      expect(byHour['23'], 2);
      expect(byHour['07'], 1);
      expect(byHour['00'], 0);
    });

    test('day-of-week has all 7 keys, Monday first', () async {
      final calc = calculatorFor([], []);
      final byDay = await calc.getListeningByDayOfWeek(days: 30);

      expect(byDay.keys.toList(),
          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']);
      expect(byDay.values.every((v) => v == 0), isTrue);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('Personality', () {
    // Enough plays to clear the minimum-sample guard.
    List<PlayEvent> atHour(int hour, int count, {String id = 'a'}) => [
          for (var i = 0; i < count; i++) play(id, daysAgo(i % 20, hour: hour)),
        ];

    test('night owl when most listening is after 9 PM', () async {
      final calc = calculatorFor(
        [...atHour(22, 9), ...atHour(14, 3)],
        [track('a')],
      );

      expect(await calc.getListeningPersonality(), 'Night Owl');
    });

    test('morning person when most listening is before 9 AM', () async {
      final calc = calculatorFor(
        [...atHour(7, 9), ...atHour(14, 3)],
        [track('a')],
      );

      expect(await calc.getListeningPersonality(), 'Morning Person');
    });

    test('eclectic explorer when unique artists exceed 40% of plays',
        () async {
      final calc = calculatorFor(
        [
          for (var i = 0; i < 12; i++) play('t$i', daysAgo(i, hour: 14)),
        ],
        [for (var i = 0; i < 12; i++) track('t$i', artist: 'Artist $i')],
      );

      expect(await calc.getListeningPersonality(), 'Eclectic Explorer');
    });

    test('genre specialist when one genre dominates', () async {
      final calc = calculatorFor(
        [
          for (var i = 0; i < 12; i++)
            play(i < 9 ? 'jazz' : 'rock', daysAgo(i, hour: 14)),
        ],
        [
          track('jazz', artist: 'A', genre: 'Jazz'),
          track('rock', artist: 'B', genre: 'Rock'),
        ],
      );

      expect(await calc.getListeningPersonality(), 'Genre Specialist');
    });

    test('album loyalist when one album dominates but genres do not',
        () async {
      final calc = calculatorFor(
        [
          for (var i = 0; i < 12; i++)
            play(i < 5 ? 'x' : 't$i', daysAgo(i, hour: 14)),
        ],
        [
          track('x', artist: 'A', albumId: 'alb_x', genre: 'Rock'),
          for (var i = 5; i < 12; i++)
            track('t$i',
                artist: 'A', albumId: 'alb_$i', genre: 'Genre $i'),
        ],
      );

      expect(await calc.getListeningPersonality(), 'Album Loyalist');
    });

    test('binge listener when weekends outweigh weekdays per day', () async {
      // February 2026, fixed so the weekday/weekend split does not depend on
      // when the suite runs: 10 plays on each of Sat 7th and Sun 8th against
      // one play on each of Mon–Fri, so the weekend rate is 10x the weekday's.
      final events = <PlayEvent>[];
      var i = 0;
      for (final day in [7, 8]) {
        for (var n = 0; n < 10; n++) {
          events.add(play('t${i++ % 5}', DateTime(2026, 2, day, 14)));
        }
      }
      for (final day in [2, 3, 4, 5, 6]) {
        events.add(play('t${i++ % 5}', DateTime(2026, 2, day, 14)));
      }

      final calc = calculatorFor(events, [
        // Five artists, genres and albums, so no earlier rule can fire first.
        for (var t = 0; t < 5; t++)
          track('t$t',
              artist: 'Artist $t', genre: 'Genre $t', albumId: 'alb_$t'),
      ]);

      final stats = await calc.getMonthlyStats(monthStart: DateTime(2026, 2, 1));
      expect(stats.personality, ListeningPersonality.bingeListener);
    });

    test('too few plays yields the balanced fallback', () async {
      // Three late-night songs must not crown a Night Owl.
      final calc = calculatorFor(
        [
          play('a', daysAgo(0, hour: 23)),
          play('a', daysAgo(1, hour: 23)),
          play('a', daysAgo(2, hour: 23)),
        ],
        [track('a')],
      );

      expect(await calc.getListeningPersonality(), 'Balanced Listener');
    });

    test('the personality enum carries an emoji and a blurb', () async {
      final calc = calculatorFor([...atHour(22, 12)], [track('a')]);
      final personality = await calc.getPersonality();

      expect(personality, ListeningPersonality.nightOwl);
      expect(personality.emoji, isNotEmpty);
      expect(personality.blurb, isNotEmpty);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('CSV export', () {
    test('writes the specified header and one row per event', () async {
      final at = DateTime(2026, 2, 14, 21, 30);
      final calc = calculatorFor(
        [play('a', at, durationPlayedMs: 210000), skip('a', at)],
        [track('a', title: 'Nights', artist: 'Frank Ocean', album: 'Blonde')],
      );

      final csv = await calc.exportPlayHistoryToCsv();
      final lines = csv.trim().split('\n');

      expect(lines.first,
          'track_title,artist,album,played_at,duration_ms,completed,skipped');
      expect(lines, hasLength(3));
      expect(lines[1], contains('"Nights","Frank Ocean","Blonde"'));
      expect(lines[1], contains('"210000","true","false"'));
      expect(lines[2], contains('"false","true"'));
    });

    test('a comma or quote in a title cannot shift the columns', () async {
      final calc = calculatorFor(
        [play('a', DateTime(2026, 2, 14, 12))],
        [track('a', title: 'Alone, Together', artist: 'The "Band"')],
      );

      final csv = await calc.exportPlayHistoryToCsv();
      final row = csv.trim().split('\n')[1];

      expect(row, startsWith('"Alone, Together","The ""Band"""'));
      // Seven quoted fields, whatever punctuation they contain.
      expect(RegExp(r'","').allMatches(row).length, 6);
    });

    test('respects the date range', () async {
      final calc = calculatorFor(
        [
          play('a', DateTime(2026, 1, 15, 12)),
          play('a', DateTime(2026, 2, 15, 12)),
          play('a', DateTime(2026, 3, 15, 12)),
        ],
        [track('a')],
      );

      final csv = await calc.exportPlayHistoryToCsv(
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 3, 1),
      );

      expect(csv.trim().split('\n'), hasLength(2));
    });

    test('a play of a purged track exports as Unknown, not a crash', () async {
      final calc = calculatorFor(
        [play('gone', DateTime(2026, 2, 14, 12))],
        const [],
      );

      final csv = await calc.exportPlayHistoryToCsv();
      expect(csv, contains('"Unknown","Unknown Artist","Unknown Album"'));
    });

    test('an empty history exports just the header', () async {
      final csv = await calculatorFor([], []).exportPlayHistoryToCsv();
      expect(csv.trim().split('\n'), hasLength(1));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('Monthly and yearly', () {
    test('a month covers its own calendar bounds', () async {
      final calc = calculatorFor(
        [
          play('a', DateTime(2026, 1, 31, 23)),
          play('a', DateTime(2026, 2, 1, 0)),
          play('a', DateTime(2026, 2, 28, 23)),
          play('a', DateTime(2026, 3, 1, 0)),
        ],
        [track('a')],
      );

      final stats = await calc.getMonthlyStats(monthStart: DateTime(2026, 2, 5));

      expect(stats.tracksPlayed, 2);
      expect(stats.monthStart, DateTime(2026, 2, 1));
      expect(stats.monthEnd, DateTime(2026, 3, 1));
    });

    test('a year buckets minutes by month', () async {
      final calc = calculatorFor(
        [
          play('a', DateTime(2026, 1, 15, 12), durationPlayedMs: 600000),
          play('a', DateTime(2026, 7, 15, 12), durationPlayedMs: 300000),
        ],
        [track('a')],
      );

      final stats = await calc.getYearlyStats(year: 2026);

      expect(stats.monthlyMinutes, hasLength(12));
      expect(stats.monthlyMinutes[0], closeTo(10.0, 1e-9));
      expect(stats.monthlyMinutes[6], closeTo(5.0, 1e-9));
      expect(stats.monthlyMinutes[1], 0);
      expect(stats.year, 2026);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('Formatting', () {
    test('durations render as hours and minutes', () {
      expect(formatDuration(const Duration(hours: 24, minutes: 36)), '24h 36m');
      expect(formatDuration(const Duration(minutes: 5)), '5m');
      expect(formatDuration(Duration.zero), '0m');
    });

    test('startOfWeek snaps back to Monday', () {
      // 2026-02-14 is a Saturday.
      expect(startOfWeek(DateTime(2026, 2, 14, 18)), DateTime(2026, 2, 9));
      // A Monday is already its own week start.
      expect(startOfWeek(DateTime(2026, 2, 9, 3)), DateTime(2026, 2, 9));
      // A Sunday belongs to the week that began six days earlier.
      expect(startOfWeek(DateTime(2026, 2, 15, 23)), DateTime(2026, 2, 9));
    });
  });
}
