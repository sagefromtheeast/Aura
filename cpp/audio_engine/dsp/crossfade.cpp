/**
 * crossfade.cpp
 * Aura — Equal-power crossfade curves.
 */

#include "crossfade.h"

#include <algorithm>
#include <cmath>

namespace aura {
namespace {
constexpr double kHalfPi = 1.57079632679489661923;

inline double clamp01(double t) { return t < 0.0 ? 0.0 : (t > 1.0 ? 1.0 : t); }
}  // namespace

void Crossfade::setDurationMs(int fadeMs, double sampleRate) {
    fadeMs_ = std::clamp(fadeMs, 0, kMaxCrossfadeMs);
    frames_ = (sampleRate > 0.0)
                  ? static_cast<std::size_t>((fadeMs_ / 1000.0) * sampleRate)
                  : 0;
}

double Crossfade::fadeOutGain(double t) {
    // cos curve: 1 → 0, with gain^2 summing to 1 against fadeInGain.
    return std::cos(clamp01(t) * kHalfPi);
}

double Crossfade::fadeInGain(double t) {
    return std::sin(clamp01(t) * kHalfPi);
}

void Crossfade::mix(float* outgoing,
                    const float* incoming,
                    std::size_t frameCount,
                    int channels,
                    std::size_t startFrame) const {
    if (outgoing == nullptr || incoming == nullptr || channels <= 0) return;
    if (frames_ == 0) return;

    for (std::size_t f = 0; f < frameCount; ++f) {
        const std::size_t pos = startFrame + f;
        const double t = (pos >= frames_)
                             ? 1.0
                             : static_cast<double>(pos) / static_cast<double>(frames_);
        const double gOut = fadeOutGain(t);
        const double gIn = fadeInGain(t);

        for (int c = 0; c < channels; ++c) {
            const std::size_t i = f * static_cast<std::size_t>(channels) + c;
            outgoing[i] = static_cast<float>(outgoing[i] * gOut + incoming[i] * gIn);
        }
    }
}

}  // namespace aura
