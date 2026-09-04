// lib/domain/stats/stats_models.dart
// Aura — Value objects returned by [StatsCalculator].
//
// All plain immutable classes rather than freezed: nothing here is serialised
// or copied with, and keeping them codegen-free means the statistics engine
// compiles without a build_runner pass.

import '../entities/track.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Period summaries
// ─────────────────────────────────────────────────────────────────────────────

/// A week of listening, Monday to Sunday.
class WeeklyStats {
  const WeeklyStats({
    required this.totalListeningTime,
    required this.tracksPlayed,
    required this.uniqueTracks,
    required this.artistsPlayed,
    required this.albumsPlayed,
    required this.skips,
    required this.likes,
    required this.newDiscoveries,
    required this.weekStart,
    required this.weekEnd,
    required this.dailyMinutes,
  });

  /// Sum of `durationPlayedMs` over completed plays only.
  final Duration totalListeningTime;

  /// Completed plays in the period.
  final int tracksPlayed;

  /// Distinct tracks among those plays.
  final int uniqueTracks;

  final int artistsPlayed;
  final int albumsPlayed;

  /// Skipped plays in the period.
  final int skips;

  /// Tracks played this period that the user rates 4 or 5 stars.
  ///
  /// Ratings are not timestamped, so this is "liked tracks you played this
  /// week", not "tracks you liked this week".
  final int likes;

  /// Tracks whose first ever play falls inside this period.
  final int newDiscoveries;

  /// Local midnight on the Monday starting the week.
  final DateTime weekStart;

  /// Exclusive end — local midnight on the following Monday.
  final DateTime weekEnd;

  /// Minutes listened per day, Monday first. Always seven entries.
  final List<double> dailyMinutes;

  /// Skips as a percentage of all plays, 0–100.
  double get skipRate {
    final total = tracksPlayed + skips;
    return total == 0 ? 0.0 : skips / total * 100;
  }

  bool get hasData => tracksPlayed > 0 || skips > 0;

  /// "24h 36m".
  String get totalListeningLabel => formatDuration(totalListeningTime);
}

/// A calendar month of listening.
class MonthlyStats {
  const MonthlyStats({
    required this.totalListeningTime,
    required this.tracksPlayed,
    required this.uniqueTracks,
    required this.artistsPlayed,
    required this.albumsPlayed,
    required this.skips,
    required this.likes,
    required this.newDiscoveries,
    required this.monthStart,
    required this.monthEnd,
    required this.topArtists,
    required this.topTracks,
    required this.topAlbums,
    required this.personality,
  });

  final Duration totalListeningTime;
  final int tracksPlayed;
  final int uniqueTracks;
  final int artistsPlayed;
  final int albumsPlayed;
  final int skips;
  final int likes;
  final int newDiscoveries;

  final DateTime monthStart;

  /// Exclusive end — local midnight on the first of the next month.
  final DateTime monthEnd;

  final List<TopArtist> topArtists;
  final List<TopTrack> topTracks;
  final List<TopAlbum> topAlbums;

  /// The personality this month's listening earned.
  final ListeningPersonality personality;

  double get skipRate {
    final total = tracksPlayed + skips;
    return total == 0 ? 0.0 : skips / total * 100;
  }

  bool get hasData => tracksPlayed > 0 || skips > 0;

  String get totalListeningLabel => formatDuration(totalListeningTime);
}

/// A calendar year of listening.
class YearlyStats {
  const YearlyStats({
    required this.year,
    required this.totalListeningTime,
    required this.tracksPlayed,
    required this.uniqueTracks,
    required this.artistsPlayed,
    required this.albumsPlayed,
    required this.skips,
    required this.newDiscoveries,
    required this.topArtists,
    required this.topTracks,
    required this.topAlbums,
    required this.monthlyMinutes,
    required this.personality,
  });

  final int year;
  final Duration totalListeningTime;
  final int tracksPlayed;
  final int uniqueTracks;
  final int artistsPlayed;
  final int albumsPlayed;
  final int skips;
  final int newDiscoveries;

