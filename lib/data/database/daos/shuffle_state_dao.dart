// lib/data/database/daos/shuffle_state_dao.dart
// Aura — ShuffleStateDao: persists IntelliShuffleEngine state per context so a
// shuffle can resume across restarts.

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/shuffle_state_table.dart';

part 'shuffle_state_dao.g.dart';

@DriftAccessor(tables: [ShuffleStateTable])
class ShuffleStateDao extends DatabaseAccessor<AppDatabase>
    with _$ShuffleStateDaoMixin {
  ShuffleStateDao(super.db);

  /// Persists (or replaces) the shuffle state for [contextId].
  ///
  /// Relies on the unique index on `shuffle_states(context_id)` so re-saving a
  /// context overwrites the previous row instead of accumulating duplicates.
  Future<void> save({
    required String contextId,
    required String configJson,
    required String shuffledIdsJson,
    int currentIndex = 0,
  }) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final existing = await load(contextId);
    if (existing == null) {
      await into(shuffleStateTable).insert(
        ShuffleStateTableCompanion.insert(
          contextId: Value(contextId),
          configJson: configJson,
          shuffledIdsJson: shuffledIdsJson,
          currentIndex: Value(currentIndex),
          createdAtMs: nowMs,
          updatedAtMs: Value(nowMs),
        ),
      );
    } else {
      await (update(shuffleStateTable)
            ..where((s) => s.contextId.equals(contextId)))
          .write(
        ShuffleStateTableCompanion(
          configJson: Value(configJson),
          shuffledIdsJson: Value(shuffledIdsJson),
          currentIndex: Value(currentIndex),
          updatedAtMs: Value(nowMs),
        ),
      );
    }
  }

  /// Loads the persisted state for [contextId], or null if none saved.
  Future<ShuffleStateRow?> load(String contextId) =>
      (select(shuffleStateTable)..where((s) => s.contextId.equals(contextId)))
          .getSingleOrNull();

  /// Clears the persisted state for a single [contextId].
  Future<void> clear(String contextId) =>
      (delete(shuffleStateTable)..where((s) => s.contextId.equals(contextId)))
          .go();

  /// Clears all persisted shuffle states.
  Future<void> clearAll() => delete(shuffleStateTable).go();
}
