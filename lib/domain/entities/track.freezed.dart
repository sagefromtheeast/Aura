// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'track.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Track _$TrackFromJson(Map<String, dynamic> json) {
  return _Track.fromJson(json);
}

/// @nodoc
mixin _$Track {
  /// Unique identifier (UUID v4, assigned at scan time).
  String get id => throw _privateConstructorUsedError;

  /// Track title from ID3/FLAC/AAC metadata.
  String get title => throw _privateConstructorUsedError;

  /// Artist display name (denormalised for fast display).
  String get artistName => throw _privateConstructorUsedError;

  /// Album title (denormalised for fast display).
  String get albumTitle => throw _privateConstructorUsedError;

  /// FK → Artist.id in the database.
  String get artistId => throw _privateConstructorUsedError;

  /// FK → Album.id in the database.
  String get albumId => throw _privateConstructorUsedError;

  /// Track duration in milliseconds (from audio container header).
  int get durationMs => throw _privateConstructorUsedError;

  /// Absolute file path on the device.
  String get filePath => throw _privateConstructorUsedError;

  /// File size in bytes (used for duplicate detection).
  int get fileSizeBytes => throw _privateConstructorUsedError;

  /// Detected audio format.
  AudioFormat get format => throw _privateConstructorUsedError;

  /// Bit rate in kbps (0 if unknown / lossless).
  int get bitRateKbps => throw _privateConstructorUsedError;

  /// Sample rate in Hz.
  int get sampleRateHz => throw _privateConstructorUsedError;

  /// Number of times this track has been played to completion (≥80% played).
  /// PRD §6.5: used in statistics dashboard.
  int get playCount => throw _privateConstructorUsedError;

  /// Number of times the user skipped this track.
  int get skipCount => throw _privateConstructorUsedError;

  /// User rating 0–5 (0 = unrated). Used in IntelliShuffle scoring.
  int get rating => throw _privateConstructorUsedError;

  /// Timestamp when the track was added to the library (epoch ms).
  int get dateAddedMs => throw _privateConstructorUsedError;

  /// Timestamp of last playback (epoch ms). null if never played.
  int? get lastPlayedMs => throw _privateConstructorUsedError;

  /// Whether the file has been deleted from disk (soft-delete for stats).
  bool get isDeleted => throw _privateConstructorUsedError;

  /// Optional path to extracted album art (may share with album).
  String? get coverArtPath => throw _privateConstructorUsedError;

  /// Track number within the album (1-based, 0 = unknown).
  int get trackNumber => throw _privateConstructorUsedError;

  /// Disc number (for multi-disc albums).
  int get discNumber => throw _privateConstructorUsedError;

  /// Genre string from metadata (may be empty).
  String get genre => throw _privateConstructorUsedError;

  /// Year of release (0 = unknown).
  int get year => throw _privateConstructorUsedError;

  /// Serializes this Track to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Track
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrackCopyWith<Track> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrackCopyWith<$Res> {
  factory $TrackCopyWith(Track value, $Res Function(Track) then) =
      _$TrackCopyWithImpl<$Res, Track>;
  @useResult
  $Res call(
      {String id,
      String title,
      String artistName,
      String albumTitle,
      String artistId,
      String albumId,
      int durationMs,
      String filePath,
      int fileSizeBytes,
      AudioFormat format,
      int bitRateKbps,
      int sampleRateHz,
      int playCount,
      int skipCount,
      int rating,
      int dateAddedMs,
      int? lastPlayedMs,
      bool isDeleted,
      String? coverArtPath,
      int trackNumber,
      int discNumber,
      String genre,
      int year});
}

/// @nodoc
class _$TrackCopyWithImpl<$Res, $Val extends Track>
    implements $TrackCopyWith<$Res> {
  _$TrackCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Track
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? artistName = null,
    Object? albumTitle = null,
    Object? artistId = null,
    Object? albumId = null,
    Object? durationMs = null,
    Object? filePath = null,
    Object? fileSizeBytes = null,
    Object? format = null,
    Object? bitRateKbps = null,
    Object? sampleRateHz = null,
    Object? playCount = null,
    Object? skipCount = null,
    Object? rating = null,
    Object? dateAddedMs = null,
    Object? lastPlayedMs = freezed,
    Object? isDeleted = null,
    Object? coverArtPath = freezed,
    Object? trackNumber = null,
    Object? discNumber = null,
    Object? genre = null,
    Object? year = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artistName: null == artistName
          ? _value.artistName
          : artistName // ignore: cast_nullable_to_non_nullable
              as String,
      albumTitle: null == albumTitle
          ? _value.albumTitle
          : albumTitle // ignore: cast_nullable_to_non_nullable
              as String,
      artistId: null == artistId
          ? _value.artistId
          : artistId // ignore: cast_nullable_to_non_nullable
              as String,
      albumId: null == albumId
          ? _value.albumId
          : albumId // ignore: cast_nullable_to_non_nullable
              as String,
      durationMs: null == durationMs
          ? _value.durationMs
          : durationMs // ignore: cast_nullable_to_non_nullable
              as int,
      filePath: null == filePath
          ? _value.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      fileSizeBytes: null == fileSizeBytes
          ? _value.fileSizeBytes
          : fileSizeBytes // ignore: cast_nullable_to_non_nullable
              as int,
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as AudioFormat,
      bitRateKbps: null == bitRateKbps
          ? _value.bitRateKbps
          : bitRateKbps // ignore: cast_nullable_to_non_nullable
              as int,
      sampleRateHz: null == sampleRateHz
          ? _value.sampleRateHz
          : sampleRateHz // ignore: cast_nullable_to_non_nullable
              as int,
      playCount: null == playCount
          ? _value.playCount
          : playCount // ignore: cast_nullable_to_non_nullable
              as int,
      skipCount: null == skipCount
          ? _value.skipCount
          : skipCount // ignore: cast_nullable_to_non_nullable
              as int,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      dateAddedMs: null == dateAddedMs
          ? _value.dateAddedMs
          : dateAddedMs // ignore: cast_nullable_to_non_nullable
              as int,
      lastPlayedMs: freezed == lastPlayedMs
          ? _value.lastPlayedMs
          : lastPlayedMs // ignore: cast_nullable_to_non_nullable
              as int?,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      coverArtPath: freezed == coverArtPath
          ? _value.coverArtPath
          : coverArtPath // ignore: cast_nullable_to_non_nullable
              as String?,
      trackNumber: null == trackNumber
          ? _value.trackNumber
          : trackNumber // ignore: cast_nullable_to_non_nullable
              as int,
      discNumber: null == discNumber
          ? _value.discNumber
          : discNumber // ignore: cast_nullable_to_non_nullable
              as int,
      genre: null == genre
          ? _value.genre
          : genre // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrackImplCopyWith<$Res> implements $TrackCopyWith<$Res> {
  factory _$$TrackImplCopyWith(
          _$TrackImpl value, $Res Function(_$TrackImpl) then) =
      __$$TrackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String artistName,
      String albumTitle,
      String artistId,
      String albumId,
      int durationMs,
      String filePath,
      int fileSizeBytes,
      AudioFormat format,
      int bitRateKbps,
      int sampleRateHz,
      int playCount,
      int skipCount,
      int rating,
      int dateAddedMs,
      int? lastPlayedMs,
      bool isDeleted,
      String? coverArtPath,
      int trackNumber,
      int discNumber,
      String genre,
      int year});
}

