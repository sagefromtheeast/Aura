// lib/data/scanner/library_scanner.dart
// Aura — Library scanner: populates the Drift database from local audio files.
//
// Pipeline:
//   1. collect   — native media library (MediaStore / MPMediaQuery), falling
//                  back to recursive folder scanning.
//   2. enrich    — read embedded tags for files the platform didn't describe.
//   3. reconcile — resolve artist/album rows, batch-upsert tracks, soft-delete
//                  files that disappeared, count likely duplicates.
//
// PRD §7: 20k tracks in under two minutes. The expensive parts are batched and
// the caller (ScanNotifier) runs collection+enrichment in a background isolate.

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import 'album_art_cache.dart';
import 'folder_scanner.dart';
import 'metadata_extractor.dart';
import 'platform_media_scanner.dart';
import 'raw_track.dart';

/// Summary of a completed scan.
@immutable
class ScanResult {
  const ScanResult({
    required this.tracksFound,
    required this.tracksAdded,
    required this.tracksRemoved,
    required this.duplicatesFound,
    required this.scanDuration,
  });

  /// Audio files discovered on disk / in the media library.
  final int tracksFound;

  /// Rows newly inserted (files not previously in the library).
  final int tracksAdded;

  /// Rows soft-deleted because their file no longer exists.
  final int tracksRemoved;

  /// Distinct files that look like duplicates of another found file
  /// (same normalised title + artist + duration within 2s).
  final int duplicatesFound;

  final Duration scanDuration;

  static const ScanResult empty = ScanResult(
    tracksFound: 0,
    tracksAdded: 0,
    tracksRemoved: 0,
    duplicatesFound: 0,
    scanDuration: Duration.zero,
  );

  @override
  String toString() => 'ScanResult(found: $tracksFound, added: $tracksAdded, '
      'removed: $tracksRemoved, duplicates: $duplicatesFound, '
      'in ${scanDuration.inMilliseconds}ms)';
}

class LibraryScanner {
  LibraryScanner({
    required AppDatabase database,
    PlatformMediaScanner? platformScanner,
    FolderScanner? folderScanner,
    MetadataExtractor? metadataExtractor,
    AlbumArtCache? artCache,
    Uuid? uuid,
  })  : _db = database,
        _platform = platformScanner ?? const PlatformMediaScanner(),
        _folders = folderScanner ?? const FolderScanner(),
        _metadata = metadataExtractor ?? const MetadataExtractor(),
        _art = artCache ?? AlbumArtCache(),
        _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final PlatformMediaScanner _platform;
  final FolderScanner _folders;
  final MetadataExtractor _metadata;
  final AlbumArtCache _art;
  final Uuid _uuid;

  /// How many track upserts to flush per batch.
  static const int _batchSize = 500;

  /// Scans the library and writes the results to the database.
  ///
  /// [extraFolders] are always walked in addition to the native media library;
  /// when the native scanner yields nothing they become the only source.
  /// [onProgress] reports `(processed, total)`; throttling is the caller's job.
  Future<ScanResult> scanLibrary({
    List<String> extraFolders = const [],
    void Function(int found, int total)? onProgress,
  }) async {
    final sw = Stopwatch()..start();

    final found = await collect(
      extraFolders: extraFolders,
      onFound: (n) => onProgress?.call(n, 0),
    );
    if (found.isEmpty) {
      sw.stop();
      return ScanResult(
        tracksFound: 0,
        tracksAdded: 0,
        tracksRemoved: await _removeMissing(const {}),
        duplicatesFound: 0,
        scanDuration: sw.elapsed,
      );
    }

    final result = await reconcile(found, onProgress: onProgress);
    sw.stop();
    return ScanResult(
      tracksFound: result.tracksFound,
      tracksAdded: result.tracksAdded,
      tracksRemoved: result.tracksRemoved,
      duplicatesFound: result.duplicatesFound,
      scanDuration: sw.elapsed,
    );
  }

  // ── 1 + 2: collection & enrichment (isolate-friendly, no DB access) ─────────

  /// Discovers audio files and fills in missing tags.
  ///
  /// Touches only plugins + `dart:io`, never the database, so it can be run
  /// inside a background isolate (see ScanNotifier).
  Future<List<RawTrack>> collect({
    List<String> extraFolders = const [],
    void Function(int found)? onFound,
  }) =>
      _collectImpl(
        platform: _platform,
        folders: _folders,
        metadata: _metadata,
        art: _art,
        extraFolders: extraFolders,
        onFound: onFound,
      );

