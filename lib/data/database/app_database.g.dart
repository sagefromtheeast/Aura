// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TracksTableTable extends TracksTable
    with TableInfo<$TracksTableTable, TrackRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TracksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistNameMeta = const VerificationMeta(
    'artistName',
  );
  @override
  late final GeneratedColumn<String> artistName = GeneratedColumn<String>(
    'artist_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumTitleMeta = const VerificationMeta(
    'albumTitle',
  );
  @override
  late final GeneratedColumn<String> albumTitle = GeneratedColumn<String>(
    'album_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistIdMeta = const VerificationMeta(
    'artistId',
  );
  @override
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
    'artist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumIdMeta = const VerificationMeta(
    'albumId',
  );
  @override
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
    'album_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _fileSizeBytesMeta = const VerificationMeta(
    'fileSizeBytes',
  );
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
    'file_size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
  );
  static const VerificationMeta _bitRateKbpsMeta = const VerificationMeta(
    'bitRateKbps',
  );
  @override
  late final GeneratedColumn<int> bitRateKbps = GeneratedColumn<int>(
    'bit_rate_kbps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sampleRateHzMeta = const VerificationMeta(
    'sampleRateHz',
  );
  @override
  late final GeneratedColumn<int> sampleRateHz = GeneratedColumn<int>(
    'sample_rate_hz',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(44100),
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _skipCountMeta = const VerificationMeta(
    'skipCount',
  );
  @override
  late final GeneratedColumn<int> skipCount = GeneratedColumn<int>(
    'skip_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dateAddedMsMeta = const VerificationMeta(
    'dateAddedMs',
  );
  @override
  late final GeneratedColumn<int> dateAddedMs = GeneratedColumn<int>(
    'date_added_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPlayedMsMeta = const VerificationMeta(
    'lastPlayedMs',
  );
  @override
  late final GeneratedColumn<int> lastPlayedMs = GeneratedColumn<int>(
    'last_played_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _coverArtPathMeta = const VerificationMeta(
    'coverArtPath',
  );
  @override
  late final GeneratedColumn<String> coverArtPath = GeneratedColumn<String>(
    'cover_art_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackNumberMeta = const VerificationMeta(
    'trackNumber',
  );
  @override
  late final GeneratedColumn<int> trackNumber = GeneratedColumn<int>(
    'track_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discNumberMeta = const VerificationMeta(
    'discNumber',
  );
  @override
  late final GeneratedColumn<int> discNumber = GeneratedColumn<int>(
    'disc_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
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
    year,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist_name')) {
      context.handle(
        _artistNameMeta,
        artistName.isAcceptableOrUnknown(data['artist_name']!, _artistNameMeta),
      );
    } else if (isInserting) {
      context.missing(_artistNameMeta);
    }
    if (data.containsKey('album_title')) {
      context.handle(
        _albumTitleMeta,
        albumTitle.isAcceptableOrUnknown(data['album_title']!, _albumTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_albumTitleMeta);
    }
    if (data.containsKey('artist_id')) {
      context.handle(
        _artistIdMeta,
        artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_artistIdMeta);
    }
    if (data.containsKey('album_id')) {
      context.handle(
        _albumIdMeta,
        albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta),
      );
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
        _fileSizeBytesMeta,
        fileSizeBytes.isAcceptableOrUnknown(
          data['file_size_bytes']!,
          _fileSizeBytesMeta,
        ),
      );
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    }
    if (data.containsKey('bit_rate_kbps')) {
      context.handle(
        _bitRateKbpsMeta,
        bitRateKbps.isAcceptableOrUnknown(
          data['bit_rate_kbps']!,
          _bitRateKbpsMeta,
        ),
      );
    }
    if (data.containsKey('sample_rate_hz')) {
      context.handle(
        _sampleRateHzMeta,
        sampleRateHz.isAcceptableOrUnknown(
          data['sample_rate_hz']!,
          _sampleRateHzMeta,
        ),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('skip_count')) {
      context.handle(
        _skipCountMeta,
        skipCount.isAcceptableOrUnknown(data['skip_count']!, _skipCountMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('date_added_ms')) {
      context.handle(
        _dateAddedMsMeta,
        dateAddedMs.isAcceptableOrUnknown(
          data['date_added_ms']!,
          _dateAddedMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateAddedMsMeta);
    }
    if (data.containsKey('last_played_ms')) {
      context.handle(
        _lastPlayedMsMeta,
        lastPlayedMs.isAcceptableOrUnknown(
          data['last_played_ms']!,
          _lastPlayedMsMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('cover_art_path')) {
      context.handle(
        _coverArtPathMeta,
        coverArtPath.isAcceptableOrUnknown(
          data['cover_art_path']!,
          _coverArtPathMeta,
        ),
      );
    }
    if (data.containsKey('track_number')) {
      context.handle(
        _trackNumberMeta,
        trackNumber.isAcceptableOrUnknown(
          data['track_number']!,
          _trackNumberMeta,
        ),
      );
    }
    if (data.containsKey('disc_number')) {
      context.handle(
        _discNumberMeta,
        discNumber.isAcceptableOrUnknown(data['disc_number']!, _discNumberMeta),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artistName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_name'],
      )!,
      albumTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_title'],
      )!,
      artistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_id'],
      )!,
      albumId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_id'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      fileSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size_bytes'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      bitRateKbps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bit_rate_kbps'],
      )!,
      sampleRateHz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sample_rate_hz'],
      )!,
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
      skipCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skip_count'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      dateAddedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_added_ms'],
      )!,
      lastPlayedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_played_ms'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      coverArtPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_art_path'],
      ),
      trackNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_number'],
      )!,
      discNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}disc_number'],
      )!,
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
    );
  }

  @override
  $TracksTableTable createAlias(String alias) {
    return $TracksTableTable(attachedDatabase, alias);
  }
}