/// @nodoc
class __$$TrackImplCopyWithImpl<$Res>
    extends _$TrackCopyWithImpl<$Res, _$TrackImpl>
    implements _$$TrackImplCopyWith<$Res> {
  __$$TrackImplCopyWithImpl(
      _$TrackImpl _value, $Res Function(_$TrackImpl) _then)
      : super(_value, _then);

  /// Create a copy of Track
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? artistName = null,
    Object? albumTitle = null,
    Object? artistId = null,
    Object? albumId = null,
    Object? durationMs = null,
    Object? filePath = null,
    Object? fileSizeBytes = null,
    Object? format = null,
    Object? bitRateKbps = null,
    Object? sampleRateHz = null,
    Object? playCount = null,
    Object? skipCount = null,
    Object? rating = null,
    Object? dateAddedMs = null,
    Object? lastPlayedMs = freezed,
    Object? isDeleted = null,
    Object? coverArtPath = freezed,
    Object? trackNumber = null,
    Object? discNumber = null,
    Object? genre = null,
    Object? year = null,
  }) {
    return _then(_$TrackImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artistName: null == artistName
          ? _value.artistName
          : artistName // ignore: cast_nullable_to_non_nullable
              as String,
      albumTitle: null == albumTitle
          ? _value.albumTitle
          : albumTitle // ignore: cast_nullable_to_non_nullable
              as String,
      artistId: null == artistId
          ? _value.artistId
          : artistId // ignore: cast_nullable_to_non_nullable
              as String,
      albumId: null == albumId
          ? _value.albumId
          : albumId // ignore: cast_nullable_to_non_nullable
              as String,
      durationMs: null == durationMs
          ? _value.durationMs
          : durationMs // ignore: cast_nullable_to_non_nullable
              as int,
      filePath: null == filePath
          ? _value.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      fileSizeBytes: null == fileSizeBytes
          ? _value.fileSizeBytes
          : fileSizeBytes // ignore: cast_nullable_to_non_nullable
              as int,
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as AudioFormat,
      bitRateKbps: null == bitRateKbps
          ? _value.bitRateKbps
          : bitRateKbps // ignore: cast_nullable_to_non_nullable
              as int,
      sampleRateHz: null == sampleRateHz
          ? _value.sampleRateHz
          : sampleRateHz // ignore: cast_nullable_to_non_nullable
              as int,
      playCount: null == playCount
          ? _value.playCount
          : playCount // ignore: cast_nullable_to_non_nullable
              as int,
      skipCount: null == skipCount
          ? _value.skipCount
          : skipCount // ignore: cast_nullable_to_non_nullable
              as int,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      dateAddedMs: null == dateAddedMs
          ? _value.dateAddedMs
          : dateAddedMs // ignore: cast_nullable_to_non_nullable
              as int,
      lastPlayedMs: freezed == lastPlayedMs
          ? _value.lastPlayedMs
          : lastPlayedMs // ignore: cast_nullable_to_non_nullable
              as int?,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      coverArtPath: freezed == coverArtPath
          ? _value.coverArtPath
          : coverArtPath // ignore: cast_nullable_to_non_nullable
              as String?,
      trackNumber: null == trackNumber
          ? _value.trackNumber
          : trackNumber // ignore: cast_nullable_to_non_nullable
              as int,
      discNumber: null == discNumber
          ? _value.discNumber
          : discNumber // ignore: cast_nullable_to_non_nullable
              as int,
      genre: null == genre
          ? _value.genre
          : genre // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrackImpl implements _Track {
  const _$TrackImpl(
      {required this.id,
      required this.title,
      required this.artistName,
      required this.albumTitle,
      required this.artistId,
      required this.albumId,
      required this.durationMs,
      required this.filePath,
      required this.fileSizeBytes,
      this.format = AudioFormat.unknown,
      this.bitRateKbps = 0,
      this.sampleRateHz = 44100,
      this.playCount = 0,
      this.skipCount = 0,
      this.rating = 0,
      required this.dateAddedMs,
      this.lastPlayedMs,
      this.isDeleted = false,
      this.coverArtPath,
      this.trackNumber = 0,
      this.discNumber = 1,
      this.genre = '',
      this.year = 0});

  factory _$TrackImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrackImplFromJson(json);

  /// Unique identifier (UUID v4, assigned at scan time).
  @override
  final String id;

  /// Track title from ID3/FLAC/AAC metadata.
  @override
  final String title;

  /// Artist display name (denormalised for fast display).
  @override
  final String artistName;

  /// Album title (denormalised for fast display).
  @override
  final String albumTitle;

  /// FK → Artist.id in the database.
  @override
  final String artistId;

  /// FK → Album.id in the database.
  @override
  final String albumId;

  /// Track duration in milliseconds (from audio container header).
  @override
  final int durationMs;

  /// Absolute file path on the device.
  @override
  final String filePath;

  /// File size in bytes (used for duplicate detection).
  @override
  final int fileSizeBytes;

  /// Detected audio format.
  @override
  @JsonKey()
  final AudioFormat format;

  /// Bit rate in kbps (0 if unknown / lossless).
  @override
  @JsonKey()
  final int bitRateKbps;

  /// Sample rate in Hz.
  @override
  @JsonKey()
  final int sampleRateHz;

  /// Number of times this track has been played to completion (≥80% played).
  /// PRD §6.5: used in statistics dashboard.
  @override
  @JsonKey()
  final int playCount;

  /// Number of times the user skipped this track.
  @override
  @JsonKey()
  final int skipCount;

  /// User rating 0–5 (0 = unrated). Used in IntelliShuffle scoring.
  @override
  @JsonKey()
  final int rating;

  /// Timestamp when the track was added to the library (epoch ms).
  @override
  final int dateAddedMs;

  /// Timestamp of last playback (epoch ms). null if never played.
  @override
  final int? lastPlayedMs;

  /// Whether the file has been deleted from disk (soft-delete for stats).
  @override
  @JsonKey()
  final bool isDeleted;

  /// Optional path to extracted album art (may share with album).
  @override
  final String? coverArtPath;

  /// Track number within the album (1-based, 0 = unknown).
  @override
  @JsonKey()
  final int trackNumber;

  /// Disc number (for multi-disc albums).
  @override
  @JsonKey()
  final int discNumber;

  /// Genre string from metadata (may be empty).
  @override
  @JsonKey()
  final String genre;

  /// Year of release (0 = unknown).
  @override
  @JsonKey()
  final int year;

  @override
  String toString() {
    return 'Track(id: $id, title: $title, artistName: $artistName, albumTitle: $albumTitle, artistId: $artistId, albumId: $albumId, durationMs: $durationMs, filePath: $filePath, fileSizeBytes: $fileSizeBytes, format: $format, bitRateKbps: $bitRateKbps, sampleRateHz: $sampleRateHz, playCount: $playCount, skipCount: $skipCount, rating: $rating, dateAddedMs: $dateAddedMs, lastPlayedMs: $lastPlayedMs, isDeleted: $isDeleted, coverArtPath: $coverArtPath, trackNumber: $trackNumber, discNumber: $discNumber, genre: $genre, year: $year)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.artistName, artistName) ||
                other.artistName == artistName) &&
            (identical(other.albumTitle, albumTitle) ||
                other.albumTitle == albumTitle) &&
            (identical(other.artistId, artistId) ||
                other.artistId == artistId) &&
            (identical(other.albumId, albumId) || other.albumId == albumId) &&
            (identical(other.durationMs, durationMs) ||
                other.durationMs == durationMs) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.fileSizeBytes, fileSizeBytes) ||
                other.fileSizeBytes == fileSizeBytes) &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.bitRateKbps, bitRateKbps) ||
                other.bitRateKbps == bitRateKbps) &&
            (identical(other.sampleRateHz, sampleRateHz) ||
                other.sampleRateHz == sampleRateHz) &&
            (identical(other.playCount, playCount) ||
                other.playCount == playCount) &&
            (identical(other.skipCount, skipCount) ||
                other.skipCount == skipCount) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.dateAddedMs, dateAddedMs) ||
                other.dateAddedMs == dateAddedMs) &&
            (identical(other.lastPlayedMs, lastPlayedMs) ||
                other.lastPlayedMs == lastPlayedMs) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.coverArtPath, coverArtPath) ||
                other.coverArtPath == coverArtPath) &&
            (identical(other.trackNumber, trackNumber) ||
                other.trackNumber == trackNumber) &&
            (identical(other.discNumber, discNumber) ||
                other.discNumber == discNumber) &&
            (identical(other.genre, genre) || other.genre == genre) &&
            (identical(other.year, year) || other.year == year));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        artistName,
        albumTitle,
        artistId,
        albumId,
        durationMs,
        filePath,
        fileSizeBytes,
        format,
        bitRateKbps,
        sampleRateHz,
        playCount,
        skipCount,
        rating,
        dateAddedMs,
        lastPlayedMs,
        isDeleted,
        coverArtPath,
        trackNumber,
        discNumber,
        genre,
        year
      ]);

  /// Create a copy of Track
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrackImplCopyWith<_$TrackImpl> get copyWith =>
      __$$TrackImplCopyWithImpl<_$TrackImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrackImplToJson(
      this,
    );
  }
}

