// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shuffle_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShuffleConfigImpl _$$ShuffleConfigImplFromJson(Map<String, dynamic> json) =>
    _$ShuffleConfigImpl(
      artistSpacing:
          (json['artistSpacing'] as num?)?.toInt() ?? kDefaultArtistSpacing,
      recencyStrength: (json['recencyStrength'] as num?)?.toDouble() ?? 0.5,
      favoriteBias: (json['favoriteBias'] as num?)?.toDouble() ?? 0.5,
      discoveryFraction:
          (json['discoveryFraction'] as num?)?.toDouble() ?? 0.15,
      seed: (json['seed'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ShuffleConfigImplToJson(_$ShuffleConfigImpl instance) =>
    <String, dynamic>{
      'artistSpacing': instance.artistSpacing,
      'recencyStrength': instance.recencyStrength,
      'favoriteBias': instance.favoriteBias,
      'discoveryFraction': instance.discoveryFraction,
      'seed': instance.seed,
    };
