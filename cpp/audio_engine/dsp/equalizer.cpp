/**
 * equalizer.cpp
 * Aura — 10-band peaking EQ (RBJ Audio EQ Cookbook).
 */

#include "equalizer.h"

#include <algorithm>
#include <cmath>
#include <complex>

namespace aura {
namespace {

constexpr double kPi = 3.14159265358979323846;

/// ISO octave centres matching the UI's frequency labels.
constexpr double kCentres[kEqBandCount] = {
    32.0, 64.0, 125.0, 250.0, 500.0, 1000.0, 2000.0, 4000.0, 8000.0, 16000.0,
};

/// Preset curves in dB. Mirrors kEqPresets in settings_providers.dart.
constexpr double kPresets[5][kEqBandCount] = {
    /* Flat      */ {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    /* Rock      */ {5, 4, 2, 0, -1, -1, 1, 3, 4, 4},
    /* Pop       */ {-1, 1, 3, 4, 4, 2, 0, -1, -1, -1},
    /* Jazz      */ {3, 2, 1, 2, -1, -1, 0, 1, 2, 3},
    /* Classical */ {4, 3, 2, 0, -1, -1, 0, 2, 3, 4},
};

inline double clampd(double v, double lo, double hi) {
    return v < lo ? lo : (v > hi ? hi : v);
}

}  // namespace

// ── Biquad ────────────────────────────────────────────────────────────────────

void Biquad::setPeaking(double sampleRate, double freqHz, double gainDb, double q) {
    // Guard against Nyquist and degenerate Q.
    const double nyquist = sampleRate * 0.5;
    freqHz = clampd(freqHz, 10.0, nyquist * 0.99);
    q = clampd(q, 0.1, 10.0);

    const double A = std::pow(10.0, gainDb / 40.0);
    const double w0 = 2.0 * kPi * freqHz / sampleRate;
    const double cosw0 = std::cos(w0);
    const double alpha = std::sin(w0) / (2.0 * q);

    const double b0n = 1.0 + alpha * A;
    const double b1n = -2.0 * cosw0;
    const double b2n = 1.0 - alpha * A;
    const double a0n = 1.0 + alpha / A;
    const double a1n = -2.0 * cosw0;
    const double a2n = 1.0 - alpha / A;

    b0 = b0n / a0n;
    b1 = b1n / a0n;
    b2 = b2n / a0n;
    a1 = a1n / a0n;
    a2 = a2n / a0n;
}

void Biquad::reset() {
    b0 = 1.0;
    b1 = b2 = a1 = a2 = 0.0;
    clearState();
}

void Biquad::clearState() {
    for (int c = 0; c < kMaxChannels; ++c) {
        x1[c] = x2[c] = y1[c] = y2[c] = 0.0;
    }
}

double Biquad::processSample(double in, int channel) {
    const double out =
        b0 * in + b1 * x1[channel] + b2 * x2[channel] - a1 * y1[channel] - a2 * y2[channel];
    x2[channel] = x1[channel];
    x1[channel] = in;
    y2[channel] = y1[channel];
    y1[channel] = out;
    return out;
}

double Biquad::magnitudeAt(double sampleRate, double freqHz) const {
    // H(e^jw) = (b0 + b1 z^-1 + b2 z^-2) / (1 + a1 z^-1 + a2 z^-2)
    const double w = 2.0 * kPi * freqHz / sampleRate;
    const std::complex<double> z1 = std::polar(1.0, -w);
    const std::complex<double> z2 = std::polar(1.0, -2.0 * w);
    const std::complex<double> num = b0 + b1 * z1 + b2 * z2;
    const std::complex<double> den = 1.0 + a1 * z1 + a2 * z2;
    return std::abs(num / den);
}

// ── Equalizer ─────────────────────────────────────────────────────────────────

Equalizer::Equalizer(double sampleRate) : sampleRate_(sampleRate) {
    for (int i = 0; i < kEqBandCount; ++i) {
        qs_[i] = 1.0;
        gains_[i] = 0.0;
        bands_[i].reset();
    }
}

void Equalizer::setSampleRate(double sampleRate) {
    if (sampleRate <= 0.0 || sampleRate == sampleRate_) return;
    sampleRate_ = sampleRate;
    for (int i = 0; i < kEqBandCount; ++i) {
        // Re-derive coefficients; keep gains. Flat bands stay pass-through.
        if (gains_[i] == 0.0) {
            bands_[i].reset();
        } else {
            bands_[i].setPeaking(sampleRate_, kCentres[i], gains_[i], qs_[i]);
        }
    }
}

void Equalizer::setBand(int band, double gainDb, double q) {
    if (band < 0 || band >= kEqBandCount) return;
    gains_[band] = clampd(gainDb, -24.0, 24.0);
    qs_[band] = clampd(q, 0.1, 10.0);

    if (gains_[band] == 0.0) {
        // Unity: bypass the maths entirely but keep the delay line intact.
        const Biquad saved = bands_[band];
        bands_[band].reset();
        for (int c = 0; c < kMaxChannels; ++c) {
            bands_[band].x1[c] = saved.x1[c];
            bands_[band].x2[c] = saved.x2[c];
            bands_[band].y1[c] = saved.y1[c];
            bands_[band].y2[c] = saved.y2[c];
        }
        return;
    }
    bands_[band].setPeaking(sampleRate_, kCentres[band], gains_[band], qs_[band]);
}

void Equalizer::setPreset(EqPreset preset) {
    const int idx = static_cast<int>(preset);
    if (idx < 0 || idx > 4) return;  // Custom (5) leaves gains untouched.
    for (int i = 0; i < kEqBandCount; ++i) {
        setBand(i, kPresets[idx][i], qs_[i]);
    }
}

void Equalizer::reset() {
    for (int i = 0; i < kEqBandCount; ++i) {
        gains_[i] = 0.0;
        qs_[i] = 1.0;
        bands_[i].reset();
    }
}

void Equalizer::clearState() {
    for (int i = 0; i < kEqBandCount; ++i) {
        bands_[i].clearState();
    }
}

void Equalizer::process(float* buffer, std::size_t frameCount, int channels) {
    if (!enabled_ || buffer == nullptr || channels <= 0) return;
    channels = std::min(channels, kMaxChannels);

    // Skip bands sitting at unity — a flat EQ costs almost nothing.
    int active[kEqBandCount];
    int activeCount = 0;
    for (int i = 0; i < kEqBandCount; ++i) {
        if (gains_[i] != 0.0) active[activeCount++] = i;
    }
    if (activeCount == 0) return;

    for (std::size_t f = 0; f < frameCount; ++f) {
        for (int c = 0; c < channels; ++c) {
            double sample = static_cast<double>(buffer[f * channels + c]);
            for (int a = 0; a < activeCount; ++a) {
                sample = bands_[active[a]].processSample(sample, c);
            }
            buffer[f * channels + c] = static_cast<float>(sample);
        }
    }
}

double Equalizer::magnitudeAt(double freqHz) const {
    double mag = 1.0;
    for (int i = 0; i < kEqBandCount; ++i) {
        if (gains_[i] == 0.0) continue;
        mag *= bands_[i].magnitudeAt(sampleRate_, freqHz);
    }
    return mag;
}

double Equalizer::gainDb(int band) const {
    if (band < 0 || band >= kEqBandCount) return 0.0;
    return gains_[band];
}

double Equalizer::centreFrequency(int band) {
    if (band < 0 || band >= kEqBandCount) return 0.0;
    return kCentres[band];
}

}  // namespace aura
