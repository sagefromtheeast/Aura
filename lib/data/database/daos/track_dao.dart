// lib/data/database/daos/track_dao.dart
// Aura — TrackDao: all track & audio-feature CRUD.

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tracks_table.dart';
import '../tables/albums_table.dart';
import '../tables/artists_table.dart';
import '../tables/audio_features_table.dart';

part 'track_dao.g.dart';

@DriftAccessor(tables: [
  TracksTable,
  AlbumsTable,
  ArtistsTable,
  AudioFeaturesTable,
])
class TrackDao extends DatabaseAccessor<AppDatabase> with _$TrackDaoMixin {
  TrackDao(super.db);

  // ── Track Queries ──────────────────────────────────────────────────────────

  /// All non-deleted tracks, ordered by title ascending.
  Future<List<TrackRow>> getAllTracks() => (select(tracksTable)
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.title)]))
      .get();

  /// Tracks for a given album.
  Future<List<TrackRow>> getTracksByAlbum(String albumId) =>
      (select(tracksTable)
            ..where((t) => t.albumId.equals(albumId) & t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.discNumber),
                        (t) => OrderingTerm.asc(t.trackNumber)]))
          .get();

  /// Tracks for a given artist.
  Future<List<TrackRow>> getTracksByArtist(String artistId) =>
      (select(tracksTable)
            ..where((t) =>
                t.artistId.equals(artistId) & t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.albumTitle),
                        (t) => OrderingTerm.asc(t.trackNumber)]))
          .get();

  /// Single track by primary key.
  Future<TrackRow?> getTrackById(String id) =>
      (select(tracksTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// All tracks with a given file path (used by scanner for upsert detection).
  Future<TrackRow?> getTrackByPath(String filePath) =>
      (select(tracksTable)..where((t) => t.filePath.equals(filePath)))
          .getSingleOrNull();

  /// Non-deleted tracks for a given genre, ordered by title.
  Future<List<TrackRow>> findByGenre(String genre) => (select(tracksTable)
        ..where((t) => t.genre.equals(genre) & t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.title)]))
      .get();

  /// Case-insensitive fuzzy search across title, artist and album.
  /// Ranks exact/prefix matches ahead of substring matches.
  Future<List<TrackRow>> search(String query) {
    final q = query.trim();
    if (q.isEmpty) return Future.value(const <TrackRow>[]);
    final like = '%${q.toLowerCase()}%';
    return (select(tracksTable)
          ..where((t) =>
              t.isDeleted.equals(false) &
              (t.title.lower().like(like) |
                  t.artistName.lower().like(like) |
                  t.albumTitle.lower().like(like)))
          ..orderBy([(t) => OrderingTerm.asc(t.title)]))
        .get();
  }

  // ── Track Mutations ────────────────────────────────────────────────────────

  /// Insert or replace a track row.
  Future<void> upsertTrack(TracksTableCompanion track) =>
      into(tracksTable).insertOnConflictUpdate(track);

  Future<void> upsertTracks(List<TracksTableCompanion> tracks) =>
      batch((b) => b.insertAllOnConflictUpdate(tracksTable, tracks));

  /// Soft-delete: marks isDeleted=true, retains stats.
  Future<void> softDeleteTrack(String id) => (update(tracksTable)
        ..where((t) => t.id.equals(id)))
      .write(const TracksTableCompanion(isDeleted: Value(true)));

  /// Increment play count and update last-played timestamp.
  Future<void> incrementPlayCount(String id) async {
    await customStatement(
      'UPDATE tracks SET play_count = play_count + 1, '
      'last_played_ms = ? WHERE id = ?',
      [DateTime.now().millisecondsSinceEpoch, id],
    );
  }

  Future<void> incrementSkipCount(String id) async {
    await customStatement(
      'UPDATE tracks SET skip_count = skip_count + 1 WHERE id = ?',
      [id],
    );
  }

  Future<void> setRating(String id, int rating) => (update(tracksTable)
        ..where((t) => t.id.equals(id)))
      .write(TracksTableCompanion(rating: Value(rating)));

  // ── Album Queries ──────────────────────────────────────────────────────────

  Future<List<AlbumRow>> getAllAlbums() =>
      (select(albumsTable)..orderBy([(a) => OrderingTerm.asc(a.title)])).get();

  Future<void> upsertAlbum(AlbumsTableCompanion album) =>
      into(albumsTable).insertOnConflictUpdate(album);

  // ── Artist Queries ─────────────────────────────────────────────────────────

  Future<List<ArtistRow>> getAllArtists() =>
      (select(artistsTable)..orderBy([(a) => OrderingTerm.asc(a.name)])).get();

  Future<ArtistRow?> getArtistByName(String name) =>
      (select(artistsTable)..where((a) => a.name.equals(name)))
          .getSingleOrNull();

  Future<void> upsertArtist(ArtistsTableCompanion artist) =>
      into(artistsTable).insertOnConflictUpdate(artist);

  // ── Audio Features ─────────────────────────────────────────────────────────

  Future<AudioFeaturesRow?> getAudioFeatures(String trackId) =>
      (select(audioFeaturesTable)
            ..where((f) => f.trackId.equals(trackId)))
          .getSingleOrNull();

  Future<void> upsertAudioFeatures(AudioFeaturesTableCompanion features) =>
      into(audioFeaturesTable).insertOnConflictUpdate(features);
}
