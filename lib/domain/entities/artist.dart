// lib/domain/entities/artist.dart
// Aura — Artist entity (freezed, immutable).

import 'package:freezed_annotation/freezed_annotation.dart';

part 'artist.freezed.dart';
part 'artist.g.dart';

@freezed
class Artist with _$Artist {
  const factory Artist({
    /// Unique identifier (UUID v4).
    required String id,

    /// Artist name from metadata (normalised: trimmed, de-duped case).
    required String name,

    /// Number of tracks by this artist in the library.
    @Default(0) int trackCount,

    /// Number of distinct albums by this artist.
    @Default(0) int albumCount,

    /// Path to artist image (from embedded cover art or online cache — future).
    String? imagePath,
  }) = _Artist;

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);
}
