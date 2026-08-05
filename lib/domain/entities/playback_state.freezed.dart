// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlaybackState _$PlaybackStateFromJson(Map<String, dynamic> json) {
  return _PlaybackState.fromJson(json);
}

/// @nodoc
mixin _$PlaybackState {
  /// Current engine status.
  EngineStatus get status => throw _privateConstructorUsedError;

  /// Currently loaded track; null when idle.
  Track? get currentTrack => throw _privateConstructorUsedError;

  /// Current playback position in milliseconds.
  int get positionMs => throw _privateConstructorUsedError;

  /// Buffer position in milliseconds (for gapless pre-loading).
  int get bufferedMs => throw _privateConstructorUsedError;

  /// Whether shuffle is active.
  bool get isShuffleEnabled => throw _privateConstructorUsedError;

  /// Current repeat mode.
  RepeatMode get repeatMode => throw _privateConstructorUsedError;

  /// Playback speed multiplier (1.0 = normal).
  double get playbackSpeed => throw _privateConstructorUsedError;

  /// Master volume 0.0–1.0.
  double get volume => throw _privateConstructorUsedError;

  /// EQ band gains (10 bands, index 0 = 32Hz … 9 = 16kHz), dB offset.
  List<int> get eqBandGains => throw _privateConstructorUsedError;

  /// Error message when [status] is [EngineStatus.error].
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Timestamp when this state was captured (for change detection).
  int get timestampMs => throw _privateConstructorUsedError;

  /// Serializes this PlaybackState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlaybackState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaybackStateCopyWith<PlaybackState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaybackStateCopyWith<$Res> {
  factory $PlaybackStateCopyWith(
          PlaybackState value, $Res Function(PlaybackState) then) =
      _$PlaybackStateCopyWithImpl<$Res, PlaybackState>;
  @useResult
  $Res call(
      {EngineStatus status,
      Track? currentTrack,
      int positionMs,
      int bufferedMs,
      bool isShuffleEnabled,
      RepeatMode repeatMode,
      double playbackSpeed,
      double volume,
      List<int> eqBandGains,
      String? errorMessage,
      int timestampMs});

  $TrackCopyWith<$Res>? get currentTrack;
}

