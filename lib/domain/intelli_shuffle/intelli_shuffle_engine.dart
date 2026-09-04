// lib/domain/intelli_shuffle/intelli_shuffle_engine.dart
// Aura — IntelliShuffle engine (pure Dart, no DB or plugin imports).
//
// PRD §6.3: non-repeating full-cycle shuffle with sliders for favourite bias,
// recency avoidance, discovery injection and artist/album spacing.
//
// ── Algorithm ────────────────────────────────────────────────────────────────
// 1. Score every track once:  w = base × recency × favourite × discovery × mood
// 2. Draw a permutation without replacement using a Fenwick tree over the
//    weights: each draw is O(log n) and removing the drawn track is O(log n),
//    so a full permutation is O(n log n). (A flat cumulative array would have
//    to be rebuilt after every pick — O(n²) — which misses the 10k/500ms
//    budget by orders of magnitude.)
// 3. Enforce artist/album spacing with sliding windows. A candidate violating
//    the window is rejected and redrawn; after a bounded number of attempts the
//    constraints relax in order artist → album → none, so the draw can never
//    deadlock and the full-cycle "no repeats" guarantee always holds.
//
// State is serialisable so a shuffle survives restarts without regenerating.

import 'dart:convert';
import 'dart:math' as math;

import '../entities/shuffle_config.dart';
import '../entities/track.dart';
import '../repositories/behavior_repository.dart';
import '../repositories/music_repository.dart';

/// Schema version for [IntelliShuffleEngine.serializeState].
const int kShuffleStateVersion = 2;

/// How many redraws to attempt before relaxing a spacing constraint.
const int _kMaxDrawAttempts = 8;

/// Fraction of the library (by play count) treated as "discovery" material.
const double _kDiscoveryPercentile = 0.20;

/// Which spacing constraints are currently being enforced.
enum _Relaxation { strict, albumOnly, none }

/// Immutable snapshot of a shuffle queue.
class ShuffleState {
  const ShuffleState({
    required this.shuffledIds,
    required this.currentIndex,
    required this.config,
    required this.generatedAtMs,
    this.recentArtists = const [],
    this.recentAlbums = const [],
    this.weights = const {},
  });

  /// The complete permutation of track IDs for this cycle.
  final List<String> shuffledIds;

  /// Index of the NEXT track to play (0-based).
  final int currentIndex;

  final ShuffleConfig config;
  final int generatedAtMs;

  /// Sliding window of recently played artist IDs (most recent last).
  final List<String> recentArtists;

  /// Sliding window of recently played album IDs (most recent last).
  final List<String> recentAlbums;

  /// Per-track weights from the last generation, kept so a restored queue can
  /// extend itself (addTracks) without re-scoring everything.
  final Map<String, double> weights;

  bool get isExhausted => currentIndex >= shuffledIds.length;
  int get remainingCount => shuffledIds.length - currentIndex;

  ShuffleState copyWith({
    List<String>? shuffledIds,
    int? currentIndex,
    ShuffleConfig? config,
    int? generatedAtMs,
    List<String>? recentArtists,
    List<String>? recentAlbums,
    Map<String, double>? weights,
  }) {
    return ShuffleState(
      shuffledIds: shuffledIds ?? this.shuffledIds,
      currentIndex: currentIndex ?? this.currentIndex,
      config: config ?? this.config,
      generatedAtMs: generatedAtMs ?? this.generatedAtMs,
      recentArtists: recentArtists ?? this.recentArtists,
      recentAlbums: recentAlbums ?? this.recentAlbums,
      weights: weights ?? this.weights,
    );
  }

  Map<String, dynamic> toJson() => {
        'version': kShuffleStateVersion,
        'shuffledIds': shuffledIds,
        'currentIndex': currentIndex,
        'config': config.toJson(),
        'generatedAtMs': generatedAtMs,
        'recentArtists': recentArtists,
        'recentAlbums': recentAlbums,
        'weights': weights,
      };