abstract class _Track implements Track {
  const factory _Track(
      {required final String id,
      required final String title,
      required final String artistName,
      required final String albumTitle,
      required final String artistId,
      required final String albumId,
      required final int durationMs,
      required final String filePath,
      required final int fileSizeBytes,
      final AudioFormat format,
      final int bitRateKbps,
      final int sampleRateHz,
      final int playCount,
      final int skipCount,
      final int rating,
      required final int dateAddedMs,
      final int? lastPlayedMs,
      final bool isDeleted,
      final String? coverArtPath,
      final int trackNumber,
      final int discNumber,
      final String genre,
      final int year}) = _$TrackImpl;

  factory _Track.fromJson(Map<String, dynamic> json) = _$TrackImpl.fromJson;

  /// Unique identifier (UUID v4, assigned at scan time).
  @override
  String get id;

  /// Track title from ID3/FLAC/AAC metadata.
  @override
  String get title;

  /// Artist display name (denormalised for fast display).
  @override
  String get artistName;

  /// Album title (denormalised for fast display).
  @override
  String get albumTitle;

  /// FK → Artist.id in the database.
  @override
  String get artistId;

  /// FK → Album.id in the database.
  @override
  String get albumId;

  /// Track duration in milliseconds (from audio container header).
  @override
  int get durationMs;

