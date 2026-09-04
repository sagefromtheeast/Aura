// lib/data/playlists/m3u.dart
// Aura — M3U / M3U8 parsing and serialisation.
//
// Kept free of dart:io so the format itself can be tested without touching the
// filesystem; the repository owns reading and writing the bytes.
//
// The format is barely a format: a list of paths, optionally annotated with
// `#EXTINF:<seconds>,<artist> - <title>` lines. Everything here is written to
// survive the variations real exporters produce — CRLF endings, a missing
// `#EXTM3U` header, Windows separators, blank lines, and `#EXTINF` metadata
// that is either "Artist - Title" or just a title.

import 'dart:convert';

/// One entry from an M3U file.
class M3uEntry {
  const M3uEntry({
    required this.path,
    this.title,
    this.artist,
    this.durationSeconds,
  });

  /// The path exactly as written in the file — absolute, relative, or a URI.
  final String path;

  /// Title from the preceding `#EXTINF`, if there was one.
  final String? title;

  /// Artist from the preceding `#EXTINF`, if it carried "Artist - Title".
  final String? artist;

  /// Duration in seconds from `#EXTINF`; -1 in the file means "unknown" and
  /// arrives here as null.
  final int? durationSeconds;

  int? get durationMs =>
      durationSeconds == null ? null : durationSeconds! * 1000;

  bool get hasMetadata => title != null || artist != null;
}

/// Parses M3U/M3U8 [content] into entries, in file order.
///
/// Unparseable lines are skipped rather than throwing: a playlist with one bad
/// line should still import the other ninety-nine.
List<M3uEntry> parseM3u(String content) {
  final entries = <M3uEntry>[];

  String? pendingTitle;
  String? pendingArtist;
  int? pendingDuration;

  // Split on either ending; exporters on Windows write CRLF.
  for (final rawLine in const LineSplitter().convert(content)) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;

    if (line.startsWith('#')) {
      if (line.toUpperCase().startsWith('#EXTINF:')) {
        final info = _parseExtInf(line);
        pendingDuration = info.durationSeconds;
        pendingArtist = info.artist;
        pendingTitle = info.title;
      }
      // Every other directive (#EXTM3U, #PLAYLIST, #EXTGRP, comments) carries
      // nothing we need.
      continue;
    }

    entries.add(M3uEntry(
      path: line,
      title: pendingTitle,
      artist: pendingArtist,
      durationSeconds: pendingDuration,
    ));

    // #EXTINF applies to the single path that follows it.
    pendingTitle = null;
    pendingArtist = null;
    pendingDuration = null;
  }

  return entries;
}

/// `#EXTINF:210,Frank Ocean - Nights`
({int? durationSeconds, String? artist, String? title}) _parseExtInf(
    String line) {
  final body = line.substring(line.indexOf(':') + 1);
  final comma = body.indexOf(',');
  if (comma < 0) {
    return (durationSeconds: _parseDuration(body), artist: null, title: null);
  }

  final duration = _parseDuration(body.substring(0, comma));
  final label = body.substring(comma + 1).trim();
  if (label.isEmpty) {
    return (durationSeconds: duration, artist: null, title: null);
  }

  // "Artist - Title" is the convention, but a title may itself contain " - ",
  // so split on the FIRST separator only and treat the rest as the title.
  final dash = label.indexOf(' - ');
  if (dash < 0) {
    return (durationSeconds: duration, artist: null, title: label);
  }
  final artist = label.substring(0, dash).trim();
  final title = label.substring(dash + 3).trim();
  if (artist.isEmpty || title.isEmpty) {
    return (durationSeconds: duration, artist: null, title: label);
  }
  return (durationSeconds: duration, artist: artist, title: title);
}

/// M3U writes -1 for an unknown duration; anything unparseable is also unknown.
int? _parseDuration(String raw) {
  final seconds = int.tryParse(raw.trim());
  if (seconds == null || seconds < 0) return null;
  return seconds;
}

/// Serialises [entries] as an extended M3U document.
///
/// Uses `\n` endings and UTF-8 (hence `.m3u8` for anything non-ASCII), and
/// always writes the `#EXTM3U` header plus one `#EXTINF` per entry so other
/// players show titles rather than filenames.
String writeM3u(List<M3uEntry> entries, {String? playlistName}) {
  final buffer = StringBuffer('#EXTM3U\n');
  if (playlistName != null && playlistName.isNotEmpty) {
    buffer.writeln('#PLAYLIST:$playlistName');
  }

  for (final entry in entries) {
    final seconds = entry.durationSeconds ?? -1;
    final label = [
      if (entry.artist != null && entry.artist!.isNotEmpty) entry.artist,
      if (entry.title != null && entry.title!.isNotEmpty) entry.title,
    ].join(' - ');
    buffer.writeln('#EXTINF:$seconds,$label');
    buffer.writeln(entry.path);
  }

  return buffer.toString();
}