  factory ShuffleState.fromJson(Map<String, dynamic> json) {
    return ShuffleState(
      shuffledIds:
          (json['shuffledIds'] as List<dynamic>? ?? const []).cast<String>(),
      currentIndex: (json['currentIndex'] as num?)?.toInt() ?? 0,
      config: json['config'] == null
          ? ShuffleConfig.defaults
          : ShuffleConfig.fromJson(
              Map<String, dynamic>.from(json['config'] as Map)),
      generatedAtMs: (json['generatedAtMs'] as num?)?.toInt() ?? 0,
      recentArtists:
          (json['recentArtists'] as List<dynamic>? ?? const []).cast<String>(),
      recentAlbums:
          (json['recentAlbums'] as List<dynamic>? ?? const []).cast<String>(),
      weights: (json['weights'] as Map<dynamic, dynamic>? ?? const {})
          .map((k, v) => MapEntry(k.toString(), (v as num).toDouble())),
    );
  }
}

/// Generates and walks a weighted, constraint-satisfying shuffle permutation.
class IntelliShuffleEngine {
  IntelliShuffleEngine({
    required ShuffleConfig config,
    required MusicRepository trackRepository,
    required BehaviorRepository behaviorRepository,
  })  : _config = config,
        _trackRepo = trackRepository,
        _behaviorRepo = behaviorRepository;

  ShuffleConfig _config;
  final MusicRepository _trackRepo;
  final BehaviorRepository _behaviorRepo;

  ShuffleState? _state;

  /// id → Track, so [nextTrack] can return entities rather than bare IDs.
  final Map<String, Track> _trackById = {};

  ShuffleConfig get config => _config;
  ShuffleState? get state => _state;
  bool get hasQueue => _state != null;
  int get remainingCount => _state?.remainingCount ?? 0;

  /// Tracks queued for this cycle, in play order.
  List<String> get queue => List.unmodifiable(_state?.shuffledIds ?? const []);

  // ── Generation ─────────────────────────────────────────────────────────────

  /// Builds a fresh shuffle permutation over [inputTracks].
  ///
  /// Async because the scoring inputs (behaviour stats, and audio features when
  /// [ShuffleConfig.moodMatching] is on) come from repositories — the same
  /// repositories this class is constructed with.
  ///
  /// Returns the tracks in play order. An empty input yields an empty queue.
  Future<List<Track>> generateShuffle(List<Track> inputTracks) async {
    _trackById
      ..clear()
      ..addEntries(inputTracks.map((t) => MapEntry(t.id, t)));

    if (inputTracks.isEmpty) {
      _state = ShuffleState(
        shuffledIds: const [],
        currentIndex: 0,
        config: _config,
        generatedAtMs: DateTime.now().millisecondsSinceEpoch,
      );
      return const [];
    }

    final stats = await _behaviorRepo
        .getBehaviorStats(inputTracks.map((t) => t.id).toList());
    final moods = await _loadMoods(inputTracks);
    final referenceMood = _referenceMood(inputTracks, stats, moods);

    final weights = <double>[
      for (final t in inputTracks)
        _weightFor(t, stats[t.id], moods[t.id], referenceMood),
    ];

    final order = _drawPermutation(inputTracks, weights);

    _state = ShuffleState(
      shuffledIds: [for (final t in order) t.id],
      currentIndex: 0,
      config: _config,
      generatedAtMs: DateTime.now().millisecondsSinceEpoch,
      weights: {
        for (int i = 0; i < inputTracks.length; i++)
          inputTracks[i].id: weights[i],
      },
    );
    return order;
  }

  // ── Queue walking ──────────────────────────────────────────────────────────