  /// Database-free collection, for use inside a background isolate where no
  /// Drift connection exists. Uses default collaborators.
  static Future<List<RawTrack>> collectOnly({
    List<String> extraFolders = const [],
    void Function(int found)? onFound,
  }) =>
      _collectImpl(
        platform: const PlatformMediaScanner(),
        folders: const FolderScanner(),
        metadata: const MetadataExtractor(),
        art: AlbumArtCache(),
        extraFolders: extraFolders,
        onFound: onFound,
      );

  static Future<List<RawTrack>> _collectImpl({
    required PlatformMediaScanner platform,
    required FolderScanner folders,
    required MetadataExtractor metadata,
    required AlbumArtCache art,
    List<String> extraFolders = const [],
    void Function(int found)? onFound,
  }) async {
    final byPath = <String, RawTrack>{};
    final platformScanner = platform;
    final folderScanner = folders;
    final metadataExtractor = metadata;
    final artCache = art;

    // Native media library first — it is a single fast query.
    for (final t in await platformScanner.scan()) {
      byPath[t.filePath] = t;
      onFound?.call(byPath.length);
    }

    // Folder fallback / additional roots.
    if (extraFolders.isNotEmpty) {
      final walked = await folderScanner.scan(extraFolders);
      for (final t in walked) {
        byPath.putIfAbsent(t.filePath, () => t);
      }
      onFound?.call(byPath.length);
    }

    // Enrich anything the platform under-described, caching embedded artwork
    // once per album as we go.
    final out = <RawTrack>[];
    final artPathByAlbum = <String, String?>{};

    for (final track in byPath.values) {
      var enriched = track;
      if (track.needsMetadata) {
        final extracted = await metadataExtractor.extract(track);
        enriched = extracted.track;

        final key = artKey(enriched.album, enriched.albumArtist ?? enriched.artist);
        if (!artPathByAlbum.containsKey(key)) {
          final bytes = extracted.artworkBytes;
          artPathByAlbum[key] =
              (bytes != null && bytes.isNotEmpty) ? await artCache.store(key, bytes) : null;
        }
      }

      if (enriched.coverArtPath == null) {
        final key = artKey(enriched.album, enriched.albumArtist ?? enriched.artist);
        final cached =
            artPathByAlbum[key] ??= await artCache.lookup(key);
        if (cached != null) enriched = enriched.copyWith(coverArtPath: cached);
      }

      out.add(enriched);
    }
    return out;
  }

