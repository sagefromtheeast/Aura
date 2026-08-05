// lib/domain/entities/track.dart
// Aura — Track entity (immutable, freezed).
// PRD §6.1: supports MP3, AAC, FLAC, ALAC, DSD, WAV formats.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'track.freezed.dart';
part 'track.g.dart';

/// Audio format enum matching supported codec types (PRD §6.1).
enum AudioFormat { mp3, aac, flac, alac, dsd, wav, ogg, opus, unknown }

/// Core track entity. All music library items are represented as [Track].
///
/// Immutability enforced by freezed — any "modification" returns a new copy
/// via [copyWith], keeping state predictable in Riverpod providers.
@freezed
class Track with _$Track {
  const factory Track({
    /// Unique identifier (UUID v4, assigned at scan time).
    required String id,

    /// Track title from ID3/FLAC/AAC metadata.
    required String title,

    /// Artist display name (denormalised for fast display).
    required String artistName,

    /// Album title (denormalised for fast display).
    required String albumTitle,

    /// FK → Artist.id in the database.
    required String artistId,

    /// FK → Album.id in the database.
    required String albumId,

    /// Track duration in milliseconds (from audio container header).
    required int durationMs,

    /// Absolute file path on the device.
    required String filePath,

    /// File size in bytes (used for duplicate detection).
    required int fileSizeBytes,

    /// Detected audio format.
    @Default(AudioFormat.unknown) AudioFormat format,

    /// Bit rate in kbps (0 if unknown / lossless).
    @Default(0) int bitRateKbps,

    /// Sample rate in Hz.
    @Default(44100) int sampleRateHz,

    /// Number of times this track has been played to completion (≥80% played).
    /// PRD §6.5: used in statistics dashboard.
    @Default(0) int playCount,

    /// Number of times the user skipped this track.
    @Default(0) int skipCount,

    /// User rating 0–5 (0 = unrated). Used in IntelliShuffle scoring.
    @Default(0) int rating,

    /// Timestamp when the track was added to the library (epoch ms).
    required int dateAddedMs,

    /// Timestamp of last playback (epoch ms). null if never played.
    int? lastPlayedMs,

    /// Whether the file has been deleted from disk (soft-delete for stats).
    @Default(false) bool isDeleted,

    /// Optional path to extracted album art (may share with album).
    String? coverArtPath,

    /// Track number within the album (1-based, 0 = unknown).
    @Default(0) int trackNumber,

    /// Disc number (for multi-disc albums).
    @Default(1) int discNumber,

    /// Genre string from metadata (may be empty).
    @Default('') String genre,

    /// Year of release (0 = unknown).
    @Default(0) int year,
  }) = _Track;

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);
}
