// lib/data/repositories/local_playlist_repository.dart
// Aura — LocalPlaylistRepository

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/playlist.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../database/app_database.dart';

class LocalPlaylistRepository implements PlaylistRepository {
  LocalPlaylistRepository({required AppDatabase database}) : _db = database;

  final AppDatabase _db;
  final _uuid = const Uuid();

  @override
  Future<List<Playlist>> getAllPlaylists() async {
    final rows = await _db.playlistDao.getAllPlaylists();
    return Future.wait(rows.map(_rowToPlaylist));
  }

  @override
  Future<Playlist?> getPlaylistById(String id) async {
    final row = await _db.playlistDao.getPlaylistById(id);
    if (row == null) return null;
    return _rowToPlaylist(row);
  }

  @override
  Future<Playlist> createPlaylist({
    required String name,
    String description = '',
    PlaylistType type = PlaylistType.userCreated,
    MixMood? mood,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = _uuid.v4();
    await _db.playlistDao.upsertPlaylist(
      PlaylistsTableCompanion(
        id: Value(id),
        name: Value(name),
        description: Value(description),
        type: Value(type.name),
        mood: Value(mood?.name),
        createdAtMs: Value(now),
        updatedAtMs: Value(now),
      ),
    );
    return Playlist(
      id: id,
      name: name,
      description: description,
      type: type,
      mood: mood,
      createdAtMs: now,
      updatedAtMs: now,
    );
  }

  @override
  Future<void> updatePlaylist(Playlist updated) =>
      _db.playlistDao.upsertPlaylist(
        PlaylistsTableCompanion(
          id: Value(updated.id),
          name: Value(updated.name),
          description: Value(updated.description),
          type: Value(updated.type.name),
          mood: Value(updated.mood?.name),
          createdAtMs: Value(updated.createdAtMs),
          updatedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
          coverArtPath: Value(updated.coverArtPath),
          isPinned: Value(updated.isPinned),
        ),
      );

  @override
  Future<void> deletePlaylist(String id) =>
      _db.playlistDao.deletePlaylist(id);

  @override
  Future<void> addTrack(String playlistId, String trackId) =>
      _db.playlistDao.addTrack(playlistId, trackId);

  @override
  Future<void> removeTrack(String playlistId, String trackId) =>
      _db.playlistDao.removeTrack(playlistId, trackId);

  @override
  Future<void> reorderTracks(String playlistId, List<String> orderedTrackIds) =>
      _db.playlistDao.reorderTracks(playlistId, orderedTrackIds);

  @override
  Future<void> upsertSmartMix(Playlist playlist) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.playlistDao.upsertPlaylist(
      PlaylistsTableCompanion(
        id: Value(playlist.id),
        name: Value(playlist.name),
        description: Value(playlist.description),
        type: Value(PlaylistType.smartMix.name),
        mood: Value(playlist.mood?.name),
        createdAtMs: Value(playlist.createdAtMs),
        updatedAtMs: Value(now),
      ),
    );
    await _db.playlistDao.reorderTracks(playlist.id, playlist.trackIds);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<Playlist> _rowToPlaylist(PlaylistRow row) async {
    final trackIds = await _db.playlistDao.getTrackIds(row.id);
    return Playlist(
      id: row.id,
      name: row.name,
      description: row.description,
      type: PlaylistType.values
          .firstWhere((t) => t.name == row.type, orElse: () => PlaylistType.userCreated),
      mood: row.mood != null
          ? MixMood.values
              .firstWhere((m) => m.name == row.mood, orElse: () => MixMood.chill)
          : null,
      trackIds: trackIds,
      createdAtMs: row.createdAtMs,
      updatedAtMs: row.updatedAtMs,
      coverArtPath: row.coverArtPath,
      isPinned: row.isPinned,
    );
  }
}
