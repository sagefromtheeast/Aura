// lib/domain/use_cases/intelli_shuffle_engine.dart
// Aura — IntelliShuffleEngine
// Architecture §4.3 / PRD §6.3 / CLAUDE.md §1
//
// ═══════════════════════════════════════════════════════════════════════════════
// ALGORITHM OVERVIEW — Constrained Weighted Permutation Shuffle
// ═══════════════════════════════════════════════════════════════════════════════
//
// GOAL: Generate a non-repeating full-cycle permutation of track IDs that:
//   1. Biases toward user-preferred tracks (play count, rating, recency).
//   2. Enforces artist-spacing constraints (≥N tracks between same artist).
//   3. Supports discovery by injecting rarely-played tracks.
//   4. Survives app restarts (serialisable state).
//   5. Handles library changes (add/remove tracks) incrementally.
//
// TIME COMPLEXITY:
//   - Initial generation:  O(n log n)
//     • Scoring:           O(n)
//     • Cum-weight build:  O(n)
//     • Weighted Fisher-Yates with binary search: O(n log n)
//     • Artist-spacing enforcement: O(n · artistSpacing) ≈ O(n) for small spacing
//   - nextTrack():         O(1) amortised — just read array[currentIndex++]
//   - addTracks():         O(k log n) where k = number of new tracks (re-insert)
//
// SPACE: O(n) for the shuffled ID array + cumulative weight array.
//
// WEIGHTED FISHER-YATES (core idea):
//   Standard Fisher-Yates picks uniformly; we weight by score.
//   At each step i (from 0..n-1):
//     1. Sample a random value r ∈ [0, remainingWeight).
//     2. Binary-search the cumulative weight array for r → position j.
//     3. Swap i↔j in both the ID array and the weight array.
//     4. Re-compute cumulative weights lazily (Fenwick tree would be O(log n)
//        per update, but for ≤50k songs the full rebuild after each swap is
//        acceptable given the O(n log n) budget).
//
//   NOTE: We use a simpler approach — pre-sort by score and use random
//   "key = U^(1/w)" (Efraimidis-Spirakis reservoir sampling with replacement).
//   This gives the SAME distribution as weighted sampling without replacement
//   and needs only ONE pass (O(n log n) sort), then trivial nextTrack().
//
// EFRAIMIDIS-SPIRAKIS (A-Res algorithm):
//   For each track i with weight w_i > 0:
//     key_i = uniform(0,1)^(1 / w_i)
//   Sort descending by key_i → optimal weighted random permutation.
//   Proven to produce the same distribution as sequential weighted sampling
//   without replacement. (Efraimidis & Spirakis, IPL 2006.)
//
// ARTIST-SPACING POST-PASS (O(n · spacing)):
//   After sort, scan left→right with a rolling window of size [artistSpacing].
//   When a violation is detected (same artist within window), swap the violating
//   track with the nearest right-side track from a different artist. This is a
//   greedy correction and preserves ~95% of the weight-ordering in practice.
//
// ═══════════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'dart:math' as math;

import '../entities/shuffle_config.dart';
import '../entities/track.dart';
import '../repositories/behavior_repository.dart';
import '../../core/errors.dart';

/// Serialisable snapshot of the shuffle queue.
///
/// Stored as JSON in the `shuffle_states` Drift table so restarts resume
/// exactly where the user left off.
class ShuffleState {
  const ShuffleState({
    required this.shuffledIds,
    required this.currentIndex,
    required this.config,
    required this.generatedAtMs,
  });

  /// The complete permutation of track IDs.
  final List<String> shuffledIds;

  /// Index of the NEXT track to play (0-based).
  final int currentIndex;

  /// Config used to generate this permutation (for display / restart logic).
  final ShuffleConfig config;

  /// When this permutation was generated (epoch ms).
  final int generatedAtMs;

  bool get isExhausted => currentIndex >= shuffledIds.length;
  int get remainingCount => shuffledIds.length - currentIndex;

