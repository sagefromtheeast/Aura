// lib/native/audio_engine_ffi.dart
// Aura — AudioEngineFfi
// Architecture §4.1 / CLAUDE.md §4: Dart FFI wrapper for the C++ audio engine.
//
// ═══════════════════════════════════════════════════════════════════════════════
// SPRINT 1 STUB STRATEGY
// ═══════════════════════════════════════════════════════════════════════════════
//
// The C++ shared library (libaura_engine.so / libaura_engine.dylib) is not yet
// compiled. This class uses a "stub mode" that:
//   1. Attempts to load the native library at runtime.
//   2. If the library is absent (Sprint 1), falls back to no-op stubs.
//   3. The callback port infrastructure is wired up now so Sprint 2 only needs
//      to compile the C++ library and call aura_set_callback().
//
// CALLBACK ARCHITECTURE (AGENTS.md: "use NativeCallable callback ports"):
//   The C++ engine emits position ticks and state changes asynchronously.
//   We use dart:ffi NativeCallable<...>.listener() which:
//     - Runs the Dart callback on the Dart isolate (no UI thread blocking).
//     - Is safe to call from C++ native threads (async port mechanism).
//
// FFI FUNCTION SIGNATURES (matches native/include/audio_engine.h):
//   int32_t  aura_init(void);
//   int32_t  aura_load_track(const char* path);
//   void     aura_play(void);
//   void     aura_pause(void);
//   void     aura_seek(int64_t position_ms);
//   void     aura_set_eq_band(int32_t band, double gain_db, double q);
//   void     aura_set_volume(double volume);
//   void     aura_set_callback(AuraCallback callback, void* user_data);
//   int64_t  aura_get_duration(void);
//   void     aura_destroy(void);
//
//   typedef void (*AuraCallback)(int32_t event_type, int64_t value, void* user_data);
//   // event_type: 0=position, 1=stateChange, 2=error
//
// ═══════════════════════════════════════════════════════════════════════════════

import 'dart:ffi';
import 'dart:io' show Platform;
import 'package:ffi/ffi.dart';

// ── Native type aliases ────────────────────────────────────────────────────────

/// C: void (*AuraCallback)(int32_t event_type, int64_t value, void* user_data)
typedef AuraCallbackNative = Void Function(
  Int32 eventType,
  Int64 value,
  Pointer<Void> userData,
);
typedef AuraCallbackDart = void Function(int eventType, int value, Pointer<Void> userData);

/// Event types emitted by the C++ engine via callback.
abstract final class EngineEvent {
  static const int position = 0;    // value = positionMs
  static const int stateChange = 1; // value = EngineStatus index
  static const int error = 2;       // value = error code
}

// ── FFI function typedefs ──────────────────────────────────────────────────────

typedef _AuraInitNative = Int32 Function();
typedef _AuraInitDart = int Function();

typedef _AuraLoadTrackNative = Int32 Function(Pointer<Utf8> path);
typedef _AuraLoadTrackDart = int Function(Pointer<Utf8> path);

typedef _AuraPlayNative = Void Function();
typedef _AuraPlayDart = void Function();

typedef _AuraPauseNative = Void Function();
typedef _AuraPauseDart = void Function();

typedef _AuraSeekNative = Void Function(Int64 positionMs);
typedef _AuraSeekDart = void Function(int positionMs);

typedef _AuraSetEqBandNative = Void Function(Int32 band, Double gainDb, Double q);
typedef _AuraSetEqBandDart = void Function(int band, double gainDb, double q);

typedef _AuraSetVolumeNative = Void Function(Double volume);
typedef _AuraSetVolumeDart = void Function(double volume);

typedef _AuraSetCallbackNative = Void Function(
  Pointer<NativeFunction<AuraCallbackNative>> callback,
  Pointer<Void> userData,
);
typedef _AuraSetCallbackDart = void Function(
  Pointer<NativeFunction<AuraCallbackNative>> callback,
  Pointer<Void> userData,
);

typedef _AuraGetDurationNative = Int64 Function();
typedef _AuraGetDurationDart = int Function();

