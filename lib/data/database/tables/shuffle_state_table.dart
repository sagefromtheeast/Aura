// lib/data/database/tables/shuffle_state_table.dart
import 'package:drift/drift.dart';

/// Persists IntelliShuffleEngine state for cross-restart resumption.
@DataClassName('ShuffleStateRow')
class ShuffleStateTable extends Table {
  @override
  String get tableName => 'shuffle_states';

  IntColumn get id => integer().autoIncrement()();

  /// JSON-encoded ShuffleConfig.
  TextColumn get configJson => text()();

  /// JSON-encoded [List] of track IDs in shuffled order.
  TextColumn get shuffledIdsJson => text()();

  IntColumn get currentIndex => integer().withDefault(const Constant(0))();
  IntColumn get createdAtMs => integer()();
}
