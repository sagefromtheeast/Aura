// lib/data/database/tables/playlists_table.dart
import 'package:drift/drift.dart';

@DataClassName('PlaylistRow')
class PlaylistsTable extends Table {
  @override
  String get tableName => 'playlists';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get type =>
      text().withDefault(const Constant('userCreated'))();
  TextColumn get mood => text().nullable()();
  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer()();
  TextColumn get coverArtPath => text().nullable()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Junction table for playlist ↔ track membership.
@DataClassName('PlaylistTrackRow')
class PlaylistTracksTable extends Table {
  @override
  String get tableName => 'playlist_tracks';

  TextColumn get playlistId =>
      text().references(PlaylistsTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get trackId => text()();

  /// 0-based position within the playlist.
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {playlistId, trackId};
}
