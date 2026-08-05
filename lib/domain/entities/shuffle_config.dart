// lib/domain/entities/shuffle_config.dart
// Aura — ShuffleConfig entity (freezed, immutable).
// PRD §6.3: IntelliShuffle sliders map directly to these fields.

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/constants.dart';

part 'shuffle_config.freezed.dart';
part 'shuffle_config.g.dart';

@freezed
class ShuffleConfig with _$ShuffleConfig {
  const factory ShuffleConfig({
    /// Minimum number of tracks between plays of the same artist.
    /// Range: 0–10. PRD §6.3: "Artist spacing (0‑5 tracks)" — extended to 10
    /// for large libraries.
    @Default(kDefaultArtistSpacing) int artistSpacing,

    /// How aggressively to avoid recently-played tracks.
    /// 0.0 = no avoidance, 1.0 = maximum recency bias (λ in scoring formula).
    @Default(0.5) double recencyStrength,

    /// How much to boost tracks the user explicitly rated or frequently plays.
    /// 0.0 = ignore ratings, 1.0 = strong bias toward favourites.
    @Default(0.5) double favoriteBias,

    /// Fraction of the queue dedicated to tracks played <3 times (discovery).
    /// 0.0 = no discovery, 1.0 = all discovery tracks.
    @Default(0.15) double discoveryFraction,

    /// Optional seed for deterministic shuffle (used in tests; null = random).
    int? seed,
  }) = _ShuffleConfig;

  factory ShuffleConfig.fromJson(Map<String, dynamic> json) =>
      _$ShuffleConfigFromJson(json);

  /// Sensible defaults matching PRD §6.3 mid-range slider positions.
  static const ShuffleConfig defaults = ShuffleConfig();
}
