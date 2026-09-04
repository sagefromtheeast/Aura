/**
 * replay_gain.h
 * Aura — ReplayGain volume normalisation.
 *
 * Applies a per-track gain (dB) with an optional soft-knee limiter so that
 * boosting a quiet track cannot clip. Real-time safe.
 */

#pragma once

#include <cstddef>

namespace aura {

class ReplayGain {
public:
    ReplayGain() = default;

    /// Sets the track gain in dB (typically -12 … +12). 0 dB = pass-through.
    void setGainDb(double gainDb);
    double gainDb() const { return gainDb_; }

    /// Linear multiplier currently applied.
    double linearGain() const { return linear_; }

    void setEnabled(bool enabled) { enabled_ = enabled; }
    bool enabled() const { return enabled_; }

    /// Soft-limits anything above this magnitude instead of hard clipping.
    void setLimiterThreshold(double threshold);

    /// Applies gain (and limiting) to interleaved float PCM in place.
    void process(float* buffer, std::size_t frameCount, int channels);

    /// Applies gain + limiter to a single sample. Exposed for tests.
    double processSample(double sample) const;

private:
    double gainDb_ = 0.0;
    double linear_ = 1.0;
    double threshold_ = 0.98;
    bool enabled_ = true;
};

}  // namespace aura
