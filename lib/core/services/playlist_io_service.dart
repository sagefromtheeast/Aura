// lib/core/services/playlist_io_service.dart
// Aura — M3U / M3U8 Playlist Import & Export Service.
// Complies with PRD §6.2: interoperability with desktop audiophile music library managers.

import 'dart:convert';
import 'dart:io';
import '../../domain/entities/track.dart';

/// Represents a parsed track entry from an M3U or M3U8 playlist file.
class M3uEntry {
  const M3uEntry({
    required this.durationSeconds,
    required this.displayTitle,
    required this.filePath,
  });

  /// Duration in seconds extracted from `#EXTINF:seconds,Title`.
  final int durationSeconds;

  /// Display title extracted from `#EXTINF` header (often `Artist - Title`).
  final String displayTitle;

  /// Local filesystem path or URI pointing to the audio recording.
  final String filePath;
}

/// Service class responsible for serializing Aura playlists and AI Smart Mixes
/// into standard UTF-8 `.m3u8` formatted files and parsing imported playlists.
class PlaylistIoService {
  /// Generates the UTF-8 `.m3u8` string representation for a collection of [tracks].
  static String exportToM3u8({
    required String playlistName,
    required List<Track> tracks,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('#EXTM3U');
    buffer.writeln('#EXTPLAYLIST:$playlistName');

    for (final track in tracks) {
      final int durationSec = track.durationMs ~/ 1000;
      final String display = '${track.artistName} - ${track.title}';
      buffer.writeln('#EXTINF:$durationSec,$display');
      buffer.writeln(track.filePath);
    }

    return buffer.toString();
  }

  /// Parses the textual content of an `.m3u` or `.m3u8` playlist file into structured [M3uEntry] objects.
  static List<M3uEntry> parseM3u8(String m3uContent) {
    final List<M3uEntry> entries = [];
    final lines = LineSplitter.split(m3uContent).map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    int lastDuration = -1;
    String lastTitle = 'Unknown Track';

    for (final line in lines) {
      if (line.startsWith('#EXTINF:')) {
        // Parse format: #EXTINF:123,Artist - Title or #EXTINF:-1,Stream
        final payload = line.substring(8);
        final commaIdx = payload.indexOf(',');
        if (commaIdx != -1) {
          final durStr = payload.substring(0, commaIdx).trim();
          lastDuration = int.tryParse(durStr) ?? -1;
          lastTitle = payload.substring(commaIdx + 1).trim();
        } else {
          lastDuration = int.tryParse(payload) ?? -1;
          lastTitle = 'Unknown Track';
        }
      } else if (!line.startsWith('#')) {
        // This line is a file path or URL
        entries.add(M3uEntry(
          durationSeconds: lastDuration,
          displayTitle: lastTitle,
          filePath: line,
        ));
        // Reset defaults for next file
        lastDuration = -1;
        lastTitle = 'Unknown Track';
      }
    }

    return entries;
  }

  /// Writes an `.m3u8` file into the target [directory].
  static Future<File> writePlaylistFile({
    required Directory directory,
    required String playlistName,
    required List<Track> tracks,
  }) async {
    final sanitizedName = playlistName.replaceAll(RegExp(r'[^\w\s-]'), '_').trim();
    final file = File('${directory.path}/$sanitizedName.m3u8');
    final content = exportToM3u8(playlistName: playlistName, tracks: tracks);
    return await file.writeAsString(content, encoding: utf8);
  }

  /// Reads an `.m3u` or `.m3u8` file from disk and parses its entries.
  static Future<List<M3uEntry>> readPlaylistFile(File file) async {
    if (!await file.exists()) {
      throw FileSystemException('Playlist file does not exist at path', file.path);
    }
    final content = await file.readAsString(encoding: utf8);
    return parseM3u8(content);
  }

  /// Resolves parsed [M3uEntry] items against the available local [allTracks] catalog.
  /// Matches first by identical file path, then fallbacks to normalized artist/title string matching.
  static List<Track> resolveTracks(List<M3uEntry> entries, List<Track> allTracks) {
    final List<Track> resolved = [];
    final pathMap = <String, Track>{
      for (final t in allTracks) t.filePath.toLowerCase().trim(): t,
    };

    for (final entry in entries) {
      final normalizedPath = entry.filePath.toLowerCase().trim();
      if (pathMap.containsKey(normalizedPath)) {
        resolved.add(pathMap[normalizedPath]!);
        continue;
      }

      // Fallback matching: check if track title appears inside displayTitle
      for (final track in allTracks) {
        final normDisplay = entry.displayTitle.toLowerCase();
        if (normDisplay.contains(track.title.toLowerCase()) &&
            normDisplay.contains(track.artistName.toLowerCase())) {
          resolved.add(track);
          break;
        }
      }
    }

    return resolved;
  }
}
