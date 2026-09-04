// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'album.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Album _$AlbumFromJson(Map<String, dynamic> json) {
  return _Album.fromJson(json);
}

/// @nodoc
mixin _$Album {
  /// Unique identifier (UUID v4).
  String get id => throw _privateConstructorUsedError;

  /// Album title from metadata.
  String get title => throw _privateConstructorUsedError;

  /// FK → Artist.id (primary/album artist).
  String get artistId => throw _privateConstructorUsedError;

  /// Artist name (denormalised for display).
  String get artistName => throw _privateConstructorUsedError;

  /// Release year (0 = unknown).
  int get year => throw _privateConstructorUsedError;

  /// Absolute path to cover art image. null if not found.
  String? get coverArtPath => throw _privateConstructorUsedError;

  /// Total number of tracks in this album (count from DB).
  int get trackCount => throw _privateConstructorUsedError;

  /// Total duration of all tracks in milliseconds.
  int get totalDurationMs => throw _privateConstructorUsedError;

  /// Genre from the majority of tracks.
  String get genre => throw _privateConstructorUsedError;

  /// Timestamp when first track was added (epoch ms).
  int get dateAddedMs => throw _privateConstructorUsedError;

  /// Serializes this Album to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Album
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AlbumCopyWith<Album> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlbumCopyWith<$Res> {
  factory $AlbumCopyWith(Album value, $Res Function(Album) then) =
      _$AlbumCopyWithImpl<$Res, Album>;
  @useResult
  $Res call({
    String id,
    String title,
    String artistId,
    String artistName,
    int year,
    String? coverArtPath,
    int trackCount,
    int totalDurationMs,
    String genre,
    int dateAddedMs,
  });
}

/// @nodoc
class _$AlbumCopyWithImpl<$Res, $Val extends Album>
    implements $AlbumCopyWith<$Res> {
  _$AlbumCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Album
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? artistId = null,
    Object? artistName = null,
    Object? year = null,
    Object? coverArtPath = freezed,
    Object? trackCount = null,
    Object? totalDurationMs = null,
    Object? genre = null,
    Object? dateAddedMs = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            artistId: null == artistId
                ? _value.artistId
                : artistId // ignore: cast_nullable_to_non_nullable
                      as String,
            artistName: null == artistName
                ? _value.artistName
                : artistName // ignore: cast_nullable_to_non_nullable
                      as String,
            year: null == year
                ? _value.year
                : year // ignore: cast_nullable_to_non_nullable
                      as int,
            coverArtPath: freezed == coverArtPath
                ? _value.coverArtPath
                : coverArtPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            trackCount: null == trackCount
                ? _value.trackCount
                : trackCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalDurationMs: null == totalDurationMs
                ? _value.totalDurationMs
                : totalDurationMs // ignore: cast_nullable_to_non_nullable
                      as int,
            genre: null == genre
                ? _value.genre
                : genre // ignore: cast_nullable_to_non_nullable
                      as String,
            dateAddedMs: null == dateAddedMs
                ? _value.dateAddedMs
                : dateAddedMs // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AlbumImplCopyWith<$Res> implements $AlbumCopyWith<$Res> {
  factory _$$AlbumImplCopyWith(
    _$AlbumImpl value,
    $Res Function(_$AlbumImpl) then,
  ) = __$$AlbumImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String artistId,
    String artistName,
    int year,
    String? coverArtPath,
    int trackCount,
    int totalDurationMs,
    String genre,
    int dateAddedMs,
  });
}

