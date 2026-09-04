/**
 * feature_extractor.h
 * Aura — Audio feature extraction for Smart Mixes / mood clustering.
 *
 * Feature vector layout (must match kAudioFeatureDimension and the
 * audio_features Drift table):
 *   [0] tempo         normalised BPM (0..1, 200 BPM = 1.0)
 *   [1] energy        0..1
 *   [2] valence       0..1
 *   [3] danceability  0..1
 *   [4] loudness      0..1 (mapped from RMS)
 *   [5] acousticness  0..1
 *
 * The core routine works on raw mono PCM so it can be unit-tested without a
 * decoder; extractFromFile() wires it to the Decoder layer.
 */

#pragma once

#include <cstddef>

namespace aura {

/// Number of features produced. Mirrors kAudioFeatureDimension in Dart.
inline constexpr int kFeatureCount = 6;

/// Sample rate the analyser downmixes to before measuring.
inline constexpr int kAnalysisSampleRate = 22050;

/// Seconds of audio analysed at most.
inline constexpr int kAnalysisMaxSeconds = 30;

class FeatureExtractor {
public:
    /// Analyses mono float PCM in [-1,1].
    /// Writes exactly kFeatureCount floats to [outFeatures].
    /// Returns false when the input is empty or [outCount] is too small.
    static bool extract(const float* mono,
                        std::size_t frameCount,
                        double sampleRate,
                        float* outFeatures,
                        int outCount);

    /// Decodes [path] to mono @ kAnalysisSampleRate and analyses it.
    /// Returns 0 on success, -1 on bad args, -2 when the file cannot be read.
    static int extractFromFile(const char* path, float* outFeatures, int outCount);
};

}  // namespace aura
