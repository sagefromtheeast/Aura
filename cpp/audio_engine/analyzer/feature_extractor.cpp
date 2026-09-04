/**
 * feature_extractor.cpp
 * Aura — Heuristic audio feature extraction.
 *
 * Ported from the original native/src/audio_engine.cpp implementation and
 * decoupled from miniaudio so the maths is unit-testable on synthetic PCM.
 */

#include "feature_extractor.h"

#include <algorithm>
#include <cmath>
#include <vector>

#include "../decoder/decoder.h"

namespace aura {
namespace {
inline float clamp01f(double v) {
    return static_cast<float>(v < 0.0 ? 0.0 : (v > 1.0 ? 1.0 : v));
}
}  // namespace

bool FeatureExtractor::extract(const float* mono,
                               std::size_t frameCount,
                               double sampleRate,
                               float* outFeatures,
                               int outCount) {
    if (mono == nullptr || outFeatures == nullptr) return false;
    if (frameCount == 0 || outCount < kFeatureCount) return false;
    if (sampleRate <= 0.0) return false;

    double sumSq = 0.0;
    std::size_t zeroCrossings = 0;

    // Onset counting over ~100ms windows of the amplitude envelope.
    const std::size_t windowSize =
        std::max<std::size_t>(1, static_cast<std::size_t>(sampleRate * 0.1));
    double windowEnergy = 0.0;
    double prevEnvelope = 0.0;
    std::size_t beatCount = 0;

    for (std::size_t i = 0; i < frameCount; ++i) {
        const double s = mono[i];
        sumSq += s * s;

        if (i > 0) {
            const bool up = (mono[i] >= 0.0f && mono[i - 1] < 0.0f);
            const bool down = (mono[i] < 0.0f && mono[i - 1] >= 0.0f);
            if (up || down) ++zeroCrossings;
        }

        windowEnergy += s * s;
        if (i > 0 && (i % windowSize) == 0) {
            const double envelope = std::sqrt(windowEnergy / static_cast<double>(windowSize));
            if (envelope - prevEnvelope > 0.05) ++beatCount;
            prevEnvelope = envelope;
            windowEnergy = 0.0;
        }
    }

    const double rms = std::sqrt(sumSq / static_cast<double>(frameCount));
    const double zcr = static_cast<double>(zeroCrossings) / static_cast<double>(frameCount);
    const double durationSec = static_cast<double>(frameCount) / sampleRate;

    // Normalised heuristics, capped to [0,1].
    const double bpm = (durationSec > 0.0)
                           ? (static_cast<double>(beatCount) / durationSec) * 60.0
                           : 0.0;
    const float tempo = clamp01f(bpm / 200.0);          // 200 BPM => 1.0
    const float loudness = clamp01f(rms * 4.0);
    const float energy = clamp01f(rms * 5.0 + tempo * 0.5);
    const float acousticness = clamp01f(1.0 - zcr * 10.0);
    const float danceability = clamp01f(tempo * 0.8 + energy * 0.2);
    const float valence = clamp01f(energy * 0.6 + (1.0 - acousticness) * 0.4);

    outFeatures[0] = tempo;
    outFeatures[1] = energy;
    outFeatures[2] = valence;
    outFeatures[3] = danceability;
    outFeatures[4] = loudness;
    outFeatures[5] = acousticness;
    return true;
}

int FeatureExtractor::extractFromFile(const char* path, float* outFeatures, int outCount) {
    if (path == nullptr || outFeatures == nullptr) return -1;
    if (outCount < kFeatureCount) return -1;

    auto decoder = Decoder::open(path, kAnalysisSampleRate, /*channels=*/1);
    if (!decoder) return -2;

    const std::size_t maxFrames =
        static_cast<std::size_t>(kAnalysisSampleRate) * kAnalysisMaxSeconds;
    std::vector<float> pcm(maxFrames, 0.0f);

    const std::size_t read = decoder->read(pcm.data(), maxFrames);
    if (read == 0) return -2;

    return extract(pcm.data(), read, kAnalysisSampleRate, outFeatures, outCount) ? 0 : -2;
}

}  // namespace aura
