// lib/ui/screens/stats/stats_providers.dart
// Aura — Presentation models for the Stats Dashboard & Monthly Wrapped screens.
//
// These map the domain aggregates from [StatsCalculator] into the shapes the
// screens render: pre-formatted labels, seven-day chart series, monograms. The
// domain layer stays free of display concerns, and the screens stay free of
// aggregation logic.
//
// Everything is computed locally from playback_history. No network calls.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/audio_features.dart';
import '../../../domain/stats/stats_calculator.dart';
import '../../../domain/stats/stats_models.dart';
import '../../../shared/providers.dart';

// ── Small value objects ───────────────────────────────────────────────────────

/// A ranked artist entry for the "Top Artist" surfaces.
@immutable
class ArtistStat {
  const ArtistStat({
    required this.name,
    required this.playCount,
    this.imageAssetPath,
  });

  final String name;
  final int playCount;

  /// Cover art of the artist's most-played track. When null, UIs fall back to
  /// a gradient + initials.
  final String? imageAssetPath;

  /// Up-to-two-letter monogram used by the circular avatar fallback.
  String get initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

/// A ranked song entry for the "Top Song" surfaces.
@immutable
class SongStat {
  const SongStat({
    required this.title,
    required this.artist,
    required this.playCount,
    this.albumArtAssetPath,
  });

  final String title;
  final String artist;
  final int playCount;
  final String? albumArtAssetPath;
}

/// A ranked album entry for the "Most Played Album" surface.
@immutable
class AlbumStat {
  const AlbumStat({
    required this.name,
    required this.artist,
    required this.playCount,
    this.albumArtAssetPath,
  });

  final String name;
  final String artist;
  final int playCount;
  final String? albumArtAssetPath;
}

// ── Weekly aggregates (Stats Dashboard) ───────────────────────────────────────

/// Weekly listening aggregates rendered by `StatsDashboardScreen`.
@immutable
class WeeklyStatsView {
  const WeeklyStatsView({
    required this.dateRangeLabel,
    required this.totalListeningLabel,
    required this.totalMinutes,
    required this.dailyMinutes,
    required this.topArtist,
    required this.topSong,
    required this.topAlbum,
    required this.streakDays,
    required this.streakMessage,
    required this.insights,
    required this.hasData,
  });

  /// e.g. "Feb 10 – Feb 16, 2026".
  final String dateRangeLabel;

  /// Pre-formatted total, e.g. "24h 36m".
  final String totalListeningLabel;

  /// Total minutes listened this week (drives the hero count-up).
  final int totalMinutes;

  /// Seven values (Mon→Sun) of minutes listened per day; drives the line chart.
  final List<double> dailyMinutes;

  final ArtistStat topArtist;
  final SongStat topSong;
  final AlbumStat topAlbum;

  final int streakDays;
  final String streakMessage;

  /// Weekly insight strings for the horizontal insight rail.
  final List<String> insights;

  /// When false the screen renders its friendly empty state.
  final bool hasData;

  /// Empty-week factory, used for the empty state and as a safe fallback.
  factory WeeklyStatsView.empty() => const WeeklyStatsView(
        dateRangeLabel: '',
        totalListeningLabel: '0h 0m',
        totalMinutes: 0,
        dailyMinutes: <double>[0, 0, 0, 0, 0, 0, 0],
        topArtist: ArtistStat(name: '—', playCount: 0),
        topSong: SongStat(title: '—', artist: '—', playCount: 0),
        topAlbum: AlbumStat(name: '—', artist: '—', playCount: 0),
        streakDays: 0,
        streakMessage: '',
        insights: <String>[],
        hasData: false,
      );
}

// ── Monthly wrapped (Story cards) ─────────────────────────────────────────────

/// Monthly "Aura Wrapped" data rendered by `MonthlyWrappedScreen`.
@immutable
class MonthlyWrapped {
  const MonthlyWrapped({
    required this.monthLabel,
    required this.totalSongs,
    required this.topArtist,
    required this.topSong,
    required this.moodLabel,
    required this.moodColors,
    required this.personalityBadge,
    required this.personalityEmoji,
    required this.personalityBlurb,
  });

  /// e.g. "February 2026".
  final String monthLabel;

  /// Total songs listened this month (drives the count-up card).
  final int totalSongs;

  final ArtistStat topArtist;
  final SongStat topSong;

  /// e.g. "Energetic Chill".
  final String moodLabel;

  /// Gradient stops used for the mood colour visualisation.
  final List<Color> moodColors;

  /// e.g. "Night Owl".
  final String personalityBadge;
  final String personalityEmoji;
  final String personalityBlurb;

