// lib/domain/repositories/behavior_repository.dart
// Aura — Abstract BehaviorRepository interface.
// Architecture §4.3: play events, skip history, ratings feed IntelliShuffle.

/// A single play event recorded to the history table.
class PlayEvent {
  const PlayEvent({
    required this.trackId,
    required this.playedAtMs,
    required this.durationPlayedMs,
    required this.skipped,
    this.contextType = 'library',
  });

  final String trackId;

  /// Epoch ms when playback started.
  final int playedAtMs;

  /// How many ms were actually played before skip/finish.
  final int durationPlayedMs;

  /// True if the user skipped before 80% completion.
  final bool skipped;

  /// Origin context: 'library', 'playlist', 'shuffle', 'mix'.
  final String contextType;
}

/// Aggregated per-track behaviour stats (used by IntelliShuffleEngine scoring).
class TrackBehaviorStats {
  const TrackBehaviorStats({
    required this.trackId,
    required this.playCount,
    required this.skipCount,
    required this.rating,
    this.lastPlayedMs,
  });

  final String trackId;
  final int playCount;
  final int skipCount;

  /// User rating 0–5.
  final int rating;

  /// Epoch ms of last play, or null if never played.
  final int? lastPlayedMs;

  /// Derived: skip rate as a fraction 0.0–1.0.
  double get skipRate =>
      (playCount + skipCount) == 0 ? 0.0 : skipCount / (playCount + skipCount);
}

/// Provides read/write access to user behaviour data.
abstract interface class BehaviorRepository {
  /// Records a single play/skip event.
  Future<void> recordEvent(PlayEvent event);

  /// Returns [TrackBehaviorStats] for every track in [trackIds].
  /// Missing entries return stats with all-zero counts.
  Future<Map<String, TrackBehaviorStats>> getBehaviorStats(
      List<String> trackIds);

  /// Returns the play history for [trackId], newest first.
  Future<List<PlayEvent>> getPlayHistory(
    String trackId, {
    int limit = 100,
  });

  /// Returns the top N most-played track IDs over the last [days] days.
  Future<List<String>> getTopPlayedTrackIds({
    int topN = 20,
    int days = 30,
  });

  /// Deletes history entries older than [retainDuration].
  Future<void> pruneHistory(Duration retainDuration);
}