  /// Returns the next track and advances the cursor, or null when the queue is
  /// empty/exhausted or the track is no longer in the library.
  Track? nextTrack() {
    final s = _state;
    if (s == null || s.shuffledIds.isEmpty) return null;
    if (s.isExhausted) return null;

    final id = s.shuffledIds[s.currentIndex];
    final track = _trackById[id];

    _state = s.copyWith(
      currentIndex: s.currentIndex + 1,
      recentArtists: track == null
          ? s.recentArtists
          : _pushWindow(s.recentArtists, track.artistId, _config.artistSpacing),
      recentAlbums: track == null
          ? s.recentAlbums
          : _pushWindow(s.recentAlbums, track.albumId, _config.albumSpacing),
    );

    // A track removed from the library mid-cycle: skip over it.
    if (track == null) return nextTrack();
    return track;
  }

  /// Peeks at the next track without advancing.
  Track? peekNext() {
    final s = _state;
    if (s == null || s.isExhausted) return null;
    return _trackById[s.shuffledIds[s.currentIndex]];
  }

  /// Records that the user skipped [skippedTrack].
  ///
  /// Skips demote the track for the *next* generation (the behaviour repo
  /// records the event); the current permutation is left intact so the
  /// full-cycle guarantee is not broken mid-cycle.
  void skip(Track skippedTrack) {
    final s = _state;
    if (s == null) return;
    final w = Map<String, double>.from(s.weights);
    final current = w[skippedTrack.id];
    if (current != null) {
      // Halve the cached weight so a regenerate/addTracks reflects the skip.
      w[skippedTrack.id] = math.max(_kMinWeight, current * 0.5);
      _state = s.copyWith(weights: w);
    }
  }

  /// Records that [finishedTrack] played through to the end.
  void onTrackFinished(Track finishedTrack) {
    final s = _state;
    if (s == null) return;
    final w = Map<String, double>.from(s.weights);
    final current = w[finishedTrack.id];
    if (current != null) {
      // A completed listen is a mild positive signal for the next cycle.
      w[finishedTrack.id] = current * (1.0 + 0.1 * _config.favouriteBias);
      _state = s.copyWith(weights: w);
    }
  }

  // ── Library mutations ──────────────────────────────────────────────────────

  /// Appends [newTracks] into the unplayed remainder of the current cycle.
  ///
  /// New tracks are interleaved at weighted-random positions after the cursor
  /// so they can be reached this cycle rather than always landing last.
  Future<void> addTracks(List<Track> newTracks) async {
    if (newTracks.isEmpty) return;

    final s = _state;
    if (s == null) {
      await generateShuffle(newTracks);
      return;
    }

    final existing = s.shuffledIds.toSet();
    final fresh = newTracks.where((t) => !existing.contains(t.id)).toList();
    if (fresh.isEmpty) return;

    _trackById.addEntries(fresh.map((t) => MapEntry(t.id, t)));

    final stats =
        await _behaviorRepo.getBehaviorStats(fresh.map((t) => t.id).toList());
    final moods = await _loadMoods(fresh);
    final reference = _referenceMood(fresh, stats, moods);

    final rng = _rng();
    final ids = List<String>.from(s.shuffledIds);
    final weights = Map<String, double>.from(s.weights);

    for (final t in fresh) {
      weights[t.id] = _weightFor(t, stats[t.id], moods[t.id], reference);
      // Insert somewhere in the not-yet-played remainder.
      final lower = s.currentIndex;
      final span = ids.length - lower;
      final at = span <= 0 ? ids.length : lower + rng.nextInt(span + 1);
      ids.insert(at, t.id);
    }

    _state = s.copyWith(shuffledIds: ids, weights: weights);
  }

  /// Removes [removedTrack] from the remaining queue (e.g. file deleted).
  void removeTrack(Track removedTrack) {
    final s = _state;
    if (s == null) return;

    _trackById.remove(removedTrack.id);

    final ids = List<String>.from(s.shuffledIds);
    var cursor = s.currentIndex;
    for (int i = ids.length - 1; i >= 0; i--) {
      if (ids[i] != removedTrack.id) continue;
      ids.removeAt(i);
      // Keep the cursor pointing at the same upcoming track.
      if (i < cursor) cursor--;
    }

    final weights = Map<String, double>.from(s.weights)..remove(removedTrack.id);
    _state = s.copyWith(
      shuffledIds: ids,
      currentIndex: cursor.clamp(0, ids.length),
      weights: weights,
    );
  }

