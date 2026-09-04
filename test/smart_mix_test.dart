// test/smart_mix_test.dart
// Aura — SmartMixGenerator unit tests.
//
// Pure Dart with in-memory fakes: no database, no plugins, deterministic
// (the generator takes an injectable Random).
//
// Run: flutter test test/smart_mix_test.dart

import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:aura/core/errors.dart';
import 'package:aura/domain/entities/album.dart';
import 'package:aura/domain/entities/artist.dart';
import 'package:aura/domain/entities/audio_features.dart';
import 'package:aura/domain/entities/camelot.dart';
import 'package:aura/domain/entities/playlist.dart';
import 'package:aura/domain/entities/track.dart';
import 'package:aura/domain/repositories/audio_feature_repository.dart';
import 'package:aura/domain/repositories/behavior_repository.dart';
import 'package:aura/domain/repositories/music_repository.dart';
import 'package:aura/domain/repositories/playlist_repository.dart';
import 'package:aura/domain/smart_mix/smart_mix_generator.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

class _FakeMusicRepo implements MusicRepository {
  _FakeMusicRepo(this.tracks);
  final List<Track> tracks;

  @override
  Future<List<Track>> getAllTracks() async => tracks;

  @override
  Future<Track?> getTrackById(String id) async {
    for (final t in tracks) {
      if (t.id == id) return t;
    }
    return null;
  }

  @override
  Future<List<Track>> getTracksByAlbum(String albumId) async => [];
  @override
  Future<List<Track>> getTracksByArtist(String artistId) async => [];
  @override
  Future<List<Album>> getAllAlbums() async => [];
  @override
  Future<List<Artist>> getAllArtists() async => [];
  @override
  Stream<int> scanLibrary() => const Stream.empty();
  @override
  Future<void> upsertTracks(List<Track> t) async {}
  @override
  Future<void> deleteTrack(String id) async {}
  @override
  Future<void> recordPlay(String id, {required int durationPlayedMs}) async {}
  @override
  Future<void> recordSkip(String id) async {}
  @override
  Future<void> setRating(String id, int rating) async {}
  @override
  Future<List<double>?> getAudioFeatures(String id) async => null;
  @override
  Future<void> upsertAudioFeatures(String id, List<double> f) async {}
}

class _FakeBehaviorRepo implements BehaviorRepository {
  _FakeBehaviorRepo([this.topIds = const []]);
  final List<String> topIds;

  @override
  Future<List<String>> getTopPlayedTrackIds({int topN = 20, int days = 30}) async =>
      topIds.take(topN).toList();

  @override
  Future<Map<String, TrackBehaviorStats>> getBehaviorStats(List<String> ids) async => {};
  @override
  Future<void> recordEvent(PlayEvent event) async {}
  @override
  Future<List<PlayEvent>> getPlayHistory(String trackId, {int limit = 100}) async => [];
  @override
  Future<void> pruneHistory(Duration retainDuration) async {}

  @override
  Future<List<PlayEvent>> getEventsInRange(int startMs, int endMs) async =>
      const [];

  @override
  Future<Map<String, int>> getFirstPlayMsPerTrack() async => const {};

  @override
  Future<int?> getFirstEventMs() async => null;
}

class _FakeFeatureRepo implements AudioFeatureRepository {
  _FakeFeatureRepo(this.features);
  final Map<String, AudioFeatures> features;

  @override
  Future<Map<String, AudioFeatures>> getAllFeatures() async => features;
  @override
  Future<AudioFeatures?> getFeatures(String trackId) async => features[trackId];
  @override
  Future<Map<String, AudioFeatures>> getFeaturesFor(List<String> ids) async => {
        for (final id in ids)
          if (features.containsKey(id)) id: features[id]!,
      };
  @override
  Future<void> upsert(AudioFeatures f) async => features[f.trackId] = f;
}

class _FakePlaylistRepo implements PlaylistRepository {
  final List<Playlist> saved = [];
  List<Playlist> existing = [];

  @override
  Future<void> upsertSmartMix(Playlist playlist) async => saved.add(playlist);

  @override
  Future<List<Playlist>> getAllPlaylists() async => existing;

