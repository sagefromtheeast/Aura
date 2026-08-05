// lib/domain/use_cases/stats_calculator.dart
// Aura — StatsCalculator
// Architecture §4.5 / PRD §6.5: Statistics & Wrapped.

import '../repositories/behavior_repository.dart';
import '../repositories/music_repository.dart';
import '../entities/track.dart';

/// Aggregated statistics snapshot for a time range.
class LibraryStats {
  const LibraryStats({
    required this.totalTracksPlayed,
    required this.totalListeningMs,
    required this.uniqueArtistsPlayed,
    required this.topTracks,
    required this.topArtists,
    required this.averageSessionLengthMs,
    required this.periodStartMs,
    required this.periodEndMs,
  });

  final int totalTracksPlayed;
  final int totalListeningMs;
  final int uniqueArtistsPlayed;

  /// Top 10 tracks by play count in period.
  final List<Track> topTracks;

  /// Top 10 artist names by total listening time.
  final List<String> topArtists;

  final int averageSessionLengthMs;
  final int periodStartMs;
  final int periodEndMs;

  /// Convenience: total listening formatted as "X h Y m".
  String get totalListeningFormatted {
    final h = totalListeningMs ~/ (1000 * 60 * 60);
    final m = (totalListeningMs ~/ (1000 * 60)) % 60;
    return '${h}h ${m}m';
  }
}

/// Computes statistics from the play history for the UI dashboard
/// and "Aura Wrapped" feature (PRD §6.5).
class StatsCalculator {
  const StatsCalculator({
    required BehaviorRepository behaviorRepository,
    required MusicRepository musicRepository,
  })  : _behaviorRepo = behaviorRepository,
        _musicRepo = musicRepository;

  final BehaviorRepository _behaviorRepo;
  final MusicRepository _musicRepo;

  /// Computes stats for the last [days] days.
  Future<LibraryStats> computeStats({int days = 7}) async {
    final since = DateTime.now()
        .subtract(Duration(days: days))
        .millisecondsSinceEpoch;

    final topIds = await _behaviorRepo.getTopPlayedTrackIds(
        topN: 10, days: days);

    final topTracks = <Track>[];
    for (final id in topIds) {
      final t = await _musicRepo.getTrackById(id);
      if (t != null) topTracks.add(t);
    }

    // Aggregate stats via behaviour repository.
    final allStats = await _behaviorRepo.getBehaviorStats(topIds);
    int totalPlays = 0;
    int totalMs = 0;
    final artistSet = <String>{};

    for (final s in allStats.values) {
      totalPlays += s.playCount;
    }

    for (final track in topTracks) {
      final s = allStats[track.id];
      if (s != null) {
        totalMs += track.durationMs * s.playCount;
        artistSet.add(track.artistId);
      }
    }

    final topArtistNames = topTracks
        .map((t) => t.artistName)
        .toSet()
        .take(10)
        .toList();

    return LibraryStats(
      totalTracksPlayed: totalPlays,
      totalListeningMs: totalMs,
      uniqueArtistsPlayed: artistSet.length,
      topTracks: topTracks,
      topArtists: topArtistNames,
      averageSessionLengthMs: totalPlays > 0 ? totalMs ~/ totalPlays : 0,
      periodStartMs: since,
      periodEndMs: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
