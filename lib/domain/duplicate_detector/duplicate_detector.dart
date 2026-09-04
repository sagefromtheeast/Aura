// lib/domain/duplicate_detector/duplicate_detector.dart
// Aura — Three-layer duplicate detector.
// Architecture §4.2 / PRD §6.2.
//
// ═══════════════════════════════════════════════════════════════════════════
// WHY THREE LAYERS
// ═══════════════════════════════════════════════════════════════════════════
//
// Each layer is strictly more expensive and strictly more tolerant than the
// one before it, so every track is handed to the cheapest layer that can
// recognise it and layers 2 and 3 only ever see what earlier layers missed.
//
//   1. EXACT       O(n) hash bucketing. Catches the common case — the same
//                  file imported twice, or a re-rip with identical tags.
//   2. FUZZY       Pairwise string metrics, pruned by duration bucket. Catches
//                  "Redbone" vs "Redbone (Album Version)".
//   3. FINGERPRINT Chromaprint via FFI, compared by bit error rate. Catches
//                  the same recording under different metadata or codec —
//                  the only layer that actually listens to the audio.
//
// ═══════════════════════════════════════════════════════════════════════════
// A NOTE ON IDs
// ═══════════════════════════════════════════════════════════════════════════
//
// The spec types these as `int`. Aura assigns tracks UUID v4 *strings* at scan
// time ([Track.id]), and every repository, table and provider in the codebase
// is built on that, so the API here uses `String` ids. Nothing else about the
// contract changes.

import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../core/constants.dart';
import '../entities/track.dart';
import '../repositories/music_repository.dart';
import 'fingerprint_math.dart';
import 'string_metrics.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────────────────────

/// How deep a scan should go. Each level implies the ones before it.
enum DuplicateDetectionLevel {
  /// Layer 1 only — hash-based, effectively instant even on huge libraries.
  exact,

  /// Layers 1 and 2 — adds fuzzy metadata matching. The default.
  fuzzy,

  /// All three layers — adds acoustic fingerprinting, which must decode every
  /// remaining file and is therefore minutes, not seconds.
  fingerprint,
}

/// Which layer found a group.
enum DuplicateType { exact, fuzzyMetadata, audioFingerprint }

/// Strategies for resolving a group, per the spec.
enum DuplicateResolutionStrategy {
  /// Keep the nominated track, soft-delete the rest.
  keepFirst,

  /// Keep whichever copy has the best bit rate / sample rate.
  keepHighestQuality,

  /// Keep whichever copy the user has played most.
  keepMostPlayed,

  /// Keep one copy, but fold the others' play counts and ratings into it first.
  merge,

  /// Change nothing — the user has looked and decided they are not duplicates.
  keepBoth,
}

/// A set of tracks believed to be the same recording.
class DuplicateGroup {
  DuplicateGroup({
    required this.tracks,
    required this.type,
    required this.confidence,
  }) : assert(tracks.length > 1, 'a duplicate group needs at least two tracks');

  /// Every track in the group, best-quality copy first (see [_rankByQuality]).
  final List<Track> tracks;

  /// Which layer found this group.
  final DuplicateType type;

  /// How sure we are, in [0, 1]. Exact matches are 1.0; fuzzy matches carry
  /// their combined score; fingerprint matches carry `1 - bitErrorRate`.
  final double confidence;

  /// The copy Aura suggests keeping. The user can override this.
  Track get suggested => tracks.first;

  /// The copies Aura suggests removing.
  List<Track> get others => tracks.sublist(1);

  /// Bytes reclaimable by removing every copy but [suggested].
  int get reclaimableBytes =>
      others.fold(0, (sum, t) => sum + t.fileSizeBytes);
}

/// Progress emitted while a scan runs.
class DuplicateScanProgress {
  const DuplicateScanProgress({
    required this.level,
    required this.comparisonsDone,
    required this.comparisonsTotal,
    required this.groupsFound,
  });

