/**
 * audio_engine.cpp
 * Aura — Handle-based audio engine implementation.
 *
 * Audio path: Decoder → Equalizer → ReplayGain → volume → device.
 * The miniaudio device callback pulls PCM and runs the DSP chain in place; a
 * separate worker thread reports position/state to Dart so the audio callback
 * itself stays allocation- and lock-light.
 */

#define MINIAUDIO_IMPLEMENTATION
#include "third_party/miniaudio.h"

#include "audio_engine.h"

#include <atomic>
#include <chrono>
#include <cstring>
#include <memory>
#include <mutex>
#include <string>
#include <thread>
#include <vector>

#include "analyzer/feature_extractor.h"
#include "analyzer/fingerprint.h"
#include "decoder/decoder.h"
#include "dsp/crossfade.h"
#include "dsp/equalizer.h"
#include "dsp/replay_gain.h"

namespace {

constexpr int kDefaultSampleRate = 48000;
constexpr int kDefaultChannels = 2;
constexpr int kDefaultBufferFrames = 1024;
constexpr auto kPositionInterval = std::chrono::milliseconds(200);

}  // namespace

/// Opaque engine handle backing every aura_engine_* call.
struct AuraEngine {
    // Configuration
    int sampleRate = kDefaultSampleRate;
    int channels = kDefaultChannels;
    int bufferFrames = kDefaultBufferFrames;

    // Device + source
    ma_device device{};
    bool deviceInitialised = false;

    std::unique_ptr<aura::Decoder> decoder;
    std::mutex decoderMutex;  // guards decoder + position

    // DSP chain
    aura::Equalizer equalizer{static_cast<double>(kDefaultSampleRate)};
    aura::ReplayGain replayGain;
    aura::Crossfade crossfade;

    std::atomic<float> volume{1.0f};
    std::atomic<float> speed{1.0f};

    // State
    std::atomic<int> state{AURA_STATE_IDLE};
    std::atomic<int64_t> positionFrames{0};
    std::atomic<int64_t> durationMs{0};

    // Callbacks
    AuraPositionCallback positionCb = nullptr;
    void* positionUser = nullptr;
    AuraStateCallback stateCb = nullptr;
    void* stateUser = nullptr;
    AuraErrorCallback errorCb = nullptr;
    void* errorUser = nullptr;
    std::mutex callbackMutex;

    // Worker
    std::thread worker;
    std::atomic<bool> workerRunning{false};

    void setState(AuraPlaybackState next) {
        state.store(next, std::memory_order_relaxed);
        AuraStateCallback cb;
        void* user;
        {
            std::lock_guard<std::mutex> lock(callbackMutex);
            cb = stateCb;
            user = stateUser;
        }
        if (cb) cb(static_cast<int32_t>(next), user);
    }

    void reportError(const char* message) {
        AuraErrorCallback cb;
        void* user;
        {
            std::lock_guard<std::mutex> lock(callbackMutex);
            cb = errorCb;
            user = errorUser;
        }
        if (cb) cb(message, user);
    }

    int64_t positionMs() const {
        if (sampleRate <= 0) return 0;
        return (positionFrames.load(std::memory_order_relaxed) * 1000) / sampleRate;
    }
};

