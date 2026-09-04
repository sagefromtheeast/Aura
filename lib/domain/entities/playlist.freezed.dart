// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playlist.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Playlist _$PlaylistFromJson(Map<String, dynamic> json) {
  return _Playlist.fromJson(json);
}

/// @nodoc
mixin _$Playlist {
  /// Unique identifier (UUID v4).
  String get id => throw _privateConstructorUsedError;

  /// Display name.
  String get name => throw _privateConstructorUsedError;

  /// Optional description / subtitle.
  String get description => throw _privateConstructorUsedError;

  /// Type of playlist — controls display and behaviour.
  PlaylistType get type => throw _privateConstructorUsedError;

  /// If this is a smart mix, which mood it represents.
  MixMood? get mood => throw _privateConstructorUsedError;

  /// Ordered list of track IDs (order matters for non-shuffle playback).
  List<String> get trackIds => throw _privateConstructorUsedError;

  /// Epoch ms when created.
  int get createdAtMs => throw _privateConstructorUsedError;

  /// Epoch ms of last modification.
  int get updatedAtMs => throw _privateConstructorUsedError;

  /// Optional cover art path (overrides default album-art mosaic in UI).
  String? get coverArtPath => throw _privateConstructorUsedError;

  /// Up to 4 album-art paths composited by the UI into a 2x2 mix cover.
  List<String> get coverArtPaths => throw _privateConstructorUsedError;

  /// Whether this playlist is pinned to the top of the library.
  bool get isPinned => throw _privateConstructorUsedError;

  /// Serializes this Playlist to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Playlist
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaylistCopyWith<Playlist> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaylistCopyWith<$Res> {
  factory $PlaylistCopyWith(Playlist value, $Res Function(Playlist) then) =
      _$PlaylistCopyWithImpl<$Res, Playlist>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      PlaylistType type,
      MixMood? mood,
      List<String> trackIds,
      int createdAtMs,
      int updatedAtMs,
      String? coverArtPath,
      List<String> coverArtPaths,
      bool isPinned});
}

/// @nodoc
class _$PlaylistCopyWithImpl<$Res, $Val extends Playlist>
    implements $PlaylistCopyWith<$Res> {
  _$PlaylistCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Playlist
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? type = null,
    Object? mood = freezed,
    Object? trackIds = null,
    Object? createdAtMs = null,
    Object? updatedAtMs = null,
    Object? coverArtPath = freezed,
    Object? coverArtPaths = null,
    Object? isPinned = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PlaylistType,
      mood: freezed == mood
          ? _value.mood
          : mood // ignore: cast_nullable_to_non_nullable
              as MixMood?,
      trackIds: null == trackIds
          ? _value.trackIds
          : trackIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAtMs: null == createdAtMs
          ? _value.createdAtMs
          : createdAtMs // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAtMs: null == updatedAtMs
          ? _value.updatedAtMs
          : updatedAtMs // ignore: cast_nullable_to_non_nullable
              as int,
      coverArtPath: freezed == coverArtPath
          ? _value.coverArtPath
          : coverArtPath // ignore: cast_nullable_to_non_nullable
              as String?,
      coverArtPaths: null == coverArtPaths
          ? _value.coverArtPaths
          : coverArtPaths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isPinned: null == isPinned
          ? _value.isPinned
          : isPinned // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlaylistImplCopyWith<$Res>
    implements $PlaylistCopyWith<$Res> {
  factory _$$PlaylistImplCopyWith(
          _$PlaylistImpl value, $Res Function(_$PlaylistImpl) then) =
      __$$PlaylistImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      PlaylistType type,
      MixMood? mood,
      List<String> trackIds,
      int createdAtMs,
      int updatedAtMs,
      String? coverArtPath,
      List<String> coverArtPaths,
      bool isPinned});
}

