// test/intelli_shuffle_test.dart
// Aura — IntelliShuffleEngine unit tests.
//
// Pure Dart: fake in-memory repositories, no database and no plugins, so the
// suite runs fast and deterministically (every case pins ShuffleConfig.seed).
//
// Run: flutter test test/intelli_shuffle_test.dart

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:aura/domain/entities/shuffle_config.dart';
import 'package:aura/domain/entities/track.dart';
import 'package:aura/domain/intelli_shuffle/intelli_shuffle_engine.dart';
import 'package:aura/domain/repositories/behavior_repository.dart';
import 'package:aura/domain/repositories/music_repository.dart';
import 'package:aura/domain/entities/album.dart';
import 'package:aura/domain/entities/artist.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

class _FakeBehaviorRepo implements BehaviorRepository {
  _FakeBehaviorRepo([this.stats = const {}]);

  final Map<String, TrackBehaviorStats> stats;

  @override
  Future<Map<String, TrackBehaviorStats>> getBehaviorStats(List<String> ids) async {
    return {
      for (final id in ids)
        if (stats.containsKey(id)) id: stats[id]!,
    };
  }

  @override
  Future<void> recordEvent(PlayEvent event) async {}

  @override
  Future<List<PlayEvent>> getPlayHistory(String trackId, {int limit = 100}) async =>
      [];

  @override
  Future<List<String>> getTopPlayedTrackIds({int topN = 20, int days = 30}) async => [];

  @override
  Future<void> pruneHistory(Duration retainDuration) async {}

  @override
  Future<List<PlayEvent>> getEventsInRange(int startMs, int endMs) async =>
      const [];

  @override
  Future<Map<String, int>> getFirstPlayMsPerTrack() async => const {};

  @override
  Future<int?> getFirstEventMs() async => null;
  @override
  Future<List<String>> getRecentlyPlayedTrackIds({int limit = 200}) async => const [];
}

class _FakeMusicRepo implements MusicRepository {
  _FakeMusicRepo({this.features = const {}});

  /// trackId → 6-dimension feature vector.
  final Map<String, List<double>> features;

  int featureCalls = 0;

  @override
  Future<List<double>?> getAudioFeatures(String trackId) async {
    featureCalls++;
    return features[trackId];
  }

  // Unused by the engine.
  @override
  Future<List<Track>> getAllTracks() async => [];
  @override
  Future<List<Track>> getTracksByAlbum(String albumId) async => [];
  @override
  Future<List<Track>> getTracksByArtist(String artistId) async => [];
  @override
  Future<Track?> getTrackById(String id) async => null;
  @override
  Future<List<Album>> getAllAlbums() async => [];
  @override
  Future<List<Artist>> getAllArtists() async => [];
  @override
  Stream<int> scanLibrary() => const Stream.empty();
  @override
  Future<void> upsertTracks(List<Track> tracks) async {}
  @override
  Future<void> deleteTrack(String trackId) async {}
  @override
  Future<void> recordPlay(String trackId, {required int durationPlayedMs}) async {}
  @override
  Future<void> recordSkip(String trackId) async {}
  @override
  Future<void> setRating(String trackId, int rating) async {}
  @override
  Future<List<Track>> getFavouriteTracks() async => const [];
  @override
  Future<List<Track>> getTracksByIds(List<String> ids) async => const [];
  @override
  Future<List<GenreSummary>> getGenres() async => const [];
  @override
  Future<List<Track>> findTracksByGenre(String genre) async => const [];
  @override
  Future<List<Track>> getRecentlyAddedTracks({int limit = 200}) async => const [];
  @override
  Future<List<Track>> getNeverPlayedTracks() async => const [];
  @override
  Future<void> setFavourite(String trackId, bool favourite) async {}
  @override
  Future<void> upsertAudioFeatures(String trackId, List<double> features) async {}
}

// ── Fixtures ──────────────────────────────────────────────────────────────────

