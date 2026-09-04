// lib/data/repositories/local_music_repository.dart
// Aura — LocalMusicRepository
// Architecture §4.2: queries MediaStore (Android) / MPMediaQuery (iOS) via
// platform channel; populates Drift DB.

import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../domain/entities/track.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/artist.dart';
import '../../domain/repositories/music_repository.dart';
import '../../core/constants.dart';
import '../../core/errors.dart';
import '../../native/audio_engine_ffi.dart';
import '../database/app_database.dart';
import 'track_mapper.dart';
import '../scanner/library_scanner.dart';
import 'package:drift/drift.dart';

class LocalMusicRepository implements MusicRepository {
  LocalMusicRepository({required AppDatabase database})
      : _db = database;

  final AppDatabase _db;
  final _uuid = const Uuid();


  // ── MusicRepository Interface ──────────────────────────────────────────────

  @override
  Future<List<Track>> getAllTracks() async {
    final rows = await _db.trackDao.getAllTracks();
    return rows.map(_rowToTrack).toList();
  }

  @override
  Future<List<Track>> getTracksByAlbum(String albumId) async {
    final rows = await _db.trackDao.getTracksByAlbum(albumId);
    return rows.map(_rowToTrack).toList();
  }

  @override
  Future<List<Track>> getTracksByArtist(String artistId) async {
    final rows = await _db.trackDao.getTracksByArtist(artistId);
    return rows.map(_rowToTrack).toList();
  }

  @override
  Future<Track?> getTrackById(String id) async {
    final row = await _db.trackDao.getTrackById(id);
    return row != null ? _rowToTrack(row) : null;
  }

  @override
  Future<List<Album>> getAllAlbums() async {
    final rows = await _db.trackDao.getAllAlbums();
    return rows.map(_rowToAlbum).toList();
  }

  @override
  Future<List<Artist>> getAllArtists() async {
    final rows = await _db.trackDao.getAllArtists();
    return rows.map(_rowToArtist).toList();
  }

  // ── Library Scan ───────────────────────────────────────────────────────────

  @override
  Stream<int> scanLibrary() async* {
    // Delegates to the canonical LibraryScanner (data/scanner/) so there is a
    // single scan implementation. Emits the running processed-track count to
    // satisfy the MusicRepository contract.
    final controller = StreamController<int>();
    final scanner = LibraryScanner(database: _db);

    unawaited(
      scanner
          .scanLibrary(onProgress: (found, _) => controller.add(found))
          .then((_) => controller.close())
          .catchError((Object e, StackTrace st) {
        controller.addError(FileScanError('Library scan failed', cause: e), st);
        controller.close();
      }),
    );

    yield* controller.stream;
  }

  @override
  Future<void> upsertTracks(List<Track> tracks) async {
    final companions = tracks.map(_trackToCompanion).toList();
    await _db.trackDao.upsertTracks(companions);
  }

  @override
  Future<void> deleteTrack(String trackId) =>
      _db.trackDao.softDeleteTrack(trackId);

  @override
  Future<void> recordPlay(String trackId, {required int durationPlayedMs}) =>
      _db.trackDao.incrementPlayCount(trackId);

  @override
  Future<void> recordSkip(String trackId) =>
      _db.trackDao.incrementSkipCount(trackId);

  @override
  Future<void> setRating(String trackId, int rating) =>
      _db.trackDao.setRating(trackId, rating);

  @override
  Future<List<double>?> getAudioFeatures(String trackId) async {
    final row = await _db.trackDao.getAudioFeatures(trackId);
    if (row == null) {
      final track = await getTrackById(trackId);
      if (track != null && track.filePath.isNotEmpty) {
        final features = AudioEngineFfi.instance.analyzeFeatures(track.filePath);
        if (features != null && features.length == 6) {
          await upsertAudioFeatures(trackId, features);
          return features;
        }
      }
      return null;
    }
    return [
      row.tempo,
      row.energy,
      row.valence,
      row.danceability,
      row.loudness,
      row.acousticness,
    ];
  }

  @override
  Future<void> upsertAudioFeatures(
      String trackId, List<double> features) async {
    assert(features.length == kAudioFeatureDimension);
    await _db.trackDao.upsertAudioFeatures(
      AudioFeaturesTableCompanion(
        trackId: Value(trackId),
        tempo: Value(features[0]),
        energy: Value(features[1]),
        valence: Value(features[2]),
        danceability: Value(features[3]),
        loudness: Value(features[4]),
        acousticness: Value(features[5]),
      ),
    );
  }

  // ── Private Helpers ────────────────────────────────────────────────────────

  // ── Row ↔ Entity Mappers ───────────────────────────────────────────────────

  Track _rowToTrack(TrackRow r) => trackFromRow(r);

  Album _rowToAlbum(AlbumRow r) => Album(
        id: r.id,
        title: r.title,
        artistId: r.artistId,
        artistName: r.artistName,
        year: r.year,
        coverArtPath: r.coverArtPath,
        trackCount: r.trackCount,
        totalDurationMs: r.totalDurationMs,
        genre: r.genre,
        dateAddedMs: r.dateAddedMs,
      );

  Artist _rowToArtist(ArtistRow r) => Artist(
        id: r.id,
        name: r.name,
        trackCount: r.trackCount,
        albumCount: r.albumCount,
        imagePath: r.imagePath,
      );

  TracksTableCompanion _trackToCompanion(Track t) => TracksTableCompanion(
        id: Value(t.id),
        title: Value(t.title),
        artistName: Value(t.artistName),
        albumTitle: Value(t.albumTitle),
        artistId: Value(t.artistId),
        albumId: Value(t.albumId),
        durationMs: Value(t.durationMs),
        filePath: Value(t.filePath),
        fileSizeBytes: Value(t.fileSizeBytes),
        format: Value(t.format.name),
        bitRateKbps: Value(t.bitRateKbps),
        sampleRateHz: Value(t.sampleRateHz),
        playCount: Value(t.playCount),
        skipCount: Value(t.skipCount),
        rating: Value(t.rating),
        dateAddedMs: Value(t.dateAddedMs),
        lastPlayedMs: Value(t.lastPlayedMs),
        isDeleted: Value(t.isDeleted),
        coverArtPath: Value(t.coverArtPath),
        trackNumber: Value(t.trackNumber),
        discNumber: Value(t.discNumber),
        genre: Value(t.genre),
        year: Value(t.year),
      );
}
