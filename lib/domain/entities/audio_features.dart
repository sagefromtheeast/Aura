// lib/domain/entities/audio_features.dart
// Aura — Per-track acoustic features extracted by the C++ analyzer.
//
// Plain immutable class (not freezed) so it stays dependency-free and needs no
// codegen: it is a straight mapping of the audio_features table.

import 'dart:math' as math;

import 'camelot.dart';

/// Number of dimensions in [AudioFeatures.similarityVector].
const int kSimilarityDimensions = 6;

class AudioFeatures {
  const AudioFeatures({
    required this.trackId,
    this.tempo = 0.0,
    this.energy = 0.0,
    this.valence = 0.0,
    this.danceability = 0.0,
    this.loudness = 0.0,
    this.acousticness = 0.0,
    this.musicalKey = -1,
    this.keyName = '',
  });

  final String trackId;

  /// Normalised 0-1 (the analyzer maps ~200 BPM to 1.0).
  final double tempo;
  final double energy;
  final double valence;
  final double danceability;
  final double loudness;
  final double acousticness;

  /// Pitch class 0-11 (C..B), or -1 when the analyzer hasn't run.
  final int musicalKey;

  /// Human-readable key ("A minor"), empty when unknown.
  final String keyName;

  /// True once the analyzer has produced usable values.
  bool get isAnalysed =>
      tempo > 0 || energy > 0 || valence > 0 || danceability > 0;

  bool get hasKey => musicalKey >= 0 && musicalKey <= 11;

  /// Camelot position, or null when the key is unknown.
  CamelotKey? get camelot =>
      hasKey ? CamelotKey.fromPitchClass(musicalKey, minor: _looksMinor) : null;

  bool get _looksMinor => keyName.toLowerCase().contains('min');

  /// Feature vector used for cosine similarity, per the Smart Mix spec:
  /// [energy, valence, danceability, acousticness, tempo, key].
  ///
  /// Key is folded onto the unit interval so it contributes without dominating;
  /// an unknown key contributes a neutral 0.5.
  List<double> get similarityVector => [
        energy,
        valence,
        danceability,
        acousticness,
        tempo,
        hasKey ? musicalKey / 11.0 : 0.5,
      ];

  /// Approximate BPM, undoing the analyzer's 0-1 normalisation.
  double get bpm => tempo * 200.0;

  AudioFeatures copyWith({
    double? tempo,
    double? energy,
    double? valence,
    double? danceability,
    double? loudness,
    double? acousticness,
    int? musicalKey,
    String? keyName,
  }) {
    return AudioFeatures(
      trackId: trackId,
      tempo: tempo ?? this.tempo,
      energy: energy ?? this.energy,
      valence: valence ?? this.valence,
      danceability: danceability ?? this.danceability,
      loudness: loudness ?? this.loudness,
      acousticness: acousticness ?? this.acousticness,
      musicalKey: musicalKey ?? this.musicalKey,
      keyName: keyName ?? this.keyName,
    );
  }
}

/// Cosine similarity between two equal-length vectors, in [0, 1] for
/// non-negative inputs. Returns 0 when either vector has no magnitude.
double cosineSimilarity(List<double> a, List<double> b) {
  if (a.length != b.length || a.isEmpty) return 0.0;
  var dot = 0.0, magA = 0.0, magB = 0.0;
  for (int i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    magA += a[i] * a[i];
    magB += b[i] * b[i];
  }
  if (magA <= 0 || magB <= 0) return 0.0;
  return dot / (math.sqrt(magA) * math.sqrt(magB));
}
