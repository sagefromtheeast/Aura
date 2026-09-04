// test/duplicate_detector_test.dart
// Aura — Step 2.6 duplicate detector.
//
//   flutter test test/duplicate_detector_test.dart

import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:aura/domain/duplicate_detector/duplicate_detector.dart';
import 'package:aura/domain/duplicate_detector/fingerprint_math.dart';
import 'package:aura/domain/duplicate_detector/string_metrics.dart';
import 'package:aura/domain/entities/album.dart';
import 'package:aura/domain/entities/artist.dart';
import 'package:aura/domain/entities/track.dart';
import 'package:aura/domain/repositories/music_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fakes
// ─────────────────────────────────────────────────────────────────────────────

class FakeMusicRepository implements MusicRepository {
  FakeMusicRepository(List<Track> tracks)
      : _tracks = {for (final t in tracks) t.id: t};

  final Map<String, Track> _tracks;

  /// Ids passed to [deleteTrack], in call order.
  final List<String> deleted = [];

  /// Tracks written back by [upsertTracks], in call order.
  final List<Track> upserted = [];

  @override
  Future<List<Track>> getAllTracks() async => _tracks.values.toList();

  @override
  Future<Track?> getTrackById(String id) async => _tracks[id];

  @override
  Future<void> deleteTrack(String trackId) async {
    deleted.add(trackId);
    final existing = _tracks[trackId];
    if (existing != null) {
      _tracks[trackId] = existing.copyWith(isDeleted: true);
    }
  }

  @override
  Future<void> upsertTracks(List<Track> tracks) async {
    upserted.addAll(tracks);
    for (final t in tracks) {
      _tracks[t.id] = t;
    }
  }