  /// Replaces the config. Takes effect on the next generation; the current
  /// permutation is preserved so playback is not disrupted mid-cycle.
  void updateConfig(ShuffleConfig config) {
    _config = config;
    final s = _state;
    if (s != null) _state = s.copyWith(config: config);
  }

  // ── Persistence ────────────────────────────────────────────────────────────

  /// Serialises the queue to JSON. O(n) — throttle to once per track change.
  String serializeState() => jsonEncode(_state?.toJson() ?? const {});

  /// Restores a queue previously produced by [serializeState].
  ///
  /// Track entities are not part of the payload; call [hydrate] with the
  /// current library afterwards so [nextTrack] can return them.
  void restoreState(String json) {
    if (json.isEmpty) return;
    final decoded = jsonDecode(json);
    if (decoded is! Map) return;
    final map = Map<String, dynamic>.from(decoded);
    if (map.isEmpty) return;

    final version = (map['version'] as num?)?.toInt() ?? 1;
    if (version > kShuffleStateVersion) return; // written by a newer build

    _state = ShuffleState.fromJson(map);
    _config = _state!.config;
  }

  /// Supplies the Track entities for a restored queue. Additive to the spec's
  /// API: [restoreState] carries IDs only, so the engine needs the library to
  /// hand back entities.
  void hydrate(Iterable<Track> library) {
    _trackById.addEntries(library.map((t) => MapEntry(t.id, t)));
  }

  // ── Scoring ────────────────────────────────────────────────────────────────

  static const double _kMinWeight = 1e-4;

  /// w = base × recencyPenalty × favouriteTerm × discoveryTerm × moodTerm
  double _weightFor(
    Track track,
    TrackBehaviorStats? stats,
    List<double>? mood,
    List<double>? reference,
  ) {
    final playCount = stats?.playCount ?? track.playCount;
    final skipCount = stats?.skipCount ?? track.skipCount;
    final rating = stats?.rating ?? track.rating;
    final lastPlayedMs = stats?.lastPlayedMs ?? track.lastPlayedMs;

    // Favourites: ratings and repeat plays both count, scaled by the slider.
    final favourite = 1.0 +
        _config.favouriteBias * ((rating / 5.0) + math.log(1 + playCount) * 0.25);

    // Skips are a negative signal.
    final skipPenalty = 1.0 + skipCount * 0.3;

    final weight = favourite * _recencyPenalty(lastPlayedMs) / skipPenalty;
    final withMood = weight * _moodTerm(mood, reference);
    return math.max(_kMinWeight, withMood);
  }

  /// Spec formula: 1 - (recencyAvoidance / (1 + log(1 + hoursSinceLastPlayed)))
  ///
  /// Never returns 0, otherwise a just-played track could become unselectable
  /// and break the full-cycle guarantee.
  double _recencyPenalty(int? lastPlayedMs) {
    if (lastPlayedMs == null || _config.recencyAvoidance <= 0) return 1.0;
    final hours =
        (DateTime.now().millisecondsSinceEpoch - lastPlayedMs) / 3600000.0;
    final safeHours = hours < 0 ? 0.0 : hours;
    final penalty =
        1.0 - (_config.recencyAvoidance / (1.0 + math.log(1.0 + safeHours)));
    return math.max(_kMinWeight, penalty);
  }

  /// Cosine-style closeness to the reference mood, scaled by moodStrength.
  /// Returns 1.0 (neutral) when mood matching is off or features are missing —
  /// the common case until the C++ analyzer has run over the library.
  double _moodTerm(List<double>? mood, List<double>? reference) {
    if (!_config.moodMatching) return 1.0;
    if (mood == null || reference == null) return 1.0;
    if (mood.length != reference.length || mood.isEmpty) return 1.0;

    // Normalised Euclidean distance over the [0,1] feature space.
    var sumSq = 0.0;
    for (int i = 0; i < mood.length; i++) {
      final d = mood[i] - reference[i];
      sumSq += d * d;
    }
    final distance = math.sqrt(sumSq / mood.length); // 0 = identical, 1 = far
    final closeness = (1.0 - distance).clamp(0.0, 1.0);
    // moodStrength 0 => no effect; 1 => up to 2x for a perfect match.
    return 1.0 + _config.moodStrength * closeness;
  }

