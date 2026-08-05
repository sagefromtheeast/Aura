// lib/domain/use_cases/smart_mix_generator.dart
// Aura — SmartMixGenerator
// Architecture §4.4 / PRD §6.4 / CLAUDE.md §2
//
// ═══════════════════════════════════════════════════════════════════════════════
// ALGORITHM OVERVIEW — k-means Clustering on Audio Features → Playlist Assembly
// ═══════════════════════════════════════════════════════════════════════════════
//
// INPUT:
//   - N tracks with 6-dimensional feature vectors:
//     [tempo, energy, valence, danceability, loudness, acousticness]
//   - Behaviour stats (play counts) for anchor selection.
//   - Target mood (MixMood enum → maps to a target centroid region).
//
// ALGORITHM (k-means, k=5 clusters):
//   1. INITIALISE centroids using k-means++ seeding (O(n·k)):
//      - Pick first centroid randomly from tracks with audio features.
//      - For each subsequent centroid: pick track with probability ∝
//        squared distance to nearest already-chosen centroid.
//      - This gives better spread than pure random init.
//
//   2. ITERATE (max 50 iterations):
//      a. ASSIGN each track to nearest centroid (Euclidean, O(n·k)).
//      b. UPDATE centroids = mean of assigned tracks (O(n)).
//      c. CHECK convergence: if all centroids move < 1e-4, stop early.
//
//   3. ANCHOR SELECTION per cluster:
//      - Within each cluster, pick the top-M tracks by:
//        score = playCount × 0.5 + (1 / distToCentroid) × 0.5
//      - Anchors ensure mixes feel familiar before introducing new tracks.
//
//   4. PLAYLIST ASSEMBLY for target mood:
//      - Map mood → cluster index (based on expected centroid position).
//      - Fill playlist: 60% from target cluster, 40% from adjacent clusters.
//      - Ensure variety: no more than 3 consecutive tracks from same artist.
//      - Target size: 25–50 tracks (kSmartMixMinTracks–kSmartMixMaxTracks).
//
// TIME COMPLEXITY:
//   - k-means: O(n · k · maxIter) = O(50·5·n) = O(n) for practical n.
//   - Playlist assembly: O(n log n) (sort by score within cluster).
//
// ═══════════════════════════════════════════════════════════════════════════════

import 'dart:math' as math;

import '../entities/playlist.dart';
import '../entities/track.dart';
import '../repositories/behavior_repository.dart';
import '../repositories/music_repository.dart';
import '../repositories/playlist_repository.dart';
import '../../core/constants.dart';
import '../../core/errors.dart';
import '../../core/extensions.dart';

/// Generates mood-based playlists (Smart Mixes) using k-means clustering
/// on audio feature vectors extracted by the C++ analyser.
///
/// Called daily by the Workmanager background task (PRD §6.4).
class SmartMixGenerator {
  SmartMixGenerator({
    required MusicRepository musicRepository,
    required BehaviorRepository behaviorRepository,
    required PlaylistRepository playlistRepository,
  })  : _musicRepo = musicRepository,
        _behaviorRepo = behaviorRepository,
        _playlistRepo = playlistRepository;

  final MusicRepository _musicRepo;
  final BehaviorRepository _behaviorRepo;
  final PlaylistRepository _playlistRepo;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Generates and persists Smart Mix playlists for all [MixMood] values.
  ///
  /// Typically called once per day from the background scheduler.
  Future<void> generateAllMixes() async {
    final tracks = await _musicRepo.getAllTracks();
    final features = await _loadFeatures(tracks);

    if (features.length < kKMeansClusters) {
      throw MixGenerationError(
        'Not enough tracks with audio features to generate mixes '
        '(need ≥$kKMeansClusters, have ${features.length})',
      );
    }

    final stats = await _behaviorRepo.getBehaviorStats(
        features.keys.toList());

    // Run k-means once; reuse clusters for all moods.
    final clusters = _runKMeans(features);

    for (final mood in MixMood.values) {
      final playlist = _assembleMix(
        mood: mood,
        clusters: clusters,
        features: features,
        stats: stats,
        allTracks: {for (final t in tracks) t.id: t},
      );
      await _playlistRepo.upsertSmartMix(playlist);
    }
  }

  /// Generates a single mix for the given [mood] (on-demand).
  Future<Playlist> generateMix(MixMood mood) async {
    final tracks = await _musicRepo.getAllTracks();
    final features = await _loadFeatures(tracks);

    if (features.length < kKMeansClusters) {
      throw const MixGenerationError('Insufficient tracks with audio features');
    }

    final stats = await _behaviorRepo.getBehaviorStats(
        features.keys.toList());
    final clusters = _runKMeans(features);

    return _assembleMix(
      mood: mood,
      clusters: clusters,
      features: features,
      stats: stats,
      allTracks: {for (final t in tracks) t.id: t},
    );
  }

  // ── Private: Feature Loading ───────────────────────────────────────────────