/// @nodoc
class __$$PlaylistImplCopyWithImpl<$Res>
    extends _$PlaylistCopyWithImpl<$Res, _$PlaylistImpl>
    implements _$$PlaylistImplCopyWith<$Res> {
  __$$PlaylistImplCopyWithImpl(
      _$PlaylistImpl _value, $Res Function(_$PlaylistImpl) _then)
      : super(_value, _then);

  /// Create a copy of Playlist
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? type = null,
    Object? mood = freezed,
    Object? trackIds = null,
    Object? createdAtMs = null,
    Object? updatedAtMs = null,
    Object? coverArtPath = freezed,
    Object? coverArtPaths = null,
    Object? isPinned = null,
  }) {
    return _then(_$PlaylistImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PlaylistType,
      mood: freezed == mood
          ? _value.mood
          : mood // ignore: cast_nullable_to_non_nullable
              as MixMood?,
      trackIds: null == trackIds
          ? _value._trackIds
          : trackIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAtMs: null == createdAtMs
          ? _value.createdAtMs
          : createdAtMs // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAtMs: null == updatedAtMs
          ? _value.updatedAtMs
          : updatedAtMs // ignore: cast_nullable_to_non_nullable
              as int,
      coverArtPath: freezed == coverArtPath
          ? _value.coverArtPath
          : coverArtPath // ignore: cast_nullable_to_non_nullable
              as String?,
      coverArtPaths: null == coverArtPaths
          ? _value._coverArtPaths
          : coverArtPaths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isPinned: null == isPinned
          ? _value.isPinned
          : isPinned // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaylistImpl implements _Playlist {
  const _$PlaylistImpl(
      {required this.id,
      required this.name,
      this.description = '',
      this.type = PlaylistType.userCreated,
      this.mood,
      final List<String> trackIds = const [],
      required this.createdAtMs,
      required this.updatedAtMs,
      this.coverArtPath,
      final List<String> coverArtPaths = const [],
      this.isPinned = false})
      : _trackIds = trackIds,
        _coverArtPaths = coverArtPaths;

  factory _$PlaylistImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaylistImplFromJson(json);

  /// Unique identifier (UUID v4).
  @override
  final String id;

  /// Display name.
  @override
  final String name;

  /// Optional description / subtitle.
  @override
  @JsonKey()
  final String description;

  /// Type of playlist — controls display and behaviour.
  @override
  @JsonKey()
  final PlaylistType type;

  /// If this is a smart mix, which mood it represents.
  @override
  final MixMood? mood;

  /// Ordered list of track IDs (order matters for non-shuffle playback).
  final List<String> _trackIds;

  /// Ordered list of track IDs (order matters for non-shuffle playback).
  @override
  @JsonKey()
  List<String> get trackIds {
    if (_trackIds is EqualUnmodifiableListView) return _trackIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trackIds);
  }

  /// Epoch ms when created.
  @override
  final int createdAtMs;

  /// Epoch ms of last modification.
  @override
  final int updatedAtMs;

  /// Optional cover art path (overrides default album-art mosaic in UI).
  @override
  final String? coverArtPath;

  /// Up to 4 album-art paths composited by the UI into a 2x2 mix cover.
  final List<String> _coverArtPaths;

  /// Up to 4 album-art paths composited by the UI into a 2x2 mix cover.
  @override
  @JsonKey()
  List<String> get coverArtPaths {
    if (_coverArtPaths is EqualUnmodifiableListView) return _coverArtPaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_coverArtPaths);
  }

  /// Whether this playlist is pinned to the top of the library.
  @override
  @JsonKey()
  final bool isPinned;

  @override
  String toString() {
    return 'Playlist(id: $id, name: $name, description: $description, type: $type, mood: $mood, trackIds: $trackIds, createdAtMs: $createdAtMs, updatedAtMs: $updatedAtMs, coverArtPath: $coverArtPath, coverArtPaths: $coverArtPaths, isPinned: $isPinned)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaylistImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            const DeepCollectionEquality().equals(other._trackIds, _trackIds) &&
            (identical(other.createdAtMs, createdAtMs) ||
                other.createdAtMs == createdAtMs) &&
            (identical(other.updatedAtMs, updatedAtMs) ||
                other.updatedAtMs == updatedAtMs) &&
            (identical(other.coverArtPath, coverArtPath) ||
                other.coverArtPath == coverArtPath) &&
            const DeepCollectionEquality()
                .equals(other._coverArtPaths, _coverArtPaths) &&
            (identical(other.isPinned, isPinned) ||
                other.isPinned == isPinned));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      type,
      mood,
      const DeepCollectionEquality().hash(_trackIds),
      createdAtMs,
      updatedAtMs,
      coverArtPath,
      const DeepCollectionEquality().hash(_coverArtPaths),
      isPinned);

  /// Create a copy of Playlist
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaylistImplCopyWith<_$PlaylistImpl> get copyWith =>
      __$$PlaylistImplCopyWithImpl<_$PlaylistImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaylistImplToJson(
      this,
    );
  }
}

abstract class _Playlist implements Playlist {
  const factory _Playlist(
      {required final String id,
      required final String name,
      final String description,
      final PlaylistType type,
      final MixMood? mood,
      final List<String> trackIds,
      required final int createdAtMs,
      required final int updatedAtMs,
      final String? coverArtPath,
      final List<String> coverArtPaths,
      final bool isPinned}) = _$PlaylistImpl;

  factory _Playlist.fromJson(Map<String, dynamic> json) =
      _$PlaylistImpl.fromJson;

  /// Unique identifier (UUID v4).
  @override
  String get id;

  /// Display name.
  @override
  String get name;

  /// Optional description / subtitle.
  @override
  String get description;

  /// Type of playlist — controls display and behaviour.
  @override
  PlaylistType get type;

  /// If this is a smart mix, which mood it represents.
  @override
  MixMood? get mood;

  /// Ordered list of track IDs (order matters for non-shuffle playback).
  @override
  List<String> get trackIds;

  /// Epoch ms when created.
  @override
  int get createdAtMs;

  /// Epoch ms of last modification.
  @override
  int get updatedAtMs;

  /// Optional cover art path (overrides default album-art mosaic in UI).
  @override
  String? get coverArtPath;

  /// Up to 4 album-art paths composited by the UI into a 2x2 mix cover.
  @override
  List<String> get coverArtPaths;

  /// Whether this playlist is pinned to the top of the library.
  @override
  bool get isPinned;

  /// Create a copy of Playlist
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaylistImplCopyWith<_$PlaylistImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