namespace {

/// miniaudio pull callback: decode → DSP → output.
void dataCallback(ma_device* device, void* output, const void* /*input*/,
                  ma_uint32 frameCount) {
    auto* engine = static_cast<AuraEngine*>(device->pUserData);
    auto* out = static_cast<float*>(output);
    const int channels = engine->channels;

    std::memset(out, 0, static_cast<std::size_t>(frameCount) * channels * sizeof(float));

    if (engine->state.load(std::memory_order_relaxed) != AURA_STATE_PLAYING) return;

    std::size_t read = 0;
    {
        std::unique_lock<std::mutex> lock(engine->decoderMutex, std::try_to_lock);
        if (!lock.owns_lock() || !engine->decoder) return;
        read = engine->decoder->read(out, frameCount);
    }

    if (read == 0) {
        // End of stream — the worker thread turns this into COMPLETED.
        engine->state.store(AURA_STATE_COMPLETED, std::memory_order_relaxed);
        return;
    }

    engine->positionFrames.fetch_add(static_cast<int64_t>(read), std::memory_order_relaxed);

    // DSP chain, in place.
    engine->equalizer.process(out, read, channels);
    engine->replayGain.process(out, read, channels);

    const float vol = engine->volume.load(std::memory_order_relaxed);
    if (vol != 1.0f) {
        const std::size_t total = read * static_cast<std::size_t>(channels);
        for (std::size_t i = 0; i < total; ++i) out[i] *= vol;
    }
}

/// Emits position updates and the terminal COMPLETED transition.
void workerLoop(AuraEngine* engine) {
    int lastState = engine->state.load(std::memory_order_relaxed);

    while (engine->workerRunning.load(std::memory_order_relaxed)) {
        std::this_thread::sleep_for(kPositionInterval);
        if (!engine->workerRunning.load(std::memory_order_relaxed)) break;

        const int current = engine->state.load(std::memory_order_relaxed);

        if (current == AURA_STATE_PLAYING) {
            AuraPositionCallback cb;
            void* user;
            {
                std::lock_guard<std::mutex> lock(engine->callbackMutex);
                cb = engine->positionCb;
                user = engine->positionUser;
            }
            if (cb) cb(engine->positionMs(), user);
        }

        // The audio thread only stores COMPLETED; announcing it is our job.
        if (current != lastState) {
            if (current == AURA_STATE_COMPLETED) {
                engine->setState(AURA_STATE_COMPLETED);
            }
            lastState = current;
        }
    }
}

inline AuraEngine* cast(void* handle) { return static_cast<AuraEngine*>(handle); }

bool startDevice(AuraEngine* engine) {
    ma_device_config cfg = ma_device_config_init(ma_device_type_playback);
    cfg.playback.format = ma_format_f32;
    cfg.playback.channels = static_cast<ma_uint32>(engine->channels);
    cfg.sampleRate = static_cast<ma_uint32>(engine->sampleRate);
    cfg.periodSizeInFrames = static_cast<ma_uint32>(engine->bufferFrames);
    cfg.dataCallback = dataCallback;
    cfg.pUserData = engine;

    if (ma_device_init(nullptr, &cfg, &engine->device) != MA_SUCCESS) return false;
    engine->deviceInitialised = true;
    return true;
}

}  // namespace

// ── C API ─────────────────────────────────────────────────────────────────────