  /// Loads audio features for all tracks that have been analysed.
  /// Tracks without features are excluded from mix generation.
  Future<Map<String, List<double>>> _loadFeatures(List<Track> tracks) async {
    final result = <String, List<double>>{};
    for (final track in tracks) {
      final f = await _musicRepo.getAudioFeatures(track.id);
      if (f != null && f.length == kAudioFeatureDimension) {
        result[track.id] = f;
      }
    }
    return result;
  }

  // ── Private: k-means Clustering ───────────────────────────────────────────

  /// Runs k-means with k=[kKMeansClusters] clusters using k-means++ seeding.
  ///
  /// Returns a list of [_Cluster] objects, each with its centroid and members.
  List<_Cluster> _runKMeans(Map<String, List<double>> features) {
    final rng = math.Random();
    final ids = features.keys.toList();

    // ── k-means++ Initialisation ─────────────────────────────────────────────
    // Seed centroids with high spread (reduces bad local minima).
    final centroids = _kMeansPlusPlusInit(features, ids, rng);

    // ── Iterative Refinement ─────────────────────────────────────────────────
    late List<_Cluster> clusters;
    for (int iter = 0; iter < kKMeansMaxIterations; iter++) {
      // Assignment step: O(n·k).
      clusters = List.generate(kKMeansClusters,
          (i) => _Cluster(centroid: centroids[i], members: []));

      for (final id in ids) {
        final vec = features[id]!;
        int nearest = 0;
        double minDist = double.infinity;
        for (int c = 0; c < centroids.length; c++) {
          final d = vec.distanceTo(centroids[c]);
          if (d < minDist) {
            minDist = d;
            nearest = c;
          }
        }
        clusters[nearest].members.add(id);
        clusters[nearest].distanceSums[id] = minDist;
      }

      // Update step: recompute centroids as mean of members.
      bool converged = true;
      for (int c = 0; c < kKMeansClusters; c++) {
        if (clusters[c].members.isEmpty) continue;
        final newCentroid = _meanVector(
            clusters[c].members.map((id) => features[id]!).toList());
        final movement = newCentroid.distanceTo(centroids[c]);
        centroids[c] = newCentroid;
        if (movement > kKMeansConvergenceThreshold) converged = false;
      }
      if (converged) break;
    }

    return clusters;
  }

  /// k-means++ seeding: O(n·k).
  List<List<double>> _kMeansPlusPlusInit(
    Map<String, List<double>> features,
    List<String> ids,
    math.Random rng,
  ) {
    final centroids = <List<double>>[];

    // Pick first centroid at random.
    centroids.add(List<double>.from(
        features[ids[rng.nextInt(ids.length)]]!));

    for (int c = 1; c < kKMeansClusters; c++) {
      // For each track, compute D² = squared distance to nearest centroid.
      final dSquared = ids.map((id) {
        final vec = features[id]!;
        double minDist = double.infinity;
        for (final centroid in centroids) {
          final d = vec.distanceTo(centroid);
          if (d < minDist) minDist = d;
        }
        return minDist * minDist;
      }).toList();

      // Sample next centroid proportional to D².
      final totalD = dSquared.fold(0.0, (a, b) => a + b);
      double sample = rng.nextDouble() * totalD;
      int selected = 0;
      for (int i = 0; i < dSquared.length; i++) {
        sample -= dSquared[i];
        if (sample <= 0) {
          selected = i;
          break;
        }
      }
      centroids.add(List<double>.from(features[ids[selected]]!));
    }

    return centroids;
  }

  /// Element-wise mean of a list of vectors.
  List<double> _meanVector(List<List<double>> vecs) {
    final sum = List<double>.filled(kAudioFeatureDimension, 0.0);
    for (final v in vecs) {
      for (int i = 0; i < kAudioFeatureDimension; i++) {
        sum[i] += v[i];
      }
    }
    return sum.map((x) => x / vecs.length).toList();
  }

  // ── Private: Mood → Cluster Mapping ───────────────────────────────────────

  /// Maps a [MixMood] to its expected feature profile.
  ///
  /// Feature order: [tempo, energy, valence, danceability, loudness, acousticness]
  /// All values normalised 0.0–1.0 (as stored by the C++ analyser).
  ///
  /// Used to find the cluster whose centroid is nearest to the mood target,
  /// making the mapping data-driven rather than hard-coded.
  static const Map<MixMood, List<double>> _moodTargets = {
    MixMood.morning:  [0.55, 0.50, 0.70, 0.55, 0.45, 0.45], // moderate tempo, positive
    MixMood.workout:  [0.85, 0.90, 0.65, 0.80, 0.80, 0.10], // high energy, fast
    MixMood.chill:    [0.35, 0.25, 0.55, 0.30, 0.25, 0.75], // slow, acoustic, calm
    MixMood.focus:    [0.45, 0.40, 0.45, 0.35, 0.35, 0.55], // low distraction, instrumental
    MixMood.evening:  [0.40, 0.35, 0.50, 0.40, 0.30, 0.65], // relaxed, slightly acoustic
  };

  int _moodToClusterIndex(MixMood mood, List<_Cluster> clusters) {
    final target = _moodTargets[mood]!;
    int bestCluster = 0;
    double minDist = double.infinity;
    for (int i = 0; i < clusters.length; i++) {
      final d = target.distanceTo(clusters[i].centroid);
      if (d < minDist) {
        minDist = d;
        bestCluster = i;
      }
    }
    return bestCluster;
  }

