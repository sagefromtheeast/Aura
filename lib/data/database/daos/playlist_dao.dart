// lib/data/database/daos/playlist_dao.dart
// Aura — PlaylistDao: playlist and playlist_track CRUD.

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/playlists_table.dart';

part 'playlist_dao.g.dart';

@DriftAccessor(tables: [PlaylistsTable, PlaylistTracksTable])
class PlaylistDao extends DatabaseAccessor<AppDatabase>
    with _$PlaylistDaoMixin {
  PlaylistDao(super.db);

  // ── Playlist Queries ───────────────────────────────────────────────────────

  Future<List<PlaylistRow>> getAllPlaylists() =>
      (select(playlistsTable)
            ..orderBy([
              (p) => OrderingTerm.desc(p.isPinned),
              (p) => OrderingTerm.asc(p.name),
            ]))
          .get();

  Future<PlaylistRow?> getPlaylistById(String id) =>
      (select(playlistsTable)..where((p) => p.id.equals(id)))
          .getSingleOrNull();

  Future<void> upsertPlaylist(PlaylistsTableCompanion playlist) =>
      into(playlistsTable).insertOnConflictUpdate(playlist);

  Future<void> deletePlaylist(String id) =>
      (delete(playlistsTable)..where((p) => p.id.equals(id))).go();

  // ── Playlist Track Management ──────────────────────────────────────────────

  /// Returns all track IDs for a playlist in position order.
  Future<List<String>> getTrackIds(String playlistId) async {
    final rows = await (select(playlistTracksTable)
          ..where((pt) => pt.playlistId.equals(playlistId))
          ..orderBy([(pt) => OrderingTerm.asc(pt.position)]))
        .get();
    return rows.map((r) => r.trackId).toList();
  }

  Future<void> addTrack(String playlistId, String trackId) async {
    final existing = await (select(playlistTracksTable)
          ..where((pt) =>
              pt.playlistId.equals(playlistId) & pt.trackId.equals(trackId)))
        .getSingleOrNull();
    if (existing != null) return; // Already in playlist.

    final maxPos = await _maxPosition(playlistId);
    await into(playlistTracksTable).insert(
      PlaylistTracksTableCompanion(
        playlistId: Value(playlistId),
        trackId: Value(trackId),
        position: Value(maxPos + 1),
      ),
    );
    await _touchUpdatedAt(playlistId);
  }

  Future<void> removeTrack(String playlistId, String trackId) async {
    await (delete(playlistTracksTable)
          ..where((pt) =>
              pt.playlistId.equals(playlistId) & pt.trackId.equals(trackId)))
        .go();
    await _touchUpdatedAt(playlistId);
  }

  /// Replaces the complete ordered track list.
  Future<void> reorderTracks(
      String playlistId, List<String> orderedIds) async {
    await transaction(() async {
      await (delete(playlistTracksTable)
            ..where((pt) => pt.playlistId.equals(playlistId)))
          .go();

      await batch((b) {
        for (int i = 0; i < orderedIds.length; i++) {
          b.insert(
            playlistTracksTable,
            PlaylistTracksTableCompanion(
              playlistId: Value(playlistId),
              trackId: Value(orderedIds[i]),
              position: Value(i),
            ),
          );
        }
      });
      await _touchUpdatedAt(playlistId);
    });
  }

  // ── Private ────────────────────────────────────────────────────────────────

  Future<int> _maxPosition(String playlistId) async {
    final row = await customSelect(
      'SELECT MAX(position) as max_pos FROM playlist_tracks WHERE playlist_id = ?',
      variables: [Variable.withString(playlistId)],
      readsFrom: {playlistTracksTable},
    ).getSingleOrNull();
    return row?.read<int?>('max_pos') ?? -1;
  }

  Future<void> _touchUpdatedAt(String playlistId) =>
      (update(playlistsTable)..where((p) => p.id.equals(playlistId))).write(
        PlaylistsTableCompanion(
          updatedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
}
