// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shuffle_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShuffleConfigImpl _$$ShuffleConfigImplFromJson(Map<String, dynamic> json) =>
    _$ShuffleConfigImpl(
      favouriteBias: (json['favouriteBias'] as num?)?.toDouble() ?? 0.4,
      recencyAvoidance: (json['recencyAvoidance'] as num?)?.toDouble() ?? 0.5,
      discovery: (json['discovery'] as num?)?.toDouble() ?? 0.3,
      artistSpacing:
          (json['artistSpacing'] as num?)?.toInt() ?? kDefaultArtistSpacing,
      albumSpacing: (json['albumSpacing'] as num?)?.toInt() ?? 5,
      moodMatching: json['moodMatching'] as bool? ?? false,
      moodStrength: (json['moodStrength'] as num?)?.toDouble() ?? 0.5,
      smoothTransitions: json['smoothTransitions'] as bool? ?? false,
      seed: (json['seed'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ShuffleConfigImplToJson(_$ShuffleConfigImpl instance) =>
    <String, dynamic>{
      'favouriteBias': instance.favouriteBias,
      'recencyAvoidance': instance.recencyAvoidance,
      'discovery': instance.discovery,
      'artistSpacing': instance.artistSpacing,
      'albumSpacing': instance.albumSpacing,
      'moodMatching': instance.moodMatching,
      'moodStrength': instance.moodStrength,
      'smoothTransitions': instance.smoothTransitions,
      'seed': instance.seed,
    };
