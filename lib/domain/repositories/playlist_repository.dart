// lib/domain/repositories/playlist_repository.dart
// Aura — Abstract PlaylistRepository interface.
// PRD §6.2: user playlists + §6.4: Smart Mix playlists.

import '../entities/playlist.dart';

abstract interface class PlaylistRepository {
  /// Returns all playlists ordered by pin status then name.
  Future<List<Playlist>> getAllPlaylists();

  /// Returns a single playlist by [id], or null.
  Future<Playlist?> getPlaylistById(String id);

  /// Creates a new playlist and returns it with its generated ID.
  Future<Playlist> createPlaylist({
    required String name,
    String description = '',
    PlaylistType type = PlaylistType.userCreated,
    MixMood? mood,
  });

  /// Replaces the stored playlist with [updated] (identified by id).
  Future<void> updatePlaylist(Playlist updated);

  /// Deletes a playlist by [id]. Track metadata is unaffected.
  Future<void> deletePlaylist(String id);

  /// Appends [trackId] to the end of playlist [playlistId].
  Future<void> addTrack(String playlistId, String trackId);

  /// Removes [trackId] from playlist [playlistId].
  Future<void> removeTrack(String playlistId, String trackId);

  /// Replaces the complete ordered track list for [playlistId].
  Future<void> reorderTracks(String playlistId, List<String> orderedTrackIds);

  /// Replaces or creates a Smart Mix playlist for the given [mood].
  /// Called daily by SmartMixGenerator.
  Future<void> upsertSmartMix(Playlist playlist);
}