  /// Stable album-art cache key derived from album + album-artist, so every
  /// track on a record shares one cached image.
  static String artKey(String? album, String? artist) {
    String norm(String? s) =>
        (s ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final seed = '${norm(album)}_${norm(artist)}';
    final hash =
        seed.codeUnits.fold<int>(17, (acc, c) => (acc * 31 + c) & 0x7fffffff);
    return 'album_$hash';
  }

  // ── 3: database reconciliation ─────────────────────────────────────────────

  /// Writes [found] into the database and prunes vanished files.
  Future<ScanResult> reconcile(
    List<RawTrack> found, {
    void Function(int processed, int total)? onProgress,
  }) async {
    final total = found.length;

    // Preload lookups once — avoids O(n) round-trips for 20k tracks.
    final existingTracks = await _db.trackDao.getAllTracks();
    final idByPath = {for (final t in existingTracks) t.filePath: t.id};

    final artistIdByName = <String, String>{
      for (final a in await _db.trackDao.getAllArtists()) a.name: a.id,
    };
    final albumIdByKey = <String, String>{
      for (final a in await _db.trackDao.getAllAlbums())
        '${a.title}|${a.artistId}': a.id,
    };

    final newArtists = <ArtistsTableCompanion>[];
    final newAlbums = <AlbumsTableCompanion>[];
    final companions = <TracksTableCompanion>[];

    final dupeKeys = <String>{};
    var duplicates = 0;
    var added = 0;
    var processed = 0;

    for (final raw in found) {
      final title = (raw.title ?? '').trim().isEmpty
          ? _fallbackTitle(raw.filePath)
          : raw.title!.trim();
      final artistName = (raw.artist ?? '').trim().isEmpty
          ? 'Unknown Artist'
          : raw.artist!.trim();
      final albumTitle = (raw.album ?? '').trim().isEmpty
          ? 'Unknown Album'
          : raw.album!.trim();
      final durationMs = raw.durationMs ?? 0;

      // Duplicate heuristic across the found set.
      final dupeKey = _duplicateKey(title, artistName, durationMs);
      if (!dupeKeys.add(dupeKey)) duplicates++;

      // Artist row.
      var artistId = artistIdByName[artistName];
      if (artistId == null) {
        artistId = _uuid.v4();
        artistIdByName[artistName] = artistId;
        newArtists.add(ArtistsTableCompanion.insert(
          id: artistId,
          name: artistName,
        ));
      }

      // Album row.
      final albumKey = '$albumTitle|$artistId';
      var albumId = albumIdByKey[albumKey];
      if (albumId == null) {
        albumId = _uuid.v4();
        albumIdByKey[albumKey] = albumId;
        newAlbums.add(AlbumsTableCompanion.insert(
          id: albumId,
          title: albumTitle,
          artistId: artistId,
          artistName: artistName,
          dateAddedMs: raw.dateAddedMs ?? DateTime.now().millisecondsSinceEpoch,
          year: Value(raw.year ?? 0),
          genre: Value(raw.genre ?? ''),
        ));
      }

      final existingId = idByPath[raw.filePath];
      if (existingId == null) added++;

      companions.add(TracksTableCompanion(
        id: Value(existingId ?? _uuid.v4()),
        title: Value(title),
        artistName: Value(artistName),
        albumTitle: Value(albumTitle),
        artistId: Value(artistId),
        albumId: Value(albumId),
        durationMs: Value(durationMs),
        filePath: Value(raw.filePath),
        fileSizeBytes: Value(raw.sizeBytes ?? 0),
        format: Value(raw.extension.isEmpty ? 'unknown' : raw.extension),
        bitRateKbps: Value(raw.bitrate ?? 0),
        sampleRateHz: Value(raw.sampleRate ?? 44100),
        dateAddedMs: Value(
            raw.dateAddedMs ?? DateTime.now().millisecondsSinceEpoch),
        trackNumber: Value(raw.trackNumber ?? 0),
        discNumber: Value(raw.discNumber ?? 1),
        genre: Value(raw.genre ?? ''),
        year: Value(raw.year ?? 0),
        coverArtPath: Value(raw.coverArtPath),
        isDeleted: const Value(false),
      ));

      processed++;
      if (companions.length >= _batchSize) {
        await _flush(newArtists, newAlbums, companions);
      }
      onProgress?.call(processed, total);
    }

    await _flush(newArtists, newAlbums, companions);

    final removed = await _removeMissing(found.map((t) => t.filePath).toSet());

    return ScanResult(
      tracksFound: total,
      tracksAdded: added,
      tracksRemoved: removed,
      duplicatesFound: duplicates,
      scanDuration: Duration.zero, // filled in by scanLibrary
    );
  }

  Future<void> _flush(
    List<ArtistsTableCompanion> artists,
    List<AlbumsTableCompanion> albums,
    List<TracksTableCompanion> tracks,
  ) async {
    if (artists.isEmpty && albums.isEmpty && tracks.isEmpty) return;
    await _db.batch((b) {
      if (artists.isNotEmpty) {
        b.insertAllOnConflictUpdate(_db.artistsTable, List.of(artists));
      }
      if (albums.isNotEmpty) {
        b.insertAllOnConflictUpdate(_db.albumsTable, List.of(albums));
      }
      if (tracks.isNotEmpty) {
        b.insertAllOnConflictUpdate(_db.tracksTable, List.of(tracks));
      }
    });
    artists.clear();
    albums.clear();
    tracks.clear();
  }

  /// Soft-deletes library rows whose file is no longer on disk.
  ///
  /// [presentPaths] are the paths seen by this scan; anything else is verified
  /// with a filesystem check before being marked deleted, so a scan that only
  /// covered some folders never wipes the rest of the library.
  Future<int> _removeMissing(Set<String> presentPaths) async {
    final rows = await _db.trackDao.getAllTracks();
    var removed = 0;
    for (final row in rows) {
      if (presentPaths.contains(row.filePath)) continue;
      // iOS asset URLs aren't real files — never prune them on a stat check.
      if (row.filePath.startsWith('ipod-library://') ||
          row.filePath.startsWith('file://')) {
        continue;
      }
      if (await File(row.filePath).exists()) continue;
      await _db.trackDao.softDeleteTrack(row.id);
      removed++;
    }
    return removed;
  }

  static String _fallbackTitle(String path) {
    final name = path.split(Platform.pathSeparator).last;
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }

  /// Normalised key used to spot duplicate recordings within one scan.
  /// Duration is bucketed to 2s so different encodes still collide.
  static String _duplicateKey(String title, String artist, int durationMs) {
    String norm(String s) =>
        s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return '${norm(title)}|${norm(artist)}|${durationMs ~/ 2000}';
  }
}

/// Default music directories walked when no folders were selected.
/// (Android surfaces these through MediaStore already; this is for the
/// fallback path and desktop.)
List<String> defaultMusicFolders() {
  final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
  return [
    if (Platform.isAndroid) '/storage/emulated/0/Music',
    if (Platform.isAndroid) '/storage/emulated/0/Download',
    if (home != null && !Platform.isAndroid) '$home/Music',
  ];
}