extern "C" {

void* aura_engine_create(void) {
    AuraEngineConfig cfg;
    cfg.sample_rate = kDefaultSampleRate;
    cfg.buffer_size_frames = kDefaultBufferFrames;
    cfg.channels = kDefaultChannels;
    cfg.crossfade_seconds = 0.0f;
    cfg.enable_replaygain = 1;
    return aura_engine_create_with_config(&cfg);
}

void* aura_engine_create_with_config(const AuraEngineConfig* config) {
    auto* engine = new (std::nothrow) AuraEngine();
    if (engine == nullptr) return nullptr;

    if (config != nullptr) {
        if (config->sample_rate > 0) engine->sampleRate = config->sample_rate;
        if (config->channels > 0) engine->channels = config->channels;
        if (config->buffer_size_frames > 0) engine->bufferFrames = config->buffer_size_frames;
        engine->replayGain.setEnabled(config->enable_replaygain != 0);
        engine->crossfade.setDurationMs(
            static_cast<int>(config->crossfade_seconds * 1000.0f), engine->sampleRate);
    }

    engine->equalizer.setSampleRate(static_cast<double>(engine->sampleRate));

    // A machine with no audio device (CI, headless tests) still yields a usable
    // engine for EQ/analysis; only playback is unavailable.
    startDevice(engine);

    engine->workerRunning.store(true);
    engine->worker = std::thread(workerLoop, engine);
    engine->setState(AURA_STATE_IDLE);
    return engine;
}

void aura_engine_destroy(void* handle) {
    auto* engine = cast(handle);
    if (engine == nullptr) return;

    engine->workerRunning.store(false);
    if (engine->worker.joinable()) engine->worker.join();

    if (engine->deviceInitialised) {
        ma_device_uninit(&engine->device);
        engine->deviceInitialised = false;
    }
    {
        std::lock_guard<std::mutex> lock(engine->decoderMutex);
        engine->decoder.reset();
    }
    delete engine;
}

bool aura_engine_load_track(void* handle, const char* file_path) {
    auto* engine = cast(handle);
    if (engine == nullptr || file_path == nullptr) return false;

    engine->setState(AURA_STATE_LOADING);

    auto decoder = aura::Decoder::open(file_path, engine->sampleRate, engine->channels);
    if (!decoder) {
        engine->reportError("Unable to decode file");
        engine->setState(AURA_STATE_ERROR);
        return false;
    }

    const int64_t duration = decoder->durationMs();
    {
        std::lock_guard<std::mutex> lock(engine->decoderMutex);
        engine->decoder = std::move(decoder);
    }
    engine->durationMs.store(duration, std::memory_order_relaxed);
    engine->positionFrames.store(0, std::memory_order_relaxed);
    engine->equalizer.clearState();
    engine->setState(AURA_STATE_READY);
    return true;
}

bool aura_engine_play(void* handle) {
    auto* engine = cast(handle);
    if (engine == nullptr) return false;
    {
        std::lock_guard<std::mutex> lock(engine->decoderMutex);
        if (!engine->decoder) return false;
    }
    if (engine->deviceInitialised && ma_device_start(&engine->device) != MA_SUCCESS) {
        engine->reportError("Failed to start audio device");
        engine->setState(AURA_STATE_ERROR);
        return false;
    }
    engine->setState(AURA_STATE_PLAYING);
    return true;
}

bool aura_engine_pause(void* handle) {
    auto* engine = cast(handle);
    if (engine == nullptr) return false;
    if (engine->deviceInitialised) ma_device_stop(&engine->device);
    engine->setState(AURA_STATE_PAUSED);
    return true;
}

bool aura_engine_stop(void* handle) {
    auto* engine = cast(handle);
    if (engine == nullptr) return false;
    if (engine->deviceInitialised) ma_device_stop(&engine->device);
    {
        std::lock_guard<std::mutex> lock(engine->decoderMutex);
        if (engine->decoder) engine->decoder->seekToFrame(0);
    }
    engine->positionFrames.store(0, std::memory_order_relaxed);
    engine->equalizer.clearState();
    engine->setState(AURA_STATE_READY);
    return true;
}

bool aura_engine_seek(void* handle, int64_t position_ms) {
    auto* engine = cast(handle);
    if (engine == nullptr) return false;
    if (position_ms < 0) position_ms = 0;

    const int64_t duration = engine->durationMs.load(std::memory_order_relaxed);
    if (duration > 0 && position_ms > duration) position_ms = duration;

    const uint64_t frame =
        static_cast<uint64_t>(position_ms) * static_cast<uint64_t>(engine->sampleRate) / 1000;

    bool ok = false;
    {
        std::lock_guard<std::mutex> lock(engine->decoderMutex);
        if (engine->decoder) ok = engine->decoder->seekToFrame(frame);
    }
    if (!ok) return false;

    engine->positionFrames.store(static_cast<int64_t>(frame), std::memory_order_relaxed);
    engine->equalizer.clearState();  // avoid filter ringing across the jump
    return true;
}

int64_t aura_engine_get_position(void* handle) {
    auto* engine = cast(handle);
    return engine ? engine->positionMs() : 0;
}

int64_t aura_engine_get_duration(void* handle) {
    auto* engine = cast(handle);
    return engine ? engine->durationMs.load(std::memory_order_relaxed) : 0;
}

bool aura_engine_is_playing(void* handle) {
    auto* engine = cast(handle);
    return engine && engine->state.load(std::memory_order_relaxed) == AURA_STATE_PLAYING;
}

int32_t aura_engine_get_state(void* handle) {
    auto* engine = cast(handle);
    return engine ? static_cast<int32_t>(engine->state.load(std::memory_order_relaxed))
                  : static_cast<int32_t>(AURA_STATE_IDLE);
}

void aura_engine_set_eq_band(void* handle, int band, float gain_db, float q) {
    auto* engine = cast(handle);
    if (engine == nullptr) return;
    engine->equalizer.setBand(band, gain_db, q <= 0.0f ? 1.0 : static_cast<double>(q));
}

void aura_engine_set_eq_preset(void* handle, int preset_id) {
    auto* engine = cast(handle);
    if (engine == nullptr) return;
    engine->equalizer.setPreset(static_cast<aura::EqPreset>(preset_id));
}

void aura_engine_reset_eq(void* handle) {
    auto* engine = cast(handle);
    if (engine) engine->equalizer.reset();
}

void aura_engine_set_eq_enabled(void* handle, bool enabled) {
    auto* engine = cast(handle);
    if (engine) engine->equalizer.setEnabled(enabled);
}

void aura_engine_set_replay_gain(void* handle, float gain_db) {
    auto* engine = cast(handle);
    if (engine) engine->replayGain.setGainDb(static_cast<double>(gain_db));
}

void aura_engine_set_crossfade(void* handle, int fade_ms) {
    auto* engine = cast(handle);
    if (engine) engine->crossfade.setDurationMs(fade_ms, engine->sampleRate);
}

void aura_engine_set_volume(void* handle, float volume) {
    auto* engine = cast(handle);
    if (engine == nullptr) return;
    if (volume < 0.0f) volume = 0.0f;
    if (volume > 1.0f) volume = 1.0f;
    engine->volume.store(volume, std::memory_order_relaxed);
}

void aura_engine_set_speed(void* handle, float speed) {
    auto* engine = cast(handle);
    if (engine == nullptr) return;
    if (speed < 0.25f) speed = 0.25f;
    if (speed > 4.0f) speed = 4.0f;
    engine->speed.store(speed, std::memory_order_relaxed);
}

void aura_engine_set_position_callback(void* handle, AuraPositionCallback callback,
                                       void* user_data) {
    auto* engine = cast(handle);
    if (engine == nullptr) return;
    std::lock_guard<std::mutex> lock(engine->callbackMutex);
    engine->positionCb = callback;
    engine->positionUser = user_data;
}

void aura_engine_set_state_callback(void* handle, AuraStateCallback callback,
                                    void* user_data) {
    auto* engine = cast(handle);
    if (engine == nullptr) return;
    std::lock_guard<std::mutex> lock(engine->callbackMutex);
    engine->stateCb = callback;
    engine->stateUser = user_data;
}

void aura_engine_set_error_callback(void* handle, AuraErrorCallback callback,
                                    void* user_data) {
    auto* engine = cast(handle);
    if (engine == nullptr) return;
    std::lock_guard<std::mutex> lock(engine->callbackMutex);
    engine->errorCb = callback;
    engine->errorUser = user_data;
}

bool aura_analyze_track(const char* file_path, float* features, int feature_count) {
    return aura::FeatureExtractor::extractFromFile(file_path, features, feature_count) == 0;
}

bool aura_get_fingerprint(const char* file_path, uint32_t* fingerprint, int* size) {
    return aura::Fingerprint::computeFromFile(file_path, fingerprint, size) == 0;
}

const char* aura_engine_version(void) { return "1.0.0"; }

bool aura_engine_has_ffmpeg(void) { return aura::Decoder::ffmpegAvailable(); }

}  // extern "C"
