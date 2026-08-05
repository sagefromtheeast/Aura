// lib/data/database/tables/artists_table.dart
import 'package:drift/drift.dart';

@DataClassName('ArtistRow')
class ArtistsTable extends Table {
  @override
  String get tableName => 'artists';

  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  IntColumn get trackCount => integer().withDefault(const Constant(0))();
  IntColumn get albumCount => integer().withDefault(const Constant(0))();
  TextColumn get imagePath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