  // ── Unused by the detector ────────────────────────────────────────────────
  @override
  Future<List<Track>> getTracksByAlbum(String albumId) async => const [];
  @override
  Future<List<Track>> getTracksByArtist(String artistId) async => const [];
  @override
  Future<List<Album>> getAllAlbums() async => const [];
  @override
  Future<List<Artist>> getAllArtists() async => const [];
  @override
  Stream<int> scanLibrary() => const Stream.empty();
  @override
  Future<void> recordPlay(String trackId,
      {required int durationPlayedMs}) async {}
  @override
  Future<void> recordSkip(String trackId) async {}
  @override
  Future<void> setRating(String trackId, int rating) async {}
  @override
  Future<List<double>?> getAudioFeatures(String trackId) async => null;
  @override
  Future<void> upsertAudioFeatures(
      String trackId, List<double> features) async {}
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Track track(
  String id, {
  String title = 'Nights',
  String artist = 'Frank Ocean',
  int durationMs = 307000,
  AudioFormat format = AudioFormat.mp3,
  int bitRateKbps = 320,
  int sampleRateHz = 44100,
  int playCount = 0,
  int skipCount = 0,
  int rating = 0,
  int fileSizeBytes = 8000000,
  int? lastPlayedMs,
}) {
  return Track(
    id: id,
    title: title,
    artistName: artist,
    albumTitle: 'Blonde',
    artistId: 'artist_${artist.hashCode}',
    albumId: 'album_blonde',
    durationMs: durationMs,
    filePath: '/music/$id.audio',
    fileSizeBytes: fileSizeBytes,
    format: format,
    bitRateKbps: bitRateKbps,
    sampleRateHz: sampleRateHz,
    playCount: playCount,
    skipCount: skipCount,
    rating: rating,
    dateAddedMs: 0,
    lastPlayedMs: lastPlayedMs,
  );
}

/// A fingerprinter driven by a fixed map, so layer 3 can be exercised without
/// a native library or real audio.
AudioFingerprinter stubFingerprinter(Map<String, List<int>> byPath) =>
    (path) async => byPath[path];

DuplicateDetector detectorFor(
  List<Track> tracks, {
  Map<String, List<int>> fingerprints = const {},
}) {
  return DuplicateDetector(
    trackRepository: FakeMusicRepository(tracks),
    audioFingerprinter: stubFingerprinter(fingerprints),
  );
}

/// Flips [bits] pseudo-randomly across [fingerprint], simulating what a
/// different encoder does to the same recording.
List<int> perturb(List<int> fingerprint, int bits, {int seed = 1}) {
  final rng = math.Random(seed);
  final out = List<int>.of(fingerprint);
  for (var i = 0; i < bits; i++) {
    final index = rng.nextInt(out.length);
    out[index] ^= 1 << rng.nextInt(32);
  }
  return out;
}

void main() {
  // ───────────────────────────────────────────────────────────────────────────
  group('Layer 1 — exact match', () {
    test('finds two copies with identical metadata', () async {
      final detector = detectorFor([
        track('a'),
        track('b', format: AudioFormat.flac, bitRateKbps: 0),
        track('c', title: 'Solo', durationMs: 259000),
      ]);

      final groups = await detector.findDuplicates(
          level: DuplicateDetectionLevel.exact);

      expect(groups, hasLength(1));
      expect(groups.single.type, DuplicateType.exact);
      expect(groups.single.confidence, 1.0);
      expect(groups.single.tracks.map((t) => t.id), unorderedEquals(['a', 'b']));
    });

    test('ignores "Remastered" and punctuation when keying', () async {
      final detector = detectorFor([
        track('a', title: 'Nights'),
        track('b', title: 'Nights (2016 Remaster)'),
        track('c', title: '  nights!  '),
      ]);

      final groups = await detector.findDuplicates(
          level: DuplicateDetectionLevel.exact);

      expect(groups, hasLength(1));
      expect(groups.single.tracks, hasLength(3));
    });

    test('a 1-second difference still buckets together, 3 seconds does not',
        () async {
      final detector = detectorFor([
        track('a', durationMs: 307000),
        track('b', durationMs: 307900),
        track('c', durationMs: 310500),
      ]);

      final groups = await detector.findDuplicates(
          level: DuplicateDetectionLevel.exact);

      expect(groups, hasLength(1));
      expect(groups.single.tracks.map((t) => t.id), unorderedEquals(['a', 'b']));
    });

    test('different artists are never an exact match', () async {
      final detector = detectorFor([
        track('a', artist: 'Frank Ocean'),
        track('b', artist: 'Blood Orange'),
      ]);

      expect(
        await detector.findDuplicates(level: DuplicateDetectionLevel.exact),
        isEmpty,
      );
    });

    test('the group is ordered best copy first', () async {
      final detector = detectorFor([
        track('mp3', format: AudioFormat.mp3, bitRateKbps: 128),
        track('flac', format: AudioFormat.flac, bitRateKbps: 0),
        track('aac', format: AudioFormat.aac, bitRateKbps: 256),
      ]);

      final group = (await detector.findDuplicates(
              level: DuplicateDetectionLevel.exact))
          .single;

      expect(group.suggested.id, 'flac');
      expect(group.tracks.map((t) => t.id), ['flac', 'aac', 'mp3']);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('Layer 2 — fuzzy metadata', () {
    test('matches slightly different titles and artists', () async {
      final detector = detectorFor([
        track('a', title: 'Redbone', artist: 'Childish Gambino',
            durationMs: 327000),
        track('b',
            title: 'Redbone (Album Version)',
            artist: 'Childish Gambino',
            durationMs: 326000),
      ]);

      final groups = await detector.findDuplicates();

      expect(groups, hasLength(1));
      expect(groups.single.type, DuplicateType.fuzzyMetadata);
      expect(groups.single.confidence, greaterThanOrEqualTo(0.85));
    });

    test('an accented artist name still matches (Jaro-Winkler)', () async {
      final detector = detectorFor([
        track('a', title: 'Hoppipolla', artist: 'Sigur Ros'),
        track('a2', title: 'Hoppipolla', artist: 'Sigur Rós'),
      ]);

      final groups = await detector.findDuplicates();
      expect(groups, hasLength(1));
    });

    test('does not match a cover by a different artist', () async {
      final detector = detectorFor([
        track('a', title: 'Hallelujah', artist: 'Leonard Cohen'),
        track('b', title: 'Hallelujah', artist: 'Jeff Buckley'),
      ]);

      expect(await detector.findDuplicates(), isEmpty);
    });

    test('durations more than 2s apart are never fuzzy-matched', () async {
      final detector = detectorFor([
        track('a', title: 'Pyramids', durationMs: 300000),
        track('b', title: 'Pyramids', durationMs: 590000),
      ]);

      expect(await detector.findDuplicates(), isEmpty);
    });

    test('a pair straddling a duration bucket boundary is still compared',
        () async {
      // 3999ms and 4001ms fall either side of the 2000ms bucket edge. The
      // fuzzy layer buckets by duration to stay tractable, so it must look one
      // bucket ahead or it would never compare these two at all.
      final detector = detectorFor([
        track('a', title: 'Pyramids', durationMs: 3999),
        track('b', title: 'Pyramid', durationMs: 4001),
      ]);

      final groups = await detector.findDuplicates();
      expect(groups, hasLength(1));
      expect(groups.single.type, DuplicateType.fuzzyMetadata);
    });

    test('exact matches are not re-reported by the fuzzy layer', () async {
      final detector = detectorFor([track('a'), track('b'), track('c')]);

      final groups = await detector.findDuplicates();

      expect(groups, hasLength(1));
      expect(groups.single.type, DuplicateType.exact);
      expect(groups.single.tracks, hasLength(3));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('Layer 3 — audio fingerprint', () {
    // The same recording, re-encoded: different tags, a handful of flipped
    // bits. Metadata cannot connect these; only the audio can.
    final base = List<int>.generate(64, (i) => 0x5A5A0000 + i * 7717);

    test('matches a re-encode whose metadata says nothing alike', () async {
      final tracks = [
        track('orig', title: 'Nights', artist: 'Frank Ocean'),
        track('rip',
            title: 'Track 07', artist: 'Unknown Artist', durationMs: 306000),
      ];

      final detector = detectorFor(
        tracks,
        fingerprints: {
          '/music/orig.audio': base,
          // ~2% of bits differ — well inside the 0.35 threshold.
          '/music/rip.audio': perturb(base, 40),
        },
      );

      final groups = await detector.findDuplicates(
          level: DuplicateDetectionLevel.fingerprint);

      expect(groups, hasLength(1));
      expect(groups.single.type, DuplicateType.audioFingerprint);
      expect(groups.single.confidence, greaterThan(0.65));
    });

    test('unrelated audio stays apart', () async {
      final tracks = [
        track('a', title: 'Nights'),
        track('b', title: 'Solo', durationMs: 259000),
      ];

      final detector = detectorFor(
        tracks,
        fingerprints: {
          '/music/a.audio': base,
          // Half the bits differ, which is where unrelated audio lands.
          '/music/b.audio': base.map((v) => v ^ 0xF0F0F0F0).toList(),
        },
      );

      expect(
        await detector.findDuplicates(
            level: DuplicateDetectionLevel.fingerprint),
        isEmpty,
      );
    });

    test('a file that cannot be fingerprinted is skipped, not fatal', () async {
      final tracks = [
        track('a', title: 'Nights'),
        track('b', title: 'Solo', durationMs: 259000),
      ];

      // No fingerprints at all — the engine is unavailable.
      final detector = detectorFor(tracks);

      expect(
        await detector.findDuplicates(
            level: DuplicateDetectionLevel.fingerprint),
        isEmpty,
      );
    });

    test('the fingerprint layer only runs when asked for', () async {
      final tracks = [
        track('a', title: 'Nights'),
        track('b', title: 'Solo', durationMs: 259000),
      ];
      final detector = detectorFor(
        tracks,
        fingerprints: {
          '/music/a.audio': base,
          '/music/b.audio': perturb(base, 10),
        },
      );

      expect(await detector.findDuplicates(), isEmpty);
      expect(
        await detector.findDuplicates(
            level: DuplicateDetectionLevel.fingerprint),
        hasLength(1),
      );
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('Bit error rate', () {
    test('identical fingerprints score 0, inverted score 1', () {
      expect(fingerprintBitErrorRateDart([1, 2, 3], [1, 2, 3]), 0.0);
      expect(fingerprintBitErrorRateDart([0, 0], [0xFFFFFFFF, 0xFFFFFFFF]), 1.0);
    });

    test('an empty fingerprint is maximally different', () {
      expect(fingerprintBitErrorRateDart([], [1, 2]), 1.0);
      expect(fingerprintBitErrorRateDart([1, 2], []), 1.0);
    });

    test('one flipped bit in 64 values is 1/2048', () {
      final a = List<int>.filled(64, 0);
      final b = List<int>.of(a)..[7] = 1;
      expect(fingerprintBitErrorRateDart(a, b), closeTo(1 / 2048, 1e-12));
    });

    test('a length mismatch compares the overlapping prefix', () {
      expect(fingerprintBitErrorRateDart([0, 0, 0], [0, 0]), 0.0);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('String metrics', () {
    test('Levenshtein distance', () {
      expect(levenshteinDistance('kitten', 'sitting'), 3);
      expect(levenshteinDistance('', 'abc'), 3);
      expect(levenshteinDistance('same', 'same'), 0);
      // Argument order must not matter.
      expect(levenshteinDistance('sitting', 'kitten'), 3);
    });

    test('Levenshtein similarity is normalised to [0, 1]', () {
      expect(levenshteinSimilarity('nights', 'nights'), 1.0);
      expect(levenshteinSimilarity('', ''), 1.0);
      expect(levenshteinSimilarity('abc', 'xyz'), 0.0);
    });

    test('Jaro-Winkler rewards a shared prefix', () {
      // The textbook worked example.
      expect(jaroWinklerSimilarity('MARTHA', 'MARHTA'), closeTo(0.961, 0.001));
      expect(jaroWinklerSimilarity('DWAYNE', 'DUANE'), closeTo(0.840, 0.001));
      expect(jaroWinklerSimilarity('DIXON', 'DICKSONX'), closeTo(0.813, 0.001));
      expect(jaroWinklerSimilarity('abc', 'abc'), 1.0);
      expect(jaroWinklerSimilarity('', ''), 1.0);
      expect(jaroWinklerSimilarity('abc', ''), 0.0);
    });

    test('a shared prefix beats the same edits at the end', () {
      final prefix = jaroWinklerSimilarity('beyonce', 'beyoncz');
      final start = jaroWinklerSimilarity('beyonce', 'zeyonce');
      expect(prefix, greaterThan(start));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('Resolution strategies', () {
    test('keepHighestQuality keeps the lossless copy', () async {
      final repo = FakeMusicRepository([
        track('mp3', format: AudioFormat.mp3, bitRateKbps: 320),
        track('flac', format: AudioFormat.flac, bitRateKbps: 0),
      ]);
      final detector = DuplicateDetector(
        trackRepository: repo,
        audioFingerprinter: stubFingerprinter(const {}),
      );

      await detector.resolveDuplicate(
        // Deliberately nominate the wrong one: the strategy must override it.
        keepTrackId: 'mp3',
        removeTrackIds: ['flac'],
        strategy: DuplicateResolutionStrategy.keepHighestQuality,
      );

      expect(repo.deleted, ['mp3']);
    });

    test('keepHighestQuality prefers the higher bit rate within a tier',
        () async {
      final repo = FakeMusicRepository([
        track('low', format: AudioFormat.mp3, bitRateKbps: 128),
        track('high', format: AudioFormat.mp3, bitRateKbps: 320),
      ]);
      final detector = DuplicateDetector(
        trackRepository: repo,
        audioFingerprinter: stubFingerprinter(const {}),
      );

      await detector.resolveDuplicate(
        keepTrackId: 'low',
        removeTrackIds: ['high'],
        strategy: DuplicateResolutionStrategy.keepHighestQuality,
      );

      expect(repo.deleted, ['low']);
    });

    test('keepMostPlayed keeps the copy the user actually listens to',
        () async {
      final repo = FakeMusicRepository([
        track('flac', format: AudioFormat.flac, bitRateKbps: 0, playCount: 1),
        track('mp3', format: AudioFormat.mp3, bitRateKbps: 192, playCount: 74),
      ]);
      final detector = DuplicateDetector(
        trackRepository: repo,
        audioFingerprinter: stubFingerprinter(const {}),
      );

      await detector.resolveDuplicate(
        keepTrackId: 'flac',
        removeTrackIds: ['mp3'],
        strategy: DuplicateResolutionStrategy.keepMostPlayed,
      );

      expect(repo.deleted, ['flac']);
    });

    test('keepFirst honours the nominated track', () async {
      final repo = FakeMusicRepository([
        track('a', format: AudioFormat.mp3, bitRateKbps: 128),
        track('b', format: AudioFormat.flac, bitRateKbps: 0),
      ]);
      final detector = DuplicateDetector(
        trackRepository: repo,
        audioFingerprinter: stubFingerprinter(const {}),
      );

      await detector.resolveDuplicate(
        keepTrackId: 'a',
        removeTrackIds: ['b'],
        strategy: DuplicateResolutionStrategy.keepFirst,
      );

      expect(repo.deleted, ['b']);
    });

    test('merge folds play counts, ratings and last-played into the keeper',
        () async {
      final repo = FakeMusicRepository([
        track('keep', playCount: 10, skipCount: 1, rating: 0, lastPlayedMs: 500),
        track('drop', playCount: 32, skipCount: 4, rating: 5, lastPlayedMs: 900),
      ]);
      final detector = DuplicateDetector(
        trackRepository: repo,
        audioFingerprinter: stubFingerprinter(const {}),
      );

      await detector.resolveDuplicate(
        keepTrackId: 'keep',
        removeTrackIds: ['drop'],
        strategy: DuplicateResolutionStrategy.merge,
      );

      expect(repo.upserted, hasLength(1));
      final merged = repo.upserted.single;
      expect(merged.id, 'keep');
      expect(merged.playCount, 42);
      expect(merged.skipCount, 5);
      // The explicit rating survives; an unrated keeper must not discard it.
      expect(merged.rating, 5);
      expect(merged.lastPlayedMs, 900);
      expect(repo.deleted, ['drop']);
    });

    test('keepBoth changes nothing at all', () async {
      final repo = FakeMusicRepository([track('a'), track('b')]);
      final detector = DuplicateDetector(
        trackRepository: repo,
        audioFingerprinter: stubFingerprinter(const {}),
      );

      await detector.resolveDuplicate(
        keepTrackId: 'a',
        removeTrackIds: ['b'],
        strategy: DuplicateResolutionStrategy.keepBoth,
      );

      expect(repo.deleted, isEmpty);
      expect(repo.upserted, isEmpty);
    });

    test('removal is a soft delete — history is retained', () async {
      final repo = FakeMusicRepository([
        track('a', playCount: 9),
        track('b', playCount: 3),
      ]);
      final detector = DuplicateDetector(
        trackRepository: repo,
        audioFingerprinter: stubFingerprinter(const {}),
      );

      await detector.resolveDuplicate(
        keepTrackId: 'a',
        removeTrackIds: ['b'],
      );

      final removed = await repo.getTrackById('b');
      expect(removed, isNotNull);
      expect(removed!.isDeleted, isTrue);
      expect(removed.playCount, 3);
    });

    test('a group whose tracks have vanished resolves to a no-op', () async {
      final repo = FakeMusicRepository([track('a')]);
      final detector = DuplicateDetector(
        trackRepository: repo,
        audioFingerprinter: stubFingerprinter(const {}),
      );

      await detector.resolveDuplicate(
        keepTrackId: 'a',
        removeTrackIds: ['gone'],
      );

      expect(repo.deleted, isEmpty);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('Progress reporting', () {
    test('reports monotonic progress and ends at 100%', () async {
      final detector = detectorFor([
        for (var i = 0; i < 200; i++)
          track('t$i', title: 'Song ${i ~/ 2}', durationMs: 180000 + i * 37),
      ]);

      final seen = <DuplicateScanProgress>[];
      await detector.findDuplicates(onProgress: seen.add);

      expect(seen, isNotEmpty);
      expect(seen.first.level, DuplicateDetectionLevel.exact);
      expect(seen.last.fraction, 1.0);
      for (final p in seen) {
        expect(p.fraction, inInclusiveRange(0.0, 1.0));
      }
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('Performance', () {
    test('exact match over 10k tracks completes in under 5 seconds', () async {
      // 10k tracks, where every 10th is an exact duplicate of its predecessor:
      // same title, artist and duration, so it hashes to the same key.
      final tracks = <Track>[];
      for (var i = 0; i < 10000; i++) {
        final key = (i % 10 == 0 && i > 0) ? i - 1 : i;
        tracks.add(track(
          't$i',
          title: 'Song $key',
          artist: 'Artist ${key % 250}',
          durationMs: 120000 + (key % 400) * 1000,
        ));
      }
      final detector = detectorFor(tracks);

      final stopwatch = Stopwatch()..start();
      final groups = await detector.findDuplicates(
          level: DuplicateDetectionLevel.exact);
      stopwatch.stop();

      expect(groups, isNotEmpty);
      expect(stopwatch.elapsedMilliseconds, lessThan(5000),
          reason: 'exact detection must stay linear; took '
              '${stopwatch.elapsedMilliseconds}ms');
    });
  });
}
