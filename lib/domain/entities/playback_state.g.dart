// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaybackStateImpl _$$PlaybackStateImplFromJson(Map<String, dynamic> json) =>
    _$PlaybackStateImpl(
      status:
          $enumDecodeNullable(_$EngineStatusEnumMap, json['status']) ??
          EngineStatus.idle,
      currentTrack: json['currentTrack'] == null
          ? null
          : Track.fromJson(json['currentTrack'] as Map<String, dynamic>),
      positionMs: (json['positionMs'] as num?)?.toInt() ?? 0,
      bufferedMs: (json['bufferedMs'] as num?)?.toInt() ?? 0,
      isShuffleEnabled: json['isShuffleEnabled'] as bool? ?? false,
      repeatMode:
          $enumDecodeNullable(_$RepeatModeEnumMap, json['repeatMode']) ??
          RepeatMode.none,
      playbackSpeed: (json['playbackSpeed'] as num?)?.toDouble() ?? 1.0,
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      eqBandGains:
          (json['eqBandGains'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      errorMessage: json['errorMessage'] as String?,
      timestampMs: (json['timestampMs'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$PlaybackStateImplToJson(_$PlaybackStateImpl instance) =>
    <String, dynamic>{
      'status': _$EngineStatusEnumMap[instance.status]!,
      'currentTrack': instance.currentTrack,
      'positionMs': instance.positionMs,
      'bufferedMs': instance.bufferedMs,
      'isShuffleEnabled': instance.isShuffleEnabled,
      'repeatMode': _$RepeatModeEnumMap[instance.repeatMode]!,
      'playbackSpeed': instance.playbackSpeed,
      'volume': instance.volume,
      'eqBandGains': instance.eqBandGains,
      'errorMessage': instance.errorMessage,
      'timestampMs': instance.timestampMs,
    };

const _$EngineStatusEnumMap = {
  EngineStatus.idle: 'idle',
  EngineStatus.ready: 'ready',
  EngineStatus.playing: 'playing',
  EngineStatus.paused: 'paused',
  EngineStatus.loading: 'loading',
  EngineStatus.completed: 'completed',
  EngineStatus.error: 'error',
};

const _$RepeatModeEnumMap = {
  RepeatMode.none: 'none',
  RepeatMode.one: 'one',
  RepeatMode.all: 'all',
};
