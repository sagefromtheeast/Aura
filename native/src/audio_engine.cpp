#define MINIAUDIO_IMPLEMENTATION
#include "../include/miniaudio.h"
#include "../include/audio_engine.h"

#include <thread>
#include <atomic>
#include <chrono>
#include <mutex>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>

// --- Globals ---
static ma_engine g_engine;
static ma_sound g_sound;
static bool g_engine_initialized = false;
static bool g_sound_loaded = false;

static AuraCallback g_callback = nullptr;
static void* g_user_data = nullptr;

static std::thread g_worker_thread;
static std::atomic<bool> g_worker_running{false};
static std::mutex g_state_mutex;

static AuraPlaybackState g_current_state = AURA_STATE_IDLE;

// --- Helper to notify state ---
static void notify_state(AuraPlaybackState state) {
    g_current_state = state;
    if (g_callback) {
        g_callback(AURA_EVENT_STATE_CHANGE, state, g_user_data);
    }
}

static void worker_loop() {
    while (g_worker_running) {
        std::this_thread::sleep_for(std::chrono::milliseconds(200));
        
        std::lock_guard<std::mutex> lock(g_state_mutex);
        if (g_sound_loaded && g_callback && g_current_state == AURA_STATE_PLAYING) {
            float cursor;
            if (ma_sound_get_cursor_in_seconds(&g_sound, &cursor) == MA_SUCCESS) {
                int64_t ms = static_cast<int64_t>(cursor * 1000.0f);
                g_callback(AURA_EVENT_POSITION, ms, g_user_data);
            }
            
            if (ma_sound_at_end(&g_sound)) {
                g_current_state = AURA_STATE_COMPLETED;
                g_callback(AURA_EVENT_STATE_CHANGE, AURA_STATE_COMPLETED, g_user_data);
                g_callback(AURA_EVENT_TRACK_END, 0, g_user_data);
            }
        }
    }
}

// --- API Implementation ---

