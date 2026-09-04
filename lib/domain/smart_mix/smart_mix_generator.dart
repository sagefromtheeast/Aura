// lib/domain/smart_mix/smart_mix_generator.dart
// Aura — On-device Daily Mixes (PRD §6.4).
//
// Pipeline, per the Smart Mix spec:
//   1. Anchors     — top plays over the last 30 days, mood-filtered, then
//                    k-means (k=3..5) over [energy, valence, tempo]; one anchor
//                    per cluster.
//   2. Expansion   — cosine similarity over the 6-dimension feature vector,
//                    keeping candidates above a threshold.
//   3. Diversity   — max 3 tracks per artist, max 2 per album.
//   4. Sequencing  — Camelot key compatibility plus a mood-shaped BPM curve;
//                    anchors bookend the mix.
//   5. Persistence — a smartMix playlist with isDaily semantics and a 2x2
//                    cover mosaic (paths only; the UI composites them).
//
// Everything is local: no network, no model downloads.

import 'dart:math' as math;

import 'package:uuid/uuid.dart';

import '../../core/constants.dart';
import '../../core/errors.dart';
import '../entities/audio_features.dart';
import '../entities/playlist.dart';
import '../entities/track.dart';
import '../repositories/audio_feature_repository.dart';
import '../repositories/behavior_repository.dart';
import '../repositories/music_repository.dart';
import '../repositories/playlist_repository.dart';

/// Cosine-similarity floor for a track to join an anchor's cluster.
const double kSimilarityThreshold = 0.7;

/// Diversity caps from the spec.
const int kMaxTracksPerArtist = 3;
const int kMaxTracksPerAlbum = 2;

/// How many recent top tracks anchors are drawn from.
const int kAnchorCandidatePool = 20;

/// Lookback window for "recently played a lot".
const int kAnchorLookbackDays = 30;

/// A mix is stale once it is older than this.
const Duration kMixStaleAfter = Duration(hours: 24);

/// Returns the mood that suits the current time of day.
MixMood getMoodForCurrentTime([DateTime? now]) {
  final hour = (now ?? DateTime.now()).hour;
  if (hour < 9) return MixMood.morning;
  if (hour < 17) return MixMood.focus;
  if (hour < 22) return MixMood.evening;
  return MixMood.chill;
}

/// Target acoustic profile for each mood: how the mix should feel.
class MoodProfile {
  const MoodProfile({
    required this.energy,
    required this.valence,
    required this.tempo,
    required this.bpmRising,
  });

  final double energy;
  final double valence;
  final double tempo;

  /// True when the mix should build (workout/morning), false when it should
  /// wind down (chill/evening). Focus stays flat-ish.
  final bool bpmRising;

  static const Map<MixMood, MoodProfile> byMood = {
    MixMood.morning:
        MoodProfile(energy: 0.65, valence: 0.75, tempo: 0.55, bpmRising: true),
    MixMood.workout:
        MoodProfile(energy: 0.90, valence: 0.70, tempo: 0.80, bpmRising: true),
    MixMood.chill:
        MoodProfile(energy: 0.25, valence: 0.55, tempo: 0.35, bpmRising: false),
    MixMood.focus:
        MoodProfile(energy: 0.45, valence: 0.45, tempo: 0.45, bpmRising: false),
    MixMood.evening:
        MoodProfile(energy: 0.35, valence: 0.60, tempo: 0.40, bpmRising: false),
  };

  static MoodProfile of(MixMood mood) => byMood[mood]!;

  /// The 3-dimension vector anchors are clustered in.
  List<double> get clusterVector => [energy, valence, tempo];
}

class SmartMixGenerator {
  SmartMixGenerator({
    required MusicRepository trackRepository,
    required BehaviorRepository behaviorRepository,
    required AudioFeatureRepository audioFeatureRepository,
    required PlaylistRepository playlistRepository,
    Uuid? uuid,
    math.Random? random,
  })  : _trackRepo = trackRepository,
        _behaviorRepo = behaviorRepository,
        _featureRepo = audioFeatureRepository,
        _playlistRepo = playlistRepository,
        _uuid = uuid ?? const Uuid(),
        _random = random ?? math.Random();

