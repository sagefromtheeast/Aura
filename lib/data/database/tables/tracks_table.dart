// lib/data/database/tables/tracks_table.dart
// Aura — Drift table definition for tracks.

import 'package:drift/drift.dart';

/// Drift table definition for the tracks entity.
/// All columns directly mirror [Track] domain entity fields.
@DataClassName('TrackRow')
class TracksTable extends Table {
  @override
  String get tableName => 'tracks';

  /// UUID v4 — primary key.
  TextColumn get id => text()();

  TextColumn get title => text()();
  TextColumn get artistName => text()();
  TextColumn get albumTitle => text()();
  TextColumn get artistId => text()();
  TextColumn get albumId => text()();
  IntColumn get durationMs => integer()();
  TextColumn get filePath => text().unique()();
  IntColumn get fileSizeBytes => integer().withDefault(const Constant(0))();
  TextColumn get format =>
      text().withDefault(const Constant('unknown'))();
  IntColumn get bitRateKbps => integer().withDefault(const Constant(0))();
  IntColumn get sampleRateHz => integer().withDefault(const Constant(44100))();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  IntColumn get skipCount => integer().withDefault(const Constant(0))();
  IntColumn get rating => integer().withDefault(const Constant(0))();
  IntColumn get dateAddedMs => integer()();
  IntColumn get lastPlayedMs => integer().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get coverArtPath => text().nullable()();
  IntColumn get trackNumber => integer().withDefault(const Constant(0))();
  IntColumn get discNumber => integer().withDefault(const Constant(1))();
  TextColumn get genre => text().withDefault(const Constant(''))();
  IntColumn get year => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