typedef _AuraDestroyNative = Void Function();
typedef _AuraDestroyDart = void Function();

typedef _AuraFingerprintNative = Int32 Function(Pointer<Utf8> path, Pointer<Utf8> outHash, Int32 outSize);
typedef _AuraFingerprintDart = int Function(Pointer<Utf8> path, Pointer<Utf8> outHash, int outSize);

typedef _AuraAnalyzeFeaturesNative = Int32 Function(Pointer<Utf8> path, Pointer<Float> outFeatures, Int32 featureCount);
typedef _AuraAnalyzeFeaturesDart = int Function(Pointer<Utf8> path, Pointer<Float> outFeatures, int featureCount);

// ─────────────────────────────────────────────────────────────────────────────

/// Dart wrapper around the C++ audio engine shared library.
///
/// In Sprint 1, the library may not be present; all calls are no-ops.
/// In Sprint 2, compile libaura_engine and drop it into the platform dirs.
class AudioEngineFfi {
  AudioEngineFfi._();

  static AudioEngineFfi? _instance;

  /// Returns the singleton instance.
  /// Initialises the FFI bindings on first call.
  static AudioEngineFfi get instance {
    _instance ??= AudioEngineFfi._().._bindNative();
    return _instance!;
  }

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  // ── Bound native functions (null when library absent) ─────────────────────
  _AuraInitDart? _init;
  _AuraLoadTrackDart? _loadTrack;
  _AuraPlayDart? _play;
  _AuraPauseDart? _pause;
  _AuraSeekDart? _seek;
  _AuraSetEqBandDart? _setEqBand;
  _AuraSetVolumeDart? _setVolume;
  _AuraSetCallbackDart? _setCallback;
  _AuraGetDurationDart? _getDuration;
  _AuraDestroyDart? _destroy;
  _AuraFingerprintDart? _fingerprint;
  _AuraAnalyzeFeaturesDart? _analyzeFeatures;

  /// Callback invoked when the engine emits a position or state event.
  /// Set by [PlaybackOrchestrator] after constructing this instance.
  void Function(int eventType, int valueMs)? onEngineEvent;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  /// Initialises the audio engine.
  ///
  /// Returns true on success, false if the library is unavailable (Sprint 1).
  bool init() {
    if (!_isAvailable) return false;
    final result = _init!();
    if (result == 0) _registerCallback();
    return result == 0;
  }

  /// Destroys the engine and frees native resources.
  void destroy() {
    if (!_isAvailable) return;
    _destroy!();
    _nativeCallable?.close();
    _nativeCallable = null;
  }

  // ── Playback Controls ──────────────────────────────────────────────────────

  /// Loads a track by absolute file [path].
  /// Returns false if the library is unavailable or the file cannot be loaded.
  bool loadTrack(String path) {
    if (!_isAvailable) return false;
    final pathPtr = path.toNativeUtf8();
    final result = _loadTrack!(pathPtr);
    calloc.free(pathPtr);
    return result == 0;
  }

  void play() => _play?.call();
  void pause() => _pause?.call();
  void seek(int positionMs) => _seek?.call(positionMs);

  /// Returns the duration of the loaded track in milliseconds.
  int getDurationMs() => _isAvailable ? _getDuration!() : 0;

  // ── EQ & Volume ───────────────────────────────────────────────────────────

  /// Sets EQ band [band] (0–9) gain to [gainDb] dB with quality factor [q].
  void setEqBand(int band, double gainDb, double q) =>
      _setEqBand?.call(band, gainDb, q);

  void setVolume(double volume) => _setVolume?.call(volume);

  // ── Fingerprint & Analysis ───────────────────────────────────────────────
  
  String? getFingerprint(String path) {
    if (!_isAvailable || _fingerprint == null) return null;
    final pathPtr = path.toNativeUtf8();
    final outHash = calloc<Int8>(256).cast<Utf8>();
    final result = _fingerprint!(pathPtr, outHash, 256);
    String? hash;
    if (result == 0) {
      hash = outHash.toDartString();
    }
    calloc.free(pathPtr);
    calloc.free(outHash);
    return hash;
  }