  final List<TopArtist> topArtists;
  final List<TopTrack> topTracks;
  final List<TopAlbum> topAlbums;

  /// Minutes listened per month, January first. Always twelve entries.
  final List<double> monthlyMinutes;

  final ListeningPersonality personality;

  double get skipRate {
    final total = tracksPlayed + skips;
    return total == 0 ? 0.0 : skips / total * 100;
  }

  bool get hasData => tracksPlayed > 0 || skips > 0;

  String get totalListeningLabel => formatDuration(totalListeningTime);
}

// ─────────────────────────────────────────────────────────────────────────────
// Breakdowns
// ─────────────────────────────────────────────────────────────────────────────

/// One day's listening, used by the dashboard's line chart.
class DailyStat {
  const DailyStat({
    required this.date,
    required this.listeningTime,
    required this.tracksPlayed,
    required this.skips,
  });

  /// Local midnight on the day in question.
  final DateTime date;

  final Duration listeningTime;
  final int tracksPlayed;
  final int skips;

  double get minutes => listeningTime.inMilliseconds / 60000.0;

  bool get hasListening => tracksPlayed > 0;
}

// ─────────────────────────────────────────────────────────────────────────────
// Rankings
// ─────────────────────────────────────────────────────────────────────────────

class TopArtist {
  const TopArtist({
    required this.name,
    required this.playCount,
    required this.totalTime,
    this.imagePath,
  });

  final String name;
  final int playCount;
  final Duration totalTime;

  /// Cover art of the artist's most-played track in the period; Aura stores no
  /// separate artist images, and the alternative is an empty circle.
  final String? imagePath;
}

class TopTrack {
  const TopTrack({
    required this.track,
    required this.playCount,
    required this.totalTime,
    required this.skipCount,
  });

  final Track track;
  final int playCount;
  final Duration totalTime;
  final int skipCount;
}

class TopAlbum {
  const TopAlbum({
    required this.title,
    required this.artistName,
    required this.playCount,
    required this.totalTime,
    this.coverArtPath,
  });

  final String title;
  final String artistName;
  final int playCount;
  final Duration totalTime;
  final String? coverArtPath;
}

// ─────────────────────────────────────────────────────────────────────────────
// Personality
// ─────────────────────────────────────────────────────────────────────────────

/// The listening personalities Aura can award, in the order they are tested.
///
/// A month's listening can satisfy several at once — a night owl who only
/// plays one genre matches two — so the first match in this order wins, and
/// the order is the one the spec lists them in.
enum ListeningPersonality {
  nightOwl('Night Owl', '🦉',
      'You chase sound when the world goes quiet — most of your listening '
      'happens after 9 PM.'),
  morningPerson('Morning Person', '🌅',
      'You start the day with music. Most of your listening happens before '
      '9 AM.'),
  eclecticExplorer('Eclectic Explorer', '🧭',
      'You rarely play the same artist twice — your library keeps widening.'),
  genreSpecialist('Genre Specialist', '🎯',
      'You know exactly what you like, and you go deep rather than wide.'),
  albumLoyalist('Album Loyalist', '💿',
      'You listen to albums the way they were made — front to back.'),
  bingeListener('Binge Listener', '🔥',
      'Your weekends do the heavy lifting — you save it all up and dive in.'),

  /// Nothing stood out strongly enough to earn a label.
  balanced('Balanced Listener', '🎧',
      'A bit of everything, spread evenly — no single habit defines you.');

  const ListeningPersonality(this.label, this.emoji, this.blurb);

  /// Display name, e.g. "Night Owl". This is what [StatsCalculator]'s
  /// `getListeningPersonality()` returns.
  final String label;

  final String emoji;

  /// One-sentence explanation for the Wrapped card.
  final String blurb;
}

// ─────────────────────────────────────────────────────────────────────────────

/// "24h 36m", or "36m" when under an hour.
String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  return hours == 0 ? '${minutes}m' : '${hours}h ${minutes}m';
}
