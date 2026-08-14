#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"
#include "audio_engine.h"

#include <string>
#include <thread>
#include <atomic>
#include <chrono>
#include <mutex>

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

int32_t aura_fingerprint(const char* path, char* out_hash, int32_t out_size) {
    // Stubbed for Phase 2
    return -1;
}

int32_t aura_analyze_features(const char* path, float* out_features, int32_t feature_count) {
    // Stubbed for Phase 3
    return -1;
}

} // extern "C"
