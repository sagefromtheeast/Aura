/**
 * replay_gain.cpp
 * Aura — ReplayGain normalisation with a soft-knee limiter.
 */

#include "replay_gain.h"

#include <cmath>

namespace aura {

void ReplayGain::setGainDb(double gainDb) {
    // Clamp to a sane range; ReplayGain tags beyond this are almost always bad
    // metadata rather than genuine intent.
    if (gainDb < -24.0) gainDb = -24.0;
    if (gainDb > 24.0) gainDb = 24.0;
    gainDb_ = gainDb;
    linear_ = std::pow(10.0, gainDb / 20.0);
}

void ReplayGain::setLimiterThreshold(double threshold) {
    if (threshold < 0.1) threshold = 0.1;
    if (threshold > 1.0) threshold = 1.0;
    threshold_ = threshold;
}

double ReplayGain::processSample(double sample) const {
    if (!enabled_) return sample;

    double out = sample * linear_;

    // Soft knee above the threshold: compress the overshoot with tanh so loud
    // peaks round off instead of squaring off.
    const double mag = std::fabs(out);
    if (mag > threshold_) {
        const double over = mag - threshold_;
        const double headroom = 1.0 - threshold_;
        const double shaped =
            threshold_ + headroom * std::tanh(over / (headroom > 0.0 ? headroom : 1.0));
        out = (out < 0.0) ? -shaped : shaped;
    }
    return out;
}

void ReplayGain::process(float* buffer, std::size_t frameCount, int channels) {
    if (!enabled_ || buffer == nullptr || channels <= 0) return;
    // Unity gain with nothing to limit: leave the buffer bit-perfect.
    if (gainDb_ == 0.0) return;

    const std::size_t total = frameCount * static_cast<std::size_t>(channels);
    for (std::size_t i = 0; i < total; ++i) {
        buffer[i] = static_cast<float>(processSample(static_cast<double>(buffer[i])));
    }
}

}  // namespace aura
