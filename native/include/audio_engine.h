/**
 * audio_engine.h
 * Aura — Public C API for the audio engine shared library.
 * Architecture §4.1: exposed via dart:ffi and auto-bound with ffigen.
 *
 * Sprint 1: Placeholder header — no implementation yet.
 * Sprint 2: Implement in native/src/audio_engine.cpp
 *
 * All functions return 0 on success, non-zero on error (except void functions).
 * Thread safety: aura_set_callback() is called once; all other functions must
 * be called from the same Dart isolate / single thread.
 */

#pragma once
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// ── Event Types ────────────────────────────────────────────────────────────────
typedef enum AuraEventType {
    AURA_EVENT_POSITION     = 0,  /**< value = current position in ms */
    AURA_EVENT_STATE_CHANGE = 1,  /**< value = AuraPlaybackState */
    AURA_EVENT_ERROR        = 2,  /**< value = error code */
    AURA_EVENT_TRACK_END    = 3,  /**< value = 0 (track completed) */
} AuraEventType;

// ── Playback States ────────────────────────────────────────────────────────────
typedef enum AuraPlaybackState {
    AURA_STATE_IDLE      = 0,
    AURA_STATE_READY     = 1,
    AURA_STATE_PLAYING   = 2,
    AURA_STATE_PAUSED    = 3,
    AURA_STATE_LOADING   = 4,
    AURA_STATE_COMPLETED = 5,
    AURA_STATE_ERROR     = 6,
} AuraPlaybackState;

// ── Callback Type ──────────────────────────────────────────────────────────────
/**
 * AuraCallback: invoked asynchronously by the engine on events.
 *
 * @param event_type  One of AuraEventType.
 * @param value       Event-specific value (position ms, state index, error code).
 * @param user_data   Opaque pointer passed to aura_set_callback().
 *
 * IMPORTANT: This callback is invoked from a native audio thread.
 * Do NOT perform Dart operations directly in this callback.
 * The Dart side receives it via NativeCallable.listener() which posts to
 * the Dart event loop safely.
 */
typedef void (*AuraCallback)(
    int32_t event_type,
    int64_t value,
    void*   user_data
);

// ── Engine Configuration ───────────────────────────────────────────────────────
typedef struct AuraEngineConfig {
    int32_t sample_rate;          /**< Output sample rate (e.g. 44100, 48000). */
    int32_t buffer_size_frames;   /**< Audio buffer size in frames (e.g. 1024). */
    int32_t eq_band_count;        /**< Number of EQ bands (must be 10). */
    float   crossfade_seconds;    /**< Gapless crossfade duration (0–12). */
    int32_t enable_replaygain;    /**< 1 = apply ReplayGain normalisation. */
} AuraEngineConfig;

// ── Lifecycle ──────────────────────────────────────────────────────────────────

/**
 * Initialises the audio engine with default configuration.
 * Must be called before any other function.
 * @return 0 on success.
 */
int32_t aura_init(void);

/**
 * Initialises the audio engine with a custom configuration.
 * @return 0 on success.
 */
int32_t aura_init_ex(const AuraEngineConfig* config);

/**
 * Destroys the engine, releasing all native resources.
 * Must be called on app shutdown.
 */
void aura_destroy(void);

// ── Track Loading ──────────────────────────────────────────────────────────────

/**
 * Loads a local audio file at the given absolute path.
 * Decodes the header; does NOT start playback.
 * @param path  Null-terminated UTF-8 absolute file path.
 * @return 0 on success, -1 if file not found, -2 for unsupported codec.
 */
int32_t aura_load_track(const char* path);

/**
 * Returns the duration of the currently loaded track in milliseconds.
 * Returns 0 if no track is loaded.
 */
int64_t aura_get_duration(void);

// ── Playback Controls ──────────────────────────────────────────────────────────

/** Starts or resumes playback of the loaded track. */
void aura_play(void);

/** Pauses playback. */
void aura_pause(void);

/**
 * Seeks to [position_ms] milliseconds within the current track.
 * Clamps to [0, duration].
 */
void aura_seek(int64_t position_ms);

/** Sets the master volume (0.0 = silent, 1.0 = full). */
void aura_set_volume(double volume);

/** Sets the playback speed (0.5 = half speed, 2.0 = double speed). */
void aura_set_speed(double speed);

// ── Equaliser ─────────────────────────────────────────────────────────────────

/**
 * Sets the gain for a parametric EQ band.
 * @param band     Band index 0–9 (32Hz → 64 → 125 → 250 → 500 → 1k → 2k → 4k → 8k → 16kHz).
 * @param gain_db  Gain in decibels (-12.0 to +12.0).
 * @param q        Quality factor (0.5 to 4.0; 1.0 = default bandwidth).
 */
void aura_set_eq_band(int32_t band, double gain_db, double q);

/** Resets all EQ bands to 0 dB. */
void aura_reset_eq(void);

// ── Callback Registration ──────────────────────────────────────────────────────

/**
 * Registers the event callback.
 * Call ONCE after aura_init(). Not thread-safe; call from Dart isolate only.
 *
 * @param callback   Function pointer to the Dart NativeCallable port.
 * @param user_data  Opaque data passed back in every callback invocation.
 */
void aura_set_callback(AuraCallback callback, void* user_data);

// ── Fingerprinting (Sprint 2) ──────────────────────────────────────────────────

/**
 * Computes the Chromaprint acoustic fingerprint for [path].
 * Writes a null-terminated hex string into [out_hash] (max [out_size] bytes).
 * @return 0 on success, -1 if engine not initialised, -2 on IO error.
 */
int32_t aura_fingerprint(
    const char* path,
    char*       out_hash,
    int32_t     out_size
);

// ── Audio Analysis (Sprint 2) ──────────────────────────────────────────────────

/**
 * Extracts audio features for [path] and writes them into [out_features].
 * Feature layout (6 floats): [tempo, energy, valence, danceability, loudness, acousticness].
 * All values normalised to [0.0, 1.0] except loudness ([0.0, 1.0] mapped from dB range).
 * @return 0 on success.
 */
int32_t aura_analyze_features(
    const char* path,
    float*      out_features,
    int32_t     feature_count
);

#ifdef __cplusplus
}
#endif
