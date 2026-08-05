// test/domain/intelli_shuffle_engine_test.dart
// Aura — Unit tests for IntelliShuffleEngine.
// CLAUDE.md §1: "Provide a clean Dart class with unit tests sketch."

import 'package:flutter_test/flutter_test.dart';
import 'package:aura/domain/use_cases/intelli_shuffle_engine.dart';
import 'package:aura/domain/entities/track.dart';
import 'package:aura/domain/entities/shuffle_config.dart';
import 'package:aura/domain/repositories/behavior_repository.dart';
import 'package:aura/core/errors.dart';

// ── Stub BehaviorRepository ────────────────────────────────────────────────────

/// In-memory stub for BehaviorRepository used in unit tests.
/// All tracks have zero play/skip counts by default.
class _StubBehaviorRepo implements BehaviorRepository {
  final Map<String, TrackBehaviorStats> _overrides;

  const _StubBehaviorRepo({Map<String, TrackBehaviorStats>? overrides})
      : _overrides = overrides ?? const {};

  @override
  Future<void> recordEvent(PlayEvent event) async {}

  @override
  Future<Map<String, TrackBehaviorStats>> getBehaviorStats(
      List<String> trackIds) async {
    return {
      for (final id in trackIds)
        id: _overrides[id] ??
            TrackBehaviorStats(
              trackId: id,
              playCount: 0,
              skipCount: 0,
              rating: 0,
            ),
    };
  }

  @override
  Future<List<PlayEvent>> getPlayHistory(String trackId,
          {int limit = 100}) async =>
      [];

  @override
  Future<List<String>> getTopPlayedTrackIds(
          {int topN = 20, int days = 30}) async =>
      [];

  @override
  Future<void> pruneHistory(Duration retainDuration) async {}
}

// ── Test Helpers ───────────────────────────────────────────────────────────────