/// @nodoc
class __$$AlbumImplCopyWithImpl<$Res>
    extends _$AlbumCopyWithImpl<$Res, _$AlbumImpl>
    implements _$$AlbumImplCopyWith<$Res> {
  __$$AlbumImplCopyWithImpl(
    _$AlbumImpl _value,
    $Res Function(_$AlbumImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Album
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? artistId = null,
    Object? artistName = null,
    Object? year = null,
    Object? coverArtPath = freezed,
    Object? trackCount = null,
    Object? totalDurationMs = null,
    Object? genre = null,
    Object? dateAddedMs = null,
  }) {
    return _then(
      _$AlbumImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        artistId: null == artistId
            ? _value.artistId
            : artistId // ignore: cast_nullable_to_non_nullable
                  as String,
        artistName: null == artistName
            ? _value.artistName
            : artistName // ignore: cast_nullable_to_non_nullable
                  as String,
        year: null == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int,
        coverArtPath: freezed == coverArtPath
            ? _value.coverArtPath
            : coverArtPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        trackCount: null == trackCount
            ? _value.trackCount
            : trackCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalDurationMs: null == totalDurationMs
            ? _value.totalDurationMs
            : totalDurationMs // ignore: cast_nullable_to_non_nullable
                  as int,
        genre: null == genre
            ? _value.genre
            : genre // ignore: cast_nullable_to_non_nullable
                  as String,
        dateAddedMs: null == dateAddedMs
            ? _value.dateAddedMs
            : dateAddedMs // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AlbumImpl implements _Album {
  const _$AlbumImpl({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    this.year = 0,
    this.coverArtPath,
    this.trackCount = 0,
    this.totalDurationMs = 0,
    this.genre = '',
    required this.dateAddedMs,
  });

  factory _$AlbumImpl.fromJson(Map<String, dynamic> json) =>
      _$$AlbumImplFromJson(json);

  /// Unique identifier (UUID v4).
  @override
  final String id;

  /// Album title from metadata.
  @override
  final String title;

  /// FK → Artist.id (primary/album artist).
  @override
  final String artistId;

  /// Artist name (denormalised for display).
  @override
  final String artistName;

  /// Release year (0 = unknown).
  @override
  @JsonKey()
  final int year;

  /// Absolute path to cover art image. null if not found.
  @override
  final String? coverArtPath;

  /// Total number of tracks in this album (count from DB).
  @override
  @JsonKey()
  final int trackCount;

  /// Total duration of all tracks in milliseconds.
  @override
  @JsonKey()
  final int totalDurationMs;

  /// Genre from the majority of tracks.
  @override
  @JsonKey()
  final String genre;

  /// Timestamp when first track was added (epoch ms).
  @override
  final int dateAddedMs;

  @override
  String toString() {
    return 'Album(id: $id, title: $title, artistId: $artistId, artistName: $artistName, year: $year, coverArtPath: $coverArtPath, trackCount: $trackCount, totalDurationMs: $totalDurationMs, genre: $genre, dateAddedMs: $dateAddedMs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlbumImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.artistId, artistId) ||
                other.artistId == artistId) &&
            (identical(other.artistName, artistName) ||
                other.artistName == artistName) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.coverArtPath, coverArtPath) ||
                other.coverArtPath == coverArtPath) &&
            (identical(other.trackCount, trackCount) ||
                other.trackCount == trackCount) &&
            (identical(other.totalDurationMs, totalDurationMs) ||
                other.totalDurationMs == totalDurationMs) &&
            (identical(other.genre, genre) || other.genre == genre) &&
            (identical(other.dateAddedMs, dateAddedMs) ||
                other.dateAddedMs == dateAddedMs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    artistId,
    artistName,
    year,
    coverArtPath,
    trackCount,
    totalDurationMs,
    genre,
    dateAddedMs,
  );

  /// Create a copy of Album
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AlbumImplCopyWith<_$AlbumImpl> get copyWith =>
      __$$AlbumImplCopyWithImpl<_$AlbumImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AlbumImplToJson(this);
  }
}

abstract class _Album implements Album {
  const factory _Album({
    required final String id,
    required final String title,
    required final String artistId,
    required final String artistName,
    final int year,
    final String? coverArtPath,
    final int trackCount,
    final int totalDurationMs,
    final String genre,
    required final int dateAddedMs,
  }) = _$AlbumImpl;

  factory _Album.fromJson(Map<String, dynamic> json) = _$AlbumImpl.fromJson;

  /// Unique identifier (UUID v4).
  @override
  String get id;

  /// Album title from metadata.
  @override
  String get title;

  /// FK → Artist.id (primary/album artist).
  @override
  String get artistId;

  /// Artist name (denormalised for display).
  @override
  String get artistName;

  /// Release year (0 = unknown).
  @override
  int get year;

  /// Absolute path to cover art image. null if not found.
  @override
  String? get coverArtPath;

  /// Total number of tracks in this album (count from DB).
  @override
  int get trackCount;

  /// Total duration of all tracks in milliseconds.
  @override
  int get totalDurationMs;

  /// Genre from the majority of tracks.
  @override
  String get genre;

  /// Timestamp when first track was added (epoch ms).
  @override
  int get dateAddedMs;

  /// Create a copy of Album
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AlbumImplCopyWith<_$AlbumImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