  /// Fetches audio features for [tracks] when mood matching is enabled.
  /// Skipped entirely when it's off, so the common path costs no repo reads.
  Future<Map<String, List<double>>> _loadMoods(List<Track> tracks) async {
    if (!_config.moodMatching) return const {};
    final out = <String, List<double>>{};
    for (final t in tracks) {
      final f = await _trackRepo.getAudioFeatures(t.id);
      if (f != null && f.isNotEmpty) out[t.id] = f;
    }
    return out;
  }

  /// The mood to match against: the rating-weighted mean of available feature
  /// vectors, i.e. "what this user's favourites sound like".
  List<double>? _referenceMood(
    List<Track> tracks,
    Map<String, TrackBehaviorStats> stats,
    Map<String, List<double>> moods,
  ) {
    if (!_config.moodMatching || moods.isEmpty) return null;

    List<double>? acc;
    var totalWeight = 0.0;
    for (final t in tracks) {
      final f = moods[t.id];
      if (f == null) continue;
      final rating = stats[t.id]?.rating ?? t.rating;
      final playCount = stats[t.id]?.playCount ?? t.playCount;
      final w = 1.0 + rating + math.log(1 + playCount);
      acc ??= List<double>.filled(f.length, 0.0);
      if (acc.length != f.length) continue;
      for (int i = 0; i < f.length; i++) {
        acc[i] += f[i] * w;
      }
      totalWeight += w;
    }
    if (acc == null || totalWeight <= 0) return null;
    return [for (final v in acc) v / totalWeight];
  }

  // ── Permutation drawing ────────────────────────────────────────────────────

  math.Random _rng() =>
      _config.seed == null ? math.Random() : math.Random(_config.seed);

  /// Weighted sampling without replacement, honouring spacing constraints.
  List<Track> _drawPermutation(List<Track> tracks, List<double> weights) {
    final n = tracks.length;
    final rng = _rng();

    final main = _Fenwick(weights);

    // Discovery pool: the least-played fifth of the library.
    final discoveryIdx = _discoveryPool(tracks);
    final discoveryWeights = List<double>.filled(n, 0.0);
    for (final i in discoveryIdx) {
      discoveryWeights[i] = weights[i];
    }
    final discovery = _Fenwick(discoveryWeights);

    final recentArtists = <String>[];
    final recentAlbums = <String>[];
    final order = <Track>[];

    for (int picked = 0; picked < n; picked++) {
      int chosen = -1;

      // Discovery injection: with probability `discovery`, prefer an
      // under-played track so unplayed music eventually surfaces.
      final tryDiscovery =
          _config.discovery > 0 && rng.nextDouble() < _config.discovery;
      if (tryDiscovery && discovery.total > 0) {
        chosen = _drawConstrained(
            discovery, tracks, rng, recentArtists, recentAlbums);
      }

      chosen = chosen >= 0
          ? chosen
          : _drawConstrained(main, tracks, rng, recentArtists, recentAlbums);

      if (chosen < 0) break; // nothing left

      final track = tracks[chosen];
      order.add(track);

      // Consume in both trees so it can never be drawn again.
      main.set(chosen, 0.0);
      discovery.set(chosen, 0.0);

      _pushWindowInPlace(recentArtists, track.artistId, _config.artistSpacing);
      _pushWindowInPlace(recentAlbums, track.albumId, _config.albumSpacing);
    }
    return order;
  }

