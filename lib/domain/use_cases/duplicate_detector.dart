// lib/domain/use_cases/duplicate_detector.dart
// Aura — DuplicateDetector
// Architecture §4.2 / PRD §6.2 / CLAUDE.md §3
//
// ═══════════════════════════════════════════════════════════════════════════════
// THREE-PATH DUPLICATE DETECTION
// ═══════════════════════════════════════════════════════════════════════════════
//
// PATH 1 — EXACT MATCH (O(n), hash-based):
//   Composite key = normalise(title) + '|' + normalise(artist) + '|' + durationBucket
//   where durationBucket = (durationMs / 2000).floor() × 2000  (±1s tolerance)
//   Hash all tracks into a Map<key, List<Track>>; groups with >1 entry are dupes.
//
// PATH 2 — FUZZY MATCH (O(n²) worst case, pruned):
//   For tracks that didn't match exactly, compute Jaro-Winkler similarity on
//   title+artist string. Pairs scoring > kFuzzyDuplicateThreshold are flagged.
//   Pruned by: only compare tracks with similar duration (±5s bucket).
//   Uses the `string_similarity` package (pure Dart, Jaro-Winkler).
//   Practical complexity: O(n × average_bucket_size), much better than O(n²).
//
// PATH 3 — FINGERPRINT MATCH (stubbed, calls C++ in Sprint 2):
//   Chromaprint-based acoustic fingerprinting. Identifies duplicates even with
//   different metadata (e.g., live vs studio with identical title/artist).
//   The [FingerprintUnavailableError] is thrown when called before Sprint 2.
//
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:string_similarity/string_similarity.dart';

import '../entities/track.dart';
import '../../core/constants.dart';
import '../../core/errors.dart';

/// A detected duplicate group.
///
/// Contains the "primary" track (kept) and all "duplicate" tracks (to remove).
/// The UI resolution wizard displays this to the user.
class DuplicateGroup {
  const DuplicateGroup({
    required this.primary,
    required this.duplicates,
    required this.matchType,
    this.similarityScore,
  });

  /// The track to keep (selected heuristically: highest quality / most plays).
  final Track primary;

  /// Tracks to discard (user can override this in the resolution wizard).
  final List<Track> duplicates;

  /// Which detection path found this group.
  final DuplicateMatchType matchType;

  /// Fuzzy similarity score (null for exact matches).
  final double? similarityScore;

  /// All tracks in this group (primary + duplicates).
  List<Track> get allTracks => [primary, ...duplicates];
}

enum DuplicateMatchType { exact, fuzzy, fingerprint }

// ─────────────────────────────────────────────────────────────────────────────

/// Detects duplicate tracks in the music library using three escalating paths.
class DuplicateDetector {
  const DuplicateDetector();

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Runs exact-match detection on [tracks].
  ///
  /// Returns a list of [DuplicateGroup] instances. O(n).
  List<DuplicateGroup> detectExact(List<Track> tracks) {
    final buckets = <String, List<Track>>{};

    for (final track in tracks) {
      final key = _exactKey(track);
      buckets.putIfAbsent(key, () => []).add(track);
    }

    return buckets.values
        .where((group) => group.length > 1)
        .map((group) {
          final sorted = _sortByQuality(group);
          return DuplicateGroup(
            primary: sorted.first,
            duplicates: sorted.skip(1).toList(),
            matchType: DuplicateMatchType.exact,
          );
        })
        .toList();
  }

  /// Runs fuzzy-match detection on [tracks] (title + artist similarity).
  ///
  /// Only compares tracks within the same duration bucket (±2s) to prune
  /// the search space from O(n²) to O(n × avgBucketSize).
  ///
  /// Returns groups with similarity > [kFuzzyDuplicateThreshold].
  List<DuplicateGroup> detectFuzzy(List<Track> tracks) {
    // Group by duration bucket (2-second windows).
    final buckets = <int, List<Track>>{};
    for (final track in tracks) {
      final bucket = (track.durationMs / 2000).floor();
      buckets.putIfAbsent(bucket, () => []).add(track);
    }

    final groups = <DuplicateGroup>[];
    final matched = <String>{};

    for (final bucket in buckets.values) {
      if (bucket.length < 2) continue;

      for (int i = 0; i < bucket.length; i++) {
        if (matched.contains(bucket[i].id)) continue;

        final trackA = bucket[i];
        final keyA = _fuzzyKey(trackA);
        final group = [trackA];

        for (int j = i + 1; j < bucket.length; j++) {
          if (matched.contains(bucket[j].id)) continue;

          final trackB = bucket[j];
          final similarity = keyA.similarityTo(_fuzzyKey(trackB));

          if (similarity >= kFuzzyDuplicateThreshold) {
            group.add(trackB);
            matched.add(trackB.id);
          }
        }

        if (group.length > 1) {
          matched.add(trackA.id);
          final sorted = _sortByQuality(group);
          groups.add(DuplicateGroup(
            primary: sorted.first,
            duplicates: sorted.skip(1).toList(),
            matchType: DuplicateMatchType.fuzzy,
            similarityScore: keyA.similarityTo(_fuzzyKey(sorted[1])),
          ));
        }
      }
    }

    return groups;
  }