  final MusicRepository _trackRepo;
  final BehaviorRepository _behaviorRepo;
  final AudioFeatureRepository _featureRepo;
  final PlaylistRepository _playlistRepo;
  final Uuid _uuid;
  final math.Random _random;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Builds (and persists) one daily mix.
  Future<Playlist> generateDailyMix({
    required String mixName,
    required MixMood mood,
    int trackCount = 30,
  }) async {
    final tracks = await _trackRepo.getAllTracks();
    if (tracks.isEmpty) {
      throw const MixGenerationError('Library is empty');
    }

    final features = await _featureRepo.getAllFeatures();
    final analysed = tracks.where((t) {
      final f = features[t.id];
      return f != null && f.isAnalysed;
    }).toList();

    if (analysed.length < kSmartMixMinTracks) {
      throw MixGenerationError(
        'Need at least $kSmartMixMinTracks analysed tracks to build a mix '
        '(have ${analysed.length}). Run the audio analyzer first.',
      );
    }

    final anchors = await _selectAnchors(analysed, features, mood);
    final selected = _expandAndDiversify(
      anchors: anchors,
      candidates: analysed,
      features: features,
      target: trackCount.clamp(kSmartMixMinTracks, kSmartMixMaxTracks),
    );
    final ordered = _sequence(selected, anchors, features, mood);

    return _persist(
      name: mixName,
      mood: mood,
      tracks: ordered,
      description: _moodDescription(mood),
    );
  }

  /// Builds one mix per mood. A mood that cannot be built is skipped rather
  /// than failing the whole batch.
  Future<List<Playlist>> generateAllDailyMixes() async {
    final out = <Playlist>[];
    for (final mood in MixMood.values) {
      try {
        out.add(await generateDailyMix(
          mixName: _moodDisplayName(mood),
          mood: mood,
        ));
      } on MixGenerationError {
        // Not enough material for this mood today — keep going.
        continue;
      }
    }
    if (out.isEmpty) {
      throw const MixGenerationError('No mixes could be generated');
    }
    return out;
  }

  /// An endless-feeling mix radiating out from one seed track.
  Future<Playlist> generateInfiniteMixtape({
    required String seedTrackId,
    int trackCount = 50,
  }) async {
    final seed = await _trackRepo.getTrackById(seedTrackId);
    if (seed == null) {
      throw MixGenerationError('Seed track $seedTrackId not found');
    }

    final tracks = await _trackRepo.getAllTracks();
    final features = await _featureRepo.getAllFeatures();
    final seedFeatures = features[seedTrackId];
    if (seedFeatures == null || !seedFeatures.isAnalysed) {
      throw MixGenerationError('Seed track has not been analysed yet');
    }

    final candidates =
        tracks.where((t) => features[t.id]?.isAnalysed ?? false).toList();

    // Walk outward: each step picks the nearest unused neighbour of the
    // current track, so the mix drifts gradually instead of jumping around.
    final selected = <Track>[seed];
    final used = <String>{seed.id};
    final perArtist = <String, int>{seed.artistId: 1};
    final perAlbum = <String, int>{seed.albumId: 1};

    var current = seedFeatures;
    final limit = trackCount.clamp(1, kSmartMixMaxTracks * 2);

    while (selected.length < limit) {
      Track? best;
      var bestScore = -1.0;

      for (final t in candidates) {
        if (used.contains(t.id)) continue;
        if ((perArtist[t.artistId] ?? 0) >= kMaxTracksPerArtist) continue;
        if ((perAlbum[t.albumId] ?? 0) >= kMaxTracksPerAlbum) continue;

        final f = features[t.id];
        if (f == null) continue;
        final score = cosineSimilarity(
            current.similarityVector, f.similarityVector);
        if (score > bestScore) {
          bestScore = score;
          best = t;
        }
      }

      if (best == null) break; // exhausted the eligible pool
      selected.add(best);
      used.add(best.id);
      perArtist[best.artistId] = (perArtist[best.artistId] ?? 0) + 1;
      perAlbum[best.albumId] = (perAlbum[best.albumId] ?? 0) + 1;
      current = features[best.id]!;
    }

    return _persist(
      name: 'Infinite Mixtape — ${seed.title}',
      mood: null,
      tracks: selected,
      description: 'An endless journey from ${seed.title} by ${seed.artistName}.',
      type: PlaylistType.smartMix,
    );
  }