  /// The layer currently running.
  final DuplicateDetectionLevel level;

  /// Pairs (or tracks, for the exact layer) checked so far.
  final int comparisonsDone;

  /// Best estimate of the total for this layer. Zero when nothing to do.
  final int comparisonsTotal;

  /// Groups found across all layers so far.
  final int groupsFound;

  double get fraction => comparisonsTotal == 0
      ? 1.0
      : (comparisonsDone / comparisonsTotal).clamp(0.0, 1.0);
}

/// Computes a fingerprint for a file. Injected so tests can supply stub
/// fingerprints without a native library or real audio.
typedef AudioFingerprinter = Future<List<int>?> Function(String filePath);

/// Compares two fingerprints, returning a bit error rate in [0, 1].
typedef FingerprintComparator = double Function(List<int> a, List<int> b);

// ─────────────────────────────────────────────────────────────────────────────
// Detector
// ─────────────────────────────────────────────────────────────────────────────

/// The pure detection half: everything that can run without touching the
/// database, and therefore everything that can run inside a background isolate.
///
/// Drift connections are not portable across isolates, so the provider loads
/// tracks on the main isolate and hands this class the resulting list.
class DuplicateScanner {
  DuplicateScanner({
    required this.audioFingerprinter,
    FingerprintComparator? compareFingerprints,
  }) : compareFingerprints =
            compareFingerprints ?? fingerprintBitErrorRateDefault;

  final AudioFingerprinter audioFingerprinter;
  final FingerprintComparator compareFingerprints;

  /// Words that describe a *release* rather than a *recording*, and so must not
  /// keep two copies of the same song apart.
  static final RegExp _noiseWords = RegExp(
    r'\b(remaster(ed)?|remastered version|deluxe( edition)?|explicit|clean|'
    r'bonus track|album version|single version|radio edit|original mix|'
    r'\d{4} (digital )?remaster)\b',
  );

  static final RegExp _punctuation = RegExp(r"[^\w\s]", unicode: true);
  static final RegExp _whitespace = RegExp(r'\s+');

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Runs the requested layers over [tracks].
  ///
  /// [level] selects how many layers run; [fuzzyThreshold] overrides the
  /// combined-score cut-off for layer 2. [onProgress] is called as work
  /// proceeds — the provider forwards it to the UI.
  Future<List<DuplicateGroup>> scan(
    List<Track> tracks, {
    DuplicateDetectionLevel level = DuplicateDetectionLevel.fuzzy,
    double fuzzyThreshold = kFuzzyDuplicateThreshold,
    void Function(DuplicateScanProgress)? onProgress,
  }) async {
    final groups = <DuplicateGroup>[];
    final claimed = <String>{};

    // ── Layer 1: exact ──
    for (final group in _detectExact(tracks, onProgress: (done, total) {
      onProgress?.call(DuplicateScanProgress(
        level: DuplicateDetectionLevel.exact,
        comparisonsDone: done,
        comparisonsTotal: total,
        groupsFound: groups.length,
      ));
    })) {
      groups.add(group);
      claimed.addAll(group.tracks.map((t) => t.id));
    }

    if (level == DuplicateDetectionLevel.exact) return groups;

    // ── Layer 2: fuzzy metadata ──
    var remaining =
        tracks.where((t) => !claimed.contains(t.id)).toList(growable: false);

    for (final group in _detectFuzzy(
      remaining,
      threshold: fuzzyThreshold,
      onProgress: (done, total) {
        onProgress?.call(DuplicateScanProgress(
          level: DuplicateDetectionLevel.fuzzy,
          comparisonsDone: done,
          comparisonsTotal: total,
          groupsFound: groups.length,
        ));
      },
    )) {
      groups.add(group);
      claimed.addAll(group.tracks.map((t) => t.id));
    }

    if (level == DuplicateDetectionLevel.fuzzy) return groups;

    // ── Layer 3: acoustic fingerprint ──
    remaining =
        tracks.where((t) => !claimed.contains(t.id)).toList(growable: false);

    final fingerprintGroups = await _detectByFingerprint(
      remaining,
      onProgress: (done, total) {
        onProgress?.call(DuplicateScanProgress(
          level: DuplicateDetectionLevel.fingerprint,
          comparisonsDone: done,
          comparisonsTotal: total,
          groupsFound: groups.length,
        ));
      },
    );
    groups.addAll(fingerprintGroups);

    return groups;
  }