  /// Runs acoustic fingerprint matching via the C++ Chromaprint engine.
  ///
  /// **STUB — Sprint 2:** This method will call `AudioEngine.fingerprint()`
  /// via FFI. Currently throws [FingerprintUnavailableError].
  ///
  /// When implemented, it will:
  ///   1. Load each track's stored fingerprint hash from the audio_features table.
  ///   2. Compare hashes using Hamming distance (threshold: ≤10 bit flips).
  ///   3. For unfingerprinted tracks, trigger the C++ analyser to compute.
  Future<List<DuplicateGroup>> detectByFingerprint(
      List<Track> tracks) async {
    throw const FingerprintUnavailableError();
  }

  /// Runs all available detection paths in order (exact → fuzzy → fingerprint).
  ///
  /// Deduplicates across paths so a track appears in at most one group.
  /// Fingerprinting is skipped silently if unavailable (Sprint 1).
  Future<List<DuplicateGroup>> detectAll(List<Track> tracks) async {
    final allGroups = <DuplicateGroup>[];
    final handledIds = <String>{};

    // Path 1: Exact.
    for (final group in detectExact(tracks)) {
      allGroups.add(group);
      for (final t in group.allTracks) {
        handledIds.add(t.id);
      }
    }

    // Path 2: Fuzzy (only on unmatched tracks).
    final unmatched = tracks.where((t) => !handledIds.contains(t.id)).toList();
    for (final group in detectFuzzy(unmatched)) {
      allGroups.add(group);
      for (final t in group.allTracks) {
        handledIds.add(t.id);
      }
    }

    // Path 3: Fingerprint — silently skipped in Sprint 1.
    // Will be enabled in Sprint 2 when FFI is fully wired.

    return allGroups;
  }

  // ── Private Helpers ────────────────────────────────────────────────────────

  /// Composite key for exact matching.
  /// Duration bucket of 2000ms gives ±1s tolerance for re-encoded files.
  String _exactKey(Track track) {
    final title = _normalise(track.title);
    final artist = _normalise(track.artistName);
    final durBucket = (track.durationMs / 2000).floor();
    return '$title|$artist|$durBucket';
  }

  /// Combined title+artist string for fuzzy comparison.
  String _fuzzyKey(Track track) =>
      '${_normalise(track.title)} ${_normalise(track.artistName)}';

  /// Lowercase, trim, collapse whitespace, strip common punctuation.
  String _normalise(String s) => s
      .toLowerCase()
      .trim()
      .replaceAll('\'', '')
      .replaceAll(RegExp(r'[\-–—.,!?&]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ');

  /// Selects the "primary" track from a group — highest quality heuristic:
  ///   1. Highest bit rate (lossless > lossy).
  ///   2. Tiebreak: highest play count (user's preferred copy).
  ///   3. Tiebreak: larger file size.
  List<Track> _sortByQuality(List<Track> group) {
    final sorted = List<Track>.from(group);
    sorted.sort((a, b) {
      // Higher bit rate wins; FLAC/WAV typically have bitRateKbps=0 → handle
      // by treating 0 as lossless (very high).
      final aBr = a.bitRateKbps == 0 ? 999999 : a.bitRateKbps;
      final bBr = b.bitRateKbps == 0 ? 999999 : b.bitRateKbps;
      if (aBr != bBr) return bBr.compareTo(aBr);
      if (a.playCount != b.playCount) return b.playCount.compareTo(a.playCount);
      return b.fileSizeBytes.compareTo(a.fileSizeBytes);
    });
    return sorted;
  }
}