  /// True when [playlist] should be rebuilt (older than [kMixStaleAfter]).
  static bool isStale(Playlist playlist, {DateTime? now}) {
    final at = (now ?? DateTime.now()).millisecondsSinceEpoch;
    return at - playlist.updatedAtMs > kMixStaleAfter.inMilliseconds;
  }

  /// Regenerates every daily mix that has gone stale. Returns what it rebuilt.
  Future<List<Playlist>> regenerateStaleMixes({DateTime? now}) async {
    final existing = await _playlistRepo.getAllPlaylists();
    final mixes =
        existing.where((p) => p.type == PlaylistType.smartMix).toList();

    // Nothing built yet — do a full run.
    if (mixes.isEmpty) return generateAllDailyMixes();

    final stale = mixes.where((p) => isStale(p, now: now)).toList();
    if (stale.isEmpty) return const [];

    final out = <Playlist>[];
    for (final mix in stale) {
      final mood = mix.mood;
      if (mood == null) continue; // infinite mixtapes aren't on a schedule
      try {
        out.add(await generateDailyMix(mixName: mix.name, mood: mood));
      } on MixGenerationError {
        continue;
      }
    }
    return out;
  }

  // ── 1. Anchor selection ────────────────────────────────────────────────────

  /// Top recent plays, filtered toward the mood, then one anchor per k-means
  /// cluster so the mix starts from genuinely different places.
  Future<List<Track>> _selectAnchors(
    List<Track> analysed,
    Map<String, AudioFeatures> features,
    MixMood mood,
  ) async {
    final byId = {for (final t in analysed) t.id: t};

    // Most-played over the lookback window.
    final topIds = await _behaviorRepo.getTopPlayedTrackIds(
      topN: kAnchorCandidatePool,
      days: kAnchorLookbackDays,
    );
    var pool = [
      for (final id in topIds)
        if (byId.containsKey(id)) byId[id]!,
    ];

    // Cold start (no history yet): fall back to the library's own play counts.
    if (pool.length < 3) {
      final byPlays = List<Track>.from(analysed)
        ..sort((a, b) => b.playCount.compareTo(a.playCount));
      pool = byPlays.take(kAnchorCandidatePool).toList();
    }

    // Keep the half that best matches the mood, but never starve the clusterer.
    final profile = MoodProfile.of(mood);
    pool.sort((a, b) {
      final da = _moodDistance(features[a.id]!, profile);
      final db = _moodDistance(features[b.id]!, profile);
      return da.compareTo(db);
    });
    final keep = math.max(3, (pool.length * 0.6).round());
    pool = pool.take(keep).toList();

    final k = pool.length.clamp(3, kKMeansClusters);
    final clusters = _kMeans(pool, features, k);

    // One anchor per cluster: the member closest to its centroid.
    final anchors = <Track>[];
    for (final cluster in clusters) {
      if (cluster.members.isEmpty) continue;
      Track? best;
      var bestDist = double.infinity;
      for (final t in cluster.members) {
        final d = _distance(
            _clusterVector(features[t.id]!), cluster.centroid);
        if (d < bestDist) {
          bestDist = d;
          best = t;
        }
      }
      if (best != null) anchors.add(best);
    }
    return anchors.isEmpty ? pool.take(1).toList() : anchors;
  }