  // ── Layer 1: exact ─────────────────────────────────────────────────────────

  /// SHA-256 of `normalisedTitle | normalisedArtist | durationBucket`.
  ///
  /// Hashing is not for security here — it collapses a long composite key into
  /// a fixed-size one, which keeps the hash map's memory flat on large
  /// libraries regardless of how long the titles are.
  String exactKey(Track track) {
    final title = normaliseTitle(track.title);
    final artist = normaliseArtist(track.artistName);
    final bucket = durationBucket(track.durationMs);
    final composite = '$title|$artist|$bucket';
    return sha256.convert(utf8.encode(composite)).toString();
  }

  /// Duration rounded to the nearest 2 seconds, so a one-second difference in
  /// how two rippers trimmed the tail does not split a pair.
  int durationBucket(int durationMs) => ((durationMs / 2000).round()) * 2000;

  List<DuplicateGroup> _detectExact(
    List<Track> tracks, {
    void Function(int done, int total)? onProgress,
  }) {
    final buckets = <String, List<Track>>{};

    for (var i = 0; i < tracks.length; i++) {
      buckets.putIfAbsent(exactKey(tracks[i]), () => <Track>[]).add(tracks[i]);
      // Reporting every track would swamp the UI thread with rebuilds.
      if (onProgress != null && (i % 512 == 0 || i == tracks.length - 1)) {
        onProgress(i + 1, tracks.length);
      }
    }

    return [
      for (final bucket in buckets.values)
        if (bucket.length > 1)
          DuplicateGroup(
            tracks: _rankByQuality(bucket),
            type: DuplicateType.exact,
            confidence: 1.0,
          ),
    ];
  }

  // ── Layer 2: fuzzy metadata ────────────────────────────────────────────────

  /// Combined fuzzy score for a pair, per the spec's weighting.
  ///
  /// Returns 0.0 when either the title or artist similarity falls below its own
  /// gate, or the durations are further apart than the tolerance — a high
  /// artist score must not drag a mismatched title over the line.
  double fuzzyScore(Track a, Track b) {
    final durationDelta = (a.durationMs - b.durationMs).abs();
    if (durationDelta > kFuzzyDurationToleranceMs) return 0.0;

    final titleSim = levenshteinSimilarity(
        normaliseTitle(a.title), normaliseTitle(b.title));
    if (titleSim < kFuzzyTitleThreshold) return 0.0;

    final artistSim = jaroWinklerSimilarity(
        normaliseArtist(a.artistName), normaliseArtist(b.artistName));
    if (artistSim < kFuzzyArtistThreshold) return 0.0;

    // 1.0 at identical length, falling linearly to 0.0 at the tolerance edge.
    final durationMatch = 1.0 - (durationDelta / kFuzzyDurationToleranceMs);

    return titleSim * 0.5 + artistSim * 0.3 + durationMatch * 0.2;
  }

