// lib/data/database/tables/shuffle_state_table.dart
import 'package:drift/drift.dart';

/// Persists IntelliShuffleEngine state for cross-restart resumption.
@DataClassName('ShuffleStateRow')
class ShuffleStateTable extends Table {
  @override
  String get tableName => 'shuffle_states';

  IntColumn get id => integer().autoIncrement()();

  /// Shuffle context this state belongs to, e.g. 'all_songs' or 'playlist_42'.
  /// One persisted state per context (enforced by a unique index; see
  /// AppDatabase.migration).
  TextColumn get contextId => text().withDefault(const Constant('all_songs'))();

  /// JSON-encoded ShuffleConfig.
  TextColumn get configJson => text()();

  /// JSON-encoded [List] of track IDs in shuffled order.
  TextColumn get shuffledIdsJson => text()();

  IntColumn get currentIndex => integer().withDefault(const Constant(0))();
  IntColumn get createdAtMs => integer()();

  /// Epoch ms of the last save.
  IntColumn get updatedAtMs => integer().withDefault(const Constant(0))();

  /// Full engine state blob from IntelliShuffleEngine.serializeState().
  /// The columns above are denormalised copies kept for debugging/queries.
  TextColumn get stateJson => text().withDefault(const Constant(''))();
}
