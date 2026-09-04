// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shuffle_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ShuffleConfig _$ShuffleConfigFromJson(Map<String, dynamic> json) {
  return _ShuffleConfig.fromJson(json);
}

/// @nodoc
mixin _$ShuffleConfig {
  /// How much to boost tracks the user rates highly or plays often.
  /// 0.0 = ignore ratings, 1.0 = strong bias toward favourites.
  double get favouriteBias => throw _privateConstructorUsedError;

  /// How aggressively to push recently-played tracks toward the end.
  /// 0.0 = no avoidance, 1.0 = maximum avoidance.
  double get recencyAvoidance => throw _privateConstructorUsedError;

  /// Probability of drawing from the least-played tracks, so unplayed music
  /// eventually gets heard. 0.0 = never, 1.0 = always.
  double get discovery => throw _privateConstructorUsedError;

  /// Minimum number of tracks between plays of the same artist.
  /// Range 0–5 in the UI; larger values are accepted for big libraries.
  int get artistSpacing => throw _privateConstructorUsedError;

  /// Minimum number of tracks between plays from the same album.
  int get albumSpacing => throw _privateConstructorUsedError;

  /// Bias the queue toward tracks with a similar mood to the seed track.
  /// Requires audio features (populated by the C++ analyzer).
  bool get moodMatching => throw _privateConstructorUsedError;

  /// How strongly [moodMatching] applies. 0.0 = off, 1.0 = dominant.
  double get moodStrength => throw _privateConstructorUsedError;

  /// Order adjacent tracks so tempo/energy flow smoothly.
  /// Reserved — not yet applied to ordering (see IntelliShuffleEngine).
  bool get smoothTransitions => throw _privateConstructorUsedError;

  /// Optional seed for deterministic shuffles (tests; null = random).
  int? get seed => throw _privateConstructorUsedError;

  /// Serializes this ShuffleConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShuffleConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShuffleConfigCopyWith<ShuffleConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShuffleConfigCopyWith<$Res> {
  factory $ShuffleConfigCopyWith(
    ShuffleConfig value,
    $Res Function(ShuffleConfig) then,
  ) = _$ShuffleConfigCopyWithImpl<$Res, ShuffleConfig>;
  @useResult
  $Res call({
    double favouriteBias,
    double recencyAvoidance,
    double discovery,
    int artistSpacing,
    int albumSpacing,
    bool moodMatching,
    double moodStrength,
    bool smoothTransitions,
    int? seed,
  });
}