  List<DuplicateGroup> _detectFuzzy(
    List<Track> tracks, {
    required double threshold,
    void Function(int done, int total)? onProgress,
  }) {
    // Bucket by duration so we never compare a 3-minute pop song against a
    // 20-minute live jam. A track is placed in its own bucket and compared
    // against the next one as well, so a pair straddling a boundary still
    // meets — without that, 119.9s and 120.1s would never be compared.
    final buckets = <int, List<Track>>{};
    for (final track in tracks) {
      final bucket = track.durationMs ~/ kFuzzyDurationToleranceMs;
      buckets.putIfAbsent(bucket, () => <Track>[]).add(track);
    }

    final groups = <DuplicateGroup>[];
    final claimed = <String>{};

    // Estimate the work up front so the progress bar does not jump.
    var total = 0;
    for (final entry in buckets.entries) {
      final here = entry.value.length;
      final next = buckets[entry.key + 1]?.length ?? 0;
      total += here * (here - 1) ~/ 2 + here * next;
    }

    var done = 0;
    final sortedKeys = buckets.keys.toList()..sort();

    for (final key in sortedKeys) {
      final candidates = <Track>[
        ...buckets[key]!,
        ...?buckets[key + 1],
      ];
      // Only tracks from this bucket seed a group; the spill-over from the next
      // bucket is there to be matched against, and will seed its own groups on
      // the following iteration.
      final seedCount = buckets[key]!.length;

      for (var i = 0; i < seedCount; i++) {
        final seed = candidates[i];
        if (claimed.contains(seed.id)) continue;

        final matches = <Track>[seed];
        var bestScore = 0.0;

        for (var j = i + 1; j < candidates.length; j++) {
          final other = candidates[j];
          done++;
          if (claimed.contains(other.id)) continue;
          if (other.id == seed.id) continue;

          final score = fuzzyScore(seed, other);
          if (score >= threshold) {
            matches.add(other);
            claimed.add(other.id);
            if (score > bestScore) bestScore = score;
          }
        }

        if (matches.length > 1) {
          claimed.add(seed.id);
          groups.add(DuplicateGroup(
            tracks: _rankByQuality(matches),
            type: DuplicateType.fuzzyMetadata,
            confidence: bestScore,
          ));
        }
      }

      onProgress?.call(done, total);
    }

    onProgress?.call(total, total);
    return groups;
  }

  // ── Layer 3: acoustic fingerprint ──────────────────────────────────────────

  Future<List<DuplicateGroup>> _detectByFingerprint(
    List<Track> tracks, {
    void Function(int done, int total)? onProgress,
  }) async {
    if (tracks.length < 2) {
      onProgress?.call(0, 0);
      return const [];
    }

    // Decoding is the expensive part, so each file is fingerprinted exactly
    // once and the comparison then runs over the cached values.
    final fingerprints = <String, List<int>>{};
    for (var i = 0; i < tracks.length; i++) {
      final track = tracks[i];
      final fp = await audioFingerprinter(track.filePath);
      if (fp != null && fp.isNotEmpty) fingerprints[track.id] = fp;
      onProgress?.call(i + 1, tracks.length);
    }

    final printable =
        tracks.where((t) => fingerprints.containsKey(t.id)).toList();

    final groups = <DuplicateGroup>[];
    final claimed = <String>{};

    for (var i = 0; i < printable.length; i++) {
      final seed = printable[i];
      if (claimed.contains(seed.id)) continue;

      final matches = <Track>[seed];
      var bestBer = 1.0;

      for (var j = i + 1; j < printable.length; j++) {
        final other = printable[j];
        if (claimed.contains(other.id)) continue;

        final ber = compareFingerprints(
            fingerprints[seed.id]!, fingerprints[other.id]!);
        if (ber < kFingerprintBerThreshold) {
          matches.add(other);
          claimed.add(other.id);
          if (ber < bestBer) bestBer = ber;
        }
      }

      if (matches.length > 1) {
        claimed.add(seed.id);
        groups.add(DuplicateGroup(
          tracks: _rankByQuality(matches),
          type: DuplicateType.audioFingerprint,
          confidence: 1.0 - bestBer,
        ));
      }
    }

    return groups;
  }

  // ── Normalisation ──────────────────────────────────────────────────────────

