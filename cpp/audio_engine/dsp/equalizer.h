/**
 * equalizer.h
 * Aura — 10-band parametric equaliser.
 *
 * Implements RBJ "Audio EQ Cookbook" peaking filters, one biquad per band, with
 * independent state per channel so stereo imaging is preserved. Bands are the
 * ISO octave centres the UI labels (32Hz … 16kHz).
 *
 * Real-time safe: process() allocates nothing and takes no locks.
 */

#pragma once

#include <cstddef>

namespace aura {

/// Number of EQ bands. Must match kEqFrequencyLabels on the Dart side.
inline constexpr int kEqBandCount = 10;

/// Maximum channels handled without allocating.
inline constexpr int kMaxChannels = 8;

/// Built-in preset identifiers. Must match kEqPresetOrder in Dart.
enum class EqPreset : int {
    Flat = 0,
    Rock = 1,
    Pop = 2,
    Jazz = 3,
    Classical = 4,
    Custom = 5,
};

/// One direct-form-I biquad section.
struct Biquad {
    // Coefficients (a0-normalised).
    double b0 = 1.0, b1 = 0.0, b2 = 0.0, a1 = 0.0, a2 = 0.0;

    // Per-channel delay lines.
    double x1[kMaxChannels] = {0};
    double x2[kMaxChannels] = {0};
    double y1[kMaxChannels] = {0};
    double y2[kMaxChannels] = {0};

    /// Configures this section as a peaking EQ filter.
    void setPeaking(double sampleRate, double freqHz, double gainDb, double q);

    /// Resets to a pass-through (unity) filter and clears state.
    void reset();

    /// Clears only the delay lines (used on seek / track change).
    void clearState();

    /// Processes one sample on [channel].
    double processSample(double in, int channel);

    /// Magnitude response at [freqHz], for tests and UI curve drawing.
    double magnitudeAt(double sampleRate, double freqHz) const;
};

/// 10-band peaking equaliser.
class Equalizer {
public:
    explicit Equalizer(double sampleRate = 48000.0);

    /// Re-derives every band for a new output rate.
    void setSampleRate(double sampleRate);

    /// Sets one band's gain. [band] 0-9, [gainDb] -12..+12, [q] 0.5..4.0.
    void setBand(int band, double gainDb, double q = 1.0);

    /// Applies a built-in preset (no-op for EqPreset::Custom).
    void setPreset(EqPreset preset);

    /// Flattens all bands to 0 dB.
    void reset();

    /// Clears filter memory without changing gains (seek / new track).
    void clearState();

    /// Enables/disables processing. Disabled = bit-perfect pass-through.
    void setEnabled(bool enabled) { enabled_ = enabled; }
    bool enabled() const { return enabled_; }

    /// Processes interleaved float PCM in place.
    void process(float* buffer, std::size_t frameCount, int channels);

    /// Combined magnitude response of every band at [freqHz]. Tests use this to
    /// prove a boosted band actually boosts.
    double magnitudeAt(double freqHz) const;

    double gainDb(int band) const;
    static double centreFrequency(int band);

private:
    double sampleRate_;
    bool enabled_ = true;
    double gains_[kEqBandCount] = {0};
    double qs_[kEqBandCount];
    Biquad bands_[kEqBandCount];
};

}  // namespace aura
