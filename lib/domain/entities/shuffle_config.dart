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
    /// How much to boost tracks the user rates highly or plays often.
    /// 0.0 = ignore ratings, 1.0 = strong bias toward favourites.
    @Default(0.4) double favouriteBias,

    /// How aggressively to push recently-played tracks toward the end.
    /// 0.0 = no avoidance, 1.0 = maximum avoidance.
    @Default(0.5) double recencyAvoidance,

    /// Probability of drawing from the least-played tracks, so unplayed music
    /// eventually gets heard. 0.0 = never, 1.0 = always.
    @Default(0.3) double discovery,

    /// Minimum number of tracks between plays of the same artist.
    /// Range 0–5 in the UI; larger values are accepted for big libraries.
    @Default(kDefaultArtistSpacing) int artistSpacing,

    /// Minimum number of tracks between plays from the same album.
    @Default(5) int albumSpacing,

    /// Bias the queue toward tracks with a similar mood to the seed track.
    /// Requires audio features (populated by the C++ analyzer).
    @Default(false) bool moodMatching,

    /// How strongly [moodMatching] applies. 0.0 = off, 1.0 = dominant.
    @Default(0.5) double moodStrength,

    /// Order adjacent tracks so tempo/energy flow smoothly.
    /// Reserved — not yet applied to ordering (see IntelliShuffleEngine).
    @Default(false) bool smoothTransitions,

    /// Optional seed for deterministic shuffles (tests; null = random).
    int? seed,
  }) = _ShuffleConfig;

  factory ShuffleConfig.fromJson(Map<String, dynamic> json) =>
      _$ShuffleConfigFromJson(json);

  /// Sensible defaults matching PRD §6.3 mid-range slider positions.
  static const ShuffleConfig defaults = ShuffleConfig();
}
