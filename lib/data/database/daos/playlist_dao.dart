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

  /// Appends [trackId] if it is not already a member.
  ///
  /// Returns false when it was already there. The membership check is a read
  /// before the write; the table's composite primary key is the actual
  /// guarantee, and catches the race between the two.
  Future<bool> addTrack(String playlistId, String trackId) async {
    final existing = await (select(playlistTracksTable)
          ..where((pt) =>
              pt.playlistId.equals(playlistId) & pt.trackId.equals(trackId)))
        .getSingleOrNull();
    if (existing != null) return false; // Already in playlist.

    final maxPos = await _maxPosition(playlistId);
    await into(playlistTracksTable).insert(
      PlaylistTracksTableCompanion(
        playlistId: Value(playlistId),
        trackId: Value(trackId),
        position: Value(maxPos + 1),
      ),
      // The primary key is the final guard: if another writer inserted the
      // same pair between the check and here, treat it as already present
      // rather than failing the caller's whole batch.
      mode: InsertMode.insertOrIgnore,
    );
    await _touchUpdatedAt(playlistId);
    return true;
  }

  /// Appends every id in [trackIds] that is not already a member, in order.
  /// Returns how many were added.
  ///
  /// One membership read and one batched insert, rather than a round trip per
  /// track — "add this album to a playlist" is the common case.
  Future<int> addTracks(String playlistId, List<String> trackIds) async {
    if (trackIds.isEmpty) return 0;

    final present = (await getTrackIds(playlistId)).toSet();
    var position = await _maxPosition(playlistId);

    final toInsert = <PlaylistTracksTableCompanion>[];
    // A caller can pass the same id twice; `present` grows as we go so the
    // second occurrence is skipped just like a pre-existing member.
    for (final trackId in trackIds) {
      if (!present.add(trackId)) continue;
      position++;
      toInsert.add(PlaylistTracksTableCompanion(
        playlistId: Value(playlistId),
        trackId: Value(trackId),
        position: Value(position),
      ));
    }
    if (toInsert.isEmpty) return 0;

    await batch((b) => b.insertAll(playlistTracksTable, toInsert,
        mode: InsertMode.insertOrIgnore));
    await _touchUpdatedAt(playlistId);
    return toInsert.length;
  }

  Future<void> removeTrack(String playlistId, String trackId) =>
      removeTracks(playlistId, [trackId]);

  /// Removes [trackIds] and closes the gaps their positions leave behind.
  Future<void> removeTracks(
      String playlistId, List<String> trackIds) async {
    if (trackIds.isEmpty) return;
    await transaction(() async {
      await (delete(playlistTracksTable)
            ..where((pt) =>
                pt.playlistId.equals(playlistId) & pt.trackId.isIn(trackIds)))
          .go();
      // Positions must stay dense: `addTrack` appends at max+1, so a hole
      // left by a removal would otherwise be reused out of order.
      await _compactPositions(playlistId);
      await _touchUpdatedAt(playlistId);
    });
  }

  /// Membership count, without loading the rows.
  Future<int> getTrackCount(String playlistId) async {
    final row = await customSelect(
      'SELECT COUNT(*) AS c FROM playlist_tracks WHERE playlist_id = ?',
      variables: [Variable.withString(playlistId)],
      readsFrom: {playlistTracksTable},
    ).getSingle();
    return row.read<int>('c');
  }

  /// Renames a playlist without touching its other columns.
  Future<void> renamePlaylist(String id, String newName) =>
      (update(playlistsTable)..where((p) => p.id.equals(id))).write(
        PlaylistsTableCompanion(
          name: Value(newName),
          updatedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

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

  /// Rewrites positions as 0..n-1 in their current order.
  Future<void> _compactPositions(String playlistId) async {
    final rows = await (select(playlistTracksTable)
          ..where((pt) => pt.playlistId.equals(playlistId))
          ..orderBy([(pt) => OrderingTerm.asc(pt.position)]))
        .get();

    await batch((b) {
      for (var i = 0; i < rows.length; i++) {
        if (rows[i].position == i) continue;
        b.update(
          playlistTracksTable,
          PlaylistTracksTableCompanion(position: Value(i)),
          where: (pt) =>
              pt.playlistId.equals(playlistId) &
              pt.trackId.equals(rows[i].trackId),
        );
      }
    });
  }

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