class TrackRow extends DataClass implements Insertable<TrackRow> {
  /// UUID v4 — primary key.
  final String id;
  final String title;
  final String artistName;
  final String albumTitle;
  final String artistId;
  final String albumId;
  final int durationMs;
  final String filePath;
  final int fileSizeBytes;
  final String format;
  final int bitRateKbps;
  final int sampleRateHz;
  final int playCount;
  final int skipCount;
  final int rating;
  final int dateAddedMs;
  final int? lastPlayedMs;
  final bool isDeleted;
  final String? coverArtPath;
  final int trackNumber;
  final int discNumber;
  final String genre;
  final int year;
  const TrackRow({
    required this.id,
    required this.title,
    required this.artistName,
    required this.albumTitle,
    required this.artistId,
    required this.albumId,
    required this.durationMs,
    required this.filePath,
    required this.fileSizeBytes,
    required this.format,
    required this.bitRateKbps,
    required this.sampleRateHz,
    required this.playCount,
    required this.skipCount,
    required this.rating,
    required this.dateAddedMs,
    this.lastPlayedMs,
    required this.isDeleted,
    this.coverArtPath,
    required this.trackNumber,
    required this.discNumber,
    required this.genre,
    required this.year,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['artist_name'] = Variable<String>(artistName);
    map['album_title'] = Variable<String>(albumTitle);
    map['artist_id'] = Variable<String>(artistId);
    map['album_id'] = Variable<String>(albumId);
    map['duration_ms'] = Variable<int>(durationMs);
    map['file_path'] = Variable<String>(filePath);
    map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    map['format'] = Variable<String>(format);
    map['bit_rate_kbps'] = Variable<int>(bitRateKbps);
    map['sample_rate_hz'] = Variable<int>(sampleRateHz);
    map['play_count'] = Variable<int>(playCount);
    map['skip_count'] = Variable<int>(skipCount);
    map['rating'] = Variable<int>(rating);
    map['date_added_ms'] = Variable<int>(dateAddedMs);
    if (!nullToAbsent || lastPlayedMs != null) {
      map['last_played_ms'] = Variable<int>(lastPlayedMs);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || coverArtPath != null) {
      map['cover_art_path'] = Variable<String>(coverArtPath);
    }
    map['track_number'] = Variable<int>(trackNumber);
    map['disc_number'] = Variable<int>(discNumber);
    map['genre'] = Variable<String>(genre);
    map['year'] = Variable<int>(year);
    return map;
  }

  TracksTableCompanion toCompanion(bool nullToAbsent) {
    return TracksTableCompanion(
      id: Value(id),
      title: Value(title),
      artistName: Value(artistName),
      albumTitle: Value(albumTitle),
      artistId: Value(artistId),
      albumId: Value(albumId),
      durationMs: Value(durationMs),
      filePath: Value(filePath),
      fileSizeBytes: Value(fileSizeBytes),
      format: Value(format),
      bitRateKbps: Value(bitRateKbps),
      sampleRateHz: Value(sampleRateHz),
      playCount: Value(playCount),
      skipCount: Value(skipCount),
      rating: Value(rating),
      dateAddedMs: Value(dateAddedMs),
      lastPlayedMs: lastPlayedMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedMs),
      isDeleted: Value(isDeleted),
      coverArtPath: coverArtPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverArtPath),
      trackNumber: Value(trackNumber),
      discNumber: Value(discNumber),
      genre: Value(genre),
      year: Value(year),
    );
  }

  factory TrackRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      artistName: serializer.fromJson<String>(json['artistName']),
      albumTitle: serializer.fromJson<String>(json['albumTitle']),
      artistId: serializer.fromJson<String>(json['artistId']),
      albumId: serializer.fromJson<String>(json['albumId']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      filePath: serializer.fromJson<String>(json['filePath']),
      fileSizeBytes: serializer.fromJson<int>(json['fileSizeBytes']),
      format: serializer.fromJson<String>(json['format']),
      bitRateKbps: serializer.fromJson<int>(json['bitRateKbps']),
      sampleRateHz: serializer.fromJson<int>(json['sampleRateHz']),
      playCount: serializer.fromJson<int>(json['playCount']),
      skipCount: serializer.fromJson<int>(json['skipCount']),
      rating: serializer.fromJson<int>(json['rating']),
      dateAddedMs: serializer.fromJson<int>(json['dateAddedMs']),
      lastPlayedMs: serializer.fromJson<int?>(json['lastPlayedMs']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      coverArtPath: serializer.fromJson<String?>(json['coverArtPath']),
      trackNumber: serializer.fromJson<int>(json['trackNumber']),
      discNumber: serializer.fromJson<int>(json['discNumber']),
      genre: serializer.fromJson<String>(json['genre']),
      year: serializer.fromJson<int>(json['year']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'artistName': serializer.toJson<String>(artistName),
      'albumTitle': serializer.toJson<String>(albumTitle),
      'artistId': serializer.toJson<String>(artistId),
      'albumId': serializer.toJson<String>(albumId),
      'durationMs': serializer.toJson<int>(durationMs),
      'filePath': serializer.toJson<String>(filePath),
      'fileSizeBytes': serializer.toJson<int>(fileSizeBytes),
      'format': serializer.toJson<String>(format),
      'bitRateKbps': serializer.toJson<int>(bitRateKbps),
      'sampleRateHz': serializer.toJson<int>(sampleRateHz),
      'playCount': serializer.toJson<int>(playCount),
      'skipCount': serializer.toJson<int>(skipCount),
      'rating': serializer.toJson<int>(rating),
      'dateAddedMs': serializer.toJson<int>(dateAddedMs),
      'lastPlayedMs': serializer.toJson<int?>(lastPlayedMs),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'coverArtPath': serializer.toJson<String?>(coverArtPath),
      'trackNumber': serializer.toJson<int>(trackNumber),
      'discNumber': serializer.toJson<int>(discNumber),
      'genre': serializer.toJson<String>(genre),
      'year': serializer.toJson<int>(year),
    };
  }

  TrackRow copyWith({
    String? id,
    String? title,
    String? artistName,
    String? albumTitle,
    String? artistId,
    String? albumId,
    int? durationMs,
    String? filePath,
    int? fileSizeBytes,
    String? format,
    int? bitRateKbps,
    int? sampleRateHz,
    int? playCount,
    int? skipCount,
    int? rating,
    int? dateAddedMs,
    Value<int?> lastPlayedMs = const Value.absent(),
    bool? isDeleted,
    Value<String?> coverArtPath = const Value.absent(),
    int? trackNumber,
    int? discNumber,
    String? genre,
    int? year,
  }) => TrackRow(
    id: id ?? this.id,
    title: title ?? this.title,
    artistName: artistName ?? this.artistName,
    albumTitle: albumTitle ?? this.albumTitle,
    artistId: artistId ?? this.artistId,
    albumId: albumId ?? this.albumId,
    durationMs: durationMs ?? this.durationMs,
    filePath: filePath ?? this.filePath,
    fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    format: format ?? this.format,
    bitRateKbps: bitRateKbps ?? this.bitRateKbps,
    sampleRateHz: sampleRateHz ?? this.sampleRateHz,
    playCount: playCount ?? this.playCount,
    skipCount: skipCount ?? this.skipCount,
    rating: rating ?? this.rating,
    dateAddedMs: dateAddedMs ?? this.dateAddedMs,
    lastPlayedMs: lastPlayedMs.present ? lastPlayedMs.value : this.lastPlayedMs,
    isDeleted: isDeleted ?? this.isDeleted,
    coverArtPath: coverArtPath.present ? coverArtPath.value : this.coverArtPath,
    trackNumber: trackNumber ?? this.trackNumber,
    discNumber: discNumber ?? this.discNumber,
    genre: genre ?? this.genre,
    year: year ?? this.year,
  );
  TrackRow copyWithCompanion(TracksTableCompanion data) {
    return TrackRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      artistName: data.artistName.present
          ? data.artistName.value
          : this.artistName,
      albumTitle: data.albumTitle.present
          ? data.albumTitle.value
          : this.albumTitle,
      artistId: data.artistId.present ? data.artistId.value : this.artistId,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      format: data.format.present ? data.format.value : this.format,
      bitRateKbps: data.bitRateKbps.present
          ? data.bitRateKbps.value
          : this.bitRateKbps,
      sampleRateHz: data.sampleRateHz.present
          ? data.sampleRateHz.value
          : this.sampleRateHz,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      skipCount: data.skipCount.present ? data.skipCount.value : this.skipCount,
      rating: data.rating.present ? data.rating.value : this.rating,
      dateAddedMs: data.dateAddedMs.present
          ? data.dateAddedMs.value
          : this.dateAddedMs,
      lastPlayedMs: data.lastPlayedMs.present
          ? data.lastPlayedMs.value
          : this.lastPlayedMs,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      coverArtPath: data.coverArtPath.present
          ? data.coverArtPath.value
          : this.coverArtPath,
      trackNumber: data.trackNumber.present
          ? data.trackNumber.value
          : this.trackNumber,
      discNumber: data.discNumber.present
          ? data.discNumber.value
          : this.discNumber,
      genre: data.genre.present ? data.genre.value : this.genre,
      year: data.year.present ? data.year.value : this.year,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artistName: $artistName, ')
          ..write('albumTitle: $albumTitle, ')
          ..write('artistId: $artistId, ')
          ..write('albumId: $albumId, ')
          ..write('durationMs: $durationMs, ')
          ..write('filePath: $filePath, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('format: $format, ')
          ..write('bitRateKbps: $bitRateKbps, ')
          ..write('sampleRateHz: $sampleRateHz, ')
          ..write('playCount: $playCount, ')
          ..write('skipCount: $skipCount, ')
          ..write('rating: $rating, ')
          ..write('dateAddedMs: $dateAddedMs, ')
          ..write('lastPlayedMs: $lastPlayedMs, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('coverArtPath: $coverArtPath, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('discNumber: $discNumber, ')
          ..write('genre: $genre, ')
          ..write('year: $year')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
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
    year,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.artistName == this.artistName &&
          other.albumTitle == this.albumTitle &&
          other.artistId == this.artistId &&
          other.albumId == this.albumId &&
          other.durationMs == this.durationMs &&
          other.filePath == this.filePath &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.format == this.format &&
          other.bitRateKbps == this.bitRateKbps &&
          other.sampleRateHz == this.sampleRateHz &&
          other.playCount == this.playCount &&
          other.skipCount == this.skipCount &&
          other.rating == this.rating &&
          other.dateAddedMs == this.dateAddedMs &&
          other.lastPlayedMs == this.lastPlayedMs &&
          other.isDeleted == this.isDeleted &&
          other.coverArtPath == this.coverArtPath &&
          other.trackNumber == this.trackNumber &&
          other.discNumber == this.discNumber &&
          other.genre == this.genre &&
          other.year == this.year);
}

class TracksTableCompanion extends UpdateCompanion<TrackRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> artistName;
  final Value<String> albumTitle;
  final Value<String> artistId;
  final Value<String> albumId;
  final Value<int> durationMs;
  final Value<String> filePath;
  final Value<int> fileSizeBytes;
  final Value<String> format;
  final Value<int> bitRateKbps;
  final Value<int> sampleRateHz;
  final Value<int> playCount;
  final Value<int> skipCount;
  final Value<int> rating;
  final Value<int> dateAddedMs;
  final Value<int?> lastPlayedMs;
  final Value<bool> isDeleted;
  final Value<String?> coverArtPath;
  final Value<int> trackNumber;
  final Value<int> discNumber;
  final Value<String> genre;
  final Value<int> year;
  final Value<int> rowid;
  const TracksTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.artistName = const Value.absent(),
    this.albumTitle = const Value.absent(),
    this.artistId = const Value.absent(),
    this.albumId = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.format = const Value.absent(),
    this.bitRateKbps = const Value.absent(),
    this.sampleRateHz = const Value.absent(),
    this.playCount = const Value.absent(),
    this.skipCount = const Value.absent(),
    this.rating = const Value.absent(),
    this.dateAddedMs = const Value.absent(),
    this.lastPlayedMs = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.coverArtPath = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.discNumber = const Value.absent(),
    this.genre = const Value.absent(),
    this.year = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TracksTableCompanion.insert({
    required String id,
    required String title,
    required String artistName,
    required String albumTitle,
    required String artistId,
    required String albumId,
    required int durationMs,
    required String filePath,
    this.fileSizeBytes = const Value.absent(),
    this.format = const Value.absent(),
    this.bitRateKbps = const Value.absent(),
    this.sampleRateHz = const Value.absent(),
    this.playCount = const Value.absent(),
    this.skipCount = const Value.absent(),
    this.rating = const Value.absent(),
    required int dateAddedMs,
    this.lastPlayedMs = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.coverArtPath = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.discNumber = const Value.absent(),
    this.genre = const Value.absent(),
    this.year = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       artistName = Value(artistName),
       albumTitle = Value(albumTitle),
       artistId = Value(artistId),
       albumId = Value(albumId),
       durationMs = Value(durationMs),
       filePath = Value(filePath),
       dateAddedMs = Value(dateAddedMs);
  static Insertable<TrackRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? artistName,
    Expression<String>? albumTitle,
    Expression<String>? artistId,
    Expression<String>? albumId,
    Expression<int>? durationMs,
    Expression<String>? filePath,
    Expression<int>? fileSizeBytes,
    Expression<String>? format,
    Expression<int>? bitRateKbps,
    Expression<int>? sampleRateHz,
    Expression<int>? playCount,
    Expression<int>? skipCount,
    Expression<int>? rating,
    Expression<int>? dateAddedMs,
    Expression<int>? lastPlayedMs,
    Expression<bool>? isDeleted,
    Expression<String>? coverArtPath,
    Expression<int>? trackNumber,
    Expression<int>? discNumber,
    Expression<String>? genre,
    Expression<int>? year,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (artistName != null) 'artist_name': artistName,
      if (albumTitle != null) 'album_title': albumTitle,
      if (artistId != null) 'artist_id': artistId,
      if (albumId != null) 'album_id': albumId,
      if (durationMs != null) 'duration_ms': durationMs,
      if (filePath != null) 'file_path': filePath,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (format != null) 'format': format,
      if (bitRateKbps != null) 'bit_rate_kbps': bitRateKbps,
      if (sampleRateHz != null) 'sample_rate_hz': sampleRateHz,
      if (playCount != null) 'play_count': playCount,
      if (skipCount != null) 'skip_count': skipCount,
      if (rating != null) 'rating': rating,
      if (dateAddedMs != null) 'date_added_ms': dateAddedMs,
      if (lastPlayedMs != null) 'last_played_ms': lastPlayedMs,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (coverArtPath != null) 'cover_art_path': coverArtPath,
      if (trackNumber != null) 'track_number': trackNumber,
      if (discNumber != null) 'disc_number': discNumber,
      if (genre != null) 'genre': genre,
      if (year != null) 'year': year,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TracksTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? artistName,
    Value<String>? albumTitle,
    Value<String>? artistId,
    Value<String>? albumId,
    Value<int>? durationMs,
    Value<String>? filePath,
    Value<int>? fileSizeBytes,
    Value<String>? format,
    Value<int>? bitRateKbps,
    Value<int>? sampleRateHz,
    Value<int>? playCount,
    Value<int>? skipCount,
    Value<int>? rating,
    Value<int>? dateAddedMs,
    Value<int?>? lastPlayedMs,
    Value<bool>? isDeleted,
    Value<String?>? coverArtPath,
    Value<int>? trackNumber,
    Value<int>? discNumber,
    Value<String>? genre,
    Value<int>? year,
    Value<int>? rowid,
  }) {
    return TracksTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      artistName: artistName ?? this.artistName,
      albumTitle: albumTitle ?? this.albumTitle,
      artistId: artistId ?? this.artistId,
      albumId: albumId ?? this.albumId,
      durationMs: durationMs ?? this.durationMs,
      filePath: filePath ?? this.filePath,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      format: format ?? this.format,
      bitRateKbps: bitRateKbps ?? this.bitRateKbps,
      sampleRateHz: sampleRateHz ?? this.sampleRateHz,
      playCount: playCount ?? this.playCount,
      skipCount: skipCount ?? this.skipCount,
      rating: rating ?? this.rating,
      dateAddedMs: dateAddedMs ?? this.dateAddedMs,
      lastPlayedMs: lastPlayedMs ?? this.lastPlayedMs,
      isDeleted: isDeleted ?? this.isDeleted,
      coverArtPath: coverArtPath ?? this.coverArtPath,
      trackNumber: trackNumber ?? this.trackNumber,
      discNumber: discNumber ?? this.discNumber,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artistName.present) {
      map['artist_name'] = Variable<String>(artistName.value);
    }
    if (albumTitle.present) {
      map['album_title'] = Variable<String>(albumTitle.value);
    }
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (bitRateKbps.present) {
      map['bit_rate_kbps'] = Variable<int>(bitRateKbps.value);
    }
    if (sampleRateHz.present) {
      map['sample_rate_hz'] = Variable<int>(sampleRateHz.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (skipCount.present) {
      map['skip_count'] = Variable<int>(skipCount.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (dateAddedMs.present) {
      map['date_added_ms'] = Variable<int>(dateAddedMs.value);
    }
    if (lastPlayedMs.present) {
      map['last_played_ms'] = Variable<int>(lastPlayedMs.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (coverArtPath.present) {
      map['cover_art_path'] = Variable<String>(coverArtPath.value);
    }
    if (trackNumber.present) {
      map['track_number'] = Variable<int>(trackNumber.value);
    }
    if (discNumber.present) {
      map['disc_number'] = Variable<int>(discNumber.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TracksTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artistName: $artistName, ')
          ..write('albumTitle: $albumTitle, ')
          ..write('artistId: $artistId, ')
          ..write('albumId: $albumId, ')
          ..write('durationMs: $durationMs, ')
          ..write('filePath: $filePath, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('format: $format, ')
          ..write('bitRateKbps: $bitRateKbps, ')
          ..write('sampleRateHz: $sampleRateHz, ')
          ..write('playCount: $playCount, ')
          ..write('skipCount: $skipCount, ')
          ..write('rating: $rating, ')
          ..write('dateAddedMs: $dateAddedMs, ')
          ..write('lastPlayedMs: $lastPlayedMs, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('coverArtPath: $coverArtPath, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('discNumber: $discNumber, ')
          ..write('genre: $genre, ')
          ..write('year: $year, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlbumsTableTable extends AlbumsTable
    with TableInfo<$AlbumsTableTable, AlbumRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlbumsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistIdMeta = const VerificationMeta(
    'artistId',
  );
  @override
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
    'artist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistNameMeta = const VerificationMeta(
    'artistName',
  );
  @override
  late final GeneratedColumn<String> artistName = GeneratedColumn<String>(
    'artist_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _coverArtPathMeta = const VerificationMeta(
    'coverArtPath',
  );
  @override
  late final GeneratedColumn<String> coverArtPath = GeneratedColumn<String>(
    'cover_art_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackCountMeta = const VerificationMeta(
    'trackCount',
  );
  @override
  late final GeneratedColumn<int> trackCount = GeneratedColumn<int>(
    'track_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalDurationMsMeta = const VerificationMeta(
    'totalDurationMs',
  );
  @override
  late final GeneratedColumn<int> totalDurationMs = GeneratedColumn<int>(
    'total_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dateAddedMsMeta = const VerificationMeta(
    'dateAddedMs',
  );
  @override
  late final GeneratedColumn<int> dateAddedMs = GeneratedColumn<int>(
    'date_added_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
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
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'albums';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlbumRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist_id')) {
      context.handle(
        _artistIdMeta,
        artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_artistIdMeta);
    }
    if (data.containsKey('artist_name')) {
      context.handle(
        _artistNameMeta,
        artistName.isAcceptableOrUnknown(data['artist_name']!, _artistNameMeta),
      );
    } else if (isInserting) {
      context.missing(_artistNameMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('cover_art_path')) {
      context.handle(
        _coverArtPathMeta,
        coverArtPath.isAcceptableOrUnknown(
          data['cover_art_path']!,
          _coverArtPathMeta,
        ),
      );
    }
    if (data.containsKey('track_count')) {
      context.handle(
        _trackCountMeta,
        trackCount.isAcceptableOrUnknown(data['track_count']!, _trackCountMeta),
      );
    }
    if (data.containsKey('total_duration_ms')) {
      context.handle(
        _totalDurationMsMeta,
        totalDurationMs.isAcceptableOrUnknown(
          data['total_duration_ms']!,
          _totalDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('date_added_ms')) {
      context.handle(
        _dateAddedMsMeta,
        dateAddedMs.isAcceptableOrUnknown(
          data['date_added_ms']!,
          _dateAddedMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateAddedMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlbumRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlbumRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_id'],
      )!,
      artistName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_name'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      coverArtPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_art_path'],
      ),
      trackCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_count'],
      )!,
      totalDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_duration_ms'],
      )!,
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      )!,
      dateAddedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_added_ms'],
      )!,
    );
  }

  @override
  $AlbumsTableTable createAlias(String alias) {
    return $AlbumsTableTable(attachedDatabase, alias);
  }
}

class AlbumRow extends DataClass implements Insertable<AlbumRow> {
  final String id;
  final String title;
  final String artistId;
  final String artistName;
  final int year;
  final String? coverArtPath;
  final int trackCount;
  final int totalDurationMs;
  final String genre;
  final int dateAddedMs;
  const AlbumRow({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    required this.year,
    this.coverArtPath,
    required this.trackCount,
    required this.totalDurationMs,
    required this.genre,
    required this.dateAddedMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['artist_id'] = Variable<String>(artistId);
    map['artist_name'] = Variable<String>(artistName);
    map['year'] = Variable<int>(year);
    if (!nullToAbsent || coverArtPath != null) {
      map['cover_art_path'] = Variable<String>(coverArtPath);
    }
    map['track_count'] = Variable<int>(trackCount);
    map['total_duration_ms'] = Variable<int>(totalDurationMs);
    map['genre'] = Variable<String>(genre);
    map['date_added_ms'] = Variable<int>(dateAddedMs);
    return map;
  }

  AlbumsTableCompanion toCompanion(bool nullToAbsent) {
    return AlbumsTableCompanion(
      id: Value(id),
      title: Value(title),
      artistId: Value(artistId),
      artistName: Value(artistName),
      year: Value(year),
      coverArtPath: coverArtPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverArtPath),
      trackCount: Value(trackCount),
      totalDurationMs: Value(totalDurationMs),
      genre: Value(genre),
      dateAddedMs: Value(dateAddedMs),
    );
  }

  factory AlbumRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlbumRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      artistId: serializer.fromJson<String>(json['artistId']),
      artistName: serializer.fromJson<String>(json['artistName']),
      year: serializer.fromJson<int>(json['year']),
      coverArtPath: serializer.fromJson<String?>(json['coverArtPath']),
      trackCount: serializer.fromJson<int>(json['trackCount']),
      totalDurationMs: serializer.fromJson<int>(json['totalDurationMs']),
      genre: serializer.fromJson<String>(json['genre']),
      dateAddedMs: serializer.fromJson<int>(json['dateAddedMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'artistId': serializer.toJson<String>(artistId),
      'artistName': serializer.toJson<String>(artistName),
      'year': serializer.toJson<int>(year),
      'coverArtPath': serializer.toJson<String?>(coverArtPath),
      'trackCount': serializer.toJson<int>(trackCount),
      'totalDurationMs': serializer.toJson<int>(totalDurationMs),
      'genre': serializer.toJson<String>(genre),
      'dateAddedMs': serializer.toJson<int>(dateAddedMs),
    };
  }

  AlbumRow copyWith({
    String? id,
    String? title,
    String? artistId,
    String? artistName,
    int? year,
    Value<String?> coverArtPath = const Value.absent(),
    int? trackCount,
    int? totalDurationMs,
    String? genre,
    int? dateAddedMs,
  }) => AlbumRow(
    id: id ?? this.id,
    title: title ?? this.title,
    artistId: artistId ?? this.artistId,
    artistName: artistName ?? this.artistName,
    year: year ?? this.year,
    coverArtPath: coverArtPath.present ? coverArtPath.value : this.coverArtPath,
    trackCount: trackCount ?? this.trackCount,
    totalDurationMs: totalDurationMs ?? this.totalDurationMs,
    genre: genre ?? this.genre,
    dateAddedMs: dateAddedMs ?? this.dateAddedMs,
  );
  AlbumRow copyWithCompanion(AlbumsTableCompanion data) {
    return AlbumRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      artistId: data.artistId.present ? data.artistId.value : this.artistId,
      artistName: data.artistName.present
          ? data.artistName.value
          : this.artistName,
      year: data.year.present ? data.year.value : this.year,
      coverArtPath: data.coverArtPath.present
          ? data.coverArtPath.value
          : this.coverArtPath,
      trackCount: data.trackCount.present
          ? data.trackCount.value
          : this.trackCount,
      totalDurationMs: data.totalDurationMs.present
          ? data.totalDurationMs.value
          : this.totalDurationMs,
      genre: data.genre.present ? data.genre.value : this.genre,
      dateAddedMs: data.dateAddedMs.present
          ? data.dateAddedMs.value
          : this.dateAddedMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlbumRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artistId: $artistId, ')
          ..write('artistName: $artistName, ')
          ..write('year: $year, ')
          ..write('coverArtPath: $coverArtPath, ')
          ..write('trackCount: $trackCount, ')
          ..write('totalDurationMs: $totalDurationMs, ')
          ..write('genre: $genre, ')
          ..write('dateAddedMs: $dateAddedMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlbumRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.artistId == this.artistId &&
          other.artistName == this.artistName &&
          other.year == this.year &&
          other.coverArtPath == this.coverArtPath &&
          other.trackCount == this.trackCount &&
          other.totalDurationMs == this.totalDurationMs &&
          other.genre == this.genre &&
          other.dateAddedMs == this.dateAddedMs);
}

class AlbumsTableCompanion extends UpdateCompanion<AlbumRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> artistId;
  final Value<String> artistName;
  final Value<int> year;
  final Value<String?> coverArtPath;
  final Value<int> trackCount;
  final Value<int> totalDurationMs;
  final Value<String> genre;
  final Value<int> dateAddedMs;
  final Value<int> rowid;
  const AlbumsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.artistId = const Value.absent(),
    this.artistName = const Value.absent(),
    this.year = const Value.absent(),
    this.coverArtPath = const Value.absent(),
    this.trackCount = const Value.absent(),
    this.totalDurationMs = const Value.absent(),
    this.genre = const Value.absent(),
    this.dateAddedMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlbumsTableCompanion.insert({
    required String id,
    required String title,
    required String artistId,
    required String artistName,
    this.year = const Value.absent(),
    this.coverArtPath = const Value.absent(),
    this.trackCount = const Value.absent(),
    this.totalDurationMs = const Value.absent(),
    this.genre = const Value.absent(),
    required int dateAddedMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       artistId = Value(artistId),
       artistName = Value(artistName),
       dateAddedMs = Value(dateAddedMs);
  static Insertable<AlbumRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? artistId,
    Expression<String>? artistName,
    Expression<int>? year,
    Expression<String>? coverArtPath,
    Expression<int>? trackCount,
    Expression<int>? totalDurationMs,
    Expression<String>? genre,
    Expression<int>? dateAddedMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (artistId != null) 'artist_id': artistId,
      if (artistName != null) 'artist_name': artistName,
      if (year != null) 'year': year,
      if (coverArtPath != null) 'cover_art_path': coverArtPath,
      if (trackCount != null) 'track_count': trackCount,
      if (totalDurationMs != null) 'total_duration_ms': totalDurationMs,
      if (genre != null) 'genre': genre,
      if (dateAddedMs != null) 'date_added_ms': dateAddedMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlbumsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? artistId,
    Value<String>? artistName,
    Value<int>? year,
    Value<String?>? coverArtPath,
    Value<int>? trackCount,
    Value<int>? totalDurationMs,
    Value<String>? genre,
    Value<int>? dateAddedMs,
    Value<int>? rowid,
  }) {
    return AlbumsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      artistId: artistId ?? this.artistId,
      artistName: artistName ?? this.artistName,
      year: year ?? this.year,
      coverArtPath: coverArtPath ?? this.coverArtPath,
      trackCount: trackCount ?? this.trackCount,
      totalDurationMs: totalDurationMs ?? this.totalDurationMs,
      genre: genre ?? this.genre,
      dateAddedMs: dateAddedMs ?? this.dateAddedMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (artistName.present) {
      map['artist_name'] = Variable<String>(artistName.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (coverArtPath.present) {
      map['cover_art_path'] = Variable<String>(coverArtPath.value);
    }
    if (trackCount.present) {
      map['track_count'] = Variable<int>(trackCount.value);
    }
    if (totalDurationMs.present) {
      map['total_duration_ms'] = Variable<int>(totalDurationMs.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (dateAddedMs.present) {
      map['date_added_ms'] = Variable<int>(dateAddedMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artistId: $artistId, ')
          ..write('artistName: $artistName, ')
          ..write('year: $year, ')
          ..write('coverArtPath: $coverArtPath, ')
          ..write('trackCount: $trackCount, ')
          ..write('totalDurationMs: $totalDurationMs, ')
          ..write('genre: $genre, ')
          ..write('dateAddedMs: $dateAddedMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ArtistsTableTable extends ArtistsTable
    with TableInfo<$ArtistsTableTable, ArtistRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArtistsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _trackCountMeta = const VerificationMeta(
    'trackCount',
  );
  @override
  late final GeneratedColumn<int> trackCount = GeneratedColumn<int>(
    'track_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _albumCountMeta = const VerificationMeta(
    'albumCount',
  );
  @override
  late final GeneratedColumn<int> albumCount = GeneratedColumn<int>(
    'album_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    trackCount,
    albumCount,
    imagePath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'artists';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArtistRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('track_count')) {
      context.handle(
        _trackCountMeta,
        trackCount.isAcceptableOrUnknown(data['track_count']!, _trackCountMeta),
      );
    }
    if (data.containsKey('album_count')) {
      context.handle(
        _albumCountMeta,
        albumCount.isAcceptableOrUnknown(data['album_count']!, _albumCountMeta),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArtistRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArtistRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      trackCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_count'],
      )!,
      albumCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}album_count'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
    );
  }

  @override
  $ArtistsTableTable createAlias(String alias) {
    return $ArtistsTableTable(attachedDatabase, alias);
  }
}

class ArtistRow extends DataClass implements Insertable<ArtistRow> {
  final String id;
  final String name;
  final int trackCount;
  final int albumCount;
  final String? imagePath;
  const ArtistRow({
    required this.id,
    required this.name,
    required this.trackCount,
    required this.albumCount,
    this.imagePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['track_count'] = Variable<int>(trackCount);
    map['album_count'] = Variable<int>(albumCount);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    return map;
  }

  ArtistsTableCompanion toCompanion(bool nullToAbsent) {
    return ArtistsTableCompanion(
      id: Value(id),
      name: Value(name),
      trackCount: Value(trackCount),
      albumCount: Value(albumCount),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
    );
  }

  factory ArtistRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArtistRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      trackCount: serializer.fromJson<int>(json['trackCount']),
      albumCount: serializer.fromJson<int>(json['albumCount']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'trackCount': serializer.toJson<int>(trackCount),
      'albumCount': serializer.toJson<int>(albumCount),
      'imagePath': serializer.toJson<String?>(imagePath),
    };
  }

  ArtistRow copyWith({
    String? id,
    String? name,
    int? trackCount,
    int? albumCount,
    Value<String?> imagePath = const Value.absent(),
  }) => ArtistRow(
    id: id ?? this.id,
    name: name ?? this.name,
    trackCount: trackCount ?? this.trackCount,
    albumCount: albumCount ?? this.albumCount,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
  );
  ArtistRow copyWithCompanion(ArtistsTableCompanion data) {
    return ArtistRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      trackCount: data.trackCount.present
          ? data.trackCount.value
          : this.trackCount,
      albumCount: data.albumCount.present
          ? data.albumCount.value
          : this.albumCount,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArtistRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('trackCount: $trackCount, ')
          ..write('albumCount: $albumCount, ')
          ..write('imagePath: $imagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, trackCount, albumCount, imagePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArtistRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.trackCount == this.trackCount &&
          other.albumCount == this.albumCount &&
          other.imagePath == this.imagePath);
}

class ArtistsTableCompanion extends UpdateCompanion<ArtistRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> trackCount;
  final Value<int> albumCount;
  final Value<String?> imagePath;
  final Value<int> rowid;
  const ArtistsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.trackCount = const Value.absent(),
    this.albumCount = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArtistsTableCompanion.insert({
    required String id,
    required String name,
    this.trackCount = const Value.absent(),
    this.albumCount = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<ArtistRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? trackCount,
    Expression<int>? albumCount,
    Expression<String>? imagePath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (trackCount != null) 'track_count': trackCount,
      if (albumCount != null) 'album_count': albumCount,
      if (imagePath != null) 'image_path': imagePath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArtistsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? trackCount,
    Value<int>? albumCount,
    Value<String?>? imagePath,
    Value<int>? rowid,
  }) {
    return ArtistsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      trackCount: trackCount ?? this.trackCount,
      albumCount: albumCount ?? this.albumCount,
      imagePath: imagePath ?? this.imagePath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (trackCount.present) {
      map['track_count'] = Variable<int>(trackCount.value);
    }
    if (albumCount.present) {
      map['album_count'] = Variable<int>(albumCount.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtistsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('trackCount: $trackCount, ')
          ..write('albumCount: $albumCount, ')
          ..write('imagePath: $imagePath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTableTable extends PlaylistsTable
    with TableInfo<$PlaylistsTableTable, PlaylistRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('userCreated'),
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
    'mood',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverArtPathMeta = const VerificationMeta(
    'coverArtPath',
  );
  @override
  late final GeneratedColumn<String> coverArtPath = GeneratedColumn<String>(
    'cover_art_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverArtPathsJsonMeta = const VerificationMeta(
    'coverArtPathsJson',
  );
  @override
  late final GeneratedColumn<String> coverArtPathsJson =
      GeneratedColumn<String>(
        'cover_art_paths_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    type,
    mood,
    createdAtMs,
    updatedAtMs,
    coverArtPath,
    coverArtPathsJson,
    isPinned,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('cover_art_path')) {
      context.handle(
        _coverArtPathMeta,
        coverArtPath.isAcceptableOrUnknown(
          data['cover_art_path']!,
          _coverArtPathMeta,
        ),
      );
    }
    if (data.containsKey('cover_art_paths_json')) {
      context.handle(
        _coverArtPathsJsonMeta,
        coverArtPathsJson.isAcceptableOrUnknown(
          data['cover_art_paths_json']!,
          _coverArtPathsJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood'],
      ),
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      coverArtPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_art_path'],
      ),
      coverArtPathsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_art_paths_json'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
    );
  }

  @override
  $PlaylistsTableTable createAlias(String alias) {
    return $PlaylistsTableTable(attachedDatabase, alias);
  }
}

class PlaylistRow extends DataClass implements Insertable<PlaylistRow> {
  final String id;
  final String name;
  final String description;
  final String type;
  final String? mood;
  final int createdAtMs;
  final int updatedAtMs;
  final String? coverArtPath;

  /// JSON array of up to 4 album-art paths; the UI draws them as a 2x2 mosaic.
  final String coverArtPathsJson;
  final bool isPinned;
  const PlaylistRow({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.mood,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.coverArtPath,
    required this.coverArtPathsJson,
    required this.isPinned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<String>(mood);
    }
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || coverArtPath != null) {
      map['cover_art_path'] = Variable<String>(coverArtPath);
    }
    map['cover_art_paths_json'] = Variable<String>(coverArtPathsJson);
    map['is_pinned'] = Variable<bool>(isPinned);
    return map;
  }

  PlaylistsTableCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsTableCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      type: Value(type),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      coverArtPath: coverArtPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverArtPath),
      coverArtPathsJson: Value(coverArtPathsJson),
      isPinned: Value(isPinned),
    );
  }

  factory PlaylistRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      type: serializer.fromJson<String>(json['type']),
      mood: serializer.fromJson<String?>(json['mood']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      coverArtPath: serializer.fromJson<String?>(json['coverArtPath']),
      coverArtPathsJson: serializer.fromJson<String>(json['coverArtPathsJson']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'type': serializer.toJson<String>(type),
      'mood': serializer.toJson<String?>(mood),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'coverArtPath': serializer.toJson<String?>(coverArtPath),
      'coverArtPathsJson': serializer.toJson<String>(coverArtPathsJson),
      'isPinned': serializer.toJson<bool>(isPinned),
    };
  }

  PlaylistRow copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    Value<String?> mood = const Value.absent(),
    int? createdAtMs,
    int? updatedAtMs,
    Value<String?> coverArtPath = const Value.absent(),
    String? coverArtPathsJson,
    bool? isPinned,
  }) => PlaylistRow(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    type: type ?? this.type,
    mood: mood.present ? mood.value : this.mood,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    coverArtPath: coverArtPath.present ? coverArtPath.value : this.coverArtPath,
    coverArtPathsJson: coverArtPathsJson ?? this.coverArtPathsJson,
    isPinned: isPinned ?? this.isPinned,
  );
  PlaylistRow copyWithCompanion(PlaylistsTableCompanion data) {
    return PlaylistRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      type: data.type.present ? data.type.value : this.type,
      mood: data.mood.present ? data.mood.value : this.mood,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      coverArtPath: data.coverArtPath.present
          ? data.coverArtPath.value
          : this.coverArtPath,
      coverArtPathsJson: data.coverArtPathsJson.present
          ? data.coverArtPathsJson.value
          : this.coverArtPathsJson,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('mood: $mood, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('coverArtPath: $coverArtPath, ')
          ..write('coverArtPathsJson: $coverArtPathsJson, ')
          ..write('isPinned: $isPinned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    type,
    mood,
    createdAtMs,
    updatedAtMs,
    coverArtPath,
    coverArtPathsJson,
    isPinned,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.type == this.type &&
          other.mood == this.mood &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.coverArtPath == this.coverArtPath &&
          other.coverArtPathsJson == this.coverArtPathsJson &&
          other.isPinned == this.isPinned);
}

class PlaylistsTableCompanion extends UpdateCompanion<PlaylistRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<String> type;
  final Value<String?> mood;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<String?> coverArtPath;
  final Value<String> coverArtPathsJson;
  final Value<bool> isPinned;
  final Value<int> rowid;
  const PlaylistsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.mood = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.coverArtPath = const Value.absent(),
    this.coverArtPathsJson = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistsTableCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.mood = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    this.coverArtPath = const Value.absent(),
    this.coverArtPathsJson = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<PlaylistRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? type,
    Expression<String>? mood,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<String>? coverArtPath,
    Expression<String>? coverArtPathsJson,
    Expression<bool>? isPinned,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (mood != null) 'mood': mood,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (coverArtPath != null) 'cover_art_path': coverArtPath,
      if (coverArtPathsJson != null) 'cover_art_paths_json': coverArtPathsJson,
      if (isPinned != null) 'is_pinned': isPinned,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? description,
    Value<String>? type,
    Value<String?>? mood,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<String?>? coverArtPath,
    Value<String>? coverArtPathsJson,
    Value<bool>? isPinned,
    Value<int>? rowid,
  }) {
    return PlaylistsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      mood: mood ?? this.mood,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      coverArtPath: coverArtPath ?? this.coverArtPath,
      coverArtPathsJson: coverArtPathsJson ?? this.coverArtPathsJson,
      isPinned: isPinned ?? this.isPinned,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (coverArtPath.present) {
      map['cover_art_path'] = Variable<String>(coverArtPath.value);
    }
    if (coverArtPathsJson.present) {
      map['cover_art_paths_json'] = Variable<String>(coverArtPathsJson.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('mood: $mood, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('coverArtPath: $coverArtPath, ')
          ..write('coverArtPathsJson: $coverArtPathsJson, ')
          ..write('isPinned: $isPinned, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistTracksTableTable extends PlaylistTracksTable
    with TableInfo<$PlaylistTracksTableTable, PlaylistTrackRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistTracksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [playlistId, trackId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistTrackRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, trackId};
  @override
  PlaylistTrackRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistTrackRow(
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $PlaylistTracksTableTable createAlias(String alias) {
    return $PlaylistTracksTableTable(attachedDatabase, alias);
  }
}

class PlaylistTrackRow extends DataClass
    implements Insertable<PlaylistTrackRow> {
  final String playlistId;
  final String trackId;

  /// 0-based position within the playlist.
  final int position;
  const PlaylistTrackRow({
    required this.playlistId,
    required this.trackId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['track_id'] = Variable<String>(trackId);
    map['position'] = Variable<int>(position);
    return map;
  }

  PlaylistTracksTableCompanion toCompanion(bool nullToAbsent) {
    return PlaylistTracksTableCompanion(
      playlistId: Value(playlistId),
      trackId: Value(trackId),
      position: Value(position),
    );
  }

  factory PlaylistTrackRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistTrackRow(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      trackId: serializer.fromJson<String>(json['trackId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'trackId': serializer.toJson<String>(trackId),
      'position': serializer.toJson<int>(position),
    };
  }

  PlaylistTrackRow copyWith({
    String? playlistId,
    String? trackId,
    int? position,
  }) => PlaylistTrackRow(
    playlistId: playlistId ?? this.playlistId,
    trackId: trackId ?? this.trackId,
    position: position ?? this.position,
  );
  PlaylistTrackRow copyWithCompanion(PlaylistTracksTableCompanion data) {
    return PlaylistTrackRow(
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTrackRow(')
          ..write('playlistId: $playlistId, ')
          ..write('trackId: $trackId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, trackId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistTrackRow &&
          other.playlistId == this.playlistId &&
          other.trackId == this.trackId &&
          other.position == this.position);
}

class PlaylistTracksTableCompanion extends UpdateCompanion<PlaylistTrackRow> {
  final Value<String> playlistId;
  final Value<String> trackId;
  final Value<int> position;
  final Value<int> rowid;
  const PlaylistTracksTableCompanion({
    this.playlistId = const Value.absent(),
    this.trackId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistTracksTableCompanion.insert({
    required String playlistId,
    required String trackId,
    required int position,
    this.rowid = const Value.absent(),
  }) : playlistId = Value(playlistId),
       trackId = Value(trackId),
       position = Value(position);
  static Insertable<PlaylistTrackRow> custom({
    Expression<String>? playlistId,
    Expression<String>? trackId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (trackId != null) 'track_id': trackId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistTracksTableCompanion copyWith({
    Value<String>? playlistId,
    Value<String>? trackId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return PlaylistTracksTableCompanion(
      playlistId: playlistId ?? this.playlistId,
      trackId: trackId ?? this.trackId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTracksTableCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('trackId: $trackId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaybackHistoryTableTable extends PlaybackHistoryTable
    with TableInfo<$PlaybackHistoryTableTable, PlaybackHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playedAtMsMeta = const VerificationMeta(
    'playedAtMs',
  );
  @override
  late final GeneratedColumn<int> playedAtMs = GeneratedColumn<int>(
    'played_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationPlayedMsMeta = const VerificationMeta(
    'durationPlayedMs',
  );
  @override
  late final GeneratedColumn<int> durationPlayedMs = GeneratedColumn<int>(
    'duration_played_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skippedMeta = const VerificationMeta(
    'skipped',
  );
  @override
  late final GeneratedColumn<bool> skipped = GeneratedColumn<bool>(
    'skipped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skipped" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _contextTypeMeta = const VerificationMeta(
    'contextType',
  );
  @override
  late final GeneratedColumn<String> contextType = GeneratedColumn<String>(
    'context_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('library'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trackId,
    playedAtMs,
    durationPlayedMs,
    skipped,
    completed,
    contextType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaybackHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('played_at_ms')) {
      context.handle(
        _playedAtMsMeta,
        playedAtMs.isAcceptableOrUnknown(
          data['played_at_ms']!,
          _playedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_playedAtMsMeta);
    }
    if (data.containsKey('duration_played_ms')) {
      context.handle(
        _durationPlayedMsMeta,
        durationPlayedMs.isAcceptableOrUnknown(
          data['duration_played_ms']!,
          _durationPlayedMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationPlayedMsMeta);
    }
    if (data.containsKey('skipped')) {
      context.handle(
        _skippedMeta,
        skipped.isAcceptableOrUnknown(data['skipped']!, _skippedMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('context_type')) {
      context.handle(
        _contextTypeMeta,
        contextType.isAcceptableOrUnknown(
          data['context_type']!,
          _contextTypeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaybackHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackHistoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      playedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}played_at_ms'],
      )!,
      durationPlayedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_played_ms'],
      )!,
      skipped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}skipped'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      contextType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_type'],
      )!,
    );
  }

  @override
  $PlaybackHistoryTableTable createAlias(String alias) {
    return $PlaybackHistoryTableTable(attachedDatabase, alias);
  }
}

class PlaybackHistoryRow extends DataClass
    implements Insertable<PlaybackHistoryRow> {
  final int id;
  final String trackId;

  /// Epoch ms when playback started.
  final int playedAtMs;

  /// How many ms were actually played.
  final int durationPlayedMs;

  /// True when the user abandoned the track before [kListenCompletionRatio].
  final bool skipped;

  /// True when the track was listened to past [kListenCompletionRatio].
  ///
  /// Not simply `!skipped`: a track can be neither, when playback stopped
  /// partway without the user skipping (the app was closed, the queue ended,
  /// a call came in). Only completed rows count toward listening totals, so
  /// the statistics engine needs the distinction the skip flag cannot make.
  final bool completed;

  /// 'library', 'playlist', 'shuffle', 'mix'
  final String contextType;
  const PlaybackHistoryRow({
    required this.id,
    required this.trackId,
    required this.playedAtMs,
    required this.durationPlayedMs,
    required this.skipped,
    required this.completed,
    required this.contextType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['track_id'] = Variable<String>(trackId);
    map['played_at_ms'] = Variable<int>(playedAtMs);
    map['duration_played_ms'] = Variable<int>(durationPlayedMs);
    map['skipped'] = Variable<bool>(skipped);
    map['completed'] = Variable<bool>(completed);
    map['context_type'] = Variable<String>(contextType);
    return map;
  }

  PlaybackHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return PlaybackHistoryTableCompanion(
      id: Value(id),
      trackId: Value(trackId),
      playedAtMs: Value(playedAtMs),
      durationPlayedMs: Value(durationPlayedMs),
      skipped: Value(skipped),
      completed: Value(completed),
      contextType: Value(contextType),
    );
  }

  factory PlaybackHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackHistoryRow(
      id: serializer.fromJson<int>(json['id']),
      trackId: serializer.fromJson<String>(json['trackId']),
      playedAtMs: serializer.fromJson<int>(json['playedAtMs']),
      durationPlayedMs: serializer.fromJson<int>(json['durationPlayedMs']),
      skipped: serializer.fromJson<bool>(json['skipped']),
      completed: serializer.fromJson<bool>(json['completed']),
      contextType: serializer.fromJson<String>(json['contextType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'trackId': serializer.toJson<String>(trackId),
      'playedAtMs': serializer.toJson<int>(playedAtMs),
      'durationPlayedMs': serializer.toJson<int>(durationPlayedMs),
      'skipped': serializer.toJson<bool>(skipped),
      'completed': serializer.toJson<bool>(completed),
      'contextType': serializer.toJson<String>(contextType),
    };
  }

  PlaybackHistoryRow copyWith({
    int? id,
    String? trackId,
    int? playedAtMs,
    int? durationPlayedMs,
    bool? skipped,
    bool? completed,
    String? contextType,
  }) => PlaybackHistoryRow(
    id: id ?? this.id,
    trackId: trackId ?? this.trackId,
    playedAtMs: playedAtMs ?? this.playedAtMs,
    durationPlayedMs: durationPlayedMs ?? this.durationPlayedMs,
    skipped: skipped ?? this.skipped,
    completed: completed ?? this.completed,
    contextType: contextType ?? this.contextType,
  );
  PlaybackHistoryRow copyWithCompanion(PlaybackHistoryTableCompanion data) {
    return PlaybackHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      playedAtMs: data.playedAtMs.present
          ? data.playedAtMs.value
          : this.playedAtMs,
      durationPlayedMs: data.durationPlayedMs.present
          ? data.durationPlayedMs.value
          : this.durationPlayedMs,
      skipped: data.skipped.present ? data.skipped.value : this.skipped,
      completed: data.completed.present ? data.completed.value : this.completed,
      contextType: data.contextType.present
          ? data.contextType.value
          : this.contextType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackHistoryRow(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('playedAtMs: $playedAtMs, ')
          ..write('durationPlayedMs: $durationPlayedMs, ')
          ..write('skipped: $skipped, ')
          ..write('completed: $completed, ')
          ..write('contextType: $contextType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    trackId,
    playedAtMs,
    durationPlayedMs,
    skipped,
    completed,
    contextType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackHistoryRow &&
          other.id == this.id &&
          other.trackId == this.trackId &&
          other.playedAtMs == this.playedAtMs &&
          other.durationPlayedMs == this.durationPlayedMs &&
          other.skipped == this.skipped &&
          other.completed == this.completed &&
          other.contextType == this.contextType);
}

class PlaybackHistoryTableCompanion
    extends UpdateCompanion<PlaybackHistoryRow> {
  final Value<int> id;
  final Value<String> trackId;
  final Value<int> playedAtMs;
  final Value<int> durationPlayedMs;
  final Value<bool> skipped;
  final Value<bool> completed;
  final Value<String> contextType;
  const PlaybackHistoryTableCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.playedAtMs = const Value.absent(),
    this.durationPlayedMs = const Value.absent(),
    this.skipped = const Value.absent(),
    this.completed = const Value.absent(),
    this.contextType = const Value.absent(),
  });
  PlaybackHistoryTableCompanion.insert({
    this.id = const Value.absent(),
    required String trackId,
    required int playedAtMs,
    required int durationPlayedMs,
    this.skipped = const Value.absent(),
    this.completed = const Value.absent(),
    this.contextType = const Value.absent(),
  }) : trackId = Value(trackId),
       playedAtMs = Value(playedAtMs),
       durationPlayedMs = Value(durationPlayedMs);
  static Insertable<PlaybackHistoryRow> custom({
    Expression<int>? id,
    Expression<String>? trackId,
    Expression<int>? playedAtMs,
    Expression<int>? durationPlayedMs,
    Expression<bool>? skipped,
    Expression<bool>? completed,
    Expression<String>? contextType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
      if (playedAtMs != null) 'played_at_ms': playedAtMs,
      if (durationPlayedMs != null) 'duration_played_ms': durationPlayedMs,
      if (skipped != null) 'skipped': skipped,
      if (completed != null) 'completed': completed,
      if (contextType != null) 'context_type': contextType,
    });
  }

  PlaybackHistoryTableCompanion copyWith({
    Value<int>? id,
    Value<String>? trackId,
    Value<int>? playedAtMs,
    Value<int>? durationPlayedMs,
    Value<bool>? skipped,
    Value<bool>? completed,
    Value<String>? contextType,
  }) {
    return PlaybackHistoryTableCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      playedAtMs: playedAtMs ?? this.playedAtMs,
      durationPlayedMs: durationPlayedMs ?? this.durationPlayedMs,
      skipped: skipped ?? this.skipped,
      completed: completed ?? this.completed,
      contextType: contextType ?? this.contextType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (playedAtMs.present) {
      map['played_at_ms'] = Variable<int>(playedAtMs.value);
    }
    if (durationPlayedMs.present) {
      map['duration_played_ms'] = Variable<int>(durationPlayedMs.value);
    }
    if (skipped.present) {
      map['skipped'] = Variable<bool>(skipped.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (contextType.present) {
      map['context_type'] = Variable<String>(contextType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('playedAtMs: $playedAtMs, ')
          ..write('durationPlayedMs: $durationPlayedMs, ')
          ..write('skipped: $skipped, ')
          ..write('completed: $completed, ')
          ..write('contextType: $contextType')
          ..write(')'))
        .toString();
  }
}

class $ShuffleStateTableTable extends ShuffleStateTable
    with TableInfo<$ShuffleStateTableTable, ShuffleStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShuffleStateTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contextIdMeta = const VerificationMeta(
    'contextId',
  );
  @override
  late final GeneratedColumn<String> contextId = GeneratedColumn<String>(
    'context_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('all_songs'),
  );
  static const VerificationMeta _configJsonMeta = const VerificationMeta(
    'configJson',
  );
  @override
  late final GeneratedColumn<String> configJson = GeneratedColumn<String>(
    'config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shuffledIdsJsonMeta = const VerificationMeta(
    'shuffledIdsJson',
  );
  @override
  late final GeneratedColumn<String> shuffledIdsJson = GeneratedColumn<String>(
    'shuffled_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentIndexMeta = const VerificationMeta(
    'currentIndex',
  );
  @override
  late final GeneratedColumn<int> currentIndex = GeneratedColumn<int>(
    'current_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stateJsonMeta = const VerificationMeta(
    'stateJson',
  );
  @override
  late final GeneratedColumn<String> stateJson = GeneratedColumn<String>(
    'state_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contextId,
    configJson,
    shuffledIdsJson,
    currentIndex,
    createdAtMs,
    updatedAtMs,
    stateJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shuffle_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShuffleStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('context_id')) {
      context.handle(
        _contextIdMeta,
        contextId.isAcceptableOrUnknown(data['context_id']!, _contextIdMeta),
      );
    }
    if (data.containsKey('config_json')) {
      context.handle(
        _configJsonMeta,
        configJson.isAcceptableOrUnknown(data['config_json']!, _configJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_configJsonMeta);
    }
    if (data.containsKey('shuffled_ids_json')) {
      context.handle(
        _shuffledIdsJsonMeta,
        shuffledIdsJson.isAcceptableOrUnknown(
          data['shuffled_ids_json']!,
          _shuffledIdsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_shuffledIdsJsonMeta);
    }
    if (data.containsKey('current_index')) {
      context.handle(
        _currentIndexMeta,
        currentIndex.isAcceptableOrUnknown(
          data['current_index']!,
          _currentIndexMeta,
        ),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('state_json')) {
      context.handle(
        _stateJsonMeta,
        stateJson.isAcceptableOrUnknown(data['state_json']!, _stateJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShuffleStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShuffleStateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contextId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_id'],
      )!,
      configJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_json'],
      )!,
      shuffledIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shuffled_ids_json'],
      )!,
      currentIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_index'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      stateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state_json'],
      )!,
    );
  }

  @override
  $ShuffleStateTableTable createAlias(String alias) {
    return $ShuffleStateTableTable(attachedDatabase, alias);
  }
}

class ShuffleStateRow extends DataClass implements Insertable<ShuffleStateRow> {
  final int id;

  /// Shuffle context this state belongs to, e.g. 'all_songs' or 'playlist_42'.
  /// One persisted state per context (enforced by a unique index; see
  /// AppDatabase.migration).
  final String contextId;

  /// JSON-encoded ShuffleConfig.
  final String configJson;

  /// JSON-encoded [List] of track IDs in shuffled order.
  final String shuffledIdsJson;
  final int currentIndex;
  final int createdAtMs;

  /// Epoch ms of the last save.
  final int updatedAtMs;

  /// Full engine state blob from IntelliShuffleEngine.serializeState().
  /// The columns above are denormalised copies kept for debugging/queries.
  final String stateJson;
  const ShuffleStateRow({
    required this.id,
    required this.contextId,
    required this.configJson,
    required this.shuffledIdsJson,
    required this.currentIndex,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.stateJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['context_id'] = Variable<String>(contextId);
    map['config_json'] = Variable<String>(configJson);
    map['shuffled_ids_json'] = Variable<String>(shuffledIdsJson);
    map['current_index'] = Variable<int>(currentIndex);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    map['state_json'] = Variable<String>(stateJson);
    return map;
  }

  ShuffleStateTableCompanion toCompanion(bool nullToAbsent) {
    return ShuffleStateTableCompanion(
      id: Value(id),
      contextId: Value(contextId),
      configJson: Value(configJson),
      shuffledIdsJson: Value(shuffledIdsJson),
      currentIndex: Value(currentIndex),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      stateJson: Value(stateJson),
    );
  }

  factory ShuffleStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShuffleStateRow(
      id: serializer.fromJson<int>(json['id']),
      contextId: serializer.fromJson<String>(json['contextId']),
      configJson: serializer.fromJson<String>(json['configJson']),
      shuffledIdsJson: serializer.fromJson<String>(json['shuffledIdsJson']),
      currentIndex: serializer.fromJson<int>(json['currentIndex']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      stateJson: serializer.fromJson<String>(json['stateJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contextId': serializer.toJson<String>(contextId),
      'configJson': serializer.toJson<String>(configJson),
      'shuffledIdsJson': serializer.toJson<String>(shuffledIdsJson),
      'currentIndex': serializer.toJson<int>(currentIndex),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'stateJson': serializer.toJson<String>(stateJson),
    };
  }

  ShuffleStateRow copyWith({
    int? id,
    String? contextId,
    String? configJson,
    String? shuffledIdsJson,
    int? currentIndex,
    int? createdAtMs,
    int? updatedAtMs,
    String? stateJson,
  }) => ShuffleStateRow(
    id: id ?? this.id,
    contextId: contextId ?? this.contextId,
    configJson: configJson ?? this.configJson,
    shuffledIdsJson: shuffledIdsJson ?? this.shuffledIdsJson,
    currentIndex: currentIndex ?? this.currentIndex,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    stateJson: stateJson ?? this.stateJson,
  );
  ShuffleStateRow copyWithCompanion(ShuffleStateTableCompanion data) {
    return ShuffleStateRow(
      id: data.id.present ? data.id.value : this.id,
      contextId: data.contextId.present ? data.contextId.value : this.contextId,
      configJson: data.configJson.present
          ? data.configJson.value
          : this.configJson,
      shuffledIdsJson: data.shuffledIdsJson.present
          ? data.shuffledIdsJson.value
          : this.shuffledIdsJson,
      currentIndex: data.currentIndex.present
          ? data.currentIndex.value
          : this.currentIndex,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      stateJson: data.stateJson.present ? data.stateJson.value : this.stateJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShuffleStateRow(')
          ..write('id: $id, ')
          ..write('contextId: $contextId, ')
          ..write('configJson: $configJson, ')
          ..write('shuffledIdsJson: $shuffledIdsJson, ')
          ..write('currentIndex: $currentIndex, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('stateJson: $stateJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contextId,
    configJson,
    shuffledIdsJson,
    currentIndex,
    createdAtMs,
    updatedAtMs,
    stateJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShuffleStateRow &&
          other.id == this.id &&
          other.contextId == this.contextId &&
          other.configJson == this.configJson &&
          other.shuffledIdsJson == this.shuffledIdsJson &&
          other.currentIndex == this.currentIndex &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.stateJson == this.stateJson);
}

class ShuffleStateTableCompanion extends UpdateCompanion<ShuffleStateRow> {
  final Value<int> id;
  final Value<String> contextId;
  final Value<String> configJson;
  final Value<String> shuffledIdsJson;
  final Value<int> currentIndex;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<String> stateJson;
  const ShuffleStateTableCompanion({
    this.id = const Value.absent(),
    this.contextId = const Value.absent(),
    this.configJson = const Value.absent(),
    this.shuffledIdsJson = const Value.absent(),
    this.currentIndex = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.stateJson = const Value.absent(),
  });
  ShuffleStateTableCompanion.insert({
    this.id = const Value.absent(),
    this.contextId = const Value.absent(),
    required String configJson,
    required String shuffledIdsJson,
    this.currentIndex = const Value.absent(),
    required int createdAtMs,
    this.updatedAtMs = const Value.absent(),
    this.stateJson = const Value.absent(),
  }) : configJson = Value(configJson),
       shuffledIdsJson = Value(shuffledIdsJson),
       createdAtMs = Value(createdAtMs);
  static Insertable<ShuffleStateRow> custom({
    Expression<int>? id,
    Expression<String>? contextId,
    Expression<String>? configJson,
    Expression<String>? shuffledIdsJson,
    Expression<int>? currentIndex,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<String>? stateJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contextId != null) 'context_id': contextId,
      if (configJson != null) 'config_json': configJson,
      if (shuffledIdsJson != null) 'shuffled_ids_json': shuffledIdsJson,
      if (currentIndex != null) 'current_index': currentIndex,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (stateJson != null) 'state_json': stateJson,
    });
  }

  ShuffleStateTableCompanion copyWith({
    Value<int>? id,
    Value<String>? contextId,
    Value<String>? configJson,
    Value<String>? shuffledIdsJson,
    Value<int>? currentIndex,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<String>? stateJson,
  }) {
    return ShuffleStateTableCompanion(
      id: id ?? this.id,
      contextId: contextId ?? this.contextId,
      configJson: configJson ?? this.configJson,
      shuffledIdsJson: shuffledIdsJson ?? this.shuffledIdsJson,
      currentIndex: currentIndex ?? this.currentIndex,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      stateJson: stateJson ?? this.stateJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contextId.present) {
      map['context_id'] = Variable<String>(contextId.value);
    }
    if (configJson.present) {
      map['config_json'] = Variable<String>(configJson.value);
    }
    if (shuffledIdsJson.present) {
      map['shuffled_ids_json'] = Variable<String>(shuffledIdsJson.value);
    }
    if (currentIndex.present) {
      map['current_index'] = Variable<int>(currentIndex.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (stateJson.present) {
      map['state_json'] = Variable<String>(stateJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShuffleStateTableCompanion(')
          ..write('id: $id, ')
          ..write('contextId: $contextId, ')
          ..write('configJson: $configJson, ')
          ..write('shuffledIdsJson: $shuffledIdsJson, ')
          ..write('currentIndex: $currentIndex, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('stateJson: $stateJson')
          ..write(')'))
        .toString();
  }
}

class $AudioFeaturesTableTable extends AudioFeaturesTable
    with TableInfo<$AudioFeaturesTableTable, AudioFeaturesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioFeaturesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tempoMeta = const VerificationMeta('tempo');
  @override
  late final GeneratedColumn<double> tempo = GeneratedColumn<double>(
    'tempo',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _energyMeta = const VerificationMeta('energy');
  @override
  late final GeneratedColumn<double> energy = GeneratedColumn<double>(
    'energy',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _valenceMeta = const VerificationMeta(
    'valence',
  );
  @override
  late final GeneratedColumn<double> valence = GeneratedColumn<double>(
    'valence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _danceabilityMeta = const VerificationMeta(
    'danceability',
  );
  @override
  late final GeneratedColumn<double> danceability = GeneratedColumn<double>(
    'danceability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _loudnessMeta = const VerificationMeta(
    'loudness',
  );
  @override
  late final GeneratedColumn<double> loudness = GeneratedColumn<double>(
    'loudness',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _acousticnessMeta = const VerificationMeta(
    'acousticness',
  );
  @override
  late final GeneratedColumn<double> acousticness = GeneratedColumn<double>(
    'acousticness',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _musicalKeyMeta = const VerificationMeta(
    'musicalKey',
  );
  @override
  late final GeneratedColumn<int> musicalKey = GeneratedColumn<int>(
    'musical_key',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(-1),
  );
  static const VerificationMeta _keyNameMeta = const VerificationMeta(
    'keyName',
  );
  @override
  late final GeneratedColumn<String> keyName = GeneratedColumn<String>(
    'key_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _fingerprintHashMeta = const VerificationMeta(
    'fingerprintHash',
  );
  @override
  late final GeneratedColumn<String> fingerprintHash = GeneratedColumn<String>(
    'fingerprint_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    trackId,
    tempo,
    energy,
    valence,
    danceability,
    loudness,
    acousticness,
    musicalKey,
    keyName,
    fingerprintHash,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_features';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioFeaturesRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('tempo')) {
      context.handle(
        _tempoMeta,
        tempo.isAcceptableOrUnknown(data['tempo']!, _tempoMeta),
      );
    }
    if (data.containsKey('energy')) {
      context.handle(
        _energyMeta,
        energy.isAcceptableOrUnknown(data['energy']!, _energyMeta),
      );
    }
    if (data.containsKey('valence')) {
      context.handle(
        _valenceMeta,
        valence.isAcceptableOrUnknown(data['valence']!, _valenceMeta),
      );
    }
    if (data.containsKey('danceability')) {
      context.handle(
        _danceabilityMeta,
        danceability.isAcceptableOrUnknown(
          data['danceability']!,
          _danceabilityMeta,
        ),
      );
    }
    if (data.containsKey('loudness')) {
      context.handle(
        _loudnessMeta,
        loudness.isAcceptableOrUnknown(data['loudness']!, _loudnessMeta),
      );
    }
    if (data.containsKey('acousticness')) {
      context.handle(
        _acousticnessMeta,
        acousticness.isAcceptableOrUnknown(
          data['acousticness']!,
          _acousticnessMeta,
        ),
      );
    }
    if (data.containsKey('musical_key')) {
      context.handle(
        _musicalKeyMeta,
        musicalKey.isAcceptableOrUnknown(data['musical_key']!, _musicalKeyMeta),
      );
    }
    if (data.containsKey('key_name')) {
      context.handle(
        _keyNameMeta,
        keyName.isAcceptableOrUnknown(data['key_name']!, _keyNameMeta),
      );
    }
    if (data.containsKey('fingerprint_hash')) {
      context.handle(
        _fingerprintHashMeta,
        fingerprintHash.isAcceptableOrUnknown(
          data['fingerprint_hash']!,
          _fingerprintHashMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  AudioFeaturesRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioFeaturesRow(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      tempo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tempo'],
      )!,
      energy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}energy'],
      )!,
      valence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valence'],
      )!,
      danceability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}danceability'],
      )!,
      loudness: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}loudness'],
      )!,
      acousticness: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}acousticness'],
      )!,
      musicalKey: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}musical_key'],
      )!,
      keyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key_name'],
      )!,
      fingerprintHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint_hash'],
      ),
    );
  }

  @override
  $AudioFeaturesTableTable createAlias(String alias) {
    return $AudioFeaturesTableTable(attachedDatabase, alias);
  }
}

class AudioFeaturesRow extends DataClass
    implements Insertable<AudioFeaturesRow> {
  /// FK → tracks.id. One row per track.
  final String trackId;

  /// Beat tempo normalised to [0, 1] (0 = 40 BPM, 1 = 220 BPM).
  final double tempo;

  /// Overall energy level (RMS-based).
  final double energy;

  /// Valence (musical positiveness, 0 = sad/angry, 1 = happy/euphoric).
  final double valence;

  /// Danceability (rhythmic regularity).
  final double danceability;

  /// Loudness normalised from dB (0 = quiet, 1 = loud).
  final double loudness;

  /// Acousticness (1 = purely acoustic, 0 = fully electronic).
  final double acousticness;

  /// Chromaprint fingerprint hash (hex string). Used by DuplicateDetector path 3.
  /// Camelot/pitch-class key, 0-11 (C..B). -1 when not yet analysed.
  final int musicalKey;

  /// Human-readable key, e.g. "A minor" / Camelot "8A". Empty when unknown.
  final String keyName;
  final String? fingerprintHash;
  const AudioFeaturesRow({
    required this.trackId,
    required this.tempo,
    required this.energy,
    required this.valence,
    required this.danceability,
    required this.loudness,
    required this.acousticness,
    required this.musicalKey,
    required this.keyName,
    this.fingerprintHash,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['tempo'] = Variable<double>(tempo);
    map['energy'] = Variable<double>(energy);
    map['valence'] = Variable<double>(valence);
    map['danceability'] = Variable<double>(danceability);
    map['loudness'] = Variable<double>(loudness);
    map['acousticness'] = Variable<double>(acousticness);
    map['musical_key'] = Variable<int>(musicalKey);
    map['key_name'] = Variable<String>(keyName);
    if (!nullToAbsent || fingerprintHash != null) {
      map['fingerprint_hash'] = Variable<String>(fingerprintHash);
    }
    return map;
  }

  AudioFeaturesTableCompanion toCompanion(bool nullToAbsent) {
    return AudioFeaturesTableCompanion(
      trackId: Value(trackId),
      tempo: Value(tempo),
      energy: Value(energy),
      valence: Value(valence),
      danceability: Value(danceability),
      loudness: Value(loudness),
      acousticness: Value(acousticness),
      musicalKey: Value(musicalKey),
      keyName: Value(keyName),
      fingerprintHash: fingerprintHash == null && nullToAbsent
          ? const Value.absent()
          : Value(fingerprintHash),
    );
  }

  factory AudioFeaturesRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioFeaturesRow(
      trackId: serializer.fromJson<String>(json['trackId']),
      tempo: serializer.fromJson<double>(json['tempo']),
      energy: serializer.fromJson<double>(json['energy']),
      valence: serializer.fromJson<double>(json['valence']),
      danceability: serializer.fromJson<double>(json['danceability']),
      loudness: serializer.fromJson<double>(json['loudness']),
      acousticness: serializer.fromJson<double>(json['acousticness']),
      musicalKey: serializer.fromJson<int>(json['musicalKey']),
      keyName: serializer.fromJson<String>(json['keyName']),
      fingerprintHash: serializer.fromJson<String?>(json['fingerprintHash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'tempo': serializer.toJson<double>(tempo),
      'energy': serializer.toJson<double>(energy),
      'valence': serializer.toJson<double>(valence),
      'danceability': serializer.toJson<double>(danceability),
      'loudness': serializer.toJson<double>(loudness),
      'acousticness': serializer.toJson<double>(acousticness),
      'musicalKey': serializer.toJson<int>(musicalKey),
      'keyName': serializer.toJson<String>(keyName),
      'fingerprintHash': serializer.toJson<String?>(fingerprintHash),
    };
  }

  AudioFeaturesRow copyWith({
    String? trackId,
    double? tempo,
    double? energy,
    double? valence,
    double? danceability,
    double? loudness,
    double? acousticness,
    int? musicalKey,
    String? keyName,
    Value<String?> fingerprintHash = const Value.absent(),
  }) => AudioFeaturesRow(
    trackId: trackId ?? this.trackId,
    tempo: tempo ?? this.tempo,
    energy: energy ?? this.energy,
    valence: valence ?? this.valence,
    danceability: danceability ?? this.danceability,
    loudness: loudness ?? this.loudness,
    acousticness: acousticness ?? this.acousticness,
    musicalKey: musicalKey ?? this.musicalKey,
    keyName: keyName ?? this.keyName,
    fingerprintHash: fingerprintHash.present
        ? fingerprintHash.value
        : this.fingerprintHash,
  );
  AudioFeaturesRow copyWithCompanion(AudioFeaturesTableCompanion data) {
    return AudioFeaturesRow(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      tempo: data.tempo.present ? data.tempo.value : this.tempo,
      energy: data.energy.present ? data.energy.value : this.energy,
      valence: data.valence.present ? data.valence.value : this.valence,
      danceability: data.danceability.present
          ? data.danceability.value
          : this.danceability,
      loudness: data.loudness.present ? data.loudness.value : this.loudness,
      acousticness: data.acousticness.present
          ? data.acousticness.value
          : this.acousticness,
      musicalKey: data.musicalKey.present
          ? data.musicalKey.value
          : this.musicalKey,
      keyName: data.keyName.present ? data.keyName.value : this.keyName,
      fingerprintHash: data.fingerprintHash.present
          ? data.fingerprintHash.value
          : this.fingerprintHash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioFeaturesRow(')
          ..write('trackId: $trackId, ')
          ..write('tempo: $tempo, ')
          ..write('energy: $energy, ')
          ..write('valence: $valence, ')
          ..write('danceability: $danceability, ')
          ..write('loudness: $loudness, ')
          ..write('acousticness: $acousticness, ')
          ..write('musicalKey: $musicalKey, ')
          ..write('keyName: $keyName, ')
          ..write('fingerprintHash: $fingerprintHash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    trackId,
    tempo,
    energy,
    valence,
    danceability,
    loudness,
    acousticness,
    musicalKey,
    keyName,
    fingerprintHash,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioFeaturesRow &&
          other.trackId == this.trackId &&
          other.tempo == this.tempo &&
          other.energy == this.energy &&
          other.valence == this.valence &&
          other.danceability == this.danceability &&
          other.loudness == this.loudness &&
          other.acousticness == this.acousticness &&
          other.musicalKey == this.musicalKey &&
          other.keyName == this.keyName &&
          other.fingerprintHash == this.fingerprintHash);
}

class AudioFeaturesTableCompanion extends UpdateCompanion<AudioFeaturesRow> {
  final Value<String> trackId;
  final Value<double> tempo;
  final Value<double> energy;
  final Value<double> valence;
  final Value<double> danceability;
  final Value<double> loudness;
  final Value<double> acousticness;
  final Value<int> musicalKey;
  final Value<String> keyName;
  final Value<String?> fingerprintHash;
  final Value<int> rowid;
  const AudioFeaturesTableCompanion({
    this.trackId = const Value.absent(),
    this.tempo = const Value.absent(),
    this.energy = const Value.absent(),
    this.valence = const Value.absent(),
    this.danceability = const Value.absent(),
    this.loudness = const Value.absent(),
    this.acousticness = const Value.absent(),
    this.musicalKey = const Value.absent(),
    this.keyName = const Value.absent(),
    this.fingerprintHash = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AudioFeaturesTableCompanion.insert({
    required String trackId,
    this.tempo = const Value.absent(),
    this.energy = const Value.absent(),
    this.valence = const Value.absent(),
    this.danceability = const Value.absent(),
    this.loudness = const Value.absent(),
    this.acousticness = const Value.absent(),
    this.musicalKey = const Value.absent(),
    this.keyName = const Value.absent(),
    this.fingerprintHash = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : trackId = Value(trackId);
  static Insertable<AudioFeaturesRow> custom({
    Expression<String>? trackId,
    Expression<double>? tempo,
    Expression<double>? energy,
    Expression<double>? valence,
    Expression<double>? danceability,
    Expression<double>? loudness,
    Expression<double>? acousticness,
    Expression<int>? musicalKey,
    Expression<String>? keyName,
    Expression<String>? fingerprintHash,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (tempo != null) 'tempo': tempo,
      if (energy != null) 'energy': energy,
      if (valence != null) 'valence': valence,
      if (danceability != null) 'danceability': danceability,
      if (loudness != null) 'loudness': loudness,
      if (acousticness != null) 'acousticness': acousticness,
      if (musicalKey != null) 'musical_key': musicalKey,
      if (keyName != null) 'key_name': keyName,
      if (fingerprintHash != null) 'fingerprint_hash': fingerprintHash,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AudioFeaturesTableCompanion copyWith({
    Value<String>? trackId,
    Value<double>? tempo,
    Value<double>? energy,
    Value<double>? valence,
    Value<double>? danceability,
    Value<double>? loudness,
    Value<double>? acousticness,
    Value<int>? musicalKey,
    Value<String>? keyName,
    Value<String?>? fingerprintHash,
    Value<int>? rowid,
  }) {
    return AudioFeaturesTableCompanion(
      trackId: trackId ?? this.trackId,
      tempo: tempo ?? this.tempo,
      energy: energy ?? this.energy,
      valence: valence ?? this.valence,
      danceability: danceability ?? this.danceability,
      loudness: loudness ?? this.loudness,
      acousticness: acousticness ?? this.acousticness,
      musicalKey: musicalKey ?? this.musicalKey,
      keyName: keyName ?? this.keyName,
      fingerprintHash: fingerprintHash ?? this.fingerprintHash,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (tempo.present) {
      map['tempo'] = Variable<double>(tempo.value);
    }
    if (energy.present) {
      map['energy'] = Variable<double>(energy.value);
    }
    if (valence.present) {
      map['valence'] = Variable<double>(valence.value);
    }
    if (danceability.present) {
      map['danceability'] = Variable<double>(danceability.value);
    }
    if (loudness.present) {
      map['loudness'] = Variable<double>(loudness.value);
    }
    if (acousticness.present) {
      map['acousticness'] = Variable<double>(acousticness.value);
    }
    if (musicalKey.present) {
      map['musical_key'] = Variable<int>(musicalKey.value);
    }
    if (keyName.present) {
      map['key_name'] = Variable<String>(keyName.value);
    }
    if (fingerprintHash.present) {
      map['fingerprint_hash'] = Variable<String>(fingerprintHash.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioFeaturesTableCompanion(')
          ..write('trackId: $trackId, ')
          ..write('tempo: $tempo, ')
          ..write('energy: $energy, ')
          ..write('valence: $valence, ')
          ..write('danceability: $danceability, ')
          ..write('loudness: $loudness, ')
          ..write('acousticness: $acousticness, ')
          ..write('musicalKey: $musicalKey, ')
          ..write('keyName: $keyName, ')
          ..write('fingerprintHash: $fingerprintHash, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAtMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;

  /// JSON-encoded value. Readers tolerate a malformed value by falling back to
  /// the default rather than failing the whole load.
  final String value;

  /// Epoch ms of the last write, so an import can tell which side is newer.
  final int updatedAtMs;
  const SettingRow({
    required this.key,
    required this.value,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(
      key: Value(key),
      value: Value(value),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  SettingRow copyWith({String? key, String? value, int? updatedAtMs}) =>
      SettingRow(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      );
  SettingRow copyWithCompanion(SettingsTableCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAtMs == this.updatedAtMs);
}

class SettingsTableCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const SettingsTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    required String key,
    required String value,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsTableCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return SettingsTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TracksTableTable tracksTable = $TracksTableTable(this);
  late final $AlbumsTableTable albumsTable = $AlbumsTableTable(this);
  late final $ArtistsTableTable artistsTable = $ArtistsTableTable(this);
  late final $PlaylistsTableTable playlistsTable = $PlaylistsTableTable(this);
  late final $PlaylistTracksTableTable playlistTracksTable =
      $PlaylistTracksTableTable(this);
  late final $PlaybackHistoryTableTable playbackHistoryTable =
      $PlaybackHistoryTableTable(this);
  late final $ShuffleStateTableTable shuffleStateTable =
      $ShuffleStateTableTable(this);
  late final $AudioFeaturesTableTable audioFeaturesTable =
      $AudioFeaturesTableTable(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  late final TrackDao trackDao = TrackDao(this as AppDatabase);
  late final BehaviorDao behaviorDao = BehaviorDao(this as AppDatabase);
  late final PlaylistDao playlistDao = PlaylistDao(this as AppDatabase);
  late final ShuffleStateDao shuffleStateDao = ShuffleStateDao(
    this as AppDatabase,
  );
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tracksTable,
    albumsTable,
    artistsTable,
    playlistsTable,
    playlistTracksTable,
    playbackHistoryTable,
    shuffleStateTable,
    audioFeaturesTable,
    settingsTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playlists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_tracks', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$TracksTableTableCreateCompanionBuilder =
    TracksTableCompanion Function({
      required String id,
      required String title,
      required String artistName,
      required String albumTitle,
      required String artistId,
      required String albumId,
      required int durationMs,
      required String filePath,
      Value<int> fileSizeBytes,
      Value<String> format,
      Value<int> bitRateKbps,
      Value<int> sampleRateHz,
      Value<int> playCount,
      Value<int> skipCount,
      Value<int> rating,
      required int dateAddedMs,
      Value<int?> lastPlayedMs,
      Value<bool> isDeleted,
      Value<String?> coverArtPath,
      Value<int> trackNumber,
      Value<int> discNumber,
      Value<String> genre,
      Value<int> year,
      Value<int> rowid,
    });
typedef $$TracksTableTableUpdateCompanionBuilder =
    TracksTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> artistName,
      Value<String> albumTitle,
      Value<String> artistId,
      Value<String> albumId,
      Value<int> durationMs,
      Value<String> filePath,
      Value<int> fileSizeBytes,
      Value<String> format,
      Value<int> bitRateKbps,
      Value<int> sampleRateHz,
      Value<int> playCount,
      Value<int> skipCount,
      Value<int> rating,
      Value<int> dateAddedMs,
      Value<int?> lastPlayedMs,
      Value<bool> isDeleted,
      Value<String?> coverArtPath,
      Value<int> trackNumber,
      Value<int> discNumber,
      Value<String> genre,
      Value<int> year,
      Value<int> rowid,
    });

class $$TracksTableTableFilterComposer
    extends Composer<_$AppDatabase, $TracksTableTable> {
  $$TracksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistName => $composableBuilder(
    column: $table.artistName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumTitle => $composableBuilder(
    column: $table.albumTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumId => $composableBuilder(
    column: $table.albumId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bitRateKbps => $composableBuilder(
    column: $table.bitRateKbps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sampleRateHz => $composableBuilder(
    column: $table.sampleRateHz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skipCount => $composableBuilder(
    column: $table.skipCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateAddedMs => $composableBuilder(
    column: $table.dateAddedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPlayedMs => $composableBuilder(
    column: $table.lastPlayedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverArtPath => $composableBuilder(
    column: $table.coverArtPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TracksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TracksTableTable> {
  $$TracksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistName => $composableBuilder(
    column: $table.artistName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumTitle => $composableBuilder(
    column: $table.albumTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumId => $composableBuilder(
    column: $table.albumId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bitRateKbps => $composableBuilder(
    column: $table.bitRateKbps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sampleRateHz => $composableBuilder(
    column: $table.sampleRateHz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skipCount => $composableBuilder(
    column: $table.skipCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateAddedMs => $composableBuilder(
    column: $table.dateAddedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPlayedMs => $composableBuilder(
    column: $table.lastPlayedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverArtPath => $composableBuilder(
    column: $table.coverArtPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TracksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TracksTableTable> {
  $$TracksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artistName => $composableBuilder(
    column: $table.artistName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get albumTitle => $composableBuilder(
    column: $table.albumTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artistId =>
      $composableBuilder(column: $table.artistId, builder: (column) => column);

  GeneratedColumn<String> get albumId =>
      $composableBuilder(column: $table.albumId, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<int> get bitRateKbps => $composableBuilder(
    column: $table.bitRateKbps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sampleRateHz => $composableBuilder(
    column: $table.sampleRateHz,
    builder: (column) => column,
  );

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<int> get skipCount =>
      $composableBuilder(column: $table.skipCount, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<int> get dateAddedMs => $composableBuilder(
    column: $table.dateAddedMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastPlayedMs => $composableBuilder(
    column: $table.lastPlayedMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get coverArtPath => $composableBuilder(
    column: $table.coverArtPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);
}

class $$TracksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TracksTableTable,
          TrackRow,
          $$TracksTableTableFilterComposer,
          $$TracksTableTableOrderingComposer,
          $$TracksTableTableAnnotationComposer,
          $$TracksTableTableCreateCompanionBuilder,
          $$TracksTableTableUpdateCompanionBuilder,
          (
            TrackRow,
            BaseReferences<_$AppDatabase, $TracksTableTable, TrackRow>,
          ),
          TrackRow,
          PrefetchHooks Function()
        > {
  $$TracksTableTableTableManager(_$AppDatabase db, $TracksTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TracksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TracksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TracksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> artistName = const Value.absent(),
                Value<String> albumTitle = const Value.absent(),
                Value<String> artistId = const Value.absent(),
                Value<String> albumId = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int> fileSizeBytes = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<int> bitRateKbps = const Value.absent(),
                Value<int> sampleRateHz = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<int> skipCount = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<int> dateAddedMs = const Value.absent(),
                Value<int?> lastPlayedMs = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> coverArtPath = const Value.absent(),
                Value<int> trackNumber = const Value.absent(),
                Value<int> discNumber = const Value.absent(),
                Value<String> genre = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TracksTableCompanion(
                id: id,
                title: title,
                artistName: artistName,
                albumTitle: albumTitle,
                artistId: artistId,
                albumId: albumId,
                durationMs: durationMs,
                filePath: filePath,
                fileSizeBytes: fileSizeBytes,
                format: format,
                bitRateKbps: bitRateKbps,
                sampleRateHz: sampleRateHz,
                playCount: playCount,
                skipCount: skipCount,
                rating: rating,
                dateAddedMs: dateAddedMs,
                lastPlayedMs: lastPlayedMs,
                isDeleted: isDeleted,
                coverArtPath: coverArtPath,
                trackNumber: trackNumber,
                discNumber: discNumber,
                genre: genre,
                year: year,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String artistName,
                required String albumTitle,
                required String artistId,
                required String albumId,
                required int durationMs,
                required String filePath,
                Value<int> fileSizeBytes = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<int> bitRateKbps = const Value.absent(),
                Value<int> sampleRateHz = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<int> skipCount = const Value.absent(),
                Value<int> rating = const Value.absent(),
                required int dateAddedMs,
                Value<int?> lastPlayedMs = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> coverArtPath = const Value.absent(),
                Value<int> trackNumber = const Value.absent(),
                Value<int> discNumber = const Value.absent(),
                Value<String> genre = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TracksTableCompanion.insert(
                id: id,
                title: title,
                artistName: artistName,
                albumTitle: albumTitle,
                artistId: artistId,
                albumId: albumId,
                durationMs: durationMs,
                filePath: filePath,
                fileSizeBytes: fileSizeBytes,
                format: format,
                bitRateKbps: bitRateKbps,
                sampleRateHz: sampleRateHz,
                playCount: playCount,
                skipCount: skipCount,
                rating: rating,
                dateAddedMs: dateAddedMs,
                lastPlayedMs: lastPlayedMs,
                isDeleted: isDeleted,
                coverArtPath: coverArtPath,
                trackNumber: trackNumber,
                discNumber: discNumber,
                genre: genre,
                year: year,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TracksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TracksTableTable,
      TrackRow,
      $$TracksTableTableFilterComposer,
      $$TracksTableTableOrderingComposer,
      $$TracksTableTableAnnotationComposer,
      $$TracksTableTableCreateCompanionBuilder,
      $$TracksTableTableUpdateCompanionBuilder,
      (TrackRow, BaseReferences<_$AppDatabase, $TracksTableTable, TrackRow>),
      TrackRow,
      PrefetchHooks Function()
    >;
typedef $$AlbumsTableTableCreateCompanionBuilder =
    AlbumsTableCompanion Function({
      required String id,
      required String title,
      required String artistId,
      required String artistName,
      Value<int> year,
      Value<String?> coverArtPath,
      Value<int> trackCount,
      Value<int> totalDurationMs,
      Value<String> genre,
      required int dateAddedMs,
      Value<int> rowid,
    });
typedef $$AlbumsTableTableUpdateCompanionBuilder =
    AlbumsTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> artistId,
      Value<String> artistName,
      Value<int> year,
      Value<String?> coverArtPath,
      Value<int> trackCount,
      Value<int> totalDurationMs,
      Value<String> genre,
      Value<int> dateAddedMs,
      Value<int> rowid,
    });

class $$AlbumsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AlbumsTableTable> {
  $$AlbumsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistName => $composableBuilder(
    column: $table.artistName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverArtPath => $composableBuilder(
    column: $table.coverArtPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackCount => $composableBuilder(
    column: $table.trackCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalDurationMs => $composableBuilder(
    column: $table.totalDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateAddedMs => $composableBuilder(
    column: $table.dateAddedMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AlbumsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AlbumsTableTable> {
  $$AlbumsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistName => $composableBuilder(
    column: $table.artistName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverArtPath => $composableBuilder(
    column: $table.coverArtPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackCount => $composableBuilder(
    column: $table.trackCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalDurationMs => $composableBuilder(
    column: $table.totalDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateAddedMs => $composableBuilder(
    column: $table.dateAddedMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlbumsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlbumsTableTable> {
  $$AlbumsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artistId =>
      $composableBuilder(column: $table.artistId, builder: (column) => column);

  GeneratedColumn<String> get artistName => $composableBuilder(
    column: $table.artistName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get coverArtPath => $composableBuilder(
    column: $table.coverArtPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trackCount => $composableBuilder(
    column: $table.trackCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalDurationMs => $composableBuilder(
    column: $table.totalDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<int> get dateAddedMs => $composableBuilder(
    column: $table.dateAddedMs,
    builder: (column) => column,
  );
}

class $$AlbumsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlbumsTableTable,
          AlbumRow,
          $$AlbumsTableTableFilterComposer,
          $$AlbumsTableTableOrderingComposer,
          $$AlbumsTableTableAnnotationComposer,
          $$AlbumsTableTableCreateCompanionBuilder,
          $$AlbumsTableTableUpdateCompanionBuilder,
          (
            AlbumRow,
            BaseReferences<_$AppDatabase, $AlbumsTableTable, AlbumRow>,
          ),
          AlbumRow,
          PrefetchHooks Function()
        > {
  $$AlbumsTableTableTableManager(_$AppDatabase db, $AlbumsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlbumsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlbumsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlbumsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> artistId = const Value.absent(),
                Value<String> artistName = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<String?> coverArtPath = const Value.absent(),
                Value<int> trackCount = const Value.absent(),
                Value<int> totalDurationMs = const Value.absent(),
                Value<String> genre = const Value.absent(),
                Value<int> dateAddedMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlbumsTableCompanion(
                id: id,
                title: title,
                artistId: artistId,
                artistName: artistName,
                year: year,
                coverArtPath: coverArtPath,
                trackCount: trackCount,
                totalDurationMs: totalDurationMs,
                genre: genre,
                dateAddedMs: dateAddedMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String artistId,
                required String artistName,
                Value<int> year = const Value.absent(),
                Value<String?> coverArtPath = const Value.absent(),
                Value<int> trackCount = const Value.absent(),
                Value<int> totalDurationMs = const Value.absent(),
                Value<String> genre = const Value.absent(),
                required int dateAddedMs,
                Value<int> rowid = const Value.absent(),
              }) => AlbumsTableCompanion.insert(
                id: id,
                title: title,
                artistId: artistId,
                artistName: artistName,
                year: year,
                coverArtPath: coverArtPath,
                trackCount: trackCount,
                totalDurationMs: totalDurationMs,
                genre: genre,
                dateAddedMs: dateAddedMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AlbumsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlbumsTableTable,
      AlbumRow,
      $$AlbumsTableTableFilterComposer,
      $$AlbumsTableTableOrderingComposer,
      $$AlbumsTableTableAnnotationComposer,
      $$AlbumsTableTableCreateCompanionBuilder,
      $$AlbumsTableTableUpdateCompanionBuilder,
      (AlbumRow, BaseReferences<_$AppDatabase, $AlbumsTableTable, AlbumRow>),
      AlbumRow,
      PrefetchHooks Function()
    >;
typedef $$ArtistsTableTableCreateCompanionBuilder =
    ArtistsTableCompanion Function({
      required String id,
      required String name,
      Value<int> trackCount,
      Value<int> albumCount,
      Value<String?> imagePath,
      Value<int> rowid,
    });
typedef $$ArtistsTableTableUpdateCompanionBuilder =
    ArtistsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> trackCount,
      Value<int> albumCount,
      Value<String?> imagePath,
      Value<int> rowid,
    });

class $$ArtistsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ArtistsTableTable> {
  $$ArtistsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackCount => $composableBuilder(
    column: $table.trackCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get albumCount => $composableBuilder(
    column: $table.albumCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ArtistsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ArtistsTableTable> {
  $$ArtistsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackCount => $composableBuilder(
    column: $table.trackCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get albumCount => $composableBuilder(
    column: $table.albumCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArtistsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArtistsTableTable> {
  $$ArtistsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get trackCount => $composableBuilder(
    column: $table.trackCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get albumCount => $composableBuilder(
    column: $table.albumCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);
}

class $$ArtistsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArtistsTableTable,
          ArtistRow,
          $$ArtistsTableTableFilterComposer,
          $$ArtistsTableTableOrderingComposer,
          $$ArtistsTableTableAnnotationComposer,
          $$ArtistsTableTableCreateCompanionBuilder,
          $$ArtistsTableTableUpdateCompanionBuilder,
          (
            ArtistRow,
            BaseReferences<_$AppDatabase, $ArtistsTableTable, ArtistRow>,
          ),
          ArtistRow,
          PrefetchHooks Function()
        > {
  $$ArtistsTableTableTableManager(_$AppDatabase db, $ArtistsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArtistsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArtistsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArtistsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> trackCount = const Value.absent(),
                Value<int> albumCount = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArtistsTableCompanion(
                id: id,
                name: name,
                trackCount: trackCount,
                albumCount: albumCount,
                imagePath: imagePath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> trackCount = const Value.absent(),
                Value<int> albumCount = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArtistsTableCompanion.insert(
                id: id,
                name: name,
                trackCount: trackCount,
                albumCount: albumCount,
                imagePath: imagePath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ArtistsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArtistsTableTable,
      ArtistRow,
      $$ArtistsTableTableFilterComposer,
      $$ArtistsTableTableOrderingComposer,
      $$ArtistsTableTableAnnotationComposer,
      $$ArtistsTableTableCreateCompanionBuilder,
      $$ArtistsTableTableUpdateCompanionBuilder,
      (ArtistRow, BaseReferences<_$AppDatabase, $ArtistsTableTable, ArtistRow>),
      ArtistRow,
      PrefetchHooks Function()
    >;
typedef $$PlaylistsTableTableCreateCompanionBuilder =
    PlaylistsTableCompanion Function({
      required String id,
      required String name,
      Value<String> description,
      Value<String> type,
      Value<String?> mood,
      required int createdAtMs,
      required int updatedAtMs,
      Value<String?> coverArtPath,
      Value<String> coverArtPathsJson,
      Value<bool> isPinned,
      Value<int> rowid,
    });
typedef $$PlaylistsTableTableUpdateCompanionBuilder =
    PlaylistsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> description,
      Value<String> type,
      Value<String?> mood,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<String?> coverArtPath,
      Value<String> coverArtPathsJson,
      Value<bool> isPinned,
      Value<int> rowid,
    });

final class $$PlaylistsTableTableReferences
    extends BaseReferences<_$AppDatabase, $PlaylistsTableTable, PlaylistRow> {
  $$PlaylistsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$PlaylistTracksTableTable, List<PlaylistTrackRow>>
  _playlistTracksTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playlistTracksTable,
        aliasName: $_aliasNameGenerator(
          db.playlistsTable.id,
          db.playlistTracksTable.playlistId,
        ),
      );

  $$PlaylistTracksTableTableProcessedTableManager get playlistTracksTableRefs {
    final manager = $$PlaylistTracksTableTableTableManager(
      $_db,
      $_db.playlistTracksTable,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistTracksTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlaylistsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistsTableTable> {
  $$PlaylistsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverArtPath => $composableBuilder(
    column: $table.coverArtPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverArtPathsJson => $composableBuilder(
    column: $table.coverArtPathsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistTracksTableRefs(
    Expression<bool> Function($$PlaylistTracksTableTableFilterComposer f) f,
  ) {
    final $$PlaylistTracksTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistTracksTable,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTracksTableTableFilterComposer(
            $db: $db,
            $table: $db.playlistTracksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistsTableTable> {
  $$PlaylistsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverArtPath => $composableBuilder(
    column: $table.coverArtPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverArtPathsJson => $composableBuilder(
    column: $table.coverArtPathsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistsTableTable> {
  $$PlaylistsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverArtPath => $composableBuilder(
    column: $table.coverArtPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverArtPathsJson => $composableBuilder(
    column: $table.coverArtPathsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  Expression<T> playlistTracksTableRefs<T extends Object>(
    Expression<T> Function($$PlaylistTracksTableTableAnnotationComposer a) f,
  ) {
    final $$PlaylistTracksTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playlistTracksTable,
          getReferencedColumn: (t) => t.playlistId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaylistTracksTableTableAnnotationComposer(
                $db: $db,
                $table: $db.playlistTracksTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PlaylistsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistsTableTable,
          PlaylistRow,
          $$PlaylistsTableTableFilterComposer,
          $$PlaylistsTableTableOrderingComposer,
          $$PlaylistsTableTableAnnotationComposer,
          $$PlaylistsTableTableCreateCompanionBuilder,
          $$PlaylistsTableTableUpdateCompanionBuilder,
          (PlaylistRow, $$PlaylistsTableTableReferences),
          PlaylistRow,
          PrefetchHooks Function({bool playlistTracksTableRefs})
        > {
  $$PlaylistsTableTableTableManager(
    _$AppDatabase db,
    $PlaylistsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> mood = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> coverArtPath = const Value.absent(),
                Value<String> coverArtPathsJson = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsTableCompanion(
                id: id,
                name: name,
                description: description,
                type: type,
                mood: mood,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                coverArtPath: coverArtPath,
                coverArtPathsJson: coverArtPathsJson,
                isPinned: isPinned,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> description = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> mood = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                Value<String?> coverArtPath = const Value.absent(),
                Value<String> coverArtPathsJson = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsTableCompanion.insert(
                id: id,
                name: name,
                description: description,
                type: type,
                mood: mood,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                coverArtPath: coverArtPath,
                coverArtPathsJson: coverArtPathsJson,
                isPinned: isPinned,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistTracksTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistTracksTableRefs) db.playlistTracksTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistTracksTableRefs)
                    await $_getPrefetchedData<
                      PlaylistRow,
                      $PlaylistsTableTable,
                      PlaylistTrackRow
                    >(
                      currentTable: table,
                      referencedTable: $$PlaylistsTableTableReferences
                          ._playlistTracksTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlaylistsTableTableReferences(
                            db,
                            table,
                            p0,
                          ).playlistTracksTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.playlistId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistsTableTable,
      PlaylistRow,
      $$PlaylistsTableTableFilterComposer,
      $$PlaylistsTableTableOrderingComposer,
      $$PlaylistsTableTableAnnotationComposer,
      $$PlaylistsTableTableCreateCompanionBuilder,
      $$PlaylistsTableTableUpdateCompanionBuilder,
      (PlaylistRow, $$PlaylistsTableTableReferences),
      PlaylistRow,
      PrefetchHooks Function({bool playlistTracksTableRefs})
    >;
typedef $$PlaylistTracksTableTableCreateCompanionBuilder =
    PlaylistTracksTableCompanion Function({
      required String playlistId,
      required String trackId,
      required int position,
      Value<int> rowid,
    });
typedef $$PlaylistTracksTableTableUpdateCompanionBuilder =
    PlaylistTracksTableCompanion Function({
      Value<String> playlistId,
      Value<String> trackId,
      Value<int> position,
      Value<int> rowid,
    });

final class $$PlaylistTracksTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PlaylistTracksTableTable,
          PlaylistTrackRow
        > {
  $$PlaylistTracksTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistsTableTable _playlistIdTable(_$AppDatabase db) =>
      db.playlistsTable.createAlias(
        $_aliasNameGenerator(
          db.playlistTracksTable.playlistId,
          db.playlistsTable.id,
        ),
      );

  $$PlaylistsTableTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<String>('playlist_id')!;

    final manager = $$PlaylistsTableTableTableManager(
      $_db,
      $_db.playlistsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaylistTracksTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistTracksTableTable> {
  $$PlaylistTracksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistsTableTableFilterComposer get playlistId {
    final $$PlaylistsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlistsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableTableFilterComposer(
            $db: $db,
            $table: $db.playlistsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTracksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistTracksTableTable> {
  $$PlaylistTracksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistsTableTableOrderingComposer get playlistId {
    final $$PlaylistsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlistsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableTableOrderingComposer(
            $db: $db,
            $table: $db.playlistsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTracksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistTracksTableTable> {
  $$PlaylistTracksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$PlaylistsTableTableAnnotationComposer get playlistId {
    final $$PlaylistsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlistsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTracksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistTracksTableTable,
          PlaylistTrackRow,
          $$PlaylistTracksTableTableFilterComposer,
          $$PlaylistTracksTableTableOrderingComposer,
          $$PlaylistTracksTableTableAnnotationComposer,
          $$PlaylistTracksTableTableCreateCompanionBuilder,
          $$PlaylistTracksTableTableUpdateCompanionBuilder,
          (PlaylistTrackRow, $$PlaylistTracksTableTableReferences),
          PlaylistTrackRow,
          PrefetchHooks Function({bool playlistId})
        > {
  $$PlaylistTracksTableTableTableManager(
    _$AppDatabase db,
    $PlaylistTracksTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistTracksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistTracksTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PlaylistTracksTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> playlistId = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistTracksTableCompanion(
                playlistId: playlistId,
                trackId: trackId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playlistId,
                required String trackId,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => PlaylistTracksTableCompanion.insert(
                playlistId: playlistId,
                trackId: trackId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistTracksTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playlistId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playlistId,
                                referencedTable:
                                    $$PlaylistTracksTableTableReferences
                                        ._playlistIdTable(db),
                                referencedColumn:
                                    $$PlaylistTracksTableTableReferences
                                        ._playlistIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistTracksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistTracksTableTable,
      PlaylistTrackRow,
      $$PlaylistTracksTableTableFilterComposer,
      $$PlaylistTracksTableTableOrderingComposer,
      $$PlaylistTracksTableTableAnnotationComposer,
      $$PlaylistTracksTableTableCreateCompanionBuilder,
      $$PlaylistTracksTableTableUpdateCompanionBuilder,
      (PlaylistTrackRow, $$PlaylistTracksTableTableReferences),
      PlaylistTrackRow,
      PrefetchHooks Function({bool playlistId})
    >;
typedef $$PlaybackHistoryTableTableCreateCompanionBuilder =
    PlaybackHistoryTableCompanion Function({
      Value<int> id,
      required String trackId,
      required int playedAtMs,
      required int durationPlayedMs,
      Value<bool> skipped,
      Value<bool> completed,
      Value<String> contextType,
    });
typedef $$PlaybackHistoryTableTableUpdateCompanionBuilder =
    PlaybackHistoryTableCompanion Function({
      Value<int> id,
      Value<String> trackId,
      Value<int> playedAtMs,
      Value<int> durationPlayedMs,
      Value<bool> skipped,
      Value<bool> completed,
      Value<String> contextType,
    });

class $$PlaybackHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaybackHistoryTableTable> {
  $$PlaybackHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playedAtMs => $composableBuilder(
    column: $table.playedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationPlayedMs => $composableBuilder(
    column: $table.durationPlayedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextType => $composableBuilder(
    column: $table.contextType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaybackHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaybackHistoryTableTable> {
  $$PlaybackHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playedAtMs => $composableBuilder(
    column: $table.playedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationPlayedMs => $composableBuilder(
    column: $table.durationPlayedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextType => $composableBuilder(
    column: $table.contextType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaybackHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaybackHistoryTableTable> {
  $$PlaybackHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<int> get playedAtMs => $composableBuilder(
    column: $table.playedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationPlayedMs => $composableBuilder(
    column: $table.durationPlayedMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get skipped =>
      $composableBuilder(column: $table.skipped, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<String> get contextType => $composableBuilder(
    column: $table.contextType,
    builder: (column) => column,
  );
}

class $$PlaybackHistoryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaybackHistoryTableTable,
          PlaybackHistoryRow,
          $$PlaybackHistoryTableTableFilterComposer,
          $$PlaybackHistoryTableTableOrderingComposer,
          $$PlaybackHistoryTableTableAnnotationComposer,
          $$PlaybackHistoryTableTableCreateCompanionBuilder,
          $$PlaybackHistoryTableTableUpdateCompanionBuilder,
          (
            PlaybackHistoryRow,
            BaseReferences<
              _$AppDatabase,
              $PlaybackHistoryTableTable,
              PlaybackHistoryRow
            >,
          ),
          PlaybackHistoryRow,
          PrefetchHooks Function()
        > {
  $$PlaybackHistoryTableTableTableManager(
    _$AppDatabase db,
    $PlaybackHistoryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaybackHistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaybackHistoryTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PlaybackHistoryTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<int> playedAtMs = const Value.absent(),
                Value<int> durationPlayedMs = const Value.absent(),
                Value<bool> skipped = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<String> contextType = const Value.absent(),
              }) => PlaybackHistoryTableCompanion(
                id: id,
                trackId: trackId,
                playedAtMs: playedAtMs,
                durationPlayedMs: durationPlayedMs,
                skipped: skipped,
                completed: completed,
                contextType: contextType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String trackId,
                required int playedAtMs,
                required int durationPlayedMs,
                Value<bool> skipped = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<String> contextType = const Value.absent(),
              }) => PlaybackHistoryTableCompanion.insert(
                id: id,
                trackId: trackId,
                playedAtMs: playedAtMs,
                durationPlayedMs: durationPlayedMs,
                skipped: skipped,
                completed: completed,
                contextType: contextType,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaybackHistoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaybackHistoryTableTable,
      PlaybackHistoryRow,
      $$PlaybackHistoryTableTableFilterComposer,
      $$PlaybackHistoryTableTableOrderingComposer,
      $$PlaybackHistoryTableTableAnnotationComposer,
      $$PlaybackHistoryTableTableCreateCompanionBuilder,
      $$PlaybackHistoryTableTableUpdateCompanionBuilder,
      (
        PlaybackHistoryRow,
        BaseReferences<
          _$AppDatabase,
          $PlaybackHistoryTableTable,
          PlaybackHistoryRow
        >,
      ),
      PlaybackHistoryRow,
      PrefetchHooks Function()
    >;
typedef $$ShuffleStateTableTableCreateCompanionBuilder =
    ShuffleStateTableCompanion Function({
      Value<int> id,
      Value<String> contextId,
      required String configJson,
      required String shuffledIdsJson,
      Value<int> currentIndex,
      required int createdAtMs,
      Value<int> updatedAtMs,
      Value<String> stateJson,
    });
typedef $$ShuffleStateTableTableUpdateCompanionBuilder =
    ShuffleStateTableCompanion Function({
      Value<int> id,
      Value<String> contextId,
      Value<String> configJson,
      Value<String> shuffledIdsJson,
      Value<int> currentIndex,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<String> stateJson,
    });

class $$ShuffleStateTableTableFilterComposer
    extends Composer<_$AppDatabase, $ShuffleStateTableTable> {
  $$ShuffleStateTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextId => $composableBuilder(
    column: $table.contextId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shuffledIdsJson => $composableBuilder(
    column: $table.shuffledIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stateJson => $composableBuilder(
    column: $table.stateJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShuffleStateTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ShuffleStateTableTable> {
  $$ShuffleStateTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextId => $composableBuilder(
    column: $table.contextId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shuffledIdsJson => $composableBuilder(
    column: $table.shuffledIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stateJson => $composableBuilder(
    column: $table.stateJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShuffleStateTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShuffleStateTableTable> {
  $$ShuffleStateTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contextId =>
      $composableBuilder(column: $table.contextId, builder: (column) => column);

  GeneratedColumn<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shuffledIdsJson => $composableBuilder(
    column: $table.shuffledIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stateJson =>
      $composableBuilder(column: $table.stateJson, builder: (column) => column);
}

class $$ShuffleStateTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShuffleStateTableTable,
          ShuffleStateRow,
          $$ShuffleStateTableTableFilterComposer,
          $$ShuffleStateTableTableOrderingComposer,
          $$ShuffleStateTableTableAnnotationComposer,
          $$ShuffleStateTableTableCreateCompanionBuilder,
          $$ShuffleStateTableTableUpdateCompanionBuilder,
          (
            ShuffleStateRow,
            BaseReferences<
              _$AppDatabase,
              $ShuffleStateTableTable,
              ShuffleStateRow
            >,
          ),
          ShuffleStateRow,
          PrefetchHooks Function()
        > {
  $$ShuffleStateTableTableTableManager(
    _$AppDatabase db,
    $ShuffleStateTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShuffleStateTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShuffleStateTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShuffleStateTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> contextId = const Value.absent(),
                Value<String> configJson = const Value.absent(),
                Value<String> shuffledIdsJson = const Value.absent(),
                Value<int> currentIndex = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String> stateJson = const Value.absent(),
              }) => ShuffleStateTableCompanion(
                id: id,
                contextId: contextId,
                configJson: configJson,
                shuffledIdsJson: shuffledIdsJson,
                currentIndex: currentIndex,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                stateJson: stateJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> contextId = const Value.absent(),
                required String configJson,
                required String shuffledIdsJson,
                Value<int> currentIndex = const Value.absent(),
                required int createdAtMs,
                Value<int> updatedAtMs = const Value.absent(),
                Value<String> stateJson = const Value.absent(),
              }) => ShuffleStateTableCompanion.insert(
                id: id,
                contextId: contextId,
                configJson: configJson,
                shuffledIdsJson: shuffledIdsJson,
                currentIndex: currentIndex,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                stateJson: stateJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShuffleStateTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShuffleStateTableTable,
      ShuffleStateRow,
      $$ShuffleStateTableTableFilterComposer,
      $$ShuffleStateTableTableOrderingComposer,
      $$ShuffleStateTableTableAnnotationComposer,
      $$ShuffleStateTableTableCreateCompanionBuilder,
      $$ShuffleStateTableTableUpdateCompanionBuilder,
      (
        ShuffleStateRow,
        BaseReferences<_$AppDatabase, $ShuffleStateTableTable, ShuffleStateRow>,
      ),
      ShuffleStateRow,
      PrefetchHooks Function()
    >;
typedef $$AudioFeaturesTableTableCreateCompanionBuilder =
    AudioFeaturesTableCompanion Function({
      required String trackId,
      Value<double> tempo,
      Value<double> energy,
      Value<double> valence,
      Value<double> danceability,
      Value<double> loudness,
      Value<double> acousticness,
      Value<int> musicalKey,
      Value<String> keyName,
      Value<String?> fingerprintHash,
      Value<int> rowid,
    });
typedef $$AudioFeaturesTableTableUpdateCompanionBuilder =
    AudioFeaturesTableCompanion Function({
      Value<String> trackId,
      Value<double> tempo,
      Value<double> energy,
      Value<double> valence,
      Value<double> danceability,
      Value<double> loudness,
      Value<double> acousticness,
      Value<int> musicalKey,
      Value<String> keyName,
      Value<String?> fingerprintHash,
      Value<int> rowid,
    });

class $$AudioFeaturesTableTableFilterComposer
    extends Composer<_$AppDatabase, $AudioFeaturesTableTable> {
  $$AudioFeaturesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tempo => $composableBuilder(
    column: $table.tempo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valence => $composableBuilder(
    column: $table.valence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get danceability => $composableBuilder(
    column: $table.danceability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get loudness => $composableBuilder(
    column: $table.loudness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get acousticness => $composableBuilder(
    column: $table.acousticness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get musicalKey => $composableBuilder(
    column: $table.musicalKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keyName => $composableBuilder(
    column: $table.keyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerprintHash => $composableBuilder(
    column: $table.fingerprintHash,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AudioFeaturesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioFeaturesTableTable> {
  $$AudioFeaturesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tempo => $composableBuilder(
    column: $table.tempo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valence => $composableBuilder(
    column: $table.valence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get danceability => $composableBuilder(
    column: $table.danceability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get loudness => $composableBuilder(
    column: $table.loudness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get acousticness => $composableBuilder(
    column: $table.acousticness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get musicalKey => $composableBuilder(
    column: $table.musicalKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keyName => $composableBuilder(
    column: $table.keyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprintHash => $composableBuilder(
    column: $table.fingerprintHash,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudioFeaturesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioFeaturesTableTable> {
  $$AudioFeaturesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<double> get tempo =>
      $composableBuilder(column: $table.tempo, builder: (column) => column);

  GeneratedColumn<double> get energy =>
      $composableBuilder(column: $table.energy, builder: (column) => column);

  GeneratedColumn<double> get valence =>
      $composableBuilder(column: $table.valence, builder: (column) => column);

  GeneratedColumn<double> get danceability => $composableBuilder(
    column: $table.danceability,
    builder: (column) => column,
  );

  GeneratedColumn<double> get loudness =>
      $composableBuilder(column: $table.loudness, builder: (column) => column);

  GeneratedColumn<double> get acousticness => $composableBuilder(
    column: $table.acousticness,
    builder: (column) => column,
  );

  GeneratedColumn<int> get musicalKey => $composableBuilder(
    column: $table.musicalKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get keyName =>
      $composableBuilder(column: $table.keyName, builder: (column) => column);

  GeneratedColumn<String> get fingerprintHash => $composableBuilder(
    column: $table.fingerprintHash,
    builder: (column) => column,
  );
}

class $$AudioFeaturesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioFeaturesTableTable,
          AudioFeaturesRow,
          $$AudioFeaturesTableTableFilterComposer,
          $$AudioFeaturesTableTableOrderingComposer,
          $$AudioFeaturesTableTableAnnotationComposer,
          $$AudioFeaturesTableTableCreateCompanionBuilder,
          $$AudioFeaturesTableTableUpdateCompanionBuilder,
          (
            AudioFeaturesRow,
            BaseReferences<
              _$AppDatabase,
              $AudioFeaturesTableTable,
              AudioFeaturesRow
            >,
          ),
          AudioFeaturesRow,
          PrefetchHooks Function()
        > {
  $$AudioFeaturesTableTableTableManager(
    _$AppDatabase db,
    $AudioFeaturesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioFeaturesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioFeaturesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudioFeaturesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> trackId = const Value.absent(),
                Value<double> tempo = const Value.absent(),
                Value<double> energy = const Value.absent(),
                Value<double> valence = const Value.absent(),
                Value<double> danceability = const Value.absent(),
                Value<double> loudness = const Value.absent(),
                Value<double> acousticness = const Value.absent(),
                Value<int> musicalKey = const Value.absent(),
                Value<String> keyName = const Value.absent(),
                Value<String?> fingerprintHash = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudioFeaturesTableCompanion(
                trackId: trackId,
                tempo: tempo,
                energy: energy,
                valence: valence,
                danceability: danceability,
                loudness: loudness,
                acousticness: acousticness,
                musicalKey: musicalKey,
                keyName: keyName,
                fingerprintHash: fingerprintHash,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trackId,
                Value<double> tempo = const Value.absent(),
                Value<double> energy = const Value.absent(),
                Value<double> valence = const Value.absent(),
                Value<double> danceability = const Value.absent(),
                Value<double> loudness = const Value.absent(),
                Value<double> acousticness = const Value.absent(),
                Value<int> musicalKey = const Value.absent(),
                Value<String> keyName = const Value.absent(),
                Value<String?> fingerprintHash = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudioFeaturesTableCompanion.insert(
                trackId: trackId,
                tempo: tempo,
                energy: energy,
                valence: valence,
                danceability: danceability,
                loudness: loudness,
                acousticness: acousticness,
                musicalKey: musicalKey,
                keyName: keyName,
                fingerprintHash: fingerprintHash,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AudioFeaturesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioFeaturesTableTable,
      AudioFeaturesRow,
      $$AudioFeaturesTableTableFilterComposer,
      $$AudioFeaturesTableTableOrderingComposer,
      $$AudioFeaturesTableTableAnnotationComposer,
      $$AudioFeaturesTableTableCreateCompanionBuilder,
      $$AudioFeaturesTableTableUpdateCompanionBuilder,
      (
        AudioFeaturesRow,
        BaseReferences<
          _$AppDatabase,
          $AudioFeaturesTableTable,
          AudioFeaturesRow
        >,
      ),
      AudioFeaturesRow,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableTableCreateCompanionBuilder =
    SettingsTableCompanion Function({
      required String key,
      required String value,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$SettingsTableTableUpdateCompanionBuilder =
    SettingsTableCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$SettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTableTable,
          SettingRow,
          $$SettingsTableTableFilterComposer,
          $$SettingsTableTableOrderingComposer,
          $$SettingsTableTableAnnotationComposer,
          $$SettingsTableTableCreateCompanionBuilder,
          $$SettingsTableTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsTableTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsTableCompanion(
                key: key,
                value: value,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => SettingsTableCompanion.insert(
                key: key,
                value: value,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTableTable,
      SettingRow,
      $$SettingsTableTableFilterComposer,
      $$SettingsTableTableOrderingComposer,
      $$SettingsTableTableAnnotationComposer,
      $$SettingsTableTableCreateCompanionBuilder,
      $$SettingsTableTableUpdateCompanionBuilder,
      (
        SettingRow,
        BaseReferences<_$AppDatabase, $SettingsTableTable, SettingRow>,
      ),
      SettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TracksTableTableTableManager get tracksTable =>
      $$TracksTableTableTableManager(_db, _db.tracksTable);
  $$AlbumsTableTableTableManager get albumsTable =>
      $$AlbumsTableTableTableManager(_db, _db.albumsTable);
  $$ArtistsTableTableTableManager get artistsTable =>
      $$ArtistsTableTableTableManager(_db, _db.artistsTable);
  $$PlaylistsTableTableTableManager get playlistsTable =>
      $$PlaylistsTableTableTableManager(_db, _db.playlistsTable);
  $$PlaylistTracksTableTableTableManager get playlistTracksTable =>
      $$PlaylistTracksTableTableTableManager(_db, _db.playlistTracksTable);
  $$PlaybackHistoryTableTableTableManager get playbackHistoryTable =>
      $$PlaybackHistoryTableTableTableManager(_db, _db.playbackHistoryTable);
  $$ShuffleStateTableTableTableManager get shuffleStateTable =>
      $$ShuffleStateTableTableTableManager(_db, _db.shuffleStateTable);
  $$AudioFeaturesTableTableTableManager get audioFeaturesTable =>
      $$AudioFeaturesTableTableTableManager(_db, _db.audioFeaturesTable);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
}