  // ── Private: Playlist Assembly ─────────────────────────────────────────────

  /// Assembles a [Playlist] for [mood] from the k-means [clusters].
  ///
  /// Fill strategy: 60% primary cluster + 40% adjacent clusters.
  /// Artist-diversity: ≤3 consecutive tracks from same artist.
  Playlist _assembleMix({
    required MixMood mood,
    required List<_Cluster> clusters,
    required Map<String, List<double>> features,
    required Map<String, TrackBehaviorStats> stats,
    required Map<String, Track> allTracks,
  }) {
    final primaryIdx = _moodToClusterIndex(mood, clusters);
    final primary = clusters[primaryIdx];

    // Score tracks within primary cluster for anchor selection.
    final scoredPrimary = _scoreClusterMembers(
        primary, stats, features, clusters[primaryIdx].centroid);

    // Gather tracks from adjacent clusters (wrap-around).
    final adjacentTracks = <String>[];
    for (int i = 0; i < kKMeansClusters; i++) {
      if (i == primaryIdx) continue;
      final scored = _scoreClusterMembers(
          clusters[i], stats, features, clusters[primaryIdx].centroid);
      adjacentTracks.addAll(scored.take(10).map((s) => s.id));
    }

    // Build candidate pool: 60% primary, 40% adjacent.
    final targetSize = math.min(kSmartMixMaxTracks,
        math.max(kSmartMixMinTracks, primary.members.length));
    final primaryCount = (targetSize * 0.6).round();
    final adjacentCount = targetSize - primaryCount;

    final candidates = [
      ...scoredPrimary.take(primaryCount).map((s) => s.id),
      ...adjacentTracks.take(adjacentCount),
    ];

    // Artist-diversity pass: no more than 3 consecutive same-artist tracks.
    final diverse = _applyArtistDiversity(candidates, allTracks);

    final now = DateTime.now().millisecondsSinceEpoch;
    return Playlist(
      id: '${mood.name}_mix',
      name: _moodDisplayName(mood),
      description: _moodDescription(mood),
      type: PlaylistType.smartMix,
      mood: mood,
      trackIds: diverse,
      createdAtMs: now,
      updatedAtMs: now,
    );
  }

  List<_ScoredMember> _scoreClusterMembers(
    _Cluster cluster,
    Map<String, TrackBehaviorStats> stats,
    Map<String, List<double>> features,
    List<double> centroid,
  ) {
    final scored = cluster.members.map((id) {
      final playCount = stats[id]?.playCount ?? 0;
      final distToCentroid = cluster.distanceSums[id] ?? 1.0;
      // Anchor score = familiarity (play count) + cluster-centrality.
      final score = (playCount * 0.5) +
          (1.0 / (1.0 + distToCentroid)) * 0.5;
      return _ScoredMember(id, score);
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored;
  }

  List<String> _applyArtistDiversity(
      List<String> trackIds, Map<String, Track> allTracks) {
    final result = <String>[];
    int consecutiveSameArtist = 0;
    String? lastArtistId;
    final remaining = List<String>.from(trackIds);

    while (remaining.isNotEmpty) {
      // Find next track respecting diversity.
      int chosen = -1;
      for (int i = 0; i < remaining.length; i++) {
        final artist = allTracks[remaining[i]]?.artistId;
        if (artist != lastArtistId || consecutiveSameArtist < 3) {
          chosen = i;
          break;
        }
      }
      if (chosen == -1) chosen = 0; // all same artist — just take next

      final id = remaining.removeAt(chosen);
      final artistId = allTracks[id]?.artistId;
      if (artistId == lastArtistId) {
        consecutiveSameArtist++;
      } else {
        consecutiveSameArtist = 1;
        lastArtistId = artistId;
      }
      result.add(id);
    }
    return result;
  }

  static String _moodDisplayName(MixMood mood) => switch (mood) {
        MixMood.morning => 'Morning Boost',
        MixMood.workout => 'Workout Power',
        MixMood.chill => 'Chill Vibes',
        MixMood.focus => 'Deep Focus',
        MixMood.evening => 'Evening Wind-Down',
      };

  static String _moodDescription(MixMood mood) => switch (mood) {
        MixMood.morning => 'Energise your morning with uplifting tracks.',
        MixMood.workout => 'High-energy beats to push your limits.',
        MixMood.chill => 'Relax and unwind with calm, acoustic sounds.',
        MixMood.focus => 'Low-distraction music to help you concentrate.',
        MixMood.evening => 'Wind down with gentle, reflective sounds.',
      };
}

// ─────────────────────────────────────────────────────────────────────────────

/// Internal representation of a k-means cluster.
class _Cluster {
  _Cluster({required this.centroid, required this.members});
  List<double> centroid;
  final List<String> members;
  /// Distance from each member to its centroid (filled during assignment).
  final Map<String, double> distanceSums = {};
}

/// Internal: track ID paired with its cluster score.
class _ScoredMember {
  const _ScoredMember(this.id, this.score);
  final String id;
  final double score;
}