/// @nodoc
class _$PlaybackStateCopyWithImpl<$Res, $Val extends PlaybackState>
    implements $PlaybackStateCopyWith<$Res> {
  _$PlaybackStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlaybackState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? currentTrack = freezed,
    Object? positionMs = null,
    Object? bufferedMs = null,
    Object? isShuffleEnabled = null,
    Object? repeatMode = null,
    Object? playbackSpeed = null,
    Object? volume = null,
    Object? eqBandGains = null,
    Object? errorMessage = freezed,
    Object? timestampMs = null,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EngineStatus,
      currentTrack: freezed == currentTrack
          ? _value.currentTrack
          : currentTrack // ignore: cast_nullable_to_non_nullable
              as Track?,
      positionMs: null == positionMs
          ? _value.positionMs
          : positionMs // ignore: cast_nullable_to_non_nullable
              as int,
      bufferedMs: null == bufferedMs
          ? _value.bufferedMs
          : bufferedMs // ignore: cast_nullable_to_non_nullable
              as int,
      isShuffleEnabled: null == isShuffleEnabled
          ? _value.isShuffleEnabled
          : isShuffleEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      repeatMode: null == repeatMode
          ? _value.repeatMode
          : repeatMode // ignore: cast_nullable_to_non_nullable
              as RepeatMode,
      playbackSpeed: null == playbackSpeed
          ? _value.playbackSpeed
          : playbackSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      volume: null == volume
          ? _value.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as double,
      eqBandGains: null == eqBandGains
          ? _value.eqBandGains
          : eqBandGains // ignore: cast_nullable_to_non_nullable
              as List<int>,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      timestampMs: null == timestampMs
          ? _value.timestampMs
          : timestampMs // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of PlaybackState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrackCopyWith<$Res>? get currentTrack {
    if (_value.currentTrack == null) {
      return null;
    }

    return $TrackCopyWith<$Res>(_value.currentTrack!, (value) {
      return _then(_value.copyWith(currentTrack: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlaybackStateImplCopyWith<$Res>
    implements $PlaybackStateCopyWith<$Res> {
  factory _$$PlaybackStateImplCopyWith(
          _$PlaybackStateImpl value, $Res Function(_$PlaybackStateImpl) then) =
      __$$PlaybackStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {EngineStatus status,
      Track? currentTrack,
      int positionMs,
      int bufferedMs,
      bool isShuffleEnabled,
      RepeatMode repeatMode,
      double playbackSpeed,
      double volume,
      List<int> eqBandGains,
      String? errorMessage,
      int timestampMs});

  @override
  $TrackCopyWith<$Res>? get currentTrack;
}

/// @nodoc
class __$$PlaybackStateImplCopyWithImpl<$Res>
    extends _$PlaybackStateCopyWithImpl<$Res, _$PlaybackStateImpl>
    implements _$$PlaybackStateImplCopyWith<$Res> {
  __$$PlaybackStateImplCopyWithImpl(
      _$PlaybackStateImpl _value, $Res Function(_$PlaybackStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlaybackState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? currentTrack = freezed,
    Object? positionMs = null,
    Object? bufferedMs = null,
    Object? isShuffleEnabled = null,
    Object? repeatMode = null,
    Object? playbackSpeed = null,
    Object? volume = null,
    Object? eqBandGains = null,
    Object? errorMessage = freezed,
    Object? timestampMs = null,
  }) {
    return _then(_$PlaybackStateImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EngineStatus,
      currentTrack: freezed == currentTrack
          ? _value.currentTrack
          : currentTrack // ignore: cast_nullable_to_non_nullable
              as Track?,
      positionMs: null == positionMs
          ? _value.positionMs
          : positionMs // ignore: cast_nullable_to_non_nullable
              as int,
      bufferedMs: null == bufferedMs
          ? _value.bufferedMs
          : bufferedMs // ignore: cast_nullable_to_non_nullable
              as int,
      isShuffleEnabled: null == isShuffleEnabled
          ? _value.isShuffleEnabled
          : isShuffleEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      repeatMode: null == repeatMode
          ? _value.repeatMode
          : repeatMode // ignore: cast_nullable_to_non_nullable
              as RepeatMode,
      playbackSpeed: null == playbackSpeed
          ? _value.playbackSpeed
          : playbackSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      volume: null == volume
          ? _value.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as double,
      eqBandGains: null == eqBandGains
          ? _value._eqBandGains
          : eqBandGains // ignore: cast_nullable_to_non_nullable
              as List<int>,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      timestampMs: null == timestampMs
          ? _value.timestampMs
          : timestampMs // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaybackStateImpl implements _PlaybackState {
  const _$PlaybackStateImpl(
      {this.status = EngineStatus.idle,
      this.currentTrack,
      this.positionMs = 0,
      this.bufferedMs = 0,
      this.isShuffleEnabled = false,
      this.repeatMode = RepeatMode.none,
      this.playbackSpeed = 1.0,
      this.volume = 1.0,
      final List<int> eqBandGains = const [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      this.errorMessage,
      this.timestampMs = 0})
      : _eqBandGains = eqBandGains;

  factory _$PlaybackStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaybackStateImplFromJson(json);

  /// Current engine status.
  @override
  @JsonKey()
  final EngineStatus status;

  /// Currently loaded track; null when idle.
  @override
  final Track? currentTrack;

  /// Current playback position in milliseconds.
  @override
  @JsonKey()
  final int positionMs;

  /// Buffer position in milliseconds (for gapless pre-loading).
  @override
  @JsonKey()
  final int bufferedMs;

  /// Whether shuffle is active.
  @override
  @JsonKey()
  final bool isShuffleEnabled;

  /// Current repeat mode.
  @override
  @JsonKey()
  final RepeatMode repeatMode;

  /// Playback speed multiplier (1.0 = normal).
  @override
  @JsonKey()
  final double playbackSpeed;

  /// Master volume 0.0–1.0.
  @override
  @JsonKey()
  final double volume;

  /// EQ band gains (10 bands, index 0 = 32Hz … 9 = 16kHz), dB offset.
  final List<int> _eqBandGains;

  /// EQ band gains (10 bands, index 0 = 32Hz … 9 = 16kHz), dB offset.
  @override
  @JsonKey()
  List<int> get eqBandGains {
    if (_eqBandGains is EqualUnmodifiableListView) return _eqBandGains;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_eqBandGains);
  }

  /// Error message when [status] is [EngineStatus.error].
  @override
  final String? errorMessage;

  /// Timestamp when this state was captured (for change detection).
  @override
  @JsonKey()
  final int timestampMs;

  @override
  String toString() {
    return 'PlaybackState(status: $status, currentTrack: $currentTrack, positionMs: $positionMs, bufferedMs: $bufferedMs, isShuffleEnabled: $isShuffleEnabled, repeatMode: $repeatMode, playbackSpeed: $playbackSpeed, volume: $volume, eqBandGains: $eqBandGains, errorMessage: $errorMessage, timestampMs: $timestampMs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaybackStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currentTrack, currentTrack) ||
                other.currentTrack == currentTrack) &&
            (identical(other.positionMs, positionMs) ||
                other.positionMs == positionMs) &&
            (identical(other.bufferedMs, bufferedMs) ||
                other.bufferedMs == bufferedMs) &&
            (identical(other.isShuffleEnabled, isShuffleEnabled) ||
                other.isShuffleEnabled == isShuffleEnabled) &&
            (identical(other.repeatMode, repeatMode) ||
                other.repeatMode == repeatMode) &&
            (identical(other.playbackSpeed, playbackSpeed) ||
                other.playbackSpeed == playbackSpeed) &&
            (identical(other.volume, volume) || other.volume == volume) &&
            const DeepCollectionEquality()
                .equals(other._eqBandGains, _eqBandGains) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.timestampMs, timestampMs) ||
                other.timestampMs == timestampMs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      status,
      currentTrack,
      positionMs,
      bufferedMs,
      isShuffleEnabled,
      repeatMode,
      playbackSpeed,
      volume,
      const DeepCollectionEquality().hash(_eqBandGains),
      errorMessage,
      timestampMs);

  /// Create a copy of PlaybackState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaybackStateImplCopyWith<_$PlaybackStateImpl> get copyWith =>
      __$$PlaybackStateImplCopyWithImpl<_$PlaybackStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaybackStateImplToJson(
      this,
    );
  }
}

abstract class _PlaybackState implements PlaybackState {
  const factory _PlaybackState(
      {final EngineStatus status,
      final Track? currentTrack,
      final int positionMs,
      final int bufferedMs,
      final bool isShuffleEnabled,
      final RepeatMode repeatMode,
      final double playbackSpeed,
      final double volume,
      final List<int> eqBandGains,
      final String? errorMessage,
      final int timestampMs}) = _$PlaybackStateImpl;

  factory _PlaybackState.fromJson(Map<String, dynamic> json) =
      _$PlaybackStateImpl.fromJson;

  /// Current engine status.
  @override
  EngineStatus get status;

  /// Currently loaded track; null when idle.
  @override
  Track? get currentTrack;

  /// Current playback position in milliseconds.
  @override
  int get positionMs;

  /// Buffer position in milliseconds (for gapless pre-loading).
  @override
  int get bufferedMs;

  /// Whether shuffle is active.
  @override
  bool get isShuffleEnabled;

  /// Current repeat mode.
  @override
  RepeatMode get repeatMode;

  /// Playback speed multiplier (1.0 = normal).
  @override
  double get playbackSpeed;

  /// Master volume 0.0–1.0.
  @override
  double get volume;

  /// EQ band gains (10 bands, index 0 = 32Hz … 9 = 16kHz), dB offset.
  @override
  List<int> get eqBandGains;

  /// Error message when [status] is [EngineStatus.error].
  @override
  String? get errorMessage;

  /// Timestamp when this state was captured (for change detection).
  @override
  int get timestampMs;

  /// Create a copy of PlaybackState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaybackStateImplCopyWith<_$PlaybackStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