  /// Lloyd's algorithm with k-means++ seeding over [energy, valence, tempo].
  List<_Cluster> _kMeans(
    List<Track> tracks,
    Map<String, AudioFeatures> features,
    int k,
  ) {
    if (tracks.isEmpty) return const [];
    final vectors = {
      for (final t in tracks) t.id: _clusterVector(features[t.id]!),
    };

    var centroids = _kMeansPlusPlusInit(tracks, vectors, k);
    var assignment = <String, int>{};

    for (int iter = 0; iter < kKMeansMaxIterations; iter++) {
      final next = <String, int>{};
      for (final t in tracks) {
        var bestIdx = 0;
        var bestDist = double.infinity;
        for (int c = 0; c < centroids.length; c++) {
          final d = _distance(vectors[t.id]!, centroids[c]);
          if (d < bestDist) {
            bestDist = d;
            bestIdx = c;
          }
        }
        next[t.id] = bestIdx;
      }

      // Recompute centroids.
      final sums = List.generate(centroids.length, (_) => <List<double>>[]);
      for (final entry in next.entries) {
        sums[entry.value].add(vectors[entry.key]!);
      }
      final moved = <List<double>>[];
      var shift = 0.0;
      for (int c = 0; c < centroids.length; c++) {
        final m = sums[c].isEmpty ? centroids[c] : _mean(sums[c]);
        shift += _distance(m, centroids[c]);
        moved.add(m);
      }
      centroids = moved;
      assignment = next;

      if (shift < kKMeansConvergenceThreshold) break;
    }

    final clusters = [
      for (final c in centroids) _Cluster(c, <Track>[]),
    ];
    for (final t in tracks) {
      final idx = assignment[t.id];
      if (idx != null && idx < clusters.length) clusters[idx].members.add(t);
    }
    return clusters;
  }

  List<List<double>> _kMeansPlusPlusInit(
    List<Track> tracks,
    Map<String, List<double>> vectors,
    int k,
  ) {
    final centroids = <List<double>>[];
    centroids.add(List<double>.from(vectors[tracks[_random.nextInt(tracks.length)].id]!));

    while (centroids.length < k) {
      // Pick the point furthest from any chosen centroid (D² seeding).
      var bestDist = -1.0;
      List<double>? bestVec;
      for (final t in tracks) {
        final v = vectors[t.id]!;
        var nearest = double.infinity;
        for (final c in centroids) {
          nearest = math.min(nearest, _distance(v, c));
        }
        if (nearest > bestDist) {
          bestDist = nearest;
          bestVec = v;
        }
      }
      if (bestVec == null) break;
      centroids.add(List<double>.from(bestVec));
    }
    return centroids;
  }

  // ── 2 + 3. Expansion and diversity ─────────────────────────────────────────

