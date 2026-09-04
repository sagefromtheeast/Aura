// lib/data/scanner/raw_track.dart
// Aura — Platform-agnostic scan result for a single audio file.
//
// Produced by both the native scanner (MediaStore / MPMediaQuery) and the
// folder-scanning fallback, then enriched by MetadataExtractor before it is
// mapped into Drift companions by LibraryScanner.

import 'package:path/path.dart' as p;

import '../../core/constants.dart';

class RawTrack {
  const RawTrack({
    required this.filePath,
    this.title,
    this.artist,
    this.albumArtist,
    this.album,
    this.durationMs,
    this.sizeBytes,
    this.dateAddedMs,
    this.trackNumber,
    this.discNumber,
    this.year,
    this.genre,
    this.sampleRate,
    this.bitDepth,
    this.bitrate,
    this.nativeAlbumId,
    this.coverArtPath,
  });

  /// Absolute path (Android/folders) or asset URL (iOS MPMediaItem).
  final String filePath;

  final String? title;
  final String? artist;
  final String? albumArtist;
  final String? album;
  final int? durationMs;
  final int? sizeBytes;
  final int? dateAddedMs;
  final int? trackNumber;
  final int? discNumber;
  final int? year;
  final String? genre;
  final int? sampleRate;
  final int? bitDepth;
  final int? bitrate;

  /// MediaStore ALBUM_ID / MPMediaItem albumPersistentID, when supplied.
  final String? nativeAlbumId;

  /// Path to already-extracted cover art, if the platform provided one.
  final String? coverArtPath;

  /// Lower-case container extension without the dot (e.g. `flac`).
  String get extension {
    final ext = p.extension(filePath);
    if (ext.isEmpty) return '';
    return ext.substring(1).toLowerCase();
  }

  bool get isSupported => kSupportedAudioExtensions.contains(extension);

  /// True when the core tags are missing and metadata extraction is worthwhile.
  bool get needsMetadata =>
      (title == null || title!.trim().isEmpty) ||
      (artist == null || artist!.trim().isEmpty) ||
      (album == null || album!.trim().isEmpty) ||
      (durationMs == null || durationMs == 0);

  RawTrack copyWith({
    String? title,
    String? artist,
    String? albumArtist,
    String? album,
    int? durationMs,
    int? sizeBytes,
    int? dateAddedMs,
    int? trackNumber,
    int? discNumber,
    int? year,
    String? genre,
    int? sampleRate,
    int? bitDepth,
    int? bitrate,
    String? nativeAlbumId,
    String? coverArtPath,
  }) {
    return RawTrack(
      filePath: filePath,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      albumArtist: albumArtist ?? this.albumArtist,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      dateAddedMs: dateAddedMs ?? this.dateAddedMs,
      trackNumber: trackNumber ?? this.trackNumber,
      discNumber: discNumber ?? this.discNumber,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      sampleRate: sampleRate ?? this.sampleRate,
      bitDepth: bitDepth ?? this.bitDepth,
      bitrate: bitrate ?? this.bitrate,
      nativeAlbumId: nativeAlbumId ?? this.nativeAlbumId,
      coverArtPath: coverArtPath ?? this.coverArtPath,
    );
  }

  /// Parses one entry of the platform channel's `scanAllAudio` payload.
  /// Keys match MainActivity.kt (Android) and AppDelegate.swift (iOS).
  factory RawTrack.fromPlatformMap(Map<Object?, Object?> raw) {
    final map = raw.map((k, v) => MapEntry(k.toString(), v));
    int? asInt(Object? v) => v is int ? v : (v is num ? v.toInt() : null);
    String? asStr(Object? v) {
      final s = v?.toString().trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    return RawTrack(
      filePath: map['path']?.toString() ?? '',
      title: asStr(map['title']),
      artist: asStr(map['artist']),
      albumArtist: asStr(map['albumArtist']),
      album: asStr(map['album']),
      durationMs: asInt(map['duration']),
      sizeBytes: asInt(map['size']),
      dateAddedMs: asInt(map['dateAdded']),
      trackNumber: asInt(map['trackNumber']),
      discNumber: asInt(map['discNumber']),
      year: asInt(map['year']),
      genre: asStr(map['genre']),
      sampleRate: asInt(map['sampleRate']),
      bitDepth: asInt(map['bitDepth']),
      bitrate: asInt(map['bitrate']),
      nativeAlbumId: asStr(map['albumId']),
      coverArtPath: asStr(map['coverArtPath']),
    );
  }

  /// Serialisable form so results can cross an isolate boundary.
  Map<String, Object?> toMap() => {
        'path': filePath,
        'title': title,
        'artist': artist,
        'albumArtist': albumArtist,
        'album': album,
        'duration': durationMs,
        'size': sizeBytes,
        'dateAdded': dateAddedMs,
        'trackNumber': trackNumber,
        'discNumber': discNumber,
        'year': year,
        'genre': genre,
        'sampleRate': sampleRate,
        'bitDepth': bitDepth,
        'bitrate': bitrate,
        'albumId': nativeAlbumId,
        'coverArtPath': coverArtPath,
      };
}
