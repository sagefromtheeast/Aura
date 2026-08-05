// lib/domain/repositories/music_repository.dart
// Aura — Abstract MusicRepository interface.
// Architecture §4.2: implemented by LocalMusicRepository (data layer).

import '../entities/track.dart';
import '../entities/album.dart';
import '../entities/artist.dart';

/// Provides access to the local music library.
///
/// Implemented by [LocalMusicRepository] in the data layer.
/// All methods are async and return domain entities (not DB rows).
abstract interface class MusicRepository {
  // ── Library Queries ─────────────────────────────────────────────────────────

  /// Returns all non-deleted tracks ordered by [Track.title].
  Future<List<Track>> getAllTracks();

  /// Returns tracks belonging to the given [albumId].
  Future<List<Track>> getTracksByAlbum(String albumId);

  /// Returns tracks by the given [artistId].
  Future<List<Track>> getTracksByArtist(String artistId);

  /// Returns a single track by its [id], or null if not found.
  Future<Track?> getTrackById(String id);

  /// Returns all albums, ordered by [Album.title].
  Future<List<Album>> getAllAlbums();

  /// Returns all artists, ordered by [Artist.name].
  Future<List<Artist>> getAllArtists();

  // ── Library Management ──────────────────────────────────────────────────────

  /// Triggers a full library scan via platform channel (MediaStore / MPMedia).
  ///
  /// Emits scan progress as a stream of integers (tracks discovered so far).
  /// PRD §6.2: "Background file scanner with progress notification."
  Stream<int> scanLibrary();

  /// Inserts or updates a list of tracks in the database.
  Future<void> upsertTracks(List<Track> tracks);

  /// Soft-deletes a track (marks [Track.isDeleted] = true; retains stats).
  Future<void> deleteTrack(String trackId);

  /// Updates the play count and last-played timestamp for [trackId].
  Future<void> recordPlay(String trackId, {required int durationPlayedMs});

  /// Updates the skip count for [trackId].
  Future<void> recordSkip(String trackId);

  /// Sets the user rating (0–5) for [trackId].
  Future<void> setRating(String trackId, int rating);

  // ── Audio Features ──────────────────────────────────────────────────────────

  /// Returns the pre-extracted audio feature vector for [trackId].
  /// Returns null if features haven't been extracted yet (C++ analyzer pending).
  Future<List<double>?> getAudioFeatures(String trackId);

  /// Upserts the audio feature vector for [trackId].
  /// Called by the C++ analyzer when a track is first analysed.
  Future<void> upsertAudioFeatures(String trackId, List<double> features);
}
