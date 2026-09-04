// lib/domain/repositories/shuffle_state_repository.dart
// Aura — Persistence port for IntelliShuffle state.
//
// The engine itself is pure Dart and knows nothing about SQLite; this interface
// is how a shuffle survives a restart. Implemented by
// LocalShuffleStateRepository in the data layer.

/// Persists the serialised shuffle queue, keyed by playback context
/// (e.g. `all_songs`, `playlist_42`).
abstract interface class ShuffleStateRepository {
  /// Returns the stored state blob for [contextId], or null when none exists.
  Future<String?> load(String contextId);

  /// Stores [stateJson] (from `IntelliShuffleEngine.serializeState()`).
  Future<void> save(String contextId, String stateJson);

  /// Drops the stored state for [contextId].
  Future<void> clear(String contextId);
}
