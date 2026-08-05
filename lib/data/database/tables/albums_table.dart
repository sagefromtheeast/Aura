// lib/data/database/tables/albums_table.dart
import 'package:drift/drift.dart';

@DataClassName('AlbumRow')
class AlbumsTable extends Table {
  @override
  String get tableName => 'albums';

  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get artistId => text()();
  TextColumn get artistName => text()();
  IntColumn get year => integer().withDefault(const Constant(0))();
  TextColumn get coverArtPath => text().nullable()();
  IntColumn get trackCount => integer().withDefault(const Constant(0))();
  IntColumn get totalDurationMs => integer().withDefault(const Constant(0))();
  TextColumn get genre => text().withDefault(const Constant(''))();
  IntColumn get dateAddedMs => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