Track makeTrack(
  String id, {
  String? artistId,
  String? albumId,
  int playCount = 0,
  int rating = 0,
  int? lastPlayedMs,
}) {
  return Track(
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
    rating: rating,
    lastPlayedMs: lastPlayedMs,
  );
}

/// [count] tracks cycling through [artistCount] artists and [albumCount] albums.
List<Track> makeLibrary(int count, {int artistCount = 10, int albumCount = 20}) {
  return List.generate(count, (i) {
    return makeTrack(
      't$i',
      artistId: 'artist_${i % artistCount}',
      albumId: 'album_${i % albumCount}',
    );
  });
}

IntelliShuffleEngine makeEngine({
  ShuffleConfig? config,
  _FakeBehaviorRepo? behavior,
  _FakeMusicRepo? music,
}) {
  return IntelliShuffleEngine(
    config: config ?? const ShuffleConfig(seed: 42),
    trackRepository: music ?? _FakeMusicRepo(),
    behaviorRepository: behavior ?? _FakeBehaviorRepo(),
  );
}

/// Walks the whole queue, returning every track handed back.
List<Track> drain(IntelliShuffleEngine engine) {
  final out = <Track>[];
  while (true) {
    final t = engine.nextTrack();
    if (t == null) break;
    out.add(t);
  }
  return out;
}

