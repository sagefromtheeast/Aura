/**
 * crossfade.h
 * Aura — Equal-power crossfade between two tracks.
 *
 * Uses sin/cos (constant-power) curves rather than a linear ramp so perceived
 * loudness stays steady through the transition. PRD §6.1: crossfade 0-12s.
 */

#pragma once

#include <cstddef>
#include <cstdint>

namespace aura {

/// Maximum crossfade length the UI allows.
inline constexpr int kMaxCrossfadeMs = 12000;

class Crossfade {
public:
    Crossfade() = default;

    /// Sets the fade duration. 0 disables crossfading (hard cut / gapless).
    void setDurationMs(int fadeMs, double sampleRate);

    int durationMs() const { return fadeMs_; }
    bool enabled() const { return fadeMs_ > 0; }

    /// Frames the fade spans at the configured sample rate.
    std::size_t durationFrames() const { return frames_; }

    /// Gain applied to the outgoing track at normalised progress [0,1].
    /// 1.0 at t=0 → 0.0 at t=1.
    static double fadeOutGain(double t);

    /// Gain applied to the incoming track at normalised progress [0,1].
    /// 0.0 at t=0 → 1.0 at t=1.
    static double fadeInGain(double t);

    /// Mixes [incoming] into [outgoing] over the fade, writing to [outgoing].
    /// [startFrame] is how far into the fade this buffer begins.
    /// Both buffers are interleaved float PCM of the same layout.
    void mix(float* outgoing,
             const float* incoming,
             std::size_t frameCount,
             int channels,
             std::size_t startFrame) const;

private:
    int fadeMs_ = 0;
    std::size_t frames_ = 0;
};

}  // namespace aura
