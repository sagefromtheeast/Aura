// lib/data/scanner/metadata_extractor.dart
// Aura — Reads embedded tags from an audio file.
//
// Primary path: `flutter_media_metadata` (ID3 / Vorbis / MP4 atoms).
// Fallback: parse the filename ("01 - Artist - Title.flac" and friends) so a
// file with no tags still lands in the library with something readable.

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:path/path.dart' as p;

import 'raw_track.dart';

/// Tags read from one file, plus any embedded artwork bytes.
class ExtractedMetadata {
  const ExtractedMetadata({required this.track, this.artworkBytes});

  final RawTrack track;
  final Uint8List? artworkBytes;
}

class MetadataExtractor {
  const MetadataExtractor();

  /// Enriches [raw] with embedded tags. Never throws — a file that cannot be
  /// parsed falls back to filename heuristics.
  Future<ExtractedMetadata> extract(RawTrack raw) async {
    Metadata? meta;
    try {
      meta = await MetadataRetriever.fromFile(File(raw.filePath));
    } catch (e) {
      debugPrint('MetadataExtractor: tag read failed for ${raw.filePath} ($e)');
    }

    final fromName = _parseFilename(raw.filePath);

    String? pick(String? tag, String? fallback) {
      final t = tag?.trim();
      if (t != null && t.isNotEmpty) return t;
      final f = fallback?.trim();
      return (f != null && f.isNotEmpty) ? f : null;
    }

    final artists = meta?.trackArtistNames;
    final tagArtist =
        (artists != null && artists.isNotEmpty) ? artists.join(', ') : null;

    final enriched = raw.copyWith(
      title: pick(meta?.trackName, raw.title ?? fromName.title),
      artist: pick(tagArtist, raw.artist ?? fromName.artist),
      albumArtist: pick(meta?.albumArtistName, raw.albumArtist),
      album: pick(meta?.albumName, raw.album),
      trackNumber: meta?.trackNumber ?? raw.trackNumber ?? fromName.trackNumber,
      discNumber: meta?.discNumber ?? raw.discNumber,
      year: meta?.year ?? raw.year,
      genre: pick(meta?.genre, raw.genre),
      durationMs: (meta?.trackDuration != null && meta!.trackDuration! > 0)
          ? meta.trackDuration
          : raw.durationMs,
      bitrate: _toKbps(meta?.bitrate) ?? raw.bitrate,
    );

    return ExtractedMetadata(
      track: enriched,
      artworkBytes: meta?.albumArt,
    );
  }

  /// flutter_media_metadata reports bits-per-second; the schema stores kbps.
  static int? _toKbps(int? bitsPerSecond) {
    if (bitsPerSecond == null || bitsPerSecond <= 0) return null;
    return bitsPerSecond > 10000 ? bitsPerSecond ~/ 1000 : bitsPerSecond;
  }

  /// Best-effort title/artist/track-number recovery from the file name.
  ///
  /// Handles the common shapes:
  ///   `05 - Artist - Title.mp3`
  ///   `05. Title.mp3`
  ///   `Artist - Title.flac`
  ///   `Title.opus`
  static _NameParts _parseFilename(String path) {
    var name = p.basenameWithoutExtension(path).trim();
    if (name.isEmpty) return const _NameParts();

    int? trackNumber;
    // Leading track number: "05 - ", "05. ", "05_"
    final numMatch = RegExp(r'^(\d{1,3})\s*[-._)]\s*').firstMatch(name);
    if (numMatch != null) {
      trackNumber = int.tryParse(numMatch.group(1)!);
      name = name.substring(numMatch.end).trim();
    }

    final parts = name.split(RegExp(r'\s+-\s+'));
    if (parts.length >= 2) {
      return _NameParts(
        artist: parts.first.trim(),
        title: parts.sublist(1).join(' - ').trim(),
        trackNumber: trackNumber,
      );
    }
    return _NameParts(title: name, trackNumber: trackNumber);
  }
}

class _NameParts {
  const _NameParts({this.title, this.artist, this.trackNumber});
  final String? title;
  final String? artist;
  final int? trackNumber;
}