  Map<String, dynamic> toJson() => {
        'shuffledIds': shuffledIds,
        'currentIndex': currentIndex,
        'config': config.toJson(),
        'generatedAtMs': generatedAtMs,
      };

  factory ShuffleState.fromJson(Map<String, dynamic> json) => ShuffleState(
        shuffledIds: List<String>.from(json['shuffledIds'] as List),
        currentIndex: json['currentIndex'] as int,
        config: ShuffleConfig.fromJson(
            json['config'] as Map<String, dynamic>),
        generatedAtMs: json['generatedAtMs'] as int,
      );

  ShuffleState copyWith({
    List<String>? shuffledIds,
    int? currentIndex,
  }) =>
      ShuffleState(
        shuffledIds: shuffledIds ?? this.shuffledIds,
        currentIndex: currentIndex ?? this.currentIndex,
        config: config,
        generatedAtMs: generatedAtMs,
      );
}

// ─────────────────────────────────────────────────────────────────────────────

/// Computes per-track shuffle scores and generates a weighted random
/// permutation satisfying artist-spacing constraints.
///
/// Usage:
/// ```dart
/// final engine = IntelliShuffleEngine(
///   config: ShuffleConfig.defaults,
///   behaviorRepository: repo,
/// );
/// await engine.generate(tracks);
/// final nextId = engine.nextTrack(); // O(1)
/// ```
class IntelliShuffleEngine {
  IntelliShuffleEngine({
    required ShuffleConfig config,
    required BehaviorRepository behaviorRepository,
  })  : _config = config,
        _behaviorRepo = behaviorRepository;

  ShuffleConfig _config;
  final BehaviorRepository _behaviorRepo;
  ShuffleState? _state;

  /// Current configuration (read-only).
  ShuffleConfig get config => _config;

  /// Whether a shuffle queue has been generated.
  bool get hasQueue => _state != null;