  factory MonthlyWrapped.empty(DateTime month) => MonthlyWrapped(
        monthLabel: '${_monthNames[month.month - 1]} ${month.year}',
        totalSongs: 0,
        topArtist: const ArtistStat(name: '—', playCount: 0),
        topSong: const SongStat(title: '—', artist: '—', playCount: 0),
        moodLabel: 'Quiet',
        moodColors: const <Color>[
          Color(0xFF6DD5FF),
          Color(0xFFFF8F6D),
        ],
        personalityBadge: ListeningPersonality.balanced.label,
        personalityEmoji: ListeningPersonality.balanced.emoji,
        personalityBlurb:
            'Play some music this month and your Wrapped will fill in.',
      );
}

// ── Providers ─────────────────────────────────────────────────────────────────

/// The spec's provider: this week's raw domain aggregates.
final statsProvider = FutureProvider<WeeklyStats>((ref) async {
  final calculator = ref.watch(statsCalculatorProvider);
  return calculator.getWeeklyStats();
});

/// This month's raw domain aggregates.
final monthlyStatsProvider = FutureProvider<MonthlyStats>((ref) async {
  final calculator = ref.watch(statsCalculatorProvider);
  return calculator.getMonthlyStats();
});

/// The current listening streak, in days.
final streakProvider = FutureProvider<int>((ref) async {
  final calculator = ref.watch(statsCalculatorProvider);
  return calculator.getCurrentStreak();
});

/// Weekly view model for `StatsDashboardScreen`.
final weeklyStatsViewProvider = FutureProvider<WeeklyStatsView>((ref) async {
  final calculator = ref.watch(statsCalculatorProvider);

  final stats = await calculator.getWeeklyStats();
  if (!stats.hasData) return WeeklyStatsView.empty();

  // Ranked over this calendar week, not a trailing 7 days — on a Thursday
  // those are different sets of plays.
  final topArtists = await calculator.getTopArtistsBetween(
      stats.weekStart, stats.weekEnd, limit: 1);
  final topTracks = await calculator.getTopTracksBetween(
      stats.weekStart, stats.weekEnd, limit: 1);
  final topAlbums = await calculator.getTopAlbumsBetween(
      stats.weekStart, stats.weekEnd, limit: 1);
  final streak = await calculator.getCurrentStreak();
  final byHour = await calculator.getListeningByHourOfDay(days: 7);

  return WeeklyStatsView(
    dateRangeLabel: _formatRange(stats.weekStart, stats.weekEnd),
    totalListeningLabel: stats.totalListeningLabel,
    totalMinutes: stats.totalListeningTime.inMinutes,
    dailyMinutes: stats.dailyMinutes,
    topArtist: topArtists.isEmpty
        ? const ArtistStat(name: '—', playCount: 0)
        : ArtistStat(
            name: topArtists.first.name,
            playCount: topArtists.first.playCount,
            imageAssetPath: topArtists.first.imagePath,
          ),
    topSong: topTracks.isEmpty
        ? const SongStat(title: '—', artist: '—', playCount: 0)
        : SongStat(
            title: topTracks.first.track.title,
            artist: topTracks.first.track.artistName,
            playCount: topTracks.first.playCount,
            albumArtAssetPath: topTracks.first.track.coverArtPath,
          ),
    topAlbum: topAlbums.isEmpty
        ? const AlbumStat(name: '—', artist: '—', playCount: 0)
        : AlbumStat(
            name: topAlbums.first.title,
            artist: topAlbums.first.artistName,
            playCount: topAlbums.first.playCount,
            albumArtAssetPath: topAlbums.first.coverArtPath,
          ),
    streakDays: streak,
    streakMessage: _streakMessage(streak),
    insights: _buildInsights(stats, byHour),
    hasData: true,
  );
});

/// Monthly story data for `MonthlyWrappedScreen`.
final wrappedProvider = FutureProvider<MonthlyWrapped>((ref) async {
  final calculator = ref.watch(statsCalculatorProvider);
  final features = ref.watch(audioFeatureRepositoryProvider);

  final stats = await calculator.getMonthlyStats();
  if (!stats.hasData) return MonthlyWrapped.empty(DateTime.now());

  // Mood comes from the acoustic features of what was actually played. When
  // the analyser has not run, the mood card says so rather than inventing one.
  final playedIds =
      stats.topTracks.map((t) => t.track.id).toList(growable: false);
  final analysed = await features.getFeaturesFor(playedIds);
  final mood = _moodFor(analysed.values.toList(growable: false));

  return MonthlyWrapped(
    monthLabel:
        '${_monthNames[stats.monthStart.month - 1]} ${stats.monthStart.year}',
    totalSongs: stats.tracksPlayed,
    topArtist: stats.topArtists.isEmpty
        ? const ArtistStat(name: '—', playCount: 0)
        : ArtistStat(
            name: stats.topArtists.first.name,
            playCount: stats.topArtists.first.playCount,
            imageAssetPath: stats.topArtists.first.imagePath,
          ),
    topSong: stats.topTracks.isEmpty
        ? const SongStat(title: '—', artist: '—', playCount: 0)
        : SongStat(
            title: stats.topTracks.first.track.title,
            artist: stats.topTracks.first.track.artistName,
            playCount: stats.topTracks.first.playCount,
            albumArtAssetPath: stats.topTracks.first.track.coverArtPath,
          ),
    moodLabel: mood.$1,
    moodColors: mood.$2,
    personalityBadge: stats.personality.label,
    personalityEmoji: stats.personality.emoji,
    personalityBlurb: stats.personality.blurb,
  );
});

// ── Formatting helpers ────────────────────────────────────────────────────────

const List<String> _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

const List<String> _monthAbbr = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "Feb 10 – Feb 16, 2026". [end] is exclusive, so the label shows the day
/// before it — the last day the user could actually have listened.
String _formatRange(DateTime start, DateTime end) {
  final last = end.subtract(const Duration(days: 1));
  final from = '${_monthAbbr[start.month - 1]} ${start.day}';
  final to = '${_monthAbbr[last.month - 1]} ${last.day}';
  return '$from – $to, ${last.year}';
}

String _streakMessage(int days) {
  if (days == 0) return 'Play something today to start a streak.';
  if (days == 1) return 'One day in — come back tomorrow to build it up.';
  if (days < 7) return '$days days running. Keep the flame alive!';
  if (days < 30) return 'A full week and counting — this is a habit now.';
  return '$days days without missing one. Remarkable.';
}

/// Insight strings, each only included when the data actually supports it —
/// an insight that appears every week regardless of behaviour is just noise.
List<String> _buildInsights(WeeklyStats stats, Map<String, int> byHour) {
  final insights = <String>[];

  final totalPlays = byHour.values.fold<int>(0, (a, b) => a + b);
  if (totalPlays > 0) {
    final night = byHour.entries
        .where((e) => int.parse(e.key) >= kNightStartHour)
        .fold<int>(0, (sum, e) => sum + e.value);
    final share = night / totalPlays;
    if (share > 0.4) {
      insights.add("You're a night owl — ${(share * 100).round()}% of your "
          'listening happens after 9 PM');
    }
  }

  // Busiest day, but only when it genuinely stands out from the rest.
  var bestDay = 0;
  for (var i = 1; i < stats.dailyMinutes.length; i++) {
    if (stats.dailyMinutes[i] > stats.dailyMinutes[bestDay]) bestDay = i;
  }
  final weekTotal = stats.dailyMinutes.fold<double>(0, (a, b) => a + b);
  if (weekTotal > 0 && stats.dailyMinutes[bestDay] / weekTotal > 0.25) {
    insights.add('Your ${_dayNames[bestDay]} energy is unmatched');
  }

  if (stats.newDiscoveries > 0) {
    insights.add("You've discovered ${stats.newDiscoveries} new "
        '${stats.newDiscoveries == 1 ? 'track' : 'tracks'} this week');
  }

  if (stats.skipRate > 40) {
    insights.add('Restless week — you skipped '
        '${stats.skipRate.round()}% of what you started');
  }

  if (stats.likes > 0) {
    insights.add('You played ${stats.likes} of your favourites');
  }

  return insights;
}

const List<String> _dayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];