  @override
  Future<Playlist?> getPlaylistById(String id) async => null;
  @override
  Future<Playlist> createPlaylist({
    required String name,
    String description = '',
    PlaylistType type = PlaylistType.userCreated,
    MixMood? mood,
  }) async =>
      Playlist(id: 'x', name: name, createdAtMs: 0, updatedAtMs: 0);
  @override
  Future<void> updatePlaylist(Playlist updated) async {}
  @override
  Future<void> deletePlaylist(String id) async {}
  @override
  Future<void> renamePlaylist(String id, String newName) async {}
  @override
  Future<bool> addTrack(String playlistId, String trackId) async => true;
  @override
  Future<int> addTracks(String playlistId, List<String> trackIds) async =>
      trackIds.length;
  @override
  Future<void> removeTrack(String playlistId, String trackId) async {}
  @override
  Future<void> removeTracks(String playlistId, List<String> trackIds) async {}
  @override
  Future<void> reorderTracks(String playlistId, List<String> ids) async {}
  @override
  Future<List<Track>> getPlaylistTracks(String playlistId) async => const [];
  @override
  Future<int> getPlaylistTrackCount(String playlistId) async => 0;
  @override
  Future<List<Track>> getDuplicateTracks(String playlistId) async => const [];
  @override
  Future<int> removeDuplicates(String playlistId) async => 0;
  @override
  Future<M3uImportResult> importM3u(String filePath, {String? playlistName}) =>
      throw UnimplementedError();
  @override
  Future<void> exportM3u(String playlistId, String outputPath) async {}
}

// ── Fixtures ──────────────────────────────────────────────────────────────────

Track mkTrack(String id, {String? artistId, String? albumId, int playCount = 0}) =>
    Track(
      id: id,
      title: 'Track $id',
      artistName: 'Artist ${artistId ?? id}',
      albumTitle: 'Album ${albumId ?? id}',
      artistId: artistId ?? 'artist_$id',
      albumId: albumId ?? 'album_$id',
      durationMs: 200000,
      filePath: '/music/$id.flac',
      fileSizeBytes: 1000,
      dateAddedMs: 0,
      playCount: playCount,
      coverArtPath: '/art/${albumId ?? id}.jpg',
    );

AudioFeatures mkFeatures(
  String id, {
  double energy = 0.5,
  double valence = 0.5,
  double tempo = 0.5,
  double danceability = 0.5,
  double acousticness = 0.5,
  int key = -1,
}) =>
    AudioFeatures(
      trackId: id,
      energy: energy,
      valence: valence,
      tempo: tempo,
      danceability: danceability,
      acousticness: acousticness,
      musicalKey: key,
      keyName: key >= 0 ? 'key$key' : '',
    );

/// A library spanning three distinct acoustic regions, so clustering has
/// something real to separate.
({List<Track> tracks, Map<String, AudioFeatures> features}) buildLibrary({
  int perGroup = 15,
  int artistsPerGroup = 15,
}) {
  final tracks = <Track>[];
  final features = <String, AudioFeatures>{};

  const groups = [
    (name: 'hi', energy: 0.9, valence: 0.85, tempo: 0.85),
    (name: 'mid', energy: 0.5, valence: 0.5, tempo: 0.5),
    (name: 'low', energy: 0.15, valence: 0.3, tempo: 0.2),
  ];

  for (final g in groups) {
    for (int i = 0; i < perGroup; i++) {
      final id = '${g.name}$i';
      tracks.add(mkTrack(
        id,
        artistId: 'artist_${g.name}_${i % artistsPerGroup}',
        albumId: 'album_${g.name}_${i % artistsPerGroup}',
        playCount: 100 - i,
      ));
      // Small jitter so members of a group aren't identical.
      final j = (i % 5) * 0.01;
      features[id] = mkFeatures(
        id,
        energy: g.energy + j,
        valence: g.valence + j,
        tempo: g.tempo + j,
        key: i % 12,
      );
    }
  }
  return (tracks: tracks, features: features);
}

SmartMixGenerator mkGenerator({
  required List<Track> tracks,
  required Map<String, AudioFeatures> features,
  List<String> topIds = const [],
  _FakePlaylistRepo? playlists,
}) {
  return SmartMixGenerator(
    trackRepository: _FakeMusicRepo(tracks),
    behaviorRepository: _FakeBehaviorRepo(topIds),
    audioFeatureRepository: _FakeFeatureRepo(features),
    playlistRepository: playlists ?? _FakePlaylistRepo(),
    random: math.Random(42),
  );
}