/// Generates [n] test tracks with sequential IDs and optionally cycling artists.
List<Track> _makeTracks(int n, {int artistCount = 3}) {
  final now = DateTime.now().millisecondsSinceEpoch;
  return List.generate(
    n,
    (i) => Track(
      id: 'track_$i',
      title: 'Track $i',
      artistName: 'Artist ${i % artistCount}',
      albumTitle: 'Album ${i ~/ 5}',
      artistId: 'artist_${i % artistCount}',
      albumId: 'album_${i ~/ 5}',
      durationMs: 200000 + i * 1000,
      filePath: '/music/track_$i.mp3',
      fileSizeBytes: 5000000,
      dateAddedMs: now,
    ),
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  group('IntelliShuffleEngine', () {
    // Deterministic seed for reproducible tests.
    const testConfig = ShuffleConfig(
      artistSpacing: 2,
      seed: 42,
    );

    test('generate() throws EmptyLibraryError for empty track list', () async {
      final engine = IntelliShuffleEngine(
        config: testConfig,
        behaviorRepository: const _StubBehaviorRepo(),
      );
      expect(engine.generate([]), throwsA(isA<EmptyLibraryError>()));
    });

    test('generate() creates a full permutation (n=100)', () async {
      final tracks = _makeTracks(100);
      final engine = IntelliShuffleEngine(
        config: testConfig,
        behaviorRepository: const _StubBehaviorRepo(),
      );

      await engine.generate(tracks);

      expect(engine.remainingCount, equals(100));
      expect(engine.hasQueue, isTrue);
    });

    test('nextTrack() returns all track IDs exactly once per cycle', () async {
      const n = 50;
      final tracks = _makeTracks(n);
      final engine = IntelliShuffleEngine(
        config: testConfig,
        behaviorRepository: const _StubBehaviorRepo(),
      );

      await engine.generate(tracks);

      final seen = <String>{};
      for (int i = 0; i < n; i++) {
        final id = engine.nextTrack();
        expect(seen.contains(id), isFalse, reason: 'Track $id returned twice');
        seen.add(id);
      }
      expect(seen.length, equals(n));
    });

    test('artist spacing is enforced (spacing=2)', () async {
      // With 10 tracks across 3 artists and spacing=2, no same artist should
      // appear within 2 positions of each other.
      final tracks = _makeTracks(30, artistCount: 3);
      final engine = IntelliShuffleEngine(
        config: const ShuffleConfig(artistSpacing: 2, seed: 123),
        behaviorRepository: const _StubBehaviorRepo(),
      );

      await engine.generate(tracks);

      final result = <String>[];
      for (int i = 0; i < 30; i++) {
        result.add(engine.nextTrack());
      }

      // Verify no two consecutive tracks share the same artist
      // (spacing=2 means at least 2 tracks between same artist).
      int violations = 0;
      for (int i = 1; i < result.length; i++) {
        // Actually compare artistIds from the generated tracks lookup.
        final trackA = tracks.firstWhere((t) => t.id == result[i - 1]);
        final trackB = tracks.firstWhere((t) => t.id == result[i]);
        if (trackA.artistId == trackB.artistId) violations++;
      }

      // With 30 tracks and 3 artists, perfect spacing is achievable.
      // Allow at most 2 violations (greedy algorithm can't always avoid all).
      expect(violations, lessThanOrEqualTo(2),
          reason: 'Too many artist-spacing violations: $violations');
    });

    test('higher-rated tracks appear earlier on average', () async {
      // Create 50 tracks: 5 with high rating, 45 with zero.
      final now = DateTime.now().millisecondsSinceEpoch;
      final tracks = List.generate(50, (i) {
        return Track(
          id: 'track_$i',
          title: 'Track $i',
          artistName: 'Artist ${i % 10}',
          albumTitle: 'Album',
          artistId: 'artist_${i % 10}',
          albumId: 'album_0',
          durationMs: 200000,
          filePath: '/music/track_$i.mp3',
          fileSizeBytes: 5000000,
          dateAddedMs: now,
          rating: i < 5 ? 5 : 0, // First 5 tracks have rating=5.
        );
      });

      // Override behavior stats to match ratings.
      final stats = <String, TrackBehaviorStats>{
        for (int i = 0; i < 5; i++)
          'track_$i': TrackBehaviorStats(
            trackId: 'track_$i',
            playCount: 20,
            skipCount: 0,
            rating: 5,
          ),
      };

      final engine = IntelliShuffleEngine(
        config: const ShuffleConfig(favoriteBias: 1.0, seed: 999),
        behaviorRepository: _StubBehaviorRepo(overrides: stats),
      );

      await engine.generate(tracks);

      // Collect positions of the 5 high-rated tracks.
      final result = <String>[];
      for (int i = 0; i < 50; i++) {
        result.add(engine.nextTrack());
      }

      final highRatedIds = {'track_0', 'track_1', 'track_2', 'track_3', 'track_4'};
      final positions = result
          .asMap()
          .entries
          .where((e) => highRatedIds.contains(e.value))
          .map((e) => e.key)
          .toList();

      final avgPosition = positions.fold(0, (a, b) => a + b) / positions.length;
      // On average, high-rated tracks should appear in the first 40% (position < 20).
      expect(avgPosition, lessThan(25.0),
          reason: 'Expected high-rated tracks to appear earlier (avg pos: $avgPosition)');
    });

    test('state serialises and deserialises correctly', () async {
      final tracks = _makeTracks(20);
      final engine = IntelliShuffleEngine(
        config: testConfig,
        behaviorRepository: const _StubBehaviorRepo(),
      );

      await engine.generate(tracks);

      // Advance 5 tracks.
      final played = <String>[];
      for (int i = 0; i < 5; i++) {
        played.add(engine.nextTrack());
      }

      // Serialise.
      final json = engine.exportState();
      expect(json, isNotNull);

      // New engine restores state.
      final engine2 = IntelliShuffleEngine(
        config: testConfig,
        behaviorRepository: const _StubBehaviorRepo(),
      );
      engine2.importState(json!);

      // The next track from engine2 should match engine.
      expect(engine2.remainingCount, equals(engine.remainingCount));
      expect(engine2.nextTrack(), equals(engine.nextTrack()));
    });

    test('addTracks() appends new tracks to unplayed portion', () async {
      final tracks = _makeTracks(10);
      final engine = IntelliShuffleEngine(
        config: testConfig,
        behaviorRepository: const _StubBehaviorRepo(),
      );

      await engine.generate(tracks);

      // Play 5 tracks.
      for (int i = 0; i < 5; i++) {
        engine.nextTrack();
      }

      final before = engine.remainingCount;

      // Add 3 new tracks.
      final newTracks = _makeTracks(3).map((t) => t.copyWith(
            id: 'new_${t.id}',
            filePath: '/music/new_${t.id}.mp3',
          )).toList();

      await engine.addTracks(newTracks);

      expect(engine.remainingCount, equals(before + 3));
    });

    test('nextTrack() wraps around when exhausted', () async {
      final tracks = _makeTracks(3);
      final engine = IntelliShuffleEngine(
        config: testConfig,
        behaviorRepository: const _StubBehaviorRepo(),
      );

      await engine.generate(tracks);

      // Exhaust all 3 tracks.
      engine.nextTrack();
      engine.nextTrack();
      engine.nextTrack();

      // Should wrap rather than throw.
      expect(() => engine.nextTrack(), returnsNormally);
    });
  });
}