/// Maps the month's average energy and valence onto a mood label and gradient.
///
/// Returns a neutral "Uncharted" mood when nothing has been analysed yet,
/// rather than implying a mood the audio never justified.
(String, List<Color>) _moodFor(List<AudioFeatures> features) {
  if (features.isEmpty) {
    return (
      'Uncharted',
      const <Color>[Color(0xFF6DD5FF), Color(0xFFFF8F6D)],
    );
  }

  var energy = 0.0;
  var valence = 0.0;
  for (final f in features) {
    energy += f.energy;
    valence += f.valence;
  }
  energy /= features.length;
  valence /= features.length;

  const apricot = Color(0xFFFF8F6D);
  const sparkle = Color(0xFFFFD36E);
  const cyan = Color(0xFF6DD5FF);
  const violet = Color(0xFF9B6DFF);

  if (energy >= 0.5 && valence >= 0.5) {
    return ('Bright and Restless', const <Color>[apricot, sparkle, cyan]);
  }
  if (energy >= 0.5) {
    return ('Dark and Driving', const <Color>[violet, apricot, cyan]);
  }
  if (valence >= 0.5) {
    return ('Warm and Easy', const <Color>[sparkle, apricot, cyan]);
  }
  return ('Slow and Blue', const <Color>[cyan, violet, apricot]);
}
