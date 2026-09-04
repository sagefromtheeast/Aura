// lib/data/repositories/local_playlist_repository.dart
// Aura — LocalPlaylistRepository

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../domain/duplicate_detector/duplicate_detector.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../database/app_database.dart';
import '../playlists/m3u.dart';
import 'track_mapper.dart';

class LocalPlaylistRepository implements PlaylistRepository {
  LocalPlaylistRepository({
    required AppDatabase database,
    DuplicateScanner? duplicateScanner,
  })  : _db = database,
        // Playlist duplicates are a metadata question — two files of one
        // recording — so the scanner never fingerprints and is given a
        // fingerprinter that always declines.
        _duplicates = duplicateScanner ??
            DuplicateScanner(audioFingerprinter: _noFingerprint);

  final AppDatabase _db;
  final DuplicateScanner _duplicates;
  final _uuid = const Uuid();

  static Future<List<int>?> _noFingerprint(String _) async => null;

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
          coverArtPathsJson: Value(jsonEncode(updated.coverArtPaths)),
          isPinned: Value(updated.isPinned),
        ),
      );

  @override
  Future<void> deletePlaylist(String id) =>
      _db.playlistDao.deletePlaylist(id);

  @override
  Future<void> renamePlaylist(String id, String newName) =>
      _db.playlistDao.renamePlaylist(id, newName);

  @override
  Future<bool> addTrack(String playlistId, String trackId) =>
      _db.playlistDao.addTrack(playlistId, trackId);

  @override
  Future<int> addTracks(String playlistId, List<String> trackIds) =>
      _db.playlistDao.addTracks(playlistId, trackIds);

  @override
  Future<void> removeTrack(String playlistId, String trackId) =>
      _db.playlistDao.removeTrack(playlistId, trackId);

  @override
  Future<void> removeTracks(String playlistId, List<String> trackIds) =>
      _db.playlistDao.removeTracks(playlistId, trackIds);

  @override
  Future<int> getPlaylistTrackCount(String playlistId) =>
      _db.playlistDao.getTrackCount(playlistId);

  @override
  Future<List<Track>> getPlaylistTracks(String playlistId) async {
    final ids = await _db.playlistDao.getTrackIds(playlistId);
    if (ids.isEmpty) return const [];

    // One query for the whole playlist, then reordered in Dart — the rows come
    // back in whatever order SQLite likes, and playlist order is the point.
    final rows = await _db.trackDao.getTracksByIds(ids);
    final byId = {for (final row in rows) row.id: trackFromRow(row)};
    return [
      for (final id in ids)
        if (byId.containsKey(id)) byId[id]!,
    ];
  }

  // ── Duplicates ─────────────────────────────────────────────────────────────

  @override
  Future<List<Track>> getDuplicateTracks(String playlistId) async {
    final tracks = await getPlaylistTracks(playlistId);
    if (tracks.length < 2) return const [];

    // Metadata layers only: fingerprinting would decode every file in the
    // playlist, which is not what a "tidy this playlist" action should do.
    final groups = await _duplicates.scan(
      tracks,
      level: DuplicateDetectionLevel.fuzzy,
    );

    // The keeper is the FIRST occurrence in playlist order, not the
    // best-quality copy the scanner ranks first — a playlist is a sequence the
    // user built, so the copy they placed earliest is the one they meant.
    final position = {
      for (var i = 0; i < tracks.length; i++) tracks[i].id: i,
    };

    final redundant = <Track>[];
    for (final group in groups) {
      final ordered = group.tracks.toList()
        ..sort((a, b) => position[a.id]!.compareTo(position[b.id]!));
      redundant.addAll(ordered.skip(1));
    }

    redundant.sort((a, b) => position[a.id]!.compareTo(position[b.id]!));
    return redundant;
  }

  @override
  Future<int> removeDuplicates(String playlistId) async {
    final redundant = await getDuplicateTracks(playlistId);
    if (redundant.isEmpty) return 0;

    // Removed from the playlist only. The files and their listening history
    // are untouched — this is not the library-wide duplicate resolver.
    await removeTracks(playlistId, redundant.map((t) => t.id).toList());
    return redundant.length;
  }

  // ── M3U ────────────────────────────────────────────────────────────────────

  @override
  Future<M3uImportResult> importM3u(
    String filePath, {
    String? playlistName,
  }) async {
    final file = File(filePath);
    final content = await file.readAsString();
    final entries = parseM3u(content);

    final name = playlistName ??
        _playlistDirective(content) ??
        p.basenameWithoutExtension(filePath);
    final playlist = await createPlaylist(name: name);

    // Relative paths in an M3U are relative to the file itself.
    final baseDir = p.dirname(p.absolute(filePath));
    final index = await _MatchIndex.build(_db, _duplicates);

    final matched = <String>[];
    final unmatched = <String>[];
    for (final entry in entries) {
      final trackId = index.resolve(entry, baseDir);
      if (trackId == null) {
        unmatched.add(entry.path);
      } else {
        matched.add(trackId);
      }
    }

    final imported = await addTracks(playlist.id, matched);

    return M3uImportResult(
      playlist: (await getPlaylistById(playlist.id))!,
      imported: imported,
      unmatched: unmatched,
    );
  }

  @override
  Future<void> exportM3u(String playlistId, String outputPath) async {
    final playlist = await getPlaylistById(playlistId);
    if (playlist == null) {
      throw ArgumentError.value(playlistId, 'playlistId', 'no such playlist');
    }
    final tracks = await getPlaylistTracks(playlistId);

    final content = writeM3u(
      [
        for (final track in tracks)
          M3uEntry(
            path: track.filePath,
            title: track.title,
            artist: track.artistName,
            // M3U counts in whole seconds.
            durationSeconds: (track.durationMs / 1000).round(),
          ),
      ],
      playlistName: playlist.name,
    );

    final file = File(outputPath);
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }

  /// `#PLAYLIST:Name` names the playlist inside the file itself.
  static String? _playlistDirective(String content) {
    for (final line in const LineSplitter().convert(content)) {
      final trimmed = line.trim();
      if (!trimmed.toUpperCase().startsWith('#PLAYLIST:')) continue;
      final name = trimmed.substring('#PLAYLIST:'.length).trim();
      if (name.isNotEmpty) return name;
    }
    return null;
  }

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
        coverArtPath: Value(playlist.coverArtPath),
        coverArtPathsJson: Value(jsonEncode(playlist.coverArtPaths)),
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
      coverArtPaths: _decodeCoverPaths(row.coverArtPathsJson),
      isPinned: row.isPinned,
    );
  }

  /// Cover paths are stored as a JSON array; a malformed value degrades to
  /// "no mosaic" rather than failing the whole playlist load.
  static List<String> _decodeCoverPaths(String json) {
    if (json.isEmpty) return const [];
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      // fall through
    }
    return const [];
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Lookup tables for resolving M3U entries to library tracks.
///
/// Built once per import: the whole library is scanned into three maps, so
/// matching a thousand-line playlist stays a thousand hash lookups rather than
/// a thousand queries.
class _MatchIndex {
  _MatchIndex._(
    this._scanner,
    this._byPath,
    this._byBasename,
    this._byMetadata,
  );

