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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ShuffleConfig _$ShuffleConfigFromJson(Map<String, dynamic> json) {
  return _ShuffleConfig.fromJson(json);
}

/// @nodoc
mixin _$ShuffleConfig {
  /// Minimum number of tracks between plays of the same artist.
  /// Range: 0–10. PRD §6.3: "Artist spacing (0‑5 tracks)" — extended to 10
  /// for large libraries.
  int get artistSpacing => throw _privateConstructorUsedError;

  /// How aggressively to avoid recently-played tracks.
  /// 0.0 = no avoidance, 1.0 = maximum recency bias (λ in scoring formula).
  double get recencyStrength => throw _privateConstructorUsedError;

  /// How much to boost tracks the user explicitly rated or frequently plays.
  /// 0.0 = ignore ratings, 1.0 = strong bias toward favourites.
  double get favoriteBias => throw _privateConstructorUsedError;

  /// Fraction of the queue dedicated to tracks played <3 times (discovery).
  /// 0.0 = no discovery, 1.0 = all discovery tracks.
  double get discoveryFraction => throw _privateConstructorUsedError;

  /// Optional seed for deterministic shuffle (used in tests; null = random).
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
          ShuffleConfig value, $Res Function(ShuffleConfig) then) =
      _$ShuffleConfigCopyWithImpl<$Res, ShuffleConfig>;
  @useResult
  $Res call(
      {int artistSpacing,
      double recencyStrength,
      double favoriteBias,
      double discoveryFraction,
      int? seed});
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
    Object? artistSpacing = null,
    Object? recencyStrength = null,
    Object? favoriteBias = null,
    Object? discoveryFraction = null,
    Object? seed = freezed,
  }) {
    return _then(_value.copyWith(
      artistSpacing: null == artistSpacing
          ? _value.artistSpacing
          : artistSpacing // ignore: cast_nullable_to_non_nullable
              as int,
      recencyStrength: null == recencyStrength
          ? _value.recencyStrength
          : recencyStrength // ignore: cast_nullable_to_non_nullable
              as double,
      favoriteBias: null == favoriteBias
          ? _value.favoriteBias
          : favoriteBias // ignore: cast_nullable_to_non_nullable
              as double,
      discoveryFraction: null == discoveryFraction
          ? _value.discoveryFraction
          : discoveryFraction // ignore: cast_nullable_to_non_nullable
              as double,
      seed: freezed == seed
          ? _value.seed
          : seed // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShuffleConfigImplCopyWith<$Res>
    implements $ShuffleConfigCopyWith<$Res> {
  factory _$$ShuffleConfigImplCopyWith(
          _$ShuffleConfigImpl value, $Res Function(_$ShuffleConfigImpl) then) =
      __$$ShuffleConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int artistSpacing,
      double recencyStrength,
      double favoriteBias,
      double discoveryFraction,
      int? seed});
}

/// @nodoc
class __$$ShuffleConfigImplCopyWithImpl<$Res>
    extends _$ShuffleConfigCopyWithImpl<$Res, _$ShuffleConfigImpl>
    implements _$$ShuffleConfigImplCopyWith<$Res> {
  __$$ShuffleConfigImplCopyWithImpl(
      _$ShuffleConfigImpl _value, $Res Function(_$ShuffleConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of ShuffleConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? artistSpacing = null,
    Object? recencyStrength = null,
    Object? favoriteBias = null,
    Object? discoveryFraction = null,
    Object? seed = freezed,
  }) {
    return _then(_$ShuffleConfigImpl(
      artistSpacing: null == artistSpacing
          ? _value.artistSpacing
          : artistSpacing // ignore: cast_nullable_to_non_nullable
              as int,
      recencyStrength: null == recencyStrength
          ? _value.recencyStrength
          : recencyStrength // ignore: cast_nullable_to_non_nullable
              as double,
      favoriteBias: null == favoriteBias
          ? _value.favoriteBias
          : favoriteBias // ignore: cast_nullable_to_non_nullable
              as double,
      discoveryFraction: null == discoveryFraction
          ? _value.discoveryFraction
          : discoveryFraction // ignore: cast_nullable_to_non_nullable
              as double,
      seed: freezed == seed
          ? _value.seed
          : seed // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShuffleConfigImpl implements _ShuffleConfig {
  const _$ShuffleConfigImpl(
      {this.artistSpacing = kDefaultArtistSpacing,
      this.recencyStrength = 0.5,
      this.favoriteBias = 0.5,
      this.discoveryFraction = 0.15,
      this.seed});

  factory _$ShuffleConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShuffleConfigImplFromJson(json);

  /// Minimum number of tracks between plays of the same artist.
  /// Range: 0–10. PRD §6.3: "Artist spacing (0‑5 tracks)" — extended to 10
  /// for large libraries.
  @override
  @JsonKey()
  final int artistSpacing;

  /// How aggressively to avoid recently-played tracks.
  /// 0.0 = no avoidance, 1.0 = maximum recency bias (λ in scoring formula).
  @override
  @JsonKey()
  final double recencyStrength;

  /// How much to boost tracks the user explicitly rated or frequently plays.
  /// 0.0 = ignore ratings, 1.0 = strong bias toward favourites.
  @override
  @JsonKey()
  final double favoriteBias;

  /// Fraction of the queue dedicated to tracks played <3 times (discovery).
  /// 0.0 = no discovery, 1.0 = all discovery tracks.
  @override
  @JsonKey()
  final double discoveryFraction;

  /// Optional seed for deterministic shuffle (used in tests; null = random).
  @override
  final int? seed;

  @override
  String toString() {
    return 'ShuffleConfig(artistSpacing: $artistSpacing, recencyStrength: $recencyStrength, favoriteBias: $favoriteBias, discoveryFraction: $discoveryFraction, seed: $seed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShuffleConfigImpl &&
            (identical(other.artistSpacing, artistSpacing) ||
                other.artistSpacing == artistSpacing) &&
            (identical(other.recencyStrength, recencyStrength) ||
                other.recencyStrength == recencyStrength) &&
            (identical(other.favoriteBias, favoriteBias) ||
                other.favoriteBias == favoriteBias) &&
            (identical(other.discoveryFraction, discoveryFraction) ||
                other.discoveryFraction == discoveryFraction) &&
            (identical(other.seed, seed) || other.seed == seed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, artistSpacing, recencyStrength,
      favoriteBias, discoveryFraction, seed);

  /// Create a copy of ShuffleConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShuffleConfigImplCopyWith<_$ShuffleConfigImpl> get copyWith =>
      __$$ShuffleConfigImplCopyWithImpl<_$ShuffleConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShuffleConfigImplToJson(
      this,
    );
  }
}

abstract class _ShuffleConfig implements ShuffleConfig {
  const factory _ShuffleConfig(
      {final int artistSpacing,
      final double recencyStrength,
      final double favoriteBias,
      final double discoveryFraction,
      final int? seed}) = _$ShuffleConfigImpl;

  factory _ShuffleConfig.fromJson(Map<String, dynamic> json) =
      _$ShuffleConfigImpl.fromJson;

  /// Minimum number of tracks between plays of the same artist.
  /// Range: 0–10. PRD §6.3: "Artist spacing (0‑5 tracks)" — extended to 10
  /// for large libraries.
  @override
  int get artistSpacing;

  /// How aggressively to avoid recently-played tracks.
  /// 0.0 = no avoidance, 1.0 = maximum recency bias (λ in scoring formula).
  @override
  double get recencyStrength;

  /// How much to boost tracks the user explicitly rated or frequently plays.
  /// 0.0 = ignore ratings, 1.0 = strong bias toward favourites.
  @override
  double get favoriteBias;

  /// Fraction of the queue dedicated to tracks played <3 times (discovery).
  /// 0.0 = no discovery, 1.0 = all discovery tracks.
  @override
  double get discoveryFraction;

  /// Optional seed for deterministic shuffle (used in tests; null = random).
  @override
  int? get seed;

  /// Create a copy of ShuffleConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShuffleConfigImplCopyWith<_$ShuffleConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