void main() {
  group('generateShuffle', () {
    test('empty library yields an empty queue rather than throwing', () async {
      final engine = makeEngine();
      final result = await engine.generateShuffle([]);
      expect(result, isEmpty);
      expect(engine.nextTrack(), isNull);
    });

    test('produces a complete permutation with no repeats in a cycle', () async {
      final engine = makeEngine();
      final library = makeLibrary(200);

      await engine.generateShuffle(library);
      final played = drain(engine);

      expect(played, hasLength(library.length));
      final ids = played.map((t) => t.id).toSet();
      expect(ids, hasLength(library.length),
          reason: 'every track appears exactly once per cycle');
      expect(ids, equals(library.map((t) => t.id).toSet()));
    });

    test('queue is exhausted after a full cycle', () async {
      final engine = makeEngine();
      await engine.generateShuffle(makeLibrary(20));
      drain(engine);
      expect(engine.remainingCount, 0);
      expect(engine.nextTrack(), isNull);
    });

    test('is deterministic for a fixed seed', () async {
      final library = makeLibrary(100);
      final a = makeEngine(config: const ShuffleConfig(seed: 7));
      final b = makeEngine(config: const ShuffleConfig(seed: 7));

      final first = (await a.generateShuffle(library)).map((t) => t.id).toList();
      final second = (await b.generateShuffle(library)).map((t) => t.id).toList();
      expect(first, equals(second));
    });
  });

  group('spacing constraints', () {
    test('artist spacing is respected when the library allows it', () async {
      const spacing = 3;
      final engine = makeEngine(
        config: const ShuffleConfig(
          artistSpacing: spacing,
          albumSpacing: 0,
          discovery: 0,
          seed: 11,
        ),
      );
      // 12 artists over 120 tracks leaves ample room to satisfy spacing.
      final order = await engine.generateShuffle(
        makeLibrary(120, artistCount: 12, albumCount: 12),
      );

      // Spacing cannot be guaranteed at the very end of a permutation: once
      // only a couple of tracks remain, they may all share an artist with the
      // window and no legal pick exists. The engine's actual promise is that
      // it relaxes ONLY then — so assert that, rather than a blanket zero,
      // which would be asserting something no shuffler can deliver.
      expect(
        _spacingViolationsWithAlternatives(
            order, spacing, (t) => t.artistId),
        isEmpty,
        reason: 'artist spacing was relaxed while a legal pick remained',
      );
    });

    test('album spacing is respected when the library allows it', () async {
      const spacing = 3;
      final engine = makeEngine(
        config: const ShuffleConfig(
          artistSpacing: 0,
          albumSpacing: spacing,
          discovery: 0,
          seed: 13,
        ),
      );
      final order = await engine.generateShuffle(
        makeLibrary(120, artistCount: 30, albumCount: 15),
      );

      expect(
        _spacingViolationsWithAlternatives(order, spacing, (t) => t.albumId),
        isEmpty,
        reason: 'album spacing was relaxed while a legal pick remained',
      );
    });

    test('relaxes constraints instead of deadlocking when they are impossible',
        () async {
      // One artist, one album, spacing 5 — the constraint cannot be satisfied,
      // so the engine must relax and still emit every track exactly once.
      final engine = makeEngine(
        config: const ShuffleConfig(
          artistSpacing: 5,
          albumSpacing: 5,
          seed: 5,
        ),
      );
      final library = makeLibrary(30, artistCount: 1, albumCount: 1);

      final order = await engine.generateShuffle(library);
      expect(order, hasLength(30));
      expect(order.map((t) => t.id).toSet(), hasLength(30));
    });

    test('spacing of zero disables the constraint', () async {
      final engine = makeEngine(
        config: const ShuffleConfig(artistSpacing: 0, albumSpacing: 0, seed: 3),
      );
      final order = await engine.generateShuffle(makeLibrary(50));
      expect(order, hasLength(50));
    });
  });

  group('weighting', () {
    test('favourite bias pulls high-rated, high-play tracks earlier', () async {
      // 20 favourites vs 80 ordinary tracks.
      final library = <Track>[
        for (int i = 0; i < 20; i++)
          makeTrack('fav$i', artistId: 'a$i', playCount: 50, rating: 5),
        for (int i = 0; i < 80; i++)
          makeTrack('plain$i', artistId: 'b$i'),
      ];

      // Average position of favourites across several seeds, to avoid pinning
      // the assertion to one lucky permutation.
      var favSum = 0.0;
      var plainSum = 0.0;
      const seeds = [1, 2, 3, 4, 5];
      for (final seed in seeds) {
        final engine = makeEngine(
          config: ShuffleConfig(
            favouriteBias: 1.0,
            recencyAvoidance: 0,
            discovery: 0,
            artistSpacing: 0,
            albumSpacing: 0,
            seed: seed,
          ),
        );
        final order = await engine.generateShuffle(library);
        for (int i = 0; i < order.length; i++) {
          if (order[i].id.startsWith('fav')) {
            favSum += i;
          } else {
            plainSum += i;
          }
        }
      }
      final favAvg = favSum / (20 * seeds.length);
      final plainAvg = plainSum / (80 * seeds.length);
      expect(favAvg, lessThan(plainAvg),
          reason: 'favourites should average an earlier position');
    });

    test('recency penalty defers recently played tracks', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      const hour = 3600000;

      final library = <Track>[
        // Played minutes ago — should be pushed back.
        for (int i = 0; i < 20; i++)
          makeTrack('recent$i', artistId: 'a$i', lastPlayedMs: now - 60000),
        // Played a year ago — effectively "fresh".
        for (int i = 0; i < 20; i++)
          makeTrack('old$i', artistId: 'b$i', lastPlayedMs: now - 8760 * hour),
      ];

      var recentSum = 0.0;
      var oldSum = 0.0;
      const seeds = [1, 2, 3, 4, 5];
      for (final seed in seeds) {
        final engine = makeEngine(
          config: ShuffleConfig(
            recencyAvoidance: 1.0,
            favouriteBias: 0,
            discovery: 0,
            artistSpacing: 0,
            albumSpacing: 0,
            seed: seed,
          ),
        );
        final order = await engine.generateShuffle(library);
        for (int i = 0; i < order.length; i++) {
          if (order[i].id.startsWith('recent')) {
            recentSum += i;
          } else {
            oldSum += i;
          }
        }
      }
      expect(recentSum / (20 * seeds.length),
          greaterThan(oldSum / (20 * seeds.length)),
          reason: 'recently played should average a later position');
    });

    test('discovery injection surfaces unplayed tracks early', () async {
      // 10 never-played tracks buried among 90 heavily-played ones.
      final library = <Track>[
        for (int i = 0; i < 90; i++)
          makeTrack('played$i', artistId: 'a$i', playCount: 100),
        for (int i = 0; i < 10; i++) makeTrack('new$i', artistId: 'b$i'),
      ];

      var withDiscovery = 0.0;
      var withoutDiscovery = 0.0;
      const seeds = [1, 2, 3, 4, 5];
      for (final seed in seeds) {
        for (final discovery in [1.0, 0.0]) {
          final engine = makeEngine(
            config: ShuffleConfig(
              discovery: discovery,
              favouriteBias: 1.0, // biases *against* the unplayed tracks
              recencyAvoidance: 0,
              artistSpacing: 0,
              albumSpacing: 0,
              seed: seed,
            ),
          );
          final order = await engine.generateShuffle(library);
          var sum = 0.0;
          for (int i = 0; i < order.length; i++) {
            if (order[i].id.startsWith('new')) sum += i;
          }
          if (discovery == 1.0) {
            withDiscovery += sum / 10;
          } else {
            withoutDiscovery += sum / 10;
          }
        }
      }
      expect(withDiscovery / seeds.length,
          lessThan(withoutDiscovery / seeds.length),
          reason: 'discovery should pull unplayed tracks forward');
    });
  });

  group('mood matching', () {
    test('costs no repository reads when disabled', () async {
      final music = _FakeMusicRepo();
      final engine = makeEngine(
        music: music,
        config: const ShuffleConfig(moodMatching: false, seed: 1),
      );
      await engine.generateShuffle(makeLibrary(50));
      expect(music.featureCalls, 0);
    });

    test('biases toward tracks near the favourite mood', () async {
      // High-energy favourites define the reference mood; matching tracks
      // should land earlier than opposite-mood ones.
      final library = <Track>[
        for (int i = 0; i < 5; i++)
          makeTrack('seed$i', artistId: 'seed$i', rating: 5, playCount: 50),
        for (int i = 0; i < 20; i++) makeTrack('match$i', artistId: 'm$i'),
        for (int i = 0; i < 20; i++) makeTrack('opposite$i', artistId: 'o$i'),
      ];

      final features = <String, List<double>>{
        for (int i = 0; i < 5; i++) 'seed$i': [0.9, 0.9, 0.9, 0.9, 0.9, 0.9],
        for (int i = 0; i < 20; i++) 'match$i': [0.9, 0.9, 0.9, 0.9, 0.9, 0.9],
        for (int i = 0; i < 20; i++) 'opposite$i': [0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      };

      var matchSum = 0.0;
      var oppositeSum = 0.0;
      const seeds = [1, 2, 3, 4, 5];
      for (final seed in seeds) {
        final engine = makeEngine(
          music: _FakeMusicRepo(features: features),
          config: ShuffleConfig(
            moodMatching: true,
            moodStrength: 1.0,
            favouriteBias: 0,
            recencyAvoidance: 0,
            discovery: 0,
            artistSpacing: 0,
            albumSpacing: 0,
            seed: seed,
          ),
        );
        final order = await engine.generateShuffle(library);
        for (int i = 0; i < order.length; i++) {
          if (order[i].id.startsWith('match')) matchSum += i;
          if (order[i].id.startsWith('opposite')) oppositeSum += i;
        }
      }
      expect(matchSum / (20 * seeds.length),
          lessThan(oppositeSum / (20 * seeds.length)),
          reason: 'mood-matched tracks should average an earlier position');
    });

    test('tracks without features stay selectable (neutral weight)', () async {
      // Only half the library has been analysed — the rest must still play.
      final library = makeLibrary(40, artistCount: 40, albumCount: 40);
      final features = <String, List<double>>{
        for (int i = 0; i < 20; i++) 't$i': [0.5, 0.5, 0.5, 0.5, 0.5, 0.5],
      };
      final engine = makeEngine(
        music: _FakeMusicRepo(features: features),
        config: const ShuffleConfig(
            moodMatching: true, moodStrength: 1.0, seed: 9),
      );
      final order = await engine.generateShuffle(library);
      expect(order, hasLength(40));
      expect(order.map((t) => t.id).toSet(), hasLength(40));
    });
  });

  group('library mutations', () {
    test('addTracks places new tracks in the unplayed remainder', () async {
      final engine = makeEngine();
      await engine.generateShuffle(makeLibrary(20, artistCount: 20));

      // Consume five, then add more.
      for (int i = 0; i < 5; i++) {
        engine.nextTrack();
      }
      await engine.addTracks([makeTrack('extra', artistId: 'zz')]);

      final remaining = drain(engine).map((t) => t.id).toList();
      expect(remaining, contains('extra'),
          reason: 'a newly added track is reachable this cycle');
    });

    test('addTracks ignores tracks already queued', () async {
      final engine = makeEngine();
      final library = makeLibrary(10, artistCount: 10);
      await engine.generateShuffle(library);

      await engine.addTracks([library.first]);
      expect(engine.queue.where((id) => id == library.first.id), hasLength(1));
    });

    test('addTracks on a fresh engine generates a queue', () async {
      final engine = makeEngine();
      await engine.addTracks(makeLibrary(5, artistCount: 5));
      expect(engine.hasQueue, isTrue);
      expect(drain(engine), hasLength(5));
    });

    test('removeTrack drops it from the remaining queue', () async {
      final engine = makeEngine();
      final library = makeLibrary(20, artistCount: 20);
      await engine.generateShuffle(library);

      final victim = library[7];
      engine.removeTrack(victim);

      expect(engine.queue, isNot(contains(victim.id)));
      final played = drain(engine);
      expect(played.map((t) => t.id), isNot(contains(victim.id)));
      expect(played, hasLength(19));
    });

    test('removeTrack keeps the cursor on the same upcoming track', () async {
      final engine = makeEngine();
      await engine.generateShuffle(makeLibrary(20, artistCount: 20));
      for (int i = 0; i < 5; i++) {
        engine.nextTrack();
      }
      final upcoming = engine.peekNext();
      expect(upcoming, isNotNull);

      // Remove something already played — the next track must not change.
      final alreadyPlayed = engine.queue[0];
      engine.removeTrack(makeTrack(alreadyPlayed));
      expect(engine.peekNext()?.id, upcoming!.id);
    });
  });

  group('state persistence', () {
    test('serialize → restore round-trips the queue and position', () async {
      final engine = makeEngine();
      final library = makeLibrary(50, artistCount: 25);
      await engine.generateShuffle(library);

      for (int i = 0; i < 10; i++) {
        engine.nextTrack();
      }
      final expectedRemaining = engine.remainingCount;
      final expectedNext = engine.peekNext()!.id;
      final json = engine.serializeState();

      final restored = makeEngine();
      restored.restoreState(json);
      restored.hydrate(library);

      expect(restored.remainingCount, expectedRemaining);
      expect(restored.peekNext()?.id, expectedNext);
      expect(restored.queue, equals(engine.queue));
    });

    test('restored queue finishes the cycle without repeats', () async {
      final engine = makeEngine();
      final library = makeLibrary(30, artistCount: 15);
      await engine.generateShuffle(library);
      final firstHalf = <String>[];
      for (int i = 0; i < 10; i++) {
        firstHalf.add(engine.nextTrack()!.id);
      }

      final restored = makeEngine();
      restored.restoreState(engine.serializeState());
      restored.hydrate(library);

      final secondHalf = drain(restored).map((t) => t.id).toList();
      expect(firstHalf.toSet().intersection(secondHalf.toSet()), isEmpty,
          reason: 'no track plays twice across the restart');
      expect(firstHalf.length + secondHalf.length, 30);
    });

    test('serialized payload carries a schema version', () async {
      final engine = makeEngine();
      await engine.generateShuffle(makeLibrary(5, artistCount: 5));
      final map = jsonDecode(engine.serializeState()) as Map<String, dynamic>;
      expect(map['version'], kShuffleStateVersion);
      expect(map['shuffledIds'], hasLength(5));
      expect(map['config'], isA<Map<String, dynamic>>());
    });

    test('malformed or empty payloads are ignored, not fatal', () {
      final engine = makeEngine();
      expect(() => engine.restoreState(''), returnsNormally);
      expect(() => engine.restoreState('{}'), returnsNormally);
      expect(() => engine.restoreState('[1,2,3]'), returnsNormally);
      expect(engine.hasQueue, isFalse);
    });

    test('a payload from a newer schema version is refused', () async {
      final engine = makeEngine();
      await engine.generateShuffle(makeLibrary(5, artistCount: 5));
      final map = jsonDecode(engine.serializeState()) as Map<String, dynamic>;
      map['version'] = kShuffleStateVersion + 1;

      final other = makeEngine();
      other.restoreState(jsonEncode(map));
      expect(other.hasQueue, isFalse);
    });
  });

  group('feedback signals', () {
    test('skip lowers the cached weight for the next generation', () async {
      final engine = makeEngine();
      final library = makeLibrary(10, artistCount: 10);
      await engine.generateShuffle(library);

      final before = engine.state!.weights[library.first.id]!;
      engine.skip(library.first);
      final after = engine.state!.weights[library.first.id]!;
      expect(after, lessThan(before));
    });

    test('finishing a track raises its cached weight', () async {
      final engine = makeEngine(
        config: const ShuffleConfig(favouriteBias: 1.0, seed: 1),
      );
      final library = makeLibrary(10, artistCount: 10);
      await engine.generateShuffle(library);

      final before = engine.state!.weights[library.first.id]!;
      engine.onTrackFinished(library.first);
      expect(engine.state!.weights[library.first.id]!, greaterThan(before));
    });

    test('feedback on an unknown track is a no-op', () async {
      final engine = makeEngine();
      await engine.generateShuffle(makeLibrary(5, artistCount: 5));
      expect(() => engine.skip(makeTrack('ghost')), returnsNormally);
      expect(() => engine.onTrackFinished(makeTrack('ghost')), returnsNormally);
    });
  });

  group('performance', () {
    test('generates a 10k-track shuffle in under 500ms', () async {
      final library = makeLibrary(10000, artistCount: 500, albumCount: 1000);
      final engine = makeEngine(
        config: const ShuffleConfig(seed: 1),
      );

      final sw = Stopwatch()..start();
      final order = await engine.generateShuffle(library);
      sw.stop();

      expect(order, hasLength(10000));
      expect(sw.elapsedMilliseconds, lessThan(500),
          reason: 'PRD §7: shuffle generation must stay well under 500ms');
    });

    test('nextTrack over a full 10k cycle stays fast', () async {
      final engine = makeEngine(config: const ShuffleConfig(seed: 2));
      await engine.generateShuffle(
          makeLibrary(10000, artistCount: 500, albumCount: 1000));

      final sw = Stopwatch()..start();
      final played = drain(engine);
      sw.stop();

      expect(played, hasLength(10000));
      expect(sw.elapsedMilliseconds, lessThan(500));
    });
  });
}

/// Positions where [order] repeats a key within [spacing] *even though* a
/// track further down the queue could legally have been placed there instead.
///
/// A violation with no alternative is the engine correctly relaxing an
/// impossible constraint; a violation with an alternative is a real bug.
List<int> _spacingViolationsWithAlternatives(
  List<Track> order,
  int spacing,
  String Function(Track) key,
) {
  final avoidable = <int>[];
  for (var i = 1; i < order.length; i++) {
    final window =
        order.sublist((i - spacing).clamp(0, i), i).map(key).toSet();
    if (!window.contains(key(order[i]))) continue;

    // Anything still unplayed at this point was a candidate for slot i.
    final hadLegalAlternative =
        order.sublist(i).any((t) => !window.contains(key(t)));
    if (hadLegalAlternative) avoidable.add(i);
  }
  return avoidable;
}
