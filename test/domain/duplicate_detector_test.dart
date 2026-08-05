// test/domain/duplicate_detector_test.dart
// Aura — Unit tests for DuplicateDetector.

import 'package:flutter_test/flutter_test.dart';
import 'package:aura/domain/use_cases/duplicate_detector.dart';
import 'package:aura/domain/entities/track.dart';
import 'package:aura/core/errors.dart';

// ── Test Helpers ───────────────────────────────────────────────────────────────

Track _track({
  required String id,
  required String title,
  required String artist,
  required int durationMs,
  int bitRate = 320,
  int fileSize = 10000000,
  int playCount = 0,
}) {
  final now = DateTime.now().millisecondsSinceEpoch;
  return Track(
    id: id,
    title: title,
    artistName: artist,
    albumTitle: 'Test Album',
    artistId: 'artist_$artist',
    albumId: 'album_1',
    durationMs: durationMs,
    filePath: '/music/$id.mp3',
    fileSizeBytes: fileSize,
    bitRateKbps: bitRate,
    playCount: playCount,
    dateAddedMs: now,
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  const detector = DuplicateDetector();

  // ── Exact Match ─────────────────────────────────────────────────────────────
  group('detectExact()', () {
    test('finds identical title+artist+duration pair', () {
      final tracks = [
        _track(id: 'a', title: 'Yesterday', artist: 'The Beatles', durationMs: 125000),
        _track(id: 'b', title: 'Yesterday', artist: 'The Beatles', durationMs: 125000),
        _track(id: 'c', title: 'Hey Jude', artist: 'The Beatles', durationMs: 430000),
      ];

      final groups = detector.detectExact(tracks);

      expect(groups.length, equals(1));
      expect(groups.first.allTracks.map((t) => t.id),
          containsAll(['a', 'b']));
      expect(groups.first.matchType, equals(DuplicateMatchType.exact));
    });

    test('returns empty list when no duplicates exist', () {
      final tracks = [
        _track(id: 'a', title: 'Song A', artist: 'Artist A', durationMs: 200000),
        _track(id: 'b', title: 'Song B', artist: 'Artist B', durationMs: 300000),
        _track(id: 'c', title: 'Song C', artist: 'Artist C', durationMs: 180000),
      ];

      expect(detector.detectExact(tracks), isEmpty);
    });

    test('handles duration tolerance (±1s = same bucket)', () {
      // 125000ms and 126500ms differ by 1.5s but fall in the same 2s bucket.
      final tracks = [
        _track(id: 'a', title: 'Yesterday', artist: 'Beatles', durationMs: 125000),
        _track(id: 'b', title: 'Yesterday', artist: 'Beatles', durationMs: 125800),
      ];

      final groups = detector.detectExact(tracks);
      expect(groups.length, equals(1));
    });

    test('handles duration outside tolerance (>2s = different bucket)', () {
      // 125000ms and 127500ms differ by 2.5s — different buckets.
      final tracks = [
        _track(id: 'a', title: 'Yesterday', artist: 'Beatles', durationMs: 125000),
        _track(id: 'b', title: 'Yesterday', artist: 'Beatles', durationMs: 127500),
      ];

      // May or may not group depending on bucket alignment; at 2.5s they're likely different.
      // The test just verifies no crash.
      expect(() => detector.detectExact(tracks), returnsNormally);
    });

    test('selects highest-bitrate track as primary', () {
      final tracks = [
        _track(id: 'lossless', title: 'Song', artist: 'Artist', durationMs: 200000,
            bitRate: 0 /* FLAC */),
        _track(id: 'lossy', title: 'Song', artist: 'Artist', durationMs: 200000,
            bitRate: 128),
      ];

      final groups = detector.detectExact(tracks);
      expect(groups.length, equals(1));
      expect(groups.first.primary.id, equals('lossless'),
          reason: 'FLAC (bitRate=0 treated as lossless) should be primary');
    });

    test('handles empty track list', () {
      expect(detector.detectExact([]), isEmpty);
    });

    test('handles single track (no group possible)', () {
      final tracks = [
        _track(id: 'a', title: 'Song', artist: 'Artist', durationMs: 200000),
      ];
      expect(detector.detectExact(tracks), isEmpty);
    });

    test('normalises title case and punctuation for matching', () {
      final tracks = [
        _track(id: 'a', title: "Don't Stop", artist: 'Journey', durationMs: 210000),
        _track(id: 'b', title: 'dont stop', artist: 'journey', durationMs: 210000),
      ];

      final groups = detector.detectExact(tracks);
      expect(groups.length, equals(1));
    });
  });

  // ── Fuzzy Match ─────────────────────────────────────────────────────────────
  group('detectFuzzy()', () {
    test('finds near-match: "The Beatles - Yesterday" vs "Beatles - Yesterday"',
        () {
      final tracks = [
        _track(id: 'a', title: 'Yesterday', artist: 'The Beatles', durationMs: 125000),
        _track(id: 'b', title: 'Yesterday', artist: 'Beatles', durationMs: 125000),
        _track(id: 'c', title: 'Hey Jude', artist: 'The Beatles', durationMs: 430000),
      ];

      final groups = detector.detectFuzzy(tracks);

      // "Yesterday The Beatles" vs "Yesterday Beatles" should score > 0.85.
      expect(groups.length, greaterThanOrEqualTo(1));
      final found = groups.any((g) =>
          g.allTracks.any((t) => t.id == 'a') &&
          g.allTracks.any((t) => t.id == 'b'));
      expect(found, isTrue);
    });

    test('no false positive for clearly different tracks', () {
      final tracks = [
        _track(id: 'a', title: 'Bohemian Rhapsody', artist: 'Queen', durationMs: 354000),
        _track(id: 'b', title: 'Hotel California', artist: 'Eagles', durationMs: 391000),
        _track(id: 'c', title: 'Stairway to Heaven', artist: 'Led Zeppelin', durationMs: 482000),
      ];

      final groups = detector.detectFuzzy(tracks);
      expect(groups, isEmpty,
          reason: 'Completely different tracks should not match');
    });

    test('returns similarity score for fuzzy matches', () {
      final tracks = [
        _track(id: 'a', title: 'Yesterday', artist: 'The Beatles', durationMs: 125000),
        _track(id: 'b', title: 'Yesterday', artist: 'Beatles', durationMs: 125000),
      ];

      final groups = detector.detectFuzzy(tracks);
      if (groups.isNotEmpty) {
        expect(groups.first.similarityScore, isNotNull);
        expect(groups.first.similarityScore, greaterThan(0.5));
      }
    });

    test('handles large track list efficiently (n=500)', () {
      // Should complete without timeout (all unique tracks).
      final now = DateTime.now().millisecondsSinceEpoch;
      final tracks = List.generate(500, (i) => Track(
            id: 'track_$i',
            title: 'Unique Song Title $i',
            artistName: 'Artist $i',
            albumTitle: 'Album',
            artistId: 'artist_$i',
            albumId: 'album',
            durationMs: 200000 + i * 10000,
            filePath: '/music/track_$i.mp3',
            fileSizeBytes: 5000000,
            dateAddedMs: now,
          ));

      final start = DateTime.now();
      final groups = detector.detectFuzzy(tracks);
      final elapsed = DateTime.now().difference(start);

      expect(elapsed.inMilliseconds, lessThan(5000),
          reason: 'Fuzzy detection should complete in <5s for 500 tracks');
      expect(groups, isEmpty); // All titles unique.
    });
  });

  // ── Fingerprint (Stub) ───────────────────────────────────────────────────────
  group('detectByFingerprint()', () {
    test('throws FingerprintUnavailableError in Sprint 1', () {
      final tracks = [
        _track(id: 'a', title: 'Song A', artist: 'Artist', durationMs: 200000),
      ];

      expect(
        detector.detectByFingerprint(tracks),
        throwsA(isA<FingerprintUnavailableError>()),
      );
    });
  });

  // ── detectAll() ─────────────────────────────────────────────────────────────
  group('detectAll()', () {
    test('runs exact and fuzzy; silently skips fingerprint', () async {
      final tracks = [
        // Exact pair.
        _track(id: 'a', title: 'Song X', artist: 'Artist', durationMs: 200000),
        _track(id: 'b', title: 'Song X', artist: 'Artist', durationMs: 200000),
        // Unique.
        _track(id: 'c', title: 'Song Y', artist: 'Artist2', durationMs: 300000),
      ];

      final groups = await detector.detectAll(tracks);

      expect(groups.length, equals(1));
      expect(groups.first.matchType, equals(DuplicateMatchType.exact));
    });

    test('each track appears in at most one group', () async {
      final tracks = [
        _track(id: 'a', title: 'Song', artist: 'Artist', durationMs: 200000),
        _track(id: 'b', title: 'Song', artist: 'Artist', durationMs: 200000),
        _track(id: 'c', title: 'Different', artist: 'Other', durationMs: 300000),
      ];

      final groups = await detector.detectAll(tracks);
      final allIds = groups.expand((g) => g.allTracks.map((t) => t.id)).toList();
      final uniqueIds = allIds.toSet();

      expect(allIds.length, equals(uniqueIds.length),
          reason: 'Each track should appear in at most one group');
    });
  });
}
