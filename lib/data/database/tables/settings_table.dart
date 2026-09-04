// lib/data/database/tables/settings_table.dart
import 'package:drift/drift.dart';

/// Key/value store for settings too large or too structured for
/// shared_preferences — the equaliser curve, notification rules.
///
/// A table rather than a column per setting: settings arrive one step at a
/// time, and adding a row is not a migration.
@DataClassName('SettingRow')
class SettingsTable extends Table {
  @override
  String get tableName => 'settings';

  TextColumn get key => text()();

  /// JSON-encoded value. Readers tolerate a malformed value by falling back to
  /// the default rather than failing the whole load.
  TextColumn get value => text()();

  /// Epoch ms of the last write, so an import can tell which side is newer.
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column> get primaryKey => {key};
}