extern "C" {

int32_t aura_init(void) {
    if (g_engine_initialized) return 0;
    
    ma_result result = ma_engine_init(NULL, &g_engine);
    if (result != MA_SUCCESS) return -1;
    
    g_engine_initialized = true;
    
    g_worker_running = true;
    g_worker_thread = std::thread(worker_loop);
    
    notify_state(AURA_STATE_READY);
    return 0;
}

int32_t aura_init_ex(const AuraEngineConfig* config) {
    if (g_engine_initialized) return 0;
    
    ma_engine_config engineConfig = ma_engine_config_init();
    if (config->sample_rate > 0) {
        engineConfig.sampleRate = config->sample_rate;
    }
    
    ma_result result = ma_engine_init(&engineConfig, &g_engine);
    if (result != MA_SUCCESS) return -1;
    
    g_engine_initialized = true;
    
    g_worker_running = true;
    g_worker_thread = std::thread(worker_loop);
    
    notify_state(AURA_STATE_READY);
    return 0;
}

void aura_destroy(void) {
    g_worker_running = false;
    if (g_worker_thread.joinable()) {
        g_worker_thread.join();
    }
    
    std::lock_guard<std::mutex> lock(g_state_mutex);
    if (g_sound_loaded) {
        ma_sound_uninit(&g_sound);
        g_sound_loaded = false;
    }
    if (g_engine_initialized) {
        ma_engine_uninit(&g_engine);
        g_engine_initialized = false;
    }
    g_callback = nullptr;
}

int32_t aura_load_track(const char* path) {
    std::lock_guard<std::mutex> lock(g_state_mutex);
    if (!g_engine_initialized) return -1;
    
    notify_state(AURA_STATE_LOADING);
    
    if (g_sound_loaded) {
        ma_sound_uninit(&g_sound);
        g_sound_loaded = false;
    }
    
    ma_result result = ma_sound_init_from_file(&g_engine, path, MA_SOUND_FLAG_DECODE | MA_SOUND_FLAG_ASYNC, NULL, NULL, &g_sound);
    if (result != MA_SUCCESS) {
        notify_state(AURA_STATE_ERROR);
        return -2;
    }
    
    g_sound_loaded = true;
    notify_state(AURA_STATE_READY);
    return 0;
}

int64_t aura_get_duration(void) {
    std::lock_guard<std::mutex> lock(g_state_mutex);
    if (!g_sound_loaded) return 0;
    
    float length;
    if (ma_sound_get_length_in_seconds(&g_sound, &length) == MA_SUCCESS) {
        return static_cast<int64_t>(length * 1000.0f);
    }
    return 0;
}

void aura_play(void) {
    std::lock_guard<std::mutex> lock(g_state_mutex);
    if (g_sound_loaded) {
        ma_sound_start(&g_sound);
        notify_state(AURA_STATE_PLAYING);
    }
}

void aura_pause(void) {
    std::lock_guard<std::mutex> lock(g_state_mutex);
    if (g_sound_loaded) {
        ma_sound_stop(&g_sound);
        notify_state(AURA_STATE_PAUSED);
    }
}

void aura_seek(int64_t position_ms) {
    std::lock_guard<std::mutex> lock(g_state_mutex);
    if (g_sound_loaded) {
        float pos_sec = position_ms / 1000.0f;
        ma_sound_seek_to_pcm_frame(&g_sound, static_cast<ma_uint64>(pos_sec * g_engine.sampleRate));
    }
}

void aura_set_volume(double volume) {
    std::lock_guard<std::mutex> lock(g_state_mutex);
    if (g_engine_initialized) {
        ma_engine_set_volume(&g_engine, static_cast<float>(volume));
    }
}

void aura_set_speed(double speed) {
    std::lock_guard<std::mutex> lock(g_state_mutex);
    if (g_sound_loaded) {
        ma_sound_set_pitch(&g_sound, static_cast<float>(speed));
    }
}

void aura_set_eq_band(int32_t band, double gain_db, double q) {
    // Stubbed for Phase 1
}

void aura_reset_eq(void) {
    // Stubbed for Phase 1
}

void aura_set_callback(AuraCallback callback, void* user_data) {
    g_callback = callback;
    g_user_data = user_data;
}

#include <math.h>

// Simple hash function for PCM data
static uint32_t murmur3_32(const uint8_t* key, size_t len, uint32_t seed) {
    uint32_t h = seed;
    if (len > 3) {
        size_t i = len >> 2;
        do {
            uint32_t k;
            memcpy(&k, key, sizeof(uint32_t));
            key += sizeof(uint32_t);
            k *= 0xcc9e2d51;
            k = (k << 15) | (k >> 17);
            k *= 0x1b873593;
            h ^= k;
            h = (h << 13) | (h >> 19);
            h = h * 5 + 0xe6546b64;
        } while (--i);
    }
    if (len & 3) {
        size_t i = len & 3;
        uint32_t k = 0;
        do {
            k <<= 8;
            k |= key[i - 1];
        } while (--i);
        k *= 0xcc9e2d51;
        k = (k << 15) | (k >> 17);
        k *= 0x1b873593;
        h ^= k;
    }
    h ^= len;
    h ^= h >> 16;
    h *= 0x85ebca6b;
    h ^= h >> 13;
    h *= 0xc2b2ae35;
    h ^= h >> 16;
    return h;
}

int32_t aura_fingerprint(const char* path, char* out_hash, int32_t out_size) {
    ma_decoder decoder;
    ma_decoder_config config = ma_decoder_config_init(ma_format_s16, 1, 16000); // mono, 16kHz
    if (ma_decoder_init_file(path, &config, &decoder) != MA_SUCCESS) {
        return -2;
    }

    // Read first 3 seconds
    const int num_frames = 16000 * 3;
    int16_t* pcm_data = (int16_t*)malloc(num_frames * sizeof(int16_t));
    ma_uint64 frames_read = 0;
    ma_decoder_read_pcm_frames(&decoder, pcm_data, num_frames, &frames_read);
    ma_decoder_uninit(&decoder);

    if (frames_read == 0) {
        free(pcm_data);
        return -2;
    }

    uint32_t hash = murmur3_32((const uint8_t*)pcm_data, frames_read * sizeof(int16_t), 0);
    free(pcm_data);

    if (out_size >= 9) {
        snprintf(out_hash, out_size, "%08x", hash);
    }
    return 0;
}

int32_t aura_analyze_features(const char* path, float* out_features, int32_t feature_count) {
    if (feature_count < 6) return -1;

    ma_decoder decoder;
    ma_decoder_config config = ma_decoder_config_init(ma_format_f32, 1, 22050); // mono, 22.05kHz
    if (ma_decoder_init_file(path, &config, &decoder) != MA_SUCCESS) {
        return -2;
    }

    // Read up to 30 seconds for analysis
    const int max_frames = 22050 * 30;
    float* pcm = (float*)malloc(max_frames * sizeof(float));
    ma_uint64 frames_read = 0;
    ma_decoder_read_pcm_frames(&decoder, pcm, max_frames, &frames_read);
    ma_decoder_uninit(&decoder);

    if (frames_read == 0) {
        free(pcm);
        return -2;
    }

    double sum_sq = 0.0;
    int zero_crossings = 0;
    double energy_sum = 0.0;
    
    // Simple beat tracking via amplitude envelope derivative
    float prev_env = 0.0f;
    int beat_count = 0;
    const int window_size = 2205; // 100ms
    float current_window_energy = 0.0f;

    for (ma_uint64 i = 0; i < frames_read; i++) {
        float sample = pcm[i];
        sum_sq += sample * sample;
        
        if (i > 0 && ((pcm[i] >= 0 && pcm[i-1] < 0) || (pcm[i] < 0 && pcm[i-1] >= 0))) {
            zero_crossings++;
        }

        current_window_energy += sample * sample;
        if (i % window_size == 0 && i > 0) {
            float env = sqrtf(current_window_energy / window_size);
            if (env - prev_env > 0.05f) { // Arbitrary onset threshold
                beat_count++;
            }
            prev_env = env;
            current_window_energy = 0.0f;
        }
    }

    free(pcm);

    double rms = sqrt(sum_sq / frames_read);
    double zcr = (double)zero_crossings / frames_read;
    double duration_sec = (double)frames_read / 22050.0;
    
    // Derived features [0.0, 1.0]
    float tempo = std::fmin(1.0f, (float)((beat_count / duration_sec) * 60.0f) / 200.0f); // Normalize max 200 BPM
    float loudness = std::fmin(1.0f, (float)(rms * 4.0)); // Normalize arbitrary loud factor
    float energy = std::fmin(1.0f, (float)(rms * 5.0 + tempo * 0.5f)); 
    float acousticness = std::fmax(0.0f, 1.0f - (float)(zcr * 10.0)); // Less zero crossings = more acoustic
    float danceability = std::fmin(1.0f, tempo * 0.8f + energy * 0.2f);
    float valence = std::fmin(1.0f, energy * 0.6f + (1.0f - acousticness) * 0.4f); // Rough heuristic

    out_features[0] = tempo;
    out_features[1] = energy;
    out_features[2] = valence;
    out_features[3] = danceability;
    out_features[4] = loudness;
    out_features[5] = acousticness;

    return 0;
}

} // extern "C"