void main() {
  group('getMoodForCurrentTime', () {
    test('maps the day into moods at the documented boundaries', () {
      DateTime at(int hour) => DateTime(2026, 1, 1, hour);

      expect(getMoodForCurrentTime(at(0)), MixMood.morning);
      expect(getMoodForCurrentTime(at(8)), MixMood.morning);
      expect(getMoodForCurrentTime(at(9)), MixMood.focus);
      expect(getMoodForCurrentTime(at(16)), MixMood.focus);
      expect(getMoodForCurrentTime(at(17)), MixMood.evening);
      expect(getMoodForCurrentTime(at(21)), MixMood.evening);
      expect(getMoodForCurrentTime(at(22)), MixMood.chill);
      expect(getMoodForCurrentTime(at(23)), MixMood.chill);
    });
  });

  group('Camelot wheel', () {
    test('A minor is 8A and C major is 8B', () {
      final aMinor = CamelotKey.fromPitchClass(9, minor: true); // A
      final cMajor = CamelotKey.fromPitchClass(0);              // C
      expect(aMinor?.label, '8A');
      expect(cMajor?.label, '8B');
    });

    test('relative major/minor are compatible', () {
      const aMinor = CamelotKey(8, true);
      const cMajor = CamelotKey(8, false);
      expect(aMinor.isCompatibleWith(cMajor), isTrue);
      expect(aMinor.compatibilityScore(cMajor), greaterThan(0.8));
    });

    test('adjacent wheel positions are compatible and wrap at 12', () {
      expect(const CamelotKey(8, true).isCompatibleWith(const CamelotKey(9, true)), isTrue);
      expect(const CamelotKey(12, false).isCompatibleWith(const CamelotKey(1, false)), isTrue);
    });

    test('distant keys are incompatible and score low', () {
      const a = CamelotKey(1, true);
      const b = CamelotKey(6, true);
      expect(a.isCompatibleWith(b), isFalse);
      expect(a.compatibilityScore(b), lessThan(0.5));
      expect(a.compatibilityScore(a), 1.0);
    });

    test('out-of-range pitch classes yield null', () {
      expect(CamelotKey.fromPitchClass(-1), isNull);
      expect(CamelotKey.fromPitchClass(12), isNull);
    });
  });

  group('cosineSimilarity', () {
    test('identical vectors score 1 and orthogonal score 0', () {
      expect(cosineSimilarity([1, 0, 0], [1, 0, 0]), closeTo(1.0, 1e-9));
      expect(cosineSimilarity([1, 0], [0, 1]), closeTo(0.0, 1e-9));
    });

    test('degenerate inputs are safe', () {
      expect(cosineSimilarity([], []), 0.0);
      expect(cosineSimilarity([0, 0], [1, 1]), 0.0);
      expect(cosineSimilarity([1, 2], [1, 2, 3]), 0.0);
    });
  });

  group('generateDailyMix', () {
    test('throws on an empty library', () async {
      final gen = mkGenerator(tracks: [], features: {});
      expect(
        () => gen.generateDailyMix(mixName: 'X', mood: MixMood.chill),
        throwsA(isA<MixGenerationError>()),
      );
    });

    test('throws when too few tracks have been analysed', () async {
      final lib = buildLibrary(perGroup: 2);
      final gen = mkGenerator(tracks: lib.tracks, features: lib.features);
      expect(
        () => gen.generateDailyMix(mixName: 'X', mood: MixMood.chill),
        throwsA(isA<MixGenerationError>()),
      );
    });

    test('produces a persisted smart-mix playlist', () async {
      final lib = buildLibrary();
      final playlists = _FakePlaylistRepo();
      final gen = mkGenerator(
          tracks: lib.tracks, features: lib.features, playlists: playlists);

      final mix = await gen.generateDailyMix(
          mixName: 'Deep Focus', mood: MixMood.focus, trackCount: 30);

      expect(mix.name, 'Deep Focus');
      expect(mix.type, PlaylistType.smartMix);
      expect(mix.mood, MixMood.focus);
      expect(mix.trackIds, isNotEmpty);
      expect(playlists.saved, hasLength(1),
          reason: 'the mix is written through the repository');
    });

    test('respects the artist (max 3) and album (max 2) diversity caps',
        () async {
      // Only 3 artists / 3 albums across 45 tracks, so the caps bind hard.
      final lib = buildLibrary(perGroup: 15, artistsPerGroup: 1);
      final gen = mkGenerator(tracks: lib.tracks, features: lib.features);

      final mix = await gen.generateDailyMix(
          mixName: 'Caps', mood: MixMood.focus, trackCount: 30);

      final byId = {for (final t in lib.tracks) t.id: t};
      final perArtist = <String, int>{};
      final perAlbum = <String, int>{};
      for (final id in mix.trackIds) {
        final t = byId[id]!;
        perArtist[t.artistId] = (perArtist[t.artistId] ?? 0) + 1;
        perAlbum[t.albumId] = (perAlbum[t.albumId] ?? 0) + 1;
      }
      expect(perArtist.values.every((c) => c <= kMaxTracksPerArtist), isTrue,
          reason: 'no artist exceeds $kMaxTracksPerArtist tracks');
      expect(perAlbum.values.every((c) => c <= kMaxTracksPerAlbum), isTrue,
          reason: 'no album exceeds $kMaxTracksPerAlbum tracks');
    });

    test('never repeats a track within a mix', () async {
      final lib = buildLibrary();
      final gen = mkGenerator(tracks: lib.tracks, features: lib.features);
      final mix = await gen.generateDailyMix(
          mixName: 'Unique', mood: MixMood.morning, trackCount: 30);
      expect(mix.trackIds.toSet().length, mix.trackIds.length);
    });

    test('anchors come from distinct acoustic clusters', () async {
      // Anchors seed the mix, so a well-clustered library should pull material
      // from more than one region rather than all from one.
      final lib = buildLibrary();
      final gen = mkGenerator(tracks: lib.tracks, features: lib.features);

      final mix = await gen.generateDailyMix(
          mixName: 'Spread', mood: MixMood.focus, trackCount: 30);

      final groups = mix.trackIds
          .map((id) => id.replaceAll(RegExp(r'\d+$'), ''))
          .toSet();
      expect(groups.length, greaterThan(1),
          reason: 'clustering should reach more than one acoustic region');
    });

    test('builds a 2x2 cover mosaic of distinct album arts', () async {
      final lib = buildLibrary();
      final gen = mkGenerator(tracks: lib.tracks, features: lib.features);
      final mix = await gen.generateDailyMix(
          mixName: 'Cover', mood: MixMood.chill, trackCount: 30);

      expect(mix.coverArtPaths, isNotEmpty);
      expect(mix.coverArtPaths.length, lessThanOrEqualTo(4));
      expect(mix.coverArtPaths.toSet().length, mix.coverArtPaths.length,
          reason: 'mosaic tiles are distinct albums');
    });

    test('prefers recently played tracks as anchors when history exists',
        () async {
      final lib = buildLibrary();
      final gen = mkGenerator(
        tracks: lib.tracks,
        features: lib.features,
        topIds: ['low0', 'low1', 'low2', 'low3', 'low4'],
      );
      final mix = await gen.generateDailyMix(
          mixName: 'Recent', mood: MixMood.chill, trackCount: 30);

      expect(mix.trackIds.any((id) => id.startsWith('low')), isTrue);
    });
  });

  group('generateAllDailyMixes', () {
    test('produces one mix per mood', () async {
      final lib = buildLibrary();
      final playlists = _FakePlaylistRepo();
      final gen = mkGenerator(
          tracks: lib.tracks, features: lib.features, playlists: playlists);

      final mixes = await gen.generateAllDailyMixes();
      expect(mixes, hasLength(MixMood.values.length));
      expect(mixes.map((m) => m.mood).toSet(), MixMood.values.toSet());
    });

    test('throws when nothing can be generated', () async {
      final gen = mkGenerator(tracks: [], features: {});
      expect(gen.generateAllDailyMixes, throwsA(isA<MixGenerationError>()));
    });
  });

  group('generateInfiniteMixtape', () {
    test('starts from the seed and drifts outward', () async {
      final lib = buildLibrary();
      final gen = mkGenerator(tracks: lib.tracks, features: lib.features);

      final mix =
          await gen.generateInfiniteMixtape(seedTrackId: 'hi0', trackCount: 20);

      expect(mix.trackIds.first, 'hi0', reason: 'the seed opens the mixtape');
      expect(mix.trackIds.toSet().length, mix.trackIds.length);
      expect(mix.trackIds.length, lessThanOrEqualTo(20));
    });

    test('honours diversity caps', () async {
      final lib = buildLibrary(perGroup: 15, artistsPerGroup: 1);
      final gen = mkGenerator(tracks: lib.tracks, features: lib.features);

      final mix =
          await gen.generateInfiniteMixtape(seedTrackId: 'hi0', trackCount: 40);

      final byId = {for (final t in lib.tracks) t.id: t};
      final perArtist = <String, int>{};
      for (final id in mix.trackIds) {
        final t = byId[id]!;
        perArtist[t.artistId] = (perArtist[t.artistId] ?? 0) + 1;
      }
      expect(perArtist.values.every((c) => c <= kMaxTracksPerArtist), isTrue);
    });

    test('rejects an unknown or unanalysed seed', () async {
      final lib = buildLibrary();
      final gen = mkGenerator(tracks: lib.tracks, features: lib.features);

      expect(
        () => gen.generateInfiniteMixtape(seedTrackId: 'nope'),
        throwsA(isA<MixGenerationError>()),
      );

      final noFeatures = mkGenerator(tracks: lib.tracks, features: const {});
      expect(
        () => noFeatures.generateInfiniteMixtape(seedTrackId: 'hi0'),
        throwsA(isA<MixGenerationError>()),
      );
    });
  });

  group('staleness', () {
    test('a mix older than 24h is stale', () {
      final now = DateTime(2026, 1, 2, 12);
      Playlist at(int hoursAgo) => Playlist(
            id: 'p',
            name: 'p',
            createdAtMs: 0,
            updatedAtMs: now
                .subtract(Duration(hours: hoursAgo))
                .millisecondsSinceEpoch,
          );

      expect(SmartMixGenerator.isStale(at(25), now: now), isTrue);
      expect(SmartMixGenerator.isStale(at(23), now: now), isFalse);
    });

    test('regenerateStaleMixes does a full run when nothing exists', () async {
      final lib = buildLibrary();
      final playlists = _FakePlaylistRepo()..existing = [];
      final gen = mkGenerator(
          tracks: lib.tracks, features: lib.features, playlists: playlists);

      final rebuilt = await gen.regenerateStaleMixes();
      expect(rebuilt, hasLength(MixMood.values.length));
    });

    test('regenerateStaleMixes skips fresh mixes', () async {
      final lib = buildLibrary();
      final now = DateTime.now().millisecondsSinceEpoch;
      final playlists = _FakePlaylistRepo()
        ..existing = [
          Playlist(
            id: 'p1',
            name: 'Deep Focus',
            type: PlaylistType.smartMix,
            mood: MixMood.focus,
            createdAtMs: now,
            updatedAtMs: now, // just built
          ),
        ];
      final gen = mkGenerator(
          tracks: lib.tracks, features: lib.features, playlists: playlists);

      expect(await gen.regenerateStaleMixes(), isEmpty);
    });

    test('regenerateStaleMixes rebuilds only the stale ones', () async {
      final lib = buildLibrary();
      final now = DateTime.now();
      final stale =
          now.subtract(const Duration(hours: 30)).millisecondsSinceEpoch;
      final playlists = _FakePlaylistRepo()
        ..existing = [
          Playlist(
            id: 'p1',
            name: 'Deep Focus',
            type: PlaylistType.smartMix,
            mood: MixMood.focus,
            createdAtMs: stale,
            updatedAtMs: stale,
          ),
          Playlist(
            id: 'p2',
            name: 'Chill Current',
            type: PlaylistType.smartMix,
            mood: MixMood.chill,
            createdAtMs: now.millisecondsSinceEpoch,
            updatedAtMs: now.millisecondsSinceEpoch,
          ),
        ];
      final gen = mkGenerator(
          tracks: lib.tracks, features: lib.features, playlists: playlists);

      final rebuilt = await gen.regenerateStaleMixes();
      expect(rebuilt, hasLength(1));
      expect(rebuilt.single.mood, MixMood.focus);
    });
  });
}