  /// Shared with the duplicate detector so "the same track" is defined once.
  final DuplicateScanner _scanner;

  /// Absolute file path (normalised) → track id.
  final Map<String, String> _byPath;

  /// Filename alone → track id. Only used when it is unambiguous.
  final Map<String, String?> _byBasename;

  /// Normalised "title|artist|durationBucket" → track id.
  final Map<String, String> _byMetadata;

  static Future<_MatchIndex> build(
      AppDatabase db, DuplicateScanner scanner) async {
    final rows = await db.trackDao.getAllTracks();

    final byPath = <String, String>{};
    final byBasename = <String, String?>{};
    final byMetadata = <String, String>{};

    for (final row in rows) {
      byPath[_normalisePath(row.filePath)] = row.id;

      final base = p.basename(row.filePath).toLowerCase();
      // Two tracks with the same filename in different folders make the
      // basename useless as an identifier; null marks it ambiguous.
      byBasename[base] = byBasename.containsKey(base) ? null : row.id;

      // The same normalisation the duplicate detector uses, so "the same
      // track" means one thing across the app.
      final key = '${scanner.normaliseTitle(row.title)}|'
          '${scanner.normaliseArtist(row.artistName)}|'
          '${scanner.durationBucket(row.durationMs)}';
      byMetadata.putIfAbsent(key, () => row.id);
    }

    return _MatchIndex._(scanner, byPath, byBasename, byMetadata);
  }

  /// Resolves one entry to a track id, or null when nothing matches.
  ///
  /// Order matters: a path is unambiguous evidence, a basename is weaker, and
  /// metadata is the last resort. Guessing wrong is worse than reporting the
  /// entry as unmatched, so there is no fuzzy step.
  String? resolve(M3uEntry entry, String baseDir) {
    final raw = entry.path;

    // Some exporters write file:// URIs.
    final path = raw.startsWith('file://') ? Uri.parse(raw).toFilePath() : raw;

    // Windows-style separators, on a playlist written elsewhere.
    final unified = path.replaceAll('\\', '/');

    final absolute =
        p.isAbsolute(unified) ? unified : p.join(baseDir, unified);
    final byPath = _byPath[_normalisePath(absolute)];
    if (byPath != null) return byPath;

    // The library may hold the same file under a different root — a moved
    // music folder, or an SD card mounted at a new path.
    final basename = p.basename(unified).toLowerCase();
    final byBasename = _byBasename[basename];
    if (byBasename != null) return byBasename;

    if (entry.title == null) return null;
    final key = '${_scanner.normaliseTitle(entry.title!)}|'
        '${_scanner.normaliseArtist(entry.artist ?? '')}|'
        '${_scanner.durationBucket(entry.durationMs ?? -1)}';
    return _byMetadata[key];
  }

  static String _normalisePath(String path) =>
      p.normalize(path).replaceAll('\\', '/').toLowerCase();
}