  /// Grows each anchor into a cluster of similar tracks, then interleaves the
  /// clusters while enforcing the artist/album caps.
  List<Track> _expandAndDiversify({
    required List<Track> anchors,
    required List<Track> candidates,
    required Map<String, AudioFeatures> features,
    required int target,
  }) {
    final anchorIds = anchors.map((a) => a.id).toSet();

    // Per-anchor ranked neighbours above the similarity threshold.
    final perAnchor = <List<Track>>[];
    for (final anchor in anchors) {
      final af = features[anchor.id]!;
      final scored = <MapEntry<Track, double>>[];
      for (final t in candidates) {
        if (t.id == anchor.id || anchorIds.contains(t.id)) continue;
        final f = features[t.id];
        if (f == null) continue;
        final sim =
            cosineSimilarity(af.similarityVector, f.similarityVector);
        if (sim >= kSimilarityThreshold) scored.add(MapEntry(t, sim));
      }
      scored.sort((a, b) => b.value.compareTo(a.value));
      perAnchor.add([for (final e in scored) e.key]);
    }

    final selected = <Track>[];
    final used = <String>{};
    final perArtist = <String, int>{};
    final perAlbum = <String, int>{};

    bool tryAdd(Track t) {
      if (used.contains(t.id)) return false;
      if ((perArtist[t.artistId] ?? 0) >= kMaxTracksPerArtist) return false;
      if ((perAlbum[t.albumId] ?? 0) >= kMaxTracksPerAlbum) return false;
      selected.add(t);
      used.add(t.id);
      perArtist[t.artistId] = (perArtist[t.artistId] ?? 0) + 1;
      perAlbum[t.albumId] = (perAlbum[t.albumId] ?? 0) + 1;
      return true;
    }

    // Anchors first — they are guaranteed members.
    for (final a in anchors) {
      if (selected.length >= target) break;
      tryAdd(a);
    }

    // Round-robin across clusters so no single anchor dominates.
    final cursors = List<int>.filled(perAnchor.length, 0);
    var progressed = true;
    while (selected.length < target && progressed) {
      progressed = false;
      for (int c = 0; c < perAnchor.length && selected.length < target; c++) {
        final list = perAnchor[c];
        while (cursors[c] < list.length) {
          final t = list[cursors[c]++];
          if (tryAdd(t)) {
            progressed = true;
            break;
          }
        }
      }
    }

    // Still short (sparse features / tight caps): top up with the closest
    // remaining tracks so the mix reaches a usable length.
    if (selected.length < kSmartMixMinTracks && anchors.isNotEmpty) {
      final af = features[anchors.first.id]!;
      final rest = candidates.where((t) => !used.contains(t.id)).toList()
        ..sort((a, b) {
          final sa = cosineSimilarity(
              af.similarityVector, features[a.id]!.similarityVector);
          final sb = cosineSimilarity(
              af.similarityVector, features[b.id]!.similarityVector);
          return sb.compareTo(sa);
        });
      for (final t in rest) {
        if (selected.length >= target) break;
        tryAdd(t);
      }
    }
    return selected;
  }

  // ── 4. Sequencing ──────────────────────────────────────────────────────────

  /// Orders the mix for smooth transitions: anchors bookend it, and each step
  /// prefers a harmonically compatible key with a BPM that follows the mood's
  /// curve (rising for workout/morning, falling for chill/evening).
  List<Track> _sequence(
    List<Track> selected,
    List<Track> anchors,
    Map<String, AudioFeatures> features,
    MixMood mood,
  ) {
    if (selected.length <= 2) return selected;

    final profile = MoodProfile.of(mood);
    final pool = List<Track>.from(selected);

    // Bookends: the first anchor opens, a different anchor closes.
    Track opener = pool.first;
    for (final a in anchors) {
      if (pool.any((t) => t.id == a.id)) {
        opener = a;
        break;
      }
    }
    pool.removeWhere((t) => t.id == opener.id);

    Track? closer;
    for (final a in anchors.reversed) {
      if (a.id != opener.id && pool.any((t) => t.id == a.id)) {
        closer = a;
        break;
      }
    }
    if (closer != null) pool.removeWhere((t) => t.id == closer!.id);

    final ordered = <Track>[opener];
    var current = features[opener.id]!;
    final total = pool.length;

    while (pool.isNotEmpty) {
      // Where we should be on the BPM curve at this point in the mix.
      final progress = total == 0 ? 0.0 : ordered.length / (total + 1);
      final targetTempo = profile.bpmRising
          ? profile.tempo + (0.25 * progress)
          : profile.tempo - (0.20 * progress);

      Track? best;
      var bestScore = -double.infinity;
      for (final t in pool) {
        final f = features[t.id]!;
        final score = _transitionScore(current, f, targetTempo);
        if (score > bestScore) {
          bestScore = score;
          best = t;
        }
      }
      best ??= pool.first;
      ordered.add(best);
      pool.removeWhere((t) => t.id == best!.id);
      current = features[best.id]!;
    }

    if (closer != null) ordered.add(closer);
    return ordered;
  }