  /// Lower-cases, strips release-noise words and punctuation, collapses space.
  ///
  /// Order matters: noise words are removed *before* punctuation, because they
  /// usually arrive wrapped in brackets — "Song (2011 Remaster)" only reads as
  /// a word boundary while the brackets are still there.
  String normaliseTitle(String title) {
    var s = title.toLowerCase().trim();
    s = s.replaceAll(_noiseWords, ' ');
    s = s.replaceAll(_punctuation, ' ');
    return s.replaceAll(_whitespace, ' ').trim();
  }

  /// Same treatment for artists, minus the release-noise pass — "The Remains"
  /// is a band, not a remaster.
  String normaliseArtist(String artist) {
    final s = artist.toLowerCase().trim().replaceAll(_punctuation, ' ');
    return s.replaceAll(_whitespace, ' ').trim();
  }

  // ── Ranking ────────────────────────────────────────────────────────────────

  /// Orders a group best-copy-first: quality, then the user's listening, then
  /// file size as a last resort.
  static List<Track> _rankByQuality(List<Track> group) {
    final sorted = List<Track>.of(group);
    sorted.sort((a, b) {
      final aq = qualityScore(a);
      final bq = qualityScore(b);
      if (aq != bq) return bq.compareTo(aq);
      if (a.playCount != b.playCount) return b.playCount.compareTo(a.playCount);
      if (a.fileSizeBytes != b.fileSizeBytes) {
        return b.fileSizeBytes.compareTo(a.fileSizeBytes);
      }
      // Total order, so a scan is reproducible run to run.
      return a.id.compareTo(b.id);
    });
    return sorted;
  }

  static List<Track> _rankByPlays(List<Track> group) {
    final sorted = List<Track>.of(group);
    sorted.sort((a, b) {
      if (a.playCount != b.playCount) return b.playCount.compareTo(a.playCount);
      final aq = qualityScore(a);
      final bq = qualityScore(b);
      if (aq != bq) return bq.compareTo(aq);
      return a.id.compareTo(b.id);
    });
    return sorted;
  }

