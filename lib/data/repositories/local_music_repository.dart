// lib/data/repositories/local_music_repository.dart
// Aura — LocalMusicRepository
// Architecture §4.2: queries MediaStore (Android) / MPMediaQuery (iOS) via
// platform channel; populates Drift DB.

import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/track.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/artist.dart';
import '../../domain/repositories/music_repository.dart';
import '../../core/constants.dart';
import '../../core/errors.dart';
import '../database/app_database.dart';
import 'package:drift/drift.dart';

class LocalMusicRepository implements MusicRepository {
  LocalMusicRepository({required AppDatabase database})
      : _db = database;

  final AppDatabase _db;
  final _uuid = const Uuid();

  /// Platform channel to the native file scanner (Android MediaStore / iOS MPMedia).
  static const _channel = MethodChannel(kFileScannerChannel);

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
    // Invoke the native scanner.
    // The platform channel returns a List<Map> of raw track metadata.
    // Each map matches the keys produced by MediaStore/MPMediaQuery.
    List<dynamic> rawTracks;
    try {
      rawTracks = await _channel.invokeMethod<List<dynamic>>(
            kScanAllAudioMethod,
          ) ??
          [];
    } on PlatformException catch (e) {
      throw FileScanError(e.message ?? 'Platform scan failed', cause: e);
    }

    int count = 0;
    final artistCache = <String, String>{}; // name → id
    final albumCache = <String, String>{}; // "title|artistId" → id

    for (final raw in rawTracks) {
      final map = Map<String, dynamic>.from(raw as Map);

      // Resolve / create artist.
      final artistName = (map['artist'] as String? ?? 'Unknown Artist').trim();
      final artistId = await _resolveArtist(artistName, artistCache);

      // Resolve / create album.
      final albumTitle = (map['album'] as String? ?? 'Unknown Album').trim();
      final albumId =
          await _resolveAlbum(albumTitle, artistId, artistName, albumCache);

      // Upsert track.
      final trackId = _uuid.v4();
      final filePath = map['path'] as String;

      // Check if already in DB by path.
      final existing = await _db.trackDao.getTrackByPath(filePath);
      final id = existing?.id ?? trackId;

      await _db.trackDao.upsertTrack(
        TracksTableCompanion(
          id: Value(id),
          title: Value((map['title'] as String? ?? 'Unknown').trim()),
          artistName: Value(artistName),
          albumTitle: Value(albumTitle),
          artistId: Value(artistId),
          albumId: Value(albumId),
          durationMs: Value((map['duration'] as int?) ?? 0),
          filePath: Value(filePath),
          fileSizeBytes: Value((map['size'] as int?) ?? 0),
          format: Value(_detectFormat(filePath)),
          bitRateKbps: Value((map['bitrate'] as int?) ?? 0),
          sampleRateHz: Value((map['sampleRate'] as int?) ?? 44100),
          dateAddedMs:
              Value((map['dateAdded'] as int?) ??
                  DateTime.now().millisecondsSinceEpoch),
          trackNumber: Value((map['trackNumber'] as int?) ?? 0),
          discNumber: Value((map['discNumber'] as int?) ?? 1),
          genre: Value((map['genre'] as String?) ?? ''),
          year: Value((map['year'] as int?) ?? 0),
          coverArtPath: Value(map['coverArtPath'] as String?),
        ),
      );

      count++;
      yield count; // Emit progress.
    }
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
    if (row == null) return null;
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

  Future<String> _resolveArtist(
      String name, Map<String, String> cache) async {
    if (cache.containsKey(name)) return cache[name]!;

    final existing = await _db.trackDao.getArtistByName(name);
    if (existing != null) {
      cache[name] = existing.id;
      return existing.id;
    }

    final id = _uuid.v4();
    await _db.trackDao.upsertArtist(
      ArtistsTableCompanion(
        id: Value(id),
        name: Value(name),
      ),
    );
    cache[name] = id;
    return id;
  }

  Future<String> _resolveAlbum(
    String title,
    String artistId,
    String artistName,
    Map<String, String> cache,
  ) async {
    final cacheKey = '$title|$artistId';
    if (cache.containsKey(cacheKey)) return cache[cacheKey]!;

    final id = _uuid.v4();
    await _db.trackDao.upsertAlbum(
      AlbumsTableCompanion(
        id: Value(id),
        title: Value(title),
        artistId: Value(artistId),
        artistName: Value(artistName),
        dateAddedMs: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    cache[cacheKey] = id;
    return id;
  }

  String _detectFormat(String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'mp3' => 'mp3',
      'aac' || 'm4a' => 'aac',
      'flac' => 'flac',
      'alac' => 'alac',
      'dsd' || 'dsf' || 'dff' => 'dsd',
      'wav' => 'wav',
      'ogg' => 'ogg',
      'opus' => 'opus',
      _ => 'unknown',
    };
  }

  // ── Row ↔ Entity Mappers ───────────────────────────────────────────────────

  Track _rowToTrack(TrackRow r) => Track(
        id: r.id,
        title: r.title,
        artistName: r.artistName,
        albumTitle: r.albumTitle,
        artistId: r.artistId,
        albumId: r.albumId,
        durationMs: r.durationMs,
        filePath: r.filePath,
        fileSizeBytes: r.fileSizeBytes,
        format: AudioFormat.values
            .firstWhere((f) => f.name == r.format, orElse: () => AudioFormat.unknown),
        bitRateKbps: r.bitRateKbps,
        sampleRateHz: r.sampleRateHz,
        playCount: r.playCount,
        skipCount: r.skipCount,
        rating: r.rating,
        dateAddedMs: r.dateAddedMs,
        lastPlayedMs: r.lastPlayedMs,
        isDeleted: r.isDeleted,
        coverArtPath: r.coverArtPath,
        trackNumber: r.trackNumber,
        discNumber: r.discNumber,
        genre: r.genre,
        year: r.year,
      );

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