  /// Higher is a smoother move: key compatibility, closeness to the target
  /// tempo, and a small penalty for big energy jumps.
  double _transitionScore(
      AudioFeatures from, AudioFeatures to, double targetTempo) {
    var score = 0.0;

    final a = from.camelot;
    final b = to.camelot;
    // Unknown keys score neutrally so unanalysed libraries still sequence.
    score += 0.5 * (a != null && b != null ? a.compatibilityScore(b) : 0.5);

    score += 0.35 * (1.0 - (to.tempo - targetTempo).abs()).clamp(0.0, 1.0);
    score += 0.15 * (1.0 - (to.energy - from.energy).abs()).clamp(0.0, 1.0);
    return score;
  }

  // ── 5. Persistence ─────────────────────────────────────────────────────────

  Future<Playlist> _persist({
    required String name,
    required MixMood? mood,
    required List<Track> tracks,
    required String description,
    PlaylistType type = PlaylistType.smartMix,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final playlist = Playlist(
      id: _uuid.v4(),
      name: name,
      description: description,
      type: type,
      mood: mood,
      trackIds: [for (final t in tracks) t.id],
      createdAtMs: now,
      updatedAtMs: now,
      coverArtPaths: _coverMosaic(tracks),
      coverArtPath: tracks.isEmpty ? null : tracks.first.coverArtPath,
    );
    await _playlistRepo.upsertSmartMix(playlist);
    return playlist;
  }

  /// Up to four distinct album arts for the 2x2 cover the UI composites.
  static List<String> _coverMosaic(List<Track> tracks) {
    final seenAlbums = <String>{};
    final paths = <String>[];
    for (final t in tracks) {
      final art = t.coverArtPath;
      if (art == null || art.isEmpty) continue;
      if (!seenAlbums.add(t.albumId)) continue;
      paths.add(art);
      if (paths.length == 4) break;
    }
    return paths;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static List<double> _clusterVector(AudioFeatures f) =>
      [f.energy, f.valence, f.tempo];

  static double _moodDistance(AudioFeatures f, MoodProfile profile) =>
      _distance(_clusterVector(f), profile.clusterVector);

  static double _distance(List<double> a, List<double> b) {
    var sum = 0.0;
    final n = math.min(a.length, b.length);
    for (int i = 0; i < n; i++) {
      final d = a[i] - b[i];
      sum += d * d;
    }
    return math.sqrt(sum);
  }

  static List<double> _mean(List<List<double>> vectors) {
    if (vectors.isEmpty) return const [];
    final out = List<double>.filled(vectors.first.length, 0.0);
    for (final v in vectors) {
      for (int i = 0; i < out.length && i < v.length; i++) {
        out[i] += v[i];
      }
    }
    for (int i = 0; i < out.length; i++) {
      out[i] /= vectors.length;
    }
    return out;
  }

  static String _moodDisplayName(MixMood mood) => switch (mood) {
        MixMood.morning => 'Morning Lift',
        MixMood.workout => 'Workout Surge',
        MixMood.chill => 'Chill Current',
        MixMood.focus => 'Deep Focus',
        MixMood.evening => 'Evening Glow',
      };

  static String _moodDescription(MixMood mood) => switch (mood) {
        MixMood.morning => 'Bright, building energy to start the day.',
        MixMood.workout => 'High tempo, high drive — keep moving.',
        MixMood.chill => 'Slow, warm and unhurried.',
        MixMood.focus => 'Steady and low-distraction for deep work.',
        MixMood.evening => 'Winding down as the light goes.',
      };
}

class _Cluster {
  _Cluster(this.centroid, this.members);
  final List<double> centroid;
  final List<Track> members;
}
