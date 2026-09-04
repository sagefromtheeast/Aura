// lib/data/database/daos/settings_dao.dart
// Aura — SettingsDao: the JSON key/value half of settings storage.

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/settings_table.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [SettingsTable])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> read(String key) async {
    final row = await (select(settingsTable)..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  /// Every stored setting, keyed. One query for a full settings load.
  Future<Map<String, String>> readAll() async {
    final rows = await select(settingsTable).get();
    return {for (final row in rows) row.key: row.value};
  }

  Future<void> write(String key, String value) =>
      into(settingsTable).insertOnConflictUpdate(
        SettingsTableCompanion(
          key: Value(key),
          value: Value(value),
          updatedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  Future<void> writeAll(Map<String, String> values) async {
    if (values.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    await batch((b) => b.insertAllOnConflictUpdate(
          settingsTable,
          [
            for (final entry in values.entries)
              SettingsTableCompanion(
                key: Value(entry.key),
                value: Value(entry.value),
                updatedAtMs: Value(now),
              ),
          ],
        ));
  }

  /// Epoch ms of the most recent write across all settings, or null when none.
  Future<int?> lastUpdatedMs() async {
    final row = await customSelect(
      'SELECT MAX(updated_at_ms) AS m FROM settings',
      readsFrom: {settingsTable},
    ).getSingleOrNull();
    return row?.readNullable<int>('m');
  }

  Future<void> clear() => delete(settingsTable).go();
}