/// @nodoc
class _$ShuffleConfigCopyWithImpl<$Res, $Val extends ShuffleConfig>
    implements $ShuffleConfigCopyWith<$Res> {
  _$ShuffleConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShuffleConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? favouriteBias = null,
    Object? recencyAvoidance = null,
    Object? discovery = null,
    Object? artistSpacing = null,
    Object? albumSpacing = null,
    Object? moodMatching = null,
    Object? moodStrength = null,
    Object? smoothTransitions = null,
    Object? seed = freezed,
  }) {
    return _then(
      _value.copyWith(
            favouriteBias: null == favouriteBias
                ? _value.favouriteBias
                : favouriteBias // ignore: cast_nullable_to_non_nullable
                      as double,
            recencyAvoidance: null == recencyAvoidance
                ? _value.recencyAvoidance
                : recencyAvoidance // ignore: cast_nullable_to_non_nullable
                      as double,
            discovery: null == discovery
                ? _value.discovery
                : discovery // ignore: cast_nullable_to_non_nullable
                      as double,
            artistSpacing: null == artistSpacing
                ? _value.artistSpacing
                : artistSpacing // ignore: cast_nullable_to_non_nullable
                      as int,
            albumSpacing: null == albumSpacing
                ? _value.albumSpacing
                : albumSpacing // ignore: cast_nullable_to_non_nullable
                      as int,
            moodMatching: null == moodMatching
                ? _value.moodMatching
                : moodMatching // ignore: cast_nullable_to_non_nullable
                      as bool,
            moodStrength: null == moodStrength
                ? _value.moodStrength
                : moodStrength // ignore: cast_nullable_to_non_nullable
                      as double,
            smoothTransitions: null == smoothTransitions
                ? _value.smoothTransitions
                : smoothTransitions // ignore: cast_nullable_to_non_nullable
                      as bool,
            seed: freezed == seed
                ? _value.seed
                : seed // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShuffleConfigImplCopyWith<$Res>
    implements $ShuffleConfigCopyWith<$Res> {
  factory _$$ShuffleConfigImplCopyWith(
    _$ShuffleConfigImpl value,
    $Res Function(_$ShuffleConfigImpl) then,
  ) = __$$ShuffleConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double favouriteBias,
    double recencyAvoidance,
    double discovery,
    int artistSpacing,
    int albumSpacing,
    bool moodMatching,
    double moodStrength,
    bool smoothTransitions,
    int? seed,
  });
}

/// @nodoc
class __$$ShuffleConfigImplCopyWithImpl<$Res>
    extends _$ShuffleConfigCopyWithImpl<$Res, _$ShuffleConfigImpl>
    implements _$$ShuffleConfigImplCopyWith<$Res> {
  __$$ShuffleConfigImplCopyWithImpl(
    _$ShuffleConfigImpl _value,
    $Res Function(_$ShuffleConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShuffleConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? favouriteBias = null,
    Object? recencyAvoidance = null,
    Object? discovery = null,
    Object? artistSpacing = null,
    Object? albumSpacing = null,
    Object? moodMatching = null,
    Object? moodStrength = null,
    Object? smoothTransitions = null,
    Object? seed = freezed,
  }) {
    return _then(
      _$ShuffleConfigImpl(
        favouriteBias: null == favouriteBias
            ? _value.favouriteBias
            : favouriteBias // ignore: cast_nullable_to_non_nullable
                  as double,
        recencyAvoidance: null == recencyAvoidance
            ? _value.recencyAvoidance
            : recencyAvoidance // ignore: cast_nullable_to_non_nullable
                  as double,
        discovery: null == discovery
            ? _value.discovery
            : discovery // ignore: cast_nullable_to_non_nullable
                  as double,
        artistSpacing: null == artistSpacing
            ? _value.artistSpacing
            : artistSpacing // ignore: cast_nullable_to_non_nullable
                  as int,
        albumSpacing: null == albumSpacing
            ? _value.albumSpacing
            : albumSpacing // ignore: cast_nullable_to_non_nullable
                  as int,
        moodMatching: null == moodMatching
            ? _value.moodMatching
            : moodMatching // ignore: cast_nullable_to_non_nullable
                  as bool,
        moodStrength: null == moodStrength
            ? _value.moodStrength
            : moodStrength // ignore: cast_nullable_to_non_nullable
                  as double,
        smoothTransitions: null == smoothTransitions
            ? _value.smoothTransitions
            : smoothTransitions // ignore: cast_nullable_to_non_nullable
                  as bool,
        seed: freezed == seed
            ? _value.seed
            : seed // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShuffleConfigImpl implements _ShuffleConfig {
  const _$ShuffleConfigImpl({
    this.favouriteBias = 0.4,
    this.recencyAvoidance = 0.5,
    this.discovery = 0.3,
    this.artistSpacing = kDefaultArtistSpacing,
    this.albumSpacing = 5,
    this.moodMatching = false,
    this.moodStrength = 0.5,
    this.smoothTransitions = false,
    this.seed,
  });

  factory _$ShuffleConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShuffleConfigImplFromJson(json);

  /// How much to boost tracks the user rates highly or plays often.
  /// 0.0 = ignore ratings, 1.0 = strong bias toward favourites.
  @override
  @JsonKey()
  final double favouriteBias;

  /// How aggressively to push recently-played tracks toward the end.
  /// 0.0 = no avoidance, 1.0 = maximum avoidance.
  @override
  @JsonKey()
  final double recencyAvoidance;

  /// Probability of drawing from the least-played tracks, so unplayed music
  /// eventually gets heard. 0.0 = never, 1.0 = always.
  @override
  @JsonKey()
  final double discovery;

  /// Minimum number of tracks between plays of the same artist.
  /// Range 0–5 in the UI; larger values are accepted for big libraries.
  @override
  @JsonKey()
  final int artistSpacing;

  /// Minimum number of tracks between plays from the same album.
  @override
  @JsonKey()
  final int albumSpacing;

  /// Bias the queue toward tracks with a similar mood to the seed track.
  /// Requires audio features (populated by the C++ analyzer).
  @override
  @JsonKey()
  final bool moodMatching;

  /// How strongly [moodMatching] applies. 0.0 = off, 1.0 = dominant.
  @override
  @JsonKey()
  final double moodStrength;

  /// Order adjacent tracks so tempo/energy flow smoothly.
  /// Reserved — not yet applied to ordering (see IntelliShuffleEngine).
  @override
  @JsonKey()
  final bool smoothTransitions;

  /// Optional seed for deterministic shuffles (tests; null = random).
  @override
  final int? seed;

  @override
  String toString() {
    return 'ShuffleConfig(favouriteBias: $favouriteBias, recencyAvoidance: $recencyAvoidance, discovery: $discovery, artistSpacing: $artistSpacing, albumSpacing: $albumSpacing, moodMatching: $moodMatching, moodStrength: $moodStrength, smoothTransitions: $smoothTransitions, seed: $seed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShuffleConfigImpl &&
            (identical(other.favouriteBias, favouriteBias) ||
                other.favouriteBias == favouriteBias) &&
            (identical(other.recencyAvoidance, recencyAvoidance) ||
                other.recencyAvoidance == recencyAvoidance) &&
            (identical(other.discovery, discovery) ||
                other.discovery == discovery) &&
            (identical(other.artistSpacing, artistSpacing) ||
                other.artistSpacing == artistSpacing) &&
            (identical(other.albumSpacing, albumSpacing) ||
                other.albumSpacing == albumSpacing) &&
            (identical(other.moodMatching, moodMatching) ||
                other.moodMatching == moodMatching) &&
            (identical(other.moodStrength, moodStrength) ||
                other.moodStrength == moodStrength) &&
            (identical(other.smoothTransitions, smoothTransitions) ||
                other.smoothTransitions == smoothTransitions) &&
            (identical(other.seed, seed) || other.seed == seed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    favouriteBias,
    recencyAvoidance,
    discovery,
    artistSpacing,
    albumSpacing,
    moodMatching,
    moodStrength,
    smoothTransitions,
    seed,
  );

  /// Create a copy of ShuffleConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShuffleConfigImplCopyWith<_$ShuffleConfigImpl> get copyWith =>
      __$$ShuffleConfigImplCopyWithImpl<_$ShuffleConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShuffleConfigImplToJson(this);
  }
}

abstract class _ShuffleConfig implements ShuffleConfig {
  const factory _ShuffleConfig({
    final double favouriteBias,
    final double recencyAvoidance,
    final double discovery,
    final int artistSpacing,
    final int albumSpacing,
    final bool moodMatching,
    final double moodStrength,
    final bool smoothTransitions,
    final int? seed,
  }) = _$ShuffleConfigImpl;

  factory _ShuffleConfig.fromJson(Map<String, dynamic> json) =
      _$ShuffleConfigImpl.fromJson;

  /// How much to boost tracks the user rates highly or plays often.
  /// 0.0 = ignore ratings, 1.0 = strong bias toward favourites.
  @override
  double get favouriteBias;

  /// How aggressively to push recently-played tracks toward the end.
  /// 0.0 = no avoidance, 1.0 = maximum avoidance.
  @override
  double get recencyAvoidance;

  /// Probability of drawing from the least-played tracks, so unplayed music
  /// eventually gets heard. 0.0 = never, 1.0 = always.
  @override
  double get discovery;

  /// Minimum number of tracks between plays of the same artist.
  /// Range 0–5 in the UI; larger values are accepted for big libraries.
  @override
  int get artistSpacing;

  /// Minimum number of tracks between plays from the same album.
  @override
  int get albumSpacing;

  /// Bias the queue toward tracks with a similar mood to the seed track.
  /// Requires audio features (populated by the C++ analyzer).
  @override
  bool get moodMatching;

  /// How strongly [moodMatching] applies. 0.0 = off, 1.0 = dominant.
  @override
  double get moodStrength;

  /// Order adjacent tracks so tempo/energy flow smoothly.
  /// Reserved — not yet applied to ordering (see IntelliShuffleEngine).
  @override
  bool get smoothTransitions;

  /// Optional seed for deterministic shuffles (tests; null = random).
  @override
  int? get seed;

  /// Create a copy of ShuffleConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShuffleConfigImplCopyWith<_$ShuffleConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