  /// Absolute file path on the device.
  @override
  String get filePath;

  /// File size in bytes (used for duplicate detection).
  @override
  int get fileSizeBytes;

  /// Detected audio format.
  @override
  AudioFormat get format;

  /// Bit rate in kbps (0 if unknown / lossless).
  @override
  int get bitRateKbps;

  /// Sample rate in Hz.
  @override
  int get sampleRateHz;

  /// Number of times this track has been played to completion (≥80% played).
  /// PRD §6.5: used in statistics dashboard.
  @override
  int get playCount;

  /// Number of times the user skipped this track.
  @override
  int get skipCount;

  /// User rating 0–5 (0 = unrated). Used in IntelliShuffle scoring.
  @override
  int get rating;

  /// Timestamp when the track was added to the library (epoch ms).
  @override
  int get dateAddedMs;

  /// Timestamp of last playback (epoch ms). null if never played.
  @override
  int? get lastPlayedMs;

  /// Whether the file has been deleted from disk (soft-delete for stats).
  @override
  bool get isDeleted;

  /// Optional path to extracted album art (may share with album).
  @override
  String? get coverArtPath;

  /// Track number within the album (1-based, 0 = unknown).
  @override
  int get trackNumber;

  /// Disc number (for multi-disc albums).
  @override
  int get discNumber;

  /// Genre string from metadata (may be empty).
  @override
  String get genre;

  /// Year of release (0 = unknown).
  @override
  int get year;

  /// Create a copy of Track
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrackImplCopyWith<_$TrackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
