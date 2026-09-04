/**
 * audio_engine.h
 * Aura — Public C API for the audio engine shared library.
 * Architecture §4.1: exposed via dart:ffi and auto-bound with ffigen.
 *
 * Handle-based: every call takes the opaque engine pointer returned by
 * aura_engine_create(), so multiple engines (e.g. main + preview) can coexist.
 *
 * Thread safety:
 *   - Callbacks fire from an internal worker thread. Dart receives them through
 *     NativeCallable.listener(), which posts to the Dart event loop safely.
 *   - Register callbacks before calling play().
 *   - All other functions may be called from any single thread.
 */

#pragma once

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// ── Playback States ────────────────────────────────────────────────────────────
// Values must stay aligned with EngineStatus in
// lib/domain/entities/playback_state.dart.
typedef enum AuraPlaybackState {
    AURA_STATE_IDLE      = 0,
    AURA_STATE_READY     = 1,
    AURA_STATE_PLAYING   = 2,
    AURA_STATE_PAUSED    = 3,
    AURA_STATE_LOADING   = 4,
    AURA_STATE_COMPLETED = 5,
    AURA_STATE_ERROR     = 6,
} AuraPlaybackState;

// ── EQ Presets ─────────────────────────────────────────────────────────────────
// Must match kEqPresetOrder in lib/ui/screens/settings/settings_providers.dart.
typedef enum AuraEqPreset {
    AURA_EQ_FLAT      = 0,
    AURA_EQ_ROCK      = 1,
    AURA_EQ_POP       = 2,
    AURA_EQ_JAZZ      = 3,
    AURA_EQ_CLASSICAL = 4,
    AURA_EQ_CUSTOM    = 5,
} AuraEqPreset;

// ── Engine Configuration ───────────────────────────────────────────────────────
typedef struct AuraEngineConfig {
    int32_t sample_rate;          /**< Output sample rate (e.g. 44100, 48000). */
    int32_t buffer_size_frames;   /**< Audio buffer size in frames (e.g. 1024). */
    int32_t channels;             /**< Output channel count (1 or 2). */
    float   crossfade_seconds;    /**< Crossfade duration (0-12). */
    int32_t enable_replaygain;    /**< 1 = apply ReplayGain normalisation. */
} AuraEngineConfig;

// ── Callback Types ─────────────────────────────────────────────────────────────
typedef void (*AuraPositionCallback)(int64_t position_ms, void* user_data);
typedef void (*AuraStateCallback)(int32_t state, void* user_data);

/**
 * Error callback.
 *
 * IMPORTANT: [message] MUST have static storage duration. Dart receives it via
 * NativeCallable.listener(), which delivers asynchronously — a pointer to a
 * stack or heap buffer freed by the engine would already dangle by the time
 * Dart reads it. Pass string literals only.
 */
typedef void (*AuraErrorCallback)(const char* message, void* user_data);

// ── Lifecycle ──────────────────────────────────────────────────────────────────

/** Creates an engine with default configuration. NULL on failure. */
void* aura_engine_create(void);

/** Creates an engine with a custom configuration. NULL on failure. */
void* aura_engine_create_with_config(const AuraEngineConfig* config);

/** Destroys the engine and releases all native resources. Safe on NULL. */
void aura_engine_destroy(void* engine);

// ── Playback ───────────────────────────────────────────────────────────────────

/** Loads a local file. Decodes the header only; does not start playback. */
bool aura_engine_load_track(void* engine, const char* file_path);

/** Starts or resumes playback. */
bool aura_engine_play(void* engine);

/** Pauses playback, retaining position. */
bool aura_engine_pause(void* engine);

/** Stops playback and rewinds to the start. */
bool aura_engine_stop(void* engine);

/** Seeks to [position_ms], clamped to [0, duration]. */
bool aura_engine_seek(void* engine, int64_t position_ms);

/** Current playback position in ms, or 0 when nothing is loaded. */
int64_t aura_engine_get_position(void* engine);

/** Duration of the loaded track in ms, or 0 when nothing is loaded. */
int64_t aura_engine_get_duration(void* engine);

/** True while audio is actively playing. */
bool aura_engine_is_playing(void* engine);

/** Current AuraPlaybackState. */
int32_t aura_engine_get_state(void* engine);

// ── Audio Processing ───────────────────────────────────────────────────────────

/**
 * Sets one parametric EQ band.
 * @param band     0-9 (32Hz, 64, 125, 250, 500, 1k, 2k, 4k, 8k, 16kHz).
 * @param gain_db  -12.0 to +12.0.
 * @param q        0.5 to 4.0 (1.0 = default bandwidth).
 */
void aura_engine_set_eq_band(void* engine, int band, float gain_db, float q);

/** Applies an AuraEqPreset. AURA_EQ_CUSTOM leaves current gains untouched. */
void aura_engine_set_eq_preset(void* engine, int preset_id);

/** Flattens every EQ band to 0 dB. */
void aura_engine_reset_eq(void* engine);

/** Enables/disables the EQ. Disabled is a bit-perfect pass-through. */
void aura_engine_set_eq_enabled(void* engine, bool enabled);

/** Sets the ReplayGain adjustment for the current track, in dB. */
void aura_engine_set_replay_gain(void* engine, float gain_db);

/** Sets the crossfade length in ms (0-12000; 0 disables). */
void aura_engine_set_crossfade(void* engine, int fade_ms);

/** Sets master volume (0.0 silent … 1.0 full). */
void aura_engine_set_volume(void* engine, float volume);

/** Sets playback speed (0.5 = half, 2.0 = double). */
void aura_engine_set_speed(void* engine, float speed);

// ── Callbacks ──────────────────────────────────────────────────────────────────

void aura_engine_set_position_callback(void* engine,
                                       AuraPositionCallback callback,
                                       void* user_data);

void aura_engine_set_state_callback(void* engine,
                                    AuraStateCallback callback,
                                    void* user_data);

void aura_engine_set_error_callback(void* engine,
                                    AuraErrorCallback callback,
                                    void* user_data);

// ── Analysis (engine-independent) ──────────────────────────────────────────────

/**
 * Extracts audio features for [file_path].
 * Layout (6 floats): [tempo, energy, valence, danceability, loudness, acousticness],
 * all normalised to [0,1].
 * @return true on success.
 */
bool aura_analyze_track(const char* file_path, float* features, int feature_count);

/**
 * Computes windowed acoustic sub-fingerprints for [file_path].
 * On entry *[size] is the capacity of [fingerprint]; on success it holds the
 * number of uint32 values written.
 * @return true on success.
 */
bool aura_get_fingerprint(const char* file_path, uint32_t* fingerprint, int* size);

// ── Build Info ─────────────────────────────────────────────────────────────────

/** Engine version string, e.g. "1.0.0". */
const char* aura_engine_version(void);

/** True when this build links the FFmpeg decoder backend. */
bool aura_engine_has_ffmpeg(void);

#ifdef __cplusplus
}
#endif