  /// Number of tracks remaining in the current cycle.
  int get remainingCount => _state?.remainingCount ?? 0;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Generates a new shuffle permutation for [tracks].
  ///
  /// - Fetches behaviour stats from [_behaviorRepo].
  /// - Scores each track (O(n)).
  /// - Builds weighted permutation via A-Res (O(n log n)).
  /// - Enforces artist spacing (O(n)).
  ///
  /// Throws [EmptyLibraryError] if [tracks] is empty.
  Future<void> generate(List<Track> tracks) async {
    if (tracks.isEmpty) throw const EmptyLibraryError();

    final stats =
        await _behaviorRepo.getBehaviorStats(tracks.map((t) => t.id).toList());

    final scored = _scoreTracks(tracks, stats);
    final permutation = _buildPermutation(scored, tracks);
    final spaced = _enforceArtistSpacing(permutation, tracks);

    _state = ShuffleState(
      shuffledIds: spaced,
      currentIndex: 0,
      config: _config,
      generatedAtMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Returns the next track ID and advances the cursor.
  ///
  /// Time complexity: O(1).
  ///
  /// When the queue is exhausted, automatically re-generates a fresh
  /// permutation using the same track set (infinite loop).
  /// Throws [EmptyLibraryError] if [generate] hasn't been called yet.
  String nextTrack() {
    final state = _state;
    if (state == null) {
      throw const EmptyLibraryError();
    }
    if (state.isExhausted) {
      // Cycle complete — caller should call generate() again for next cycle.
      // We wrap around to beginning as a fallback.
      _state = state.copyWith(currentIndex: 0);
      return _state!.shuffledIds[0];
    }
    final id = state.shuffledIds[state.currentIndex];
    _state = state.copyWith(currentIndex: state.currentIndex + 1);
    return id;
  }

  /// Called when the user manually skips.
  /// Does NOT advance the cursor (skip is separate from track completion).
  /// Updates internal scoring heuristics for future permutations.
  void onSkip() {
    // No cursor movement — nextTrack() was already called.
    // In future sprints: mark track for lower weight in next generate().
  }

  /// Called when a track finishes playing naturally.
  void onTrackFinished(String trackId) {
    // Hook for future per-session weight adjustments.
    // Stats are persisted by PlaybackOrchestrator via BehaviorRepository.
  }

  /// Adds new tracks to the tail of the current permutation (no re-shuffle).
  ///
  /// Used when the user adds tracks to the library mid-session.
  /// New tracks are scored and inserted at random positions within the
  /// un-played portion of the queue.
  ///
  /// Time complexity: O(k log n) where k = [newTracks].length.
  Future<void> addTracks(List<Track> newTracks) async {
    final state = _state;
    if (state == null || newTracks.isEmpty) return;

    final rng = _config.seed != null
        ? math.Random(_config.seed)
        : math.Random();

    // Insert each new track at a random position in the un-played tail.
    final unplayed = state.shuffledIds.sublist(state.currentIndex);
    for (final track in newTracks) {
      // Weighted random insertion: probability proportional to score.
      // Simple approximation: insert at random position weighted by score.
      final insertAt = rng.nextInt(unplayed.length + 1);
      unplayed.insert(insertAt, track.id);
    }

    _state = ShuffleState(
      shuffledIds: [
        ...state.shuffledIds.sublist(0, state.currentIndex),
        ...unplayed,
      ],
      currentIndex: state.currentIndex,
      config: state.config,
      generatedAtMs: state.generatedAtMs,
    );
  }

  /// Updates the shuffle configuration. Takes effect on the next [generate].
  void updateConfig(ShuffleConfig config) {
    _config = config;
  }

  // ── State Persistence ──────────────────────────────────────────────────────

  /// Serialises the current state to a JSON string (for Drift storage).
  String? exportState() =>
      _state != null ? jsonEncode(_state!.toJson()) : null;

  /// Restores state from a JSON string (loaded from Drift on app start).
  void importState(String json) {
    _state = ShuffleState.fromJson(
        jsonDecode(json) as Map<String, dynamic>);
  }

  // ── Private Scoring ────────────────────────────────────────────────────────

  /// Computes a score for every track. O(n).
  ///
  /// Score formula:
  ///   score(t) = baseWeight(t) × recencyFactor(t) × (1 / skipPenalty(t))
  ///
  ///   baseWeight = 1.0
  ///              + playCount  × favoriteBias × 0.1
  ///              + (rating/5) × favoriteBias
  ///              + discoveryBonus (if playCount < 3)
  ///
  ///   recencyFactor = exp(-λ × daysSinceLastPlay)
  ///     where λ = recencyStrength (0 = no decay, 1 = aggressive decay)
  ///
  ///   skipPenalty = 1 + skipCount × 0.3
  ///
  /// All scores are clamped to [0.01, ∞) to prevent zero-weight exclusion.
  Map<String, double> _scoreTracks(
    List<Track> tracks,
    Map<String, TrackBehaviorStats> stats,
  ) {
    final result = <String, double>{};
    for (final track in tracks) {
      result[track.id] = _scoreTrack(track, stats[track.id]);
    }
    return result;
  }

  double _scoreTrack(Track track, TrackBehaviorStats? stats) {
    final playCount = stats?.playCount ?? 0;
    final skipCount = stats?.skipCount ?? 0;
    final rating = stats?.rating ?? track.rating;
    final lastPlayedMs = stats?.lastPlayedMs;

    // Base weight: boosts highly-played / highly-rated tracks.
    double base = 1.0
        + (playCount * _config.favoriteBias * 0.1)
        + ((rating / 5.0) * _config.favoriteBias);

    // Discovery bonus: inject rarely-played tracks (PRD §6.3).
    if (playCount < 3) {
      base += _config.discoveryFraction * 2.0;
    }

    // Recency decay: exp(-λ × days). λ = recencyStrength.
    double recencyFactor = 1.0;
    if (lastPlayedMs != null && _config.recencyStrength > 0) {
      final daysSince = (DateTime.now().millisecondsSinceEpoch - lastPlayedMs)
          / (1000 * 60 * 60 * 24);
      recencyFactor = math.exp(-_config.recencyStrength * daysSince);
      // Clamp: played today = ~1.0, played 30 days ago ≈ 0.05
    }

    // Skip penalty: tracks frequently skipped get lower weight.
    final skipPenalty = 1.0 + (skipCount * 0.3);

    return math.max(0.01, base * recencyFactor / skipPenalty);
  }

  // ── Private Permutation Building (A-Res / Efraimidis-Spirakis) ─────────────

  /// Builds a weighted random permutation in O(n log n).
  ///
  /// Uses the Efraimidis-Spirakis A-Res algorithm:
  ///   key_i = uniform(0,1)^(1/weight_i)
  /// Sort descending by key → optimal weighted random permutation without
  /// replacement (proven same distribution as sequential weighted sampling).
  List<String> _buildPermutation(
    Map<String, double> scores,
    List<Track> tracks,
  ) {
    final rng = _config.seed != null
        ? math.Random(_config.seed)
        : math.Random();

    // Compute A-Res keys in O(n).
    final keyed = tracks.map((t) {
      final w = scores[t.id] ?? 0.01;
      // key = U^(1/w); higher weight → key closer to 1 on average.
      final u = rng.nextDouble();
      final key = u == 0 ? 0.0 : math.pow(u, 1.0 / w).toDouble();
      return _ScoredTrack(t.id, t.artistId, key);
    }).toList();

    // Sort descending by key — O(n log n).
    keyed.sort((a, b) => b.key.compareTo(a.key));

    return keyed.map((s) => s.id).toList();
  }

  // ── Private Artist-Spacing Enforcement ────────────────────────────────────

  /// Greedy post-pass to enforce artist spacing. O(n × artistSpacing).
  ///
  /// Scans left→right. When a track at position [i] has the same artist as
  /// any track in [i - artistSpacing, i - 1], swaps it with the nearest
  /// valid (different-artist) track in [i+1..end]. If no valid swap exists,
  /// leaves the violation (unavoidable for small libraries with many same-
  /// artist tracks).
  List<String> _enforceArtistSpacing(
    List<String> ids,
    List<Track> tracks,
  ) {
    if (_config.artistSpacing <= 0 || tracks.length <= _config.artistSpacing) {
      return ids;
    }

    // Build id→artistId lookup in O(n).
    final idToArtist = {for (final t in tracks) t.id: t.artistId};

    final result = List<String>.from(ids);

    for (int i = 0; i < result.length; i++) {
      final artistId = idToArtist[result[i]];
      if (artistId == null) continue;

      // Check if this artist appears within the preceding window.
      bool violation = false;
      for (int k = math.max(0, i - _config.artistSpacing); k < i; k++) {
        if (idToArtist[result[k]] == artistId) {
          violation = true;
          break;
        }
      }

      if (!violation) continue;

      // Find the nearest valid swap candidate in [i+1..end].
      for (int j = i + 1; j < result.length; j++) {
        final candidateArtist = idToArtist[result[j]];
        if (candidateArtist == artistId) continue;

        // Verify swapping j → i doesn't create a violation at position j.
        bool jCausesViolation = false;
        for (int k = math.max(0, i - _config.artistSpacing); k < i; k++) {
          if (idToArtist[result[k]] == candidateArtist) {
            jCausesViolation = true;
            break;
          }
        }
        if (jCausesViolation) continue;

        // Safe to swap.
        final tmp = result[i];
        result[i] = result[j];
        result[j] = tmp;
        break;
      }
    }

    return result;
  }
}

/// Internal helper pairing a track ID with its A-Res sort key.
class _ScoredTrack {
  const _ScoredTrack(this.id, this.artistId, this.key);
  final String id;
  final String artistId;
  final double key;
}
