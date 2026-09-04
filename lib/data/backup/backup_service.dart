// lib/data/backup/backup_service.dart
// Aura — Full backup and restore.
//
// A backup captures what the user built, never the audio files: playlists,
// favourites, per-track stats (play/skip counts, rating, last played) and
// settings. Same scope Musicolet's backup carries, and the same explicit
// promise — your music library on disk is untouched.
//
// Everything keys on FILE PATH, not the database UUID. A track's id is
// regenerated on every rescan, so a UUID-keyed backup would fail to reconnect
// to anything after a reinstall; the file path is stable for the same file on
// the same device. Restore resolves each path back to whatever id the track
// currently has, and silently skips anything no longer present.

import 'dart:convert';
import 'dart:io';

import '../../domain/entities/playlist.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/music_repository.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../repositories/settings_repository.dart';
import '../settings/app_settings.dart';

/// Bumped when the archive shape changes incompatibly.
const int kBackupVersion = 1;

/// What a restore managed to do — surfaced so the UI can be honest about
/// anything that couldn't be reconnected.
class RestoreResult {
  const RestoreResult({
    required this.playlistsRestored,
    required this.tracksReconnected,
    required this.tracksMissing,
    required this.settingsRestored,
  });

  final int playlistsRestored;

  /// Backed-up tracks (across stats + playlists) matched to a current track.
  final int tracksReconnected;

  /// Backed-up file paths no longer in the library.
  final int tracksMissing;

  final bool settingsRestored;
}

class BackupService {
  BackupService({
    required MusicRepository musicRepository,
    required PlaylistRepository playlistRepository,
    required SettingsRepository settingsRepository,
  })  : _music = musicRepository,
        _playlists = playlistRepository,
        _settings = settingsRepository;

  final MusicRepository _music;
  final PlaylistRepository _playlists;
  final SettingsRepository _settings;

  // ── Export ─────────────────────────────────────────────────────────────────

  /// Builds the backup archive as a JSON-encodable map.
  Future<Map<String, dynamic>> buildArchive() async {
    final tracks = await _music.getAllTracks();
    final byId = {for (final t in tracks) t.id: t};

    // Per-track stats worth keeping: anything the user's listening produced.
    final trackStats = <Map<String, dynamic>>[
      for (final t in tracks)
        if (t.rating > 0 ||
            t.playCount > 0 ||
            t.skipCount > 0 ||
            t.lastPlayedMs != null)
          {
            'path': t.filePath,
            'title': t.title,
            'artist': t.artistName,
            'rating': t.rating,
            'playCount': t.playCount,
            'skipCount': t.skipCount,
            'lastPlayedMs': t.lastPlayedMs,
          },
    ];

    // User playlists as ordered lists of file paths, so restore survives a
    // rescan. Smart mixes are regenerated, not backed up.
    final playlists = <Map<String, dynamic>>[];
    for (final playlist in await _playlists.getAllPlaylists()) {
      if (playlist.type != PlaylistType.userCreated) continue;
      playlists.add({
        'name': playlist.name,
        'description': playlist.description,
        'trackPaths': [
          for (final id in playlist.trackIds)
            if (byId.containsKey(id)) byId[id]!.filePath,
        ],
      });
    }

    return {
      'version': kBackupVersion,
      'createdAtMs': DateTime.now().millisecondsSinceEpoch,
      'settings': (await _settings.load()).toJson(),
      'trackStats': trackStats,
      'playlists': playlists,
    };
  }

  /// Writes the archive to [path] as pretty JSON.
  Future<void> exportToFile(String path) async {
    final archive = await buildArchive();
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(archive));
  }

  // ── Import ─────────────────────────────────────────────────────────────────

  /// Restores from an archive map. Additive: it re-applies stats and recreates
  /// playlists, and never deletes anything already present.
  Future<RestoreResult> restoreArchive(Map<String, dynamic> archive) async {
    final version = archive['version'];
    if (version is int && version > kBackupVersion) {
      throw FormatException('Backup is from a newer version of Aura (v$version)');
    }

    // Resolve every path in the library once.
    final library = await _music.getAllTracks();
    final byPath = <String, Track>{for (final t in library) t.filePath: t};

    var reconnected = 0;
    var missing = 0;

    // Stats.
    final stats = archive['trackStats'];
    if (stats is List) {
      for (final entry in stats) {
        if (entry is! Map) continue;
        final path = entry['path'];
        if (path is! String) continue;
        final track = byPath[path];
        if (track == null) {
          missing++;
          continue;
        }
        reconnected++;
        await _music.applyBackupStats(
          track.id,
          rating: _asInt(entry['rating']),
          playCount: _asInt(entry['playCount']),
          skipCount: _asInt(entry['skipCount']),
          lastPlayedMs: _asInt(entry['lastPlayedMs']),
        );
      }
    }

    // Playlists.
    var playlistsRestored = 0;
    final playlists = archive['playlists'];
    if (playlists is List) {
      for (final entry in playlists) {
        if (entry is! Map) continue;
        final name = entry['name'];
        if (name is! String) continue;
        final paths = entry['trackPaths'];
        final ids = <String>[];
        if (paths is List) {
          for (final path in paths) {
            if (path is! String) continue;
            final track = byPath[path];
            if (track != null) {
              ids.add(track.id);
            } else {
              missing++;
            }
          }
        }
        final created = await _playlists.createPlaylist(
          name: name,
          description: entry['description'] is String
              ? entry['description'] as String
              : '',
        );
        if (ids.isNotEmpty) await _playlists.addTracks(created.id, ids);
        playlistsRestored++;
      }
    }

    // Settings.
    var settingsRestored = false;
    final settings = archive['settings'];
    if (settings is Map) {
      await _settings
          .save(AppSettings.fromJson(Map<String, dynamic>.from(settings)));
      settingsRestored = true;
    }

    return RestoreResult(
      playlistsRestored: playlistsRestored,
      tracksReconnected: reconnected,
      tracksMissing: missing,
      settingsRestored: settingsRestored,
    );
  }

  /// Restores from a file. Throws [FormatException] when the file is not an
  /// Aura backup.
  Future<RestoreResult> restoreFromFile(String path) async {
    final raw = await File(path).readAsString();
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      throw const FormatException('Not a valid Aura backup file');
    }
    if (decoded is! Map || decoded['version'] == null) {
      throw const FormatException('Not a valid Aura backup file');
    }
    return restoreArchive(Map<String, dynamic>.from(decoded));
  }

  static int? _asInt(Object? v) =>
      v is int ? v : (v is num ? v.toInt() : null);
}
