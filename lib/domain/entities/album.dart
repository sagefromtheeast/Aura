// lib/domain/entities/album.dart
// Aura — Album entity (freezed, immutable).

import 'package:freezed_annotation/freezed_annotation.dart';

part 'album.freezed.dart';
part 'album.g.dart';

@freezed
class Album with _$Album {
  const factory Album({
    /// Unique identifier (UUID v4).
    required String id,

    /// Album title from metadata.
    required String title,

    /// FK → Artist.id (primary/album artist).
    required String artistId,

    /// Artist name (denormalised for display).
    required String artistName,

    /// Release year (0 = unknown).
    @Default(0) int year,

    /// Absolute path to cover art image. null if not found.
    String? coverArtPath,

    /// Total number of tracks in this album (count from DB).
    @Default(0) int trackCount,

    /// Total duration of all tracks in milliseconds.
    @Default(0) int totalDurationMs,

    /// Genre from the majority of tracks.
    @Default('') String genre,

    /// Timestamp when first track was added (epoch ms).
    required int dateAddedMs,
  }) = _Album;

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);
}
