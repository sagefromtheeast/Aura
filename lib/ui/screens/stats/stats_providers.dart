// lib/ui/screens/stats/stats_providers.dart
// Aura — Stub providers for the Stats Dashboard & Monthly Wrapped screens.
//
// These expose immutable view-models consumed by:
//   • StatsDashboardScreen  → statsProvider   (weekly aggregates)
//   • MonthlyWrappedScreen  → wrappedProvider (monthly story data)
//
// All values are computed 100% locally. In production these providers would be
// backed by StatsCalculator (lib/domain/use_cases/stats_calculator.dart); for
// now they return deterministic stub data that matches the design spec copy.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  /// Optional bundled asset. When null, UIs fall back to a gradient + initials.
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

/// Weekly listening aggregates rendered by [StatsDashboardScreen].
@immutable
class WeeklyStats {
  const WeeklyStats({
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

  /// Fun weekly insight strings for the horizontal insight rail.
  final List<String> insights;

  /// When false the screen renders its friendly empty state.
  final bool hasData;

  /// Empty-week factory used to preview / drive the empty state.
  factory WeeklyStats.empty() => const WeeklyStats(
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

/// Monthly "Aura Wrapped" data rendered by [MonthlyWrappedScreen].
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

  /// e.g. "Night Owl Explorer".
  final String personalityBadge;
  final String personalityEmoji;
  final String personalityBlurb;
}

// ── Providers ─────────────────────────────────────────────────────────────────

/// Weekly aggregates for [StatsDashboardScreen].
///
/// Swap the returned value for `WeeklyStats.empty()` to preview the empty state.
final statsProvider = Provider<WeeklyStats>((ref) {
  return const WeeklyStats(
    dateRangeLabel: 'Feb 10 – Feb 16, 2026',
    totalListeningLabel: '24h 36m',
    totalMinutes: 24 * 60 + 36,
    // Mon→Sun minutes; Friday spikes (matches the "Friday energy" insight).
    dailyMinutes: <double>[184, 142, 205, 168, 352, 246, 179],
    topArtist: ArtistStat(name: 'Tame Impala', playCount: 87),
    topSong: SongStat(
      title: 'The Less I Know The Better',
      artist: 'Tame Impala',
      playCount: 34,
    ),
    topAlbum: AlbumStat(
      name: 'Currents',
      artist: 'Tame Impala',
      playCount: 122,
    ),
    streakDays: 7,
    streakMessage: 'A full week of daily listening — keep the flame alive!',
    insights: <String>[
      "You're a night owl — 68% of your listening happens after 9 PM",
      'Your Friday energy is unmatched',
      "You've discovered 12 new artists this week",
    ],
    hasData: true,
  );
});

/// Monthly story data for [MonthlyWrappedScreen].
final wrappedProvider = Provider<MonthlyWrapped>((ref) {
  return const MonthlyWrapped(
    monthLabel: 'February 2026',
    totalSongs: 1423,
    topArtist: ArtistStat(name: 'Tame Impala', playCount: 312),
    topSong: SongStat(
      title: 'The Less I Know The Better',
      artist: 'Tame Impala',
      playCount: 96,
    ),
    moodLabel: 'Energetic Chill',
    moodColors: <Color>[
      Color(0xFFFF8F6D), // apricot
      Color(0xFFFFD36E), // sparkle
      Color(0xFF6DD5FF), // cool cyan
    ],
    personalityBadge: 'Night Owl Explorer',
    personalityEmoji: '🦉',
    personalityBlurb:
        'You chase new sounds when the world goes quiet. 68% of your listening '
        'happens after 9 PM, and you tried 12 new artists this month.',
  );
});
