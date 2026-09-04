// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrackImpl _$$TrackImplFromJson(Map<String, dynamic> json) => _$TrackImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  artistName: json['artistName'] as String,
  albumTitle: json['albumTitle'] as String,
  artistId: json['artistId'] as String,
  albumId: json['albumId'] as String,
  durationMs: (json['durationMs'] as num).toInt(),
  filePath: json['filePath'] as String,
  fileSizeBytes: (json['fileSizeBytes'] as num).toInt(),
  format:
      $enumDecodeNullable(_$AudioFormatEnumMap, json['format']) ??
      AudioFormat.unknown,
  bitRateKbps: (json['bitRateKbps'] as num?)?.toInt() ?? 0,
  sampleRateHz: (json['sampleRateHz'] as num?)?.toInt() ?? 44100,
  playCount: (json['playCount'] as num?)?.toInt() ?? 0,
  skipCount: (json['skipCount'] as num?)?.toInt() ?? 0,
  rating: (json['rating'] as num?)?.toInt() ?? 0,
  dateAddedMs: (json['dateAddedMs'] as num).toInt(),
  lastPlayedMs: (json['lastPlayedMs'] as num?)?.toInt(),
  isDeleted: json['isDeleted'] as bool? ?? false,
  coverArtPath: json['coverArtPath'] as String?,
  trackNumber: (json['trackNumber'] as num?)?.toInt() ?? 0,
  discNumber: (json['discNumber'] as num?)?.toInt() ?? 1,
  genre: json['genre'] as String? ?? '',
  year: (json['year'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$TrackImplToJson(_$TrackImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'artistName': instance.artistName,
      'albumTitle': instance.albumTitle,
      'artistId': instance.artistId,
      'albumId': instance.albumId,
      'durationMs': instance.durationMs,
      'filePath': instance.filePath,
      'fileSizeBytes': instance.fileSizeBytes,
      'format': _$AudioFormatEnumMap[instance.format]!,
      'bitRateKbps': instance.bitRateKbps,
      'sampleRateHz': instance.sampleRateHz,
      'playCount': instance.playCount,
      'skipCount': instance.skipCount,
      'rating': instance.rating,
      'dateAddedMs': instance.dateAddedMs,
      'lastPlayedMs': instance.lastPlayedMs,
      'isDeleted': instance.isDeleted,
      'coverArtPath': instance.coverArtPath,
      'trackNumber': instance.trackNumber,
      'discNumber': instance.discNumber,
      'genre': instance.genre,
      'year': instance.year,
    };

const _$AudioFormatEnumMap = {
  AudioFormat.mp3: 'mp3',
  AudioFormat.aac: 'aac',
  AudioFormat.flac: 'flac',
  AudioFormat.alac: 'alac',
  AudioFormat.dsd: 'dsd',
  AudioFormat.wav: 'wav',
  AudioFormat.ogg: 'ogg',
  AudioFormat.opus: 'opus',
  AudioFormat.unknown: 'unknown',
};
