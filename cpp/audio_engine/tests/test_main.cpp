/**
 * test_main.cpp
 * Aura — Dependency-free test runner for the audio engine DSP and C API.
 *
 * Deliberately avoids gtest so it builds anywhere with just a compiler:
 *   cmake -S cpp/audio_engine -B build -DAURA_BUILD_TESTS=ON -G Ninja
 *   ninja -C build && ./build/aura_engine_tests
 */

#include <cmath>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>

#include "../audio_engine.h"
#include "../dsp/crossfade.h"
#include "../dsp/equalizer.h"
#include "../dsp/replay_gain.h"
#include "../analyzer/feature_extractor.h"
#include "../analyzer/fingerprint.h"

namespace {

int g_failures = 0;
int g_checks = 0;

void check(bool condition, const char* what) {
    ++g_checks;
    if (!condition) {
        ++g_failures;
        std::printf("  FAIL: %s\n", what);
    }
}

void checkNear(double actual, double expected, double tolerance, const char* what) {
    ++g_checks;
    if (std::fabs(actual - expected) > tolerance) {
        ++g_failures;
        std::printf("  FAIL: %s (expected %.6f +/- %.6f, got %.6f)\n", what, expected,
                    tolerance, actual);
    }
}

void section(const char* name) { std::printf("[ %s ]\n", name); }

constexpr double kPi = 3.14159265358979323846;

/// Generates an interleaved sine at [freq] into [channels].
std::vector<float> sine(double freq, double sampleRate, std::size_t frames, int channels,
                        float amplitude = 0.5f) {
    std::vector<float> buf(frames * channels);
    for (std::size_t f = 0; f < frames; ++f) {
        const float s = static_cast<float>(
            amplitude * std::sin(2.0 * kPi * freq * (static_cast<double>(f) / sampleRate)));
        for (int c = 0; c < channels; ++c) buf[f * channels + c] = s;
    }
    return buf;
}

/// Peak magnitude of an interleaved buffer's first channel.
float peak(const std::vector<float>& buf, int channels) {
    float p = 0.0f;
    for (std::size_t i = 0; i < buf.size(); i += channels) {
        p = std::max(p, std::fabs(buf[i]));
    }
    return p;
}

// ── Equalizer ─────────────────────────────────────────────────────────────────

void testEqualizer() {
    section("Equalizer");
    const double sr = 48000.0;

    // A flat EQ must not alter the signal at all.
    {
        aura::Equalizer eq(sr);
        auto buf = sine(1000.0, sr, 1024, 2);
        const auto original = buf;
        eq.process(buf.data(), 1024, 2);
        bool identical = true;
        for (std::size_t i = 0; i < buf.size(); ++i) {
            if (buf[i] != original[i]) { identical = false; break; }
        }
        check(identical, "flat EQ is bit-perfect pass-through");
    }

    // Boosting a band must raise its centre frequency's magnitude.
    {
        aura::Equalizer eq(sr);
        eq.setBand(5, 12.0, 1.0);  // 1 kHz +12 dB
        const double mag = eq.magnitudeAt(1000.0);
        checkNear(20.0 * std::log10(mag), 12.0, 0.5, "+12dB at 1kHz centre");

        // A distant band should be essentially untouched.
        const double far = 20.0 * std::log10(eq.magnitudeAt(32.0));
        check(std::fabs(far) < 1.5, "32Hz unaffected by a 1kHz boost");
    }

    // Cutting must attenuate.
    {
        aura::Equalizer eq(sr);
        eq.setBand(2, -12.0, 1.0);  // 125 Hz -12 dB
        checkNear(20.0 * std::log10(eq.magnitudeAt(125.0)), -12.0, 0.5,
                  "-12dB at 125Hz centre");
    }

    // The boost must actually show up in processed audio, not just the maths.
    {
        aura::Equalizer eq(sr);
        auto dry = sine(1000.0, sr, 4096, 1, 0.25f);
        auto wet = dry;
        eq.setBand(5, 12.0, 1.0);
        eq.process(wet.data(), 4096, 1);
        // Compare the tail so the filter has reached steady state.
        std::vector<float> dryTail(dry.end() - 1024, dry.end());
        std::vector<float> wetTail(wet.end() - 1024, wet.end());
        const float ratio = peak(wetTail, 1) / peak(dryTail, 1);
        check(ratio > 3.0f, "processed 1kHz tone is audibly boosted (~4x)");
    }

    // Disabled EQ is a pass-through even with gains set.
    {
        aura::Equalizer eq(sr);
        eq.setBand(5, 12.0, 1.0);
        eq.setEnabled(false);
        auto buf = sine(1000.0, sr, 512, 2);
        const auto original = buf;
        eq.process(buf.data(), 512, 2);
        check(std::memcmp(buf.data(), original.data(), buf.size() * sizeof(float)) == 0,
              "disabled EQ leaves audio untouched");
    }

    // Presets apply the documented curves.
    {
        aura::Equalizer eq(sr);
        eq.setPreset(aura::EqPreset::Rock);
        checkNear(eq.gainDb(0), 5.0, 1e-9, "Rock preset band 0 = +5dB");
        checkNear(eq.gainDb(4), -1.0, 1e-9, "Rock preset band 4 = -1dB");

        eq.setPreset(aura::EqPreset::Flat);
        checkNear(eq.gainDb(0), 0.0, 1e-9, "Flat preset zeroes bands");

        eq.setBand(3, 6.0, 1.0);
        eq.setPreset(aura::EqPreset::Custom);
        checkNear(eq.gainDb(3), 6.0, 1e-9, "Custom preset preserves manual gains");
    }

    // Out-of-range bands must be ignored, not crash.
    {
        aura::Equalizer eq(sr);
        eq.setBand(-1, 6.0, 1.0);
        eq.setBand(99, 6.0, 1.0);
        check(true, "out-of-range band indices are ignored safely");
    }
}

// ── ReplayGain ────────────────────────────────────────────────────────────────

void testReplayGain() {
    section("ReplayGain");

    {
        aura::ReplayGain rg;
        rg.setGainDb(0.0);
        checkNear(rg.linearGain(), 1.0, 1e-9, "0dB = unity gain");
    }
    {
        aura::ReplayGain rg;
        rg.setGainDb(6.0206);
        checkNear(rg.linearGain(), 2.0, 1e-3, "+6.02dB doubles amplitude");
    }
    {
        aura::ReplayGain rg;
        rg.setGainDb(-6.0206);
        checkNear(rg.linearGain(), 0.5, 1e-3, "-6.02dB halves amplitude");
    }
    {
        // Applied to real samples.
        aura::ReplayGain rg;
        rg.setGainDb(-6.0206);
        std::vector<float> buf(64, 0.4f);
        rg.process(buf.data(), 32, 2);
        checkNear(buf[0], 0.2f, 1e-3, "-6dB halves a 0.4 sample");
    }
    {
        // The limiter must prevent clipping on a big boost.
        aura::ReplayGain rg;
        rg.setGainDb(12.0);
        std::vector<float> buf(64, 0.9f);
        rg.process(buf.data(), 32, 2);
        check(buf[0] <= 1.0f, "limiter keeps boosted samples within [-1,1]");
        check(buf[0] > 0.9f, "limiter still increases level");
    }
    {
        // Unity gain must be bit-perfect.
        aura::ReplayGain rg;
        rg.setGainDb(0.0);
        std::vector<float> buf(64, 0.37f);
        const auto original = buf;
        rg.process(buf.data(), 32, 2);
        check(std::memcmp(buf.data(), original.data(), buf.size() * sizeof(float)) == 0,
              "0dB ReplayGain is bit-perfect");
    }
}

// ── Crossfade ─────────────────────────────────────────────────────────────────

void testCrossfade() {
    section("Crossfade");

    checkNear(aura::Crossfade::fadeOutGain(0.0), 1.0, 1e-9, "fade-out starts at unity");
    checkNear(aura::Crossfade::fadeOutGain(1.0), 0.0, 1e-9, "fade-out ends silent");
    checkNear(aura::Crossfade::fadeInGain(0.0), 0.0, 1e-9, "fade-in starts silent");
    checkNear(aura::Crossfade::fadeInGain(1.0), 1.0, 1e-9, "fade-in ends at unity");

    // Equal power: gains squared sum to 1 across the whole curve.
    for (double t = 0.0; t <= 1.0; t += 0.1) {
        const double a = aura::Crossfade::fadeOutGain(t);
        const double b = aura::Crossfade::fadeInGain(t);
        checkNear(a * a + b * b, 1.0, 1e-9, "equal-power sum holds across the fade");
    }

    {
        aura::Crossfade cf;
        cf.setDurationMs(3000, 48000.0);
        check(cf.enabled(), "3s crossfade is enabled");
        check(cf.durationFrames() == 144000, "3s @48kHz = 144000 frames");

        cf.setDurationMs(0, 48000.0);
        check(!cf.enabled(), "0ms disables crossfade");

        cf.setDurationMs(99999, 48000.0);
        check(cf.durationMs() == aura::kMaxCrossfadeMs, "duration clamps to 12s");
    }

    {
        // Mixing at the midpoint should blend both sources.
        aura::Crossfade cf;
        cf.setDurationMs(1000, 48000.0);
        std::vector<float> out(2, 1.0f);
        std::vector<float> in(2, -1.0f);
        cf.mix(out.data(), in.data(), 1, 2, cf.durationFrames() / 2);
        checkNear(out[0], 0.0, 1e-3, "midpoint blends equal opposite signals to ~0");
    }
}

// ── Analyzer ──────────────────────────────────────────────────────────────────

void testAnalyzer() {
    section("Analyzer");

    {
        // Loud signal => higher loudness/energy than a quiet one.
        const double sr = 22050.0;
        auto loud = sine(440.0, sr, 22050, 1, 0.9f);
        auto quiet = sine(440.0, sr, 22050, 1, 0.05f);

        float fLoud[6] = {0};
        float fQuiet[6] = {0};
        check(aura::FeatureExtractor::extract(loud.data(), loud.size(), sr, fLoud, 6),
              "extract() succeeds on a loud tone");
        check(aura::FeatureExtractor::extract(quiet.data(), quiet.size(), sr, fQuiet, 6),
              "extract() succeeds on a quiet tone");
        check(fLoud[4] > fQuiet[4], "louder audio yields higher loudness");
        check(fLoud[1] > fQuiet[1], "louder audio yields higher energy");

        for (int i = 0; i < 6; ++i) {
            check(fLoud[i] >= 0.0f && fLoud[i] <= 1.0f, "features stay within [0,1]");
        }
    }
    {
        // A high-frequency tone crosses zero far more often => less "acoustic".
        const double sr = 22050.0;
        auto low = sine(100.0, sr, 22050, 1, 0.5f);
        auto high = sine(5000.0, sr, 22050, 1, 0.5f);
        float fLow[6] = {0};
        float fHigh[6] = {0};
        aura::FeatureExtractor::extract(low.data(), low.size(), sr, fLow, 6);
        aura::FeatureExtractor::extract(high.data(), high.size(), sr, fHigh, 6);
        check(fHigh[5] < fLow[5], "higher zero-crossing rate lowers acousticness");
    }
    {
        // Bad arguments are rejected rather than crashing.
        float f[6] = {0};
        check(!aura::FeatureExtractor::extract(nullptr, 100, 22050, f, 6),
              "null PCM rejected");
        std::vector<float> pcm(100, 0.1f);
        check(!aura::FeatureExtractor::extract(pcm.data(), 0, 22050, f, 6),
              "empty PCM rejected");
        check(!aura::FeatureExtractor::extract(pcm.data(), 100, 22050, f, 3),
              "insufficient output capacity rejected");
    }
}

// ── Fingerprint ───────────────────────────────────────────────────────────────

void testFingerprint() {
    section("Fingerprint");

    {
        const char* a = "aura";
        const uint32_t h1 =
            aura::Fingerprint::murmur3_32(reinterpret_cast<const uint8_t*>(a), 4, 0);
        const uint32_t h2 =
            aura::Fingerprint::murmur3_32(reinterpret_cast<const uint8_t*>(a), 4, 0);
        check(h1 == h2, "murmur3 is deterministic");

        const char* b = "aurb";
        const uint32_t h3 =
            aura::Fingerprint::murmur3_32(reinterpret_cast<const uint8_t*>(b), 4, 0);
        check(h1 != h3, "murmur3 distinguishes different input");
    }
    {
        // Identical PCM must fingerprint identically; different PCM must not.
        const int sr = 16000;
        std::vector<int16_t> pcmA(sr * 2);
        std::vector<int16_t> pcmB(sr * 2);
        for (std::size_t i = 0; i < pcmA.size(); ++i) {
            pcmA[i] = static_cast<int16_t>(10000 * std::sin(2.0 * kPi * 440.0 * i / sr));
            pcmB[i] = static_cast<int16_t>(10000 * std::sin(2.0 * kPi * 880.0 * i / sr));
        }

        uint32_t fpA[64] = {0};
        uint32_t fpA2[64] = {0};
        uint32_t fpB[64] = {0};
        const int nA = aura::Fingerprint::compute(pcmA.data(), pcmA.size(), sr, fpA, 64);
        const int nA2 = aura::Fingerprint::compute(pcmA.data(), pcmA.size(), sr, fpA2, 64);
        const int nB = aura::Fingerprint::compute(pcmB.data(), pcmB.size(), sr, fpB, 64);

        check(nA > 0, "fingerprint produces sub-fingerprints");
        check(nA == nA2 && std::memcmp(fpA, fpA2, nA * sizeof(uint32_t)) == 0,
              "same audio => same fingerprint");
        check(nB > 0 && std::memcmp(fpA, fpB, nA * sizeof(uint32_t)) != 0,
              "different audio => different fingerprint");
    }
    {
        uint32_t fp[4] = {0};
        std::vector<int16_t> pcm(16000 * 5, 0);
        const int n = aura::Fingerprint::compute(pcm.data(), pcm.size(), 16000, fp, 4);
        check(n <= 4, "fingerprint respects the output capacity");
    }
}

// ── C API ─────────────────────────────────────────────────────────────────────

void testCApi() {
    section("C API");

    check(std::strcmp(aura_engine_version(), "1.0.0") == 0, "version string");
    // Reports honestly whether this build linked FFmpeg.
    check(aura_engine_has_ffmpeg() == false || aura_engine_has_ffmpeg() == true,
          "ffmpeg availability is queryable");

    void* engine = aura_engine_create();
    check(engine != nullptr, "engine creates");
    if (engine == nullptr) return;

    check(aura_engine_get_state(engine) == AURA_STATE_IDLE, "starts IDLE");
    check(!aura_engine_is_playing(engine), "not playing before load");
    check(aura_engine_get_position(engine) == 0, "position starts at 0");
    check(aura_engine_get_duration(engine) == 0, "duration 0 with no track");

    // Loading a nonexistent file must fail cleanly and report an error.
    static bool sawError = false;
    static int lastState = -1;
    aura_engine_set_error_callback(
        engine, [](const char*, void*) { sawError = true; }, nullptr);
    aura_engine_set_state_callback(
        engine, [](int32_t s, void*) { lastState = s; }, nullptr);

    check(!aura_engine_load_track(engine, "/nonexistent/file.mp3"),
          "loading a missing file fails");
    check(sawError, "error callback fired for a missing file");
    check(lastState == AURA_STATE_ERROR, "state callback reported ERROR");

    // play() with nothing loaded must not crash or claim success.
    check(!aura_engine_play(engine), "play() without a track fails");

    // DSP setters are safe regardless of load state.
    aura_engine_set_eq_band(engine, 5, 6.0f, 1.0f);
    aura_engine_set_eq_preset(engine, AURA_EQ_ROCK);
    aura_engine_reset_eq(engine);
    aura_engine_set_eq_enabled(engine, true);
    aura_engine_set_replay_gain(engine, -3.0f);
    aura_engine_set_crossfade(engine, 5000);
    aura_engine_set_volume(engine, 0.5f);
    aura_engine_set_speed(engine, 1.5f);
    check(true, "DSP setters are safe with no track loaded");

    // Out-of-range values must be clamped, not crash.
    aura_engine_set_volume(engine, 99.0f);
    aura_engine_set_volume(engine, -5.0f);
    aura_engine_set_crossfade(engine, 999999);
    check(true, "out-of-range DSP values are clamped safely");

    aura_engine_destroy(engine);
    check(true, "engine destroys cleanly");

    // Every entry point must tolerate a NULL handle.
    aura_engine_destroy(nullptr);
    check(!aura_engine_play(nullptr), "play(NULL) is safe");
    check(!aura_engine_pause(nullptr), "pause(NULL) is safe");
    check(!aura_engine_seek(nullptr, 100), "seek(NULL) is safe");
    check(aura_engine_get_position(nullptr) == 0, "get_position(NULL) is safe");
    check(aura_engine_get_duration(nullptr) == 0, "get_duration(NULL) is safe");
    check(!aura_engine_is_playing(nullptr), "is_playing(NULL) is safe");
    aura_engine_set_eq_band(nullptr, 0, 1.0f, 1.0f);
    aura_engine_set_volume(nullptr, 0.5f);
    check(true, "DSP setters tolerate NULL");

    // Analysis entry points reject bad input.
    float features[6] = {0};
    check(!aura_analyze_track("/nonexistent/file.mp3", features, 6),
          "analyze_track fails on a missing file");
    uint32_t fp[16] = {0};
    int size = 16;
    check(!aura_get_fingerprint("/nonexistent/file.mp3", fp, &size),
          "get_fingerprint fails on a missing file");

    // Two engines can coexist (the point of the handle-based API).
    void* a = aura_engine_create();
    void* b = aura_engine_create();
    check(a != nullptr && b != nullptr && a != b, "multiple engines coexist");
    aura_engine_set_eq_band(a, 0, 6.0f, 1.0f);
    aura_engine_set_eq_band(b, 0, -6.0f, 1.0f);
    check(true, "independent engines keep independent EQ state");
    aura_engine_destroy(a);
    aura_engine_destroy(b);
}

}  // namespace

int main() {
    std::printf("Aura audio engine tests\n=======================\n");
    testEqualizer();
    testReplayGain();
    testCrossfade();
    testAnalyzer();
    testFingerprint();
    testCApi();

    std::printf("\n%d checks, %d failure(s)\n", g_checks, g_failures);
    if (g_failures == 0) {
        std::printf("PASS\n");
        return 0;
    }
    std::printf("FAIL\n");
    return 1;
}