  /// A single comparable number for "how good is this copy".
  ///
  /// Lossless formats win outright, because a FLAC's reported bit rate varies
  /// with the material and would otherwise lose to a 320 kbps MP3 on quiet
  /// tracks. Within a tier, higher bit rate then higher sample rate wins.
  static int qualityScore(Track track) {
    const lossless = {AudioFormat.flac, AudioFormat.alac, AudioFormat.wav,
        AudioFormat.dsd};
    final tier = lossless.contains(track.format) ? 1 : 0;
    // Bit rate is capped so an implausible tag cannot outrank a whole tier.
    final bitRate = track.bitRateKbps.clamp(0, 9999);
    return tier * 100000000 + bitRate * 1000 + (track.sampleRateHz ~/ 100);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// The repository-backed detector: the API the spec describes, and what the
/// rest of the app talks to.
class DuplicateDetector {
  DuplicateDetector({
    required this.trackRepository,
    required AudioFingerprinter audioFingerprinter,
    FingerprintComparator? compareFingerprints,
  }) : scanner = DuplicateScanner(
          audioFingerprinter: audioFingerprinter,
          compareFingerprints: compareFingerprints,
        );

  final MusicRepository trackRepository;

  /// The isolate-portable detection half.
  final DuplicateScanner scanner;

  AudioFingerprinter get audioFingerprinter => scanner.audioFingerprinter;

  /// Scans the whole library for duplicates.
  Future<List<DuplicateGroup>> findDuplicates({
    DuplicateDetectionLevel level = DuplicateDetectionLevel.fuzzy,
    double fuzzyThreshold = kFuzzyDuplicateThreshold,
    void Function(DuplicateScanProgress)? onProgress,
  }) async {
    final tracks = (await trackRepository.getAllTracks())
        .where((t) => !t.isDeleted)
        .toList(growable: false);

    return findDuplicatesIn(
      tracks,
      level: level,
      fuzzyThreshold: fuzzyThreshold,
      onProgress: onProgress,
    );
  }

  /// The same scan over an explicit track list.
  Future<List<DuplicateGroup>> findDuplicatesIn(
    List<Track> tracks, {
    DuplicateDetectionLevel level = DuplicateDetectionLevel.fuzzy,
    double fuzzyThreshold = kFuzzyDuplicateThreshold,
    void Function(DuplicateScanProgress)? onProgress,
  }) =>
      scanner.scan(
        tracks,
        level: level,
        fuzzyThreshold: fuzzyThreshold,
        onProgress: onProgress,
      );

  /// Applies [strategy] to a resolved group.
  ///
  /// Removal is a *soft* delete: [MusicRepository.deleteTrack] sets
  /// `isDeleted = true`, which hides the copy from the library while keeping
  /// its listening history intact. Nothing is unlinked from disk, so a mistake
  /// here is always recoverable.
  Future<void> resolveDuplicate({
    required String keepTrackId,
    required List<String> removeTrackIds,
    DuplicateResolutionStrategy strategy =
        DuplicateResolutionStrategy.keepFirst,
  }) async {
    if (strategy == DuplicateResolutionStrategy.keepBoth) {
      // Reviewed and dismissed: the caller records that, nothing to delete.
      return;
    }

    final ids = <String>{keepTrackId, ...removeTrackIds};
    final loaded = <Track>[];
    for (final id in ids) {
      final track = await trackRepository.getTrackById(id);
      if (track != null) loaded.add(track);
    }
    if (loaded.length < 2) return;

    // Every strategy but keepFirst re-picks the survivor from the group.
    final keeper = switch (strategy) {
      DuplicateResolutionStrategy.keepFirst =>
        loaded.firstWhere((t) => t.id == keepTrackId,
            orElse: () => loaded.first),
      DuplicateResolutionStrategy.keepHighestQuality =>
        DuplicateScanner._rankByQuality(loaded).first,
      DuplicateResolutionStrategy.keepMostPlayed => DuplicateScanner._rankByPlays(loaded).first,
      DuplicateResolutionStrategy.merge => loaded.firstWhere(
          (t) => t.id == keepTrackId,
          orElse: () => DuplicateScanner._rankByQuality(loaded).first),
      DuplicateResolutionStrategy.keepBoth => loaded.first,
    };

    final doomed = loaded.where((t) => t.id != keeper.id).toList();

    if (strategy == DuplicateResolutionStrategy.merge) {
      // Fold the discarded copies' history into the survivor so the user does
      // not lose play counts by tidying up.
      var playCount = keeper.playCount;
      var skipCount = keeper.skipCount;
      var rating = keeper.rating;
      var lastPlayedMs = keeper.lastPlayedMs;

      for (final t in doomed) {
        playCount += t.playCount;
        skipCount += t.skipCount;
        // An explicit rating beats an unrated copy; between two ratings, keep
        // the higher one rather than silently downgrading the user's opinion.
        if (t.rating > rating) rating = t.rating;
        if (t.lastPlayedMs != null &&
            (lastPlayedMs == null || t.lastPlayedMs! > lastPlayedMs)) {
          lastPlayedMs = t.lastPlayedMs;
        }
      }

      await trackRepository.upsertTracks([
        keeper.copyWith(
          playCount: playCount,
          skipCount: skipCount,
          rating: rating,
          lastPlayedMs: lastPlayedMs,
        ),
      ]);
    }

    for (final t in doomed) {
      await trackRepository.deleteTrack(t.id);
    }
  }
}

/// Default comparator: bit error rate, computed natively when the engine is
/// loaded and in Dart otherwise.
double fingerprintBitErrorRateDefault(List<int> a, List<int> b) =>
    fingerprintBitErrorRateDart(a, b);