  List<double>? analyzeFeatures(String path) {
    if (!_isAvailable || _analyzeFeatures == null) return null;
    final pathPtr = path.toNativeUtf8();
    final outFeatures = calloc<Float>(6);
    final result = _analyzeFeatures!(pathPtr, outFeatures, 6);
    List<double>? features;
    if (result == 0) {
      features = [
        outFeatures[0].toDouble(),
        outFeatures[1].toDouble(),
        outFeatures[2].toDouble(),
        outFeatures[3].toDouble(),
        outFeatures[4].toDouble(),
        outFeatures[5].toDouble(),
      ];
    }
    calloc.free(pathPtr);
    calloc.free(outFeatures);
    return features;
  }

  // ── Private: Library Loading ───────────────────────────────────────────────

  void _bindNative() {
    try {
      final lib = _loadLibrary();
      if (lib == null) return; // Library not yet compiled.

      _init = lib.lookupFunction<_AuraInitNative, _AuraInitDart>('aura_init');
      _loadTrack = lib.lookupFunction<_AuraLoadTrackNative, _AuraLoadTrackDart>(
          'aura_load_track');
      _play = lib.lookupFunction<_AuraPlayNative, _AuraPlayDart>('aura_play');
      _pause =
          lib.lookupFunction<_AuraPauseNative, _AuraPauseDart>('aura_pause');
      _seek = lib.lookupFunction<_AuraSeekNative, _AuraSeekDart>('aura_seek');
      _setEqBand = lib.lookupFunction<_AuraSetEqBandNative, _AuraSetEqBandDart>(
          'aura_set_eq_band');
      _setVolume = lib.lookupFunction<_AuraSetVolumeNative, _AuraSetVolumeDart>(
          'aura_set_volume');
      _setCallback =
          lib.lookupFunction<_AuraSetCallbackNative, _AuraSetCallbackDart>(
              'aura_set_callback');
      _getDuration =
          lib.lookupFunction<_AuraGetDurationNative, _AuraGetDurationDart>(
              'aura_get_duration');
      _destroy =
          lib.lookupFunction<_AuraDestroyNative, _AuraDestroyDart>('aura_destroy');
      _fingerprint = 
          lib.lookupFunction<_AuraFingerprintNative, _AuraFingerprintDart>('aura_fingerprint');
      _analyzeFeatures = 
          lib.lookupFunction<_AuraAnalyzeFeaturesNative, _AuraAnalyzeFeaturesDart>('aura_analyze_features');

      _isAvailable = true;
    } catch (_) {
      // Library not present in Sprint 1 — silent fallback.
      _isAvailable = false;
    }
  }

  DynamicLibrary? _loadLibrary() {
    try {
      if (Platform.isAndroid) {
        return DynamicLibrary.open('libaura_engine.so');
      } else if (Platform.isIOS) {
        return DynamicLibrary.process(); // Statically linked on iOS.
      }
    } catch (_) {
      // Library not compiled yet.
    }
    return null;
  }

  // ── Private: Callback Registration ────────────────────────────────────────

  NativeCallable<AuraCallbackNative>? _nativeCallable;

  /// Registers a [NativeCallable] with the C++ engine.
  ///
  /// AGENTS.md: "use NativeCallable callback ports to prevent blocking UI thread."
  /// The callback runs on the Dart event loop asynchronously.
  void _registerCallback() {
    if (!_isAvailable || _setCallback == null) return;

    _nativeCallable = NativeCallable<AuraCallbackNative>.listener(
      _onEngineCallback,
    );

    _setCallback!(
      _nativeCallable!.nativeFunction,
      Pointer.fromAddress(0), // user_data = null
    );
  }

  /// Static callback invoked by the C++ engine on position/state changes.
  /// Runs on Dart isolate via the NativeCallable port.
  static void _onEngineCallback(
      int eventType, int value, Pointer<Void> userData) {
    _instance?.onEngineEvent?.call(eventType, value);
  }
}
