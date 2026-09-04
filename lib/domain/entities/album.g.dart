// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AlbumImpl _$$AlbumImplFromJson(Map<String, dynamic> json) => _$AlbumImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  artistId: json['artistId'] as String,
  artistName: json['artistName'] as String,
  year: (json['year'] as num?)?.toInt() ?? 0,
  coverArtPath: json['coverArtPath'] as String?,
  trackCount: (json['trackCount'] as num?)?.toInt() ?? 0,
  totalDurationMs: (json['totalDurationMs'] as num?)?.toInt() ?? 0,
  genre: json['genre'] as String? ?? '',
  dateAddedMs: (json['dateAddedMs'] as num).toInt(),
);

Map<String, dynamic> _$$AlbumImplToJson(_$AlbumImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'artistId': instance.artistId,
      'artistName': instance.artistName,
      'year': instance.year,
      'coverArtPath': instance.coverArtPath,
      'trackCount': instance.trackCount,
      'totalDurationMs': instance.totalDurationMs,
      'genre': instance.genre,
      'dateAddedMs': instance.dateAddedMs,
    };
