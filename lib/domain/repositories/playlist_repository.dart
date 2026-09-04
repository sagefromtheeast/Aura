// lib/domain/repositories/playlist_repository.dart
// Aura — Abstract PlaylistRepository interface.
// PRD §6.2: user playlists + §6.4: Smart Mix playlists.

import '../entities/playlist.dart';
import '../entities/track.dart';

/// What an M3U import managed to do.
///
/// Import returns this rather than void because an import that silently drops
/// half a playlist is worse than one that says so: the caller needs to tell the
/// user "42 of 50 tracks imported" and which eight are missing.
class M3uImportResult {
  const M3uImportResult({
    required this.playlist,
    required this.imported,
    required this.unmatched,
  });

  /// The playlist the entries were imported into (created, if it did not
  /// already exist).
  final Playlist playlist;

  /// How many entries resolved to a library track and were added.
  final int imported;

  /// Paths from the file that no track in the library matched — usually music
  /// the user has not scanned, or that lives on another device.
  final List<String> unmatched;

  int get total => imported + unmatched.length;
}

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

  /// Renames playlist [id]. Cheaper than a full [updatePlaylist] round trip,
  /// which would need the caller to load the playlist first.
  Future<void> renamePlaylist(String id, String newName);

  /// Appends [trackId] to the end of playlist [playlistId].
  ///
  /// Returns false when the track is already in the playlist and nothing was
  /// added, so the UI can say "Already in playlist" instead of silently
  /// appearing to succeed.
  Future<bool> addTrack(String playlistId, String trackId);

  /// Appends every id in [trackIds] that is not already present, in order.
  /// Returns how many were actually added.
  Future<int> addTracks(String playlistId, List<String> trackIds);

  /// Removes [trackId] from playlist [playlistId].
  Future<void> removeTrack(String playlistId, String trackId);

  /// Removes every id in [trackIds] from playlist [playlistId].
  Future<void> removeTracks(String playlistId, List<String> trackIds);

  /// Replaces the complete ordered track list for [playlistId].
  Future<void> reorderTracks(String playlistId, List<String> orderedTrackIds);

  /// The playlist's tracks as full entities, in playlist order.
  ///
  /// Ids referring to tracks no longer in the library are skipped, so the
  /// result can be shorter than [getPlaylistTrackCount].
  Future<List<Track>> getPlaylistTracks(String playlistId);

  /// Number of membership rows, counted in SQL rather than by loading them.
  Future<int> getPlaylistTrackCount(String playlistId);

  /// Tracks in [playlistId] that duplicate an earlier entry — the same
  /// recording added twice as different files, e.g. the FLAC and the MP3.
  ///
  /// The same track *id* cannot appear twice (the membership table's composite
  /// primary key forbids it), so this is the only duplication a playlist can
  /// actually contain. Detection is Step 2.6's metadata matching; the first
  /// occurrence by position is the keeper and is never returned.
  Future<List<Track>> getDuplicateTracks(String playlistId);

  /// Removes everything [getDuplicateTracks] reports, keeping the first
  /// occurrence of each recording. Returns how many were removed.
  Future<int> removeDuplicates(String playlistId);

  /// Imports an `.m3u` / `.m3u8` file into a playlist.
  ///
  /// Creates a playlist named [playlistName], defaulting to the file's own
  /// `#PLAYLIST` directive or its basename.
  Future<M3uImportResult> importM3u(String filePath, {String? playlistName});

  /// Writes [playlistId] to [outputPath] as an extended M3U file.
  Future<void> exportM3u(String playlistId, String outputPath);

  /// Replaces or creates a Smart Mix playlist for the given [mood].
  /// Called daily by SmartMixGenerator.
  Future<void> upsertSmartMix(Playlist playlist);
}