  /// Draws from [tree], relaxing constraints only when it must.
  /// Fallback chain: artist+album → album only → unconstrained.
  int _drawConstrained(
    _Fenwick tree,
    List<Track> tracks,
    math.Random rng,
    List<String> recentArtists,
    List<String> recentAlbums,
  ) {
    if (tree.total <= 0) return -1;

    for (final relaxation in _Relaxation.values) {
      for (int attempt = 0; attempt < _kMaxDrawAttempts; attempt++) {
        final idx = tree.sample(rng.nextDouble() * tree.total);
        if (idx < 0) return -1;
        final t = tracks[idx];

        final artistOk = relaxation != _Relaxation.strict ||
            !recentArtists.contains(t.artistId);
        final albumOk = relaxation == _Relaxation.none ||
            !recentAlbums.contains(t.albumId);

        if (artistOk && albumOk) return idx;
      }
      // Constraints unsatisfiable with this pool — relax and retry.
    }
    // _Relaxation.none accepts anything, so this is unreachable unless empty.
    return tree.sample(rng.nextDouble() * tree.total);
  }

  /// Indices of the least-played [_kDiscoveryPercentile] of the library.
  List<int> _discoveryPool(List<Track> tracks) {
    final idx = List<int>.generate(tracks.length, (i) => i);
    idx.sort((a, b) => tracks[a].playCount.compareTo(tracks[b].playCount));
    final take = math.max(1, (tracks.length * _kDiscoveryPercentile).round());
    return idx.take(take).toList();
  }

  // ── Sliding windows ────────────────────────────────────────────────────────

  static List<String> _pushWindow(List<String> window, String value, int size) {
    if (size <= 0) return const [];
    final next = List<String>.from(window)..add(value);
    while (next.length > size) {
      next.removeAt(0);
    }
    return next;
  }

  static void _pushWindowInPlace(
      List<String> window, String value, int size) {
    if (size <= 0) {
      window.clear();
      return;
    }
    window.add(value);
    while (window.length > size) {
      window.removeAt(0);
    }
  }
}

/// Fenwick (binary indexed) tree over non-negative weights.
///
/// Supports O(log n) weighted sampling and O(log n) point updates, which is
/// what makes drawing a full permutation O(n log n) instead of O(n²).
class _Fenwick {
  _Fenwick(List<double> weights)
      : _n = weights.length,
        _values = List<double>.from(weights),
        _tree = List<double>.filled(weights.length + 1, 0.0) {
    // O(n) build.
    for (int i = 0; i < _n; i++) {
      _tree[i + 1] += _values[i];
      final parent = (i + 1) + ((i + 1) & -(i + 1));
      if (parent <= _n) _tree[parent] += _tree[i + 1];
    }
  }

  final int _n;
  final List<double> _values;
  final List<double> _tree;

  double get total => _prefix(_n);

  /// Sets index [i] to [value].
  void set(int i, double value) {
    final delta = value - _values[i];
    if (delta == 0) return;
    _values[i] = value;
    for (int j = i + 1; j <= _n; j += j & -j) {
      _tree[j] += delta;
    }
  }

  double _prefix(int i) {
    var sum = 0.0;
    for (int j = i; j > 0; j -= j & -j) {
      sum += _tree[j];
    }
    return sum;
  }

  /// Smallest index whose prefix sum exceeds [target]; -1 when empty.
  int sample(double target) {
    if (total <= 0) return -1;

    var idx = 0;
    var remaining = target;
    var bit = _highestPowerOfTwo(_n);
    while (bit > 0) {
      final next = idx + bit;
      if (next <= _n && _tree[next] <= remaining) {
        idx = next;
        remaining -= _tree[next];
      }
      bit >>= 1;
    }
    // idx is the count of entries fully consumed; the next one is the hit.
    if (idx >= _n) {
      // Floating-point drift landed past the end — fall back to the last
      // entry that still carries weight.
      for (int i = _n - 1; i >= 0; i--) {
        if (_values[i] > 0) return i;
      }
      return -1;
    }
    return idx;
  }

  static int _highestPowerOfTwo(int n) {
    var p = 1;
    while (p * 2 <= n) {
      p *= 2;
    }
    return p;
  }
}
