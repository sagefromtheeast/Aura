// lib/native/audio_engine_ffi.dart
// Aura — AudioEngineFfi
// Architecture §4.1: Dart FFI wrapper for the C++ audio engine.
//
// Binds the handle-based C API in cpp/audio_engine/audio_engine.h. Every call
// goes through an opaque engine pointer returned by aura_engine_create(), so
// multiple engines could coexist; this class owns one process-wide instance.
//
// GRACEFUL DEGRADATION
//   If libaura_engine is not present (engine not compiled for this platform),
//   [isAvailable] stays false and every method is a safe no-op. main.dart logs
//   this and the app falls back to the just_audio backend — see
//   lib/native/playback_backend.dart.
//
// CALLBACKS (AGENTS.md: "use NativeCallable callback ports")
//   The engine reports position/state/error from a native worker thread.
//   NativeCallable.listener() marshals those onto the Dart event loop, so the
//   UI thread is never blocked. Each is also republished as a broadcast stream.

import 'dart:async';
import 'dart:ffi';
import 'dart:io' show Platform;

import 'package:ffi/ffi.dart';

// ── Engine states (mirrors AuraPlaybackState and domain EngineStatus) ─────────

enum EngineState {
  idle,
  ready,
  playing,
  paused,
  loading,
  completed,
  error;

  static EngineState fromIndex(int index) =>
      (index >= 0 && index < EngineState.values.length)
          ? EngineState.values[index]
          : EngineState.idle;
}

/// Built-in EQ presets (mirrors AuraEqPreset and kEqPresetOrder in Dart).
enum EqPreset {
  flat,
  rock,
  pop,
  jazz,
  classical,
  custom;

  static EqPreset fromName(String name) {
    switch (name.toLowerCase()) {
      case 'rock':
        return EqPreset.rock;
      case 'pop':
        return EqPreset.pop;
      case 'jazz':
        return EqPreset.jazz;
      case 'classical':
        return EqPreset.classical;
      case 'custom':
        return EqPreset.custom;
      default:
        return EqPreset.flat;
    }
  }
}

/// Legacy event discriminators kept for `onEngineEvent` consumers.
abstract final class EngineEvent {
  static const int position = 0;
  static const int stateChange = 1;
  static const int error = 2;
}

// ── Native typedefs ───────────────────────────────────────────────────────────

typedef _CreateNative = Pointer<Void> Function();
typedef _CreateDart = Pointer<Void> Function();

typedef _DestroyNative = Void Function(Pointer<Void>);
typedef _DestroyDart = void Function(Pointer<Void>);

typedef _LoadTrackNative = Bool Function(Pointer<Void>, Pointer<Utf8>);
typedef _LoadTrackDart = bool Function(Pointer<Void>, Pointer<Utf8>);

typedef _VoidBoolNative = Bool Function(Pointer<Void>);
typedef _VoidBoolDart = bool Function(Pointer<Void>);

typedef _SeekNative = Bool Function(Pointer<Void>, Int64);
typedef _SeekDart = bool Function(Pointer<Void>, int);

typedef _GetI64Native = Int64 Function(Pointer<Void>);
typedef _GetI64Dart = int Function(Pointer<Void>);

typedef _GetI32Native = Int32 Function(Pointer<Void>);
typedef _GetI32Dart = int Function(Pointer<Void>);

typedef _SetEqBandNative = Void Function(Pointer<Void>, Int32, Float, Float);
typedef _SetEqBandDart = void Function(Pointer<Void>, int, double, double);

typedef _SetIntNative = Void Function(Pointer<Void>, Int32);
typedef _SetIntDart = void Function(Pointer<Void>, int);

typedef _SetFloatNative = Void Function(Pointer<Void>, Float);
typedef _SetFloatDart = void Function(Pointer<Void>, double);

typedef _SetBoolNative = Void Function(Pointer<Void>, Bool);
typedef _SetBoolDart = void Function(Pointer<Void>, bool);

typedef _VoidNative = Void Function(Pointer<Void>);
typedef _VoidDart = void Function(Pointer<Void>);

// Callback signatures.
typedef _PositionCbNative = Void Function(Int64, Pointer<Void>);
typedef _StateCbNative = Void Function(Int32, Pointer<Void>);
typedef _ErrorCbNative = Void Function(Pointer<Utf8>, Pointer<Void>);

typedef _SetPositionCbNative = Void Function(
    Pointer<Void>, Pointer<NativeFunction<_PositionCbNative>>, Pointer<Void>);
typedef _SetPositionCbDart = void Function(
    Pointer<Void>, Pointer<NativeFunction<_PositionCbNative>>, Pointer<Void>);

typedef _SetStateCbNative = Void Function(
    Pointer<Void>, Pointer<NativeFunction<_StateCbNative>>, Pointer<Void>);
typedef _SetStateCbDart = void Function(
    Pointer<Void>, Pointer<NativeFunction<_StateCbNative>>, Pointer<Void>);

typedef _SetErrorCbNative = Void Function(
    Pointer<Void>, Pointer<NativeFunction<_ErrorCbNative>>, Pointer<Void>);
typedef _SetErrorCbDart = void Function(
    Pointer<Void>, Pointer<NativeFunction<_ErrorCbNative>>, Pointer<Void>);

// Analysis (engine-independent).
typedef _AnalyzeNative = Bool Function(Pointer<Utf8>, Pointer<Float>, Int32);
typedef _AnalyzeDart = bool Function(Pointer<Utf8>, Pointer<Float>, int);

typedef _FingerprintNative = Bool Function(
    Pointer<Utf8>, Pointer<Uint32>, Pointer<Int32>);
typedef _FingerprintDart = bool Function(
    Pointer<Utf8>, Pointer<Uint32>, Pointer<Int32>);

typedef _VersionNative = Pointer<Utf8> Function();
typedef _VersionDart = Pointer<Utf8> Function();

typedef _HasFfmpegNative = Bool Function();
typedef _HasFfmpegDart = bool Function();

// ─────────────────────────────────────────────────────────────────────────────

/// Dart wrapper around the C++ audio engine shared library.
class AudioEngineFfi {
  AudioEngineFfi._();

  static AudioEngineFfi? _instance;

  /// Singleton; binds the native library on first access.
  static AudioEngineFfi get instance {
    _instance ??= AudioEngineFfi._().._bindNative();
    return _instance!;
  }

  /// Test seam: drops the cached singleton so a fresh bind can be attempted.
  static void resetForTesting() {
    _instance?.destroy();
    _instance = null;
  }

  bool _isAvailable = false;

  /// True when the shared library loaded and every symbol resolved.
  bool get isAvailable => _isAvailable;

  /// Opaque `AuraEngine*`. `nullptr` until [init] succeeds.
  Pointer<Void> _engine = nullptr;

  bool get _ready => _isAvailable && _engine != nullptr;

  // Bound symbols (null when the library is absent).
  _CreateDart? _create;
  _DestroyDart? _destroyEngine;
  _LoadTrackDart? _loadTrackFn;
  _VoidBoolDart? _playFn;
  _VoidBoolDart? _pauseFn;
  _VoidBoolDart? _stopFn;
  _SeekDart? _seekFn;
  _GetI64Dart? _getPositionFn;
  _GetI64Dart? _getDurationFn;
  _VoidBoolDart? _isPlayingFn;
  _GetI32Dart? _getStateFn;
  _SetEqBandDart? _setEqBandFn;
  _SetIntDart? _setEqPresetFn;
  _VoidDart? _resetEqFn;
  _SetBoolDart? _setEqEnabledFn;
  _SetFloatDart? _setReplayGainFn;
  _SetIntDart? _setCrossfadeFn;
  _SetFloatDart? _setVolumeFn;
  _SetFloatDart? _setSpeedFn;
  _SetPositionCbDart? _setPositionCb;
  _SetStateCbDart? _setStateCb;
  _SetErrorCbDart? _setErrorCb;
  _AnalyzeDart? _analyzeFn;
  _FingerprintDart? _fingerprintFn;
  _VersionDart? _versionFn;
  _HasFfmpegDart? _hasFfmpegFn;

  // ── Event surfaces ─────────────────────────────────────────────────────────

  /// Legacy unified callback: `(eventType, value)` using [EngineEvent].
  /// Retained so existing wiring in shared/providers.dart keeps working.
  void Function(int eventType, int valueMs)? onEngineEvent;

  final _positionController = StreamController<Duration>.broadcast();
  final _stateController = StreamController<EngineState>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  /// Playback position ticks (~5/second while playing).
  Stream<Duration> get positionStream => _positionController.stream;

  /// Engine state transitions.
  Stream<EngineState> get stateStream => _stateController.stream;

  /// Fatal and non-fatal engine errors.
  Stream<String> get errorStream => _errorController.stream;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  /// Creates the native engine and registers callbacks.
  /// Returns false when the library is unavailable.
  bool init() {
    if (!_isAvailable) return false;
    if (_engine != nullptr) return true;

    _engine = _create!();
    if (_engine == nullptr) return false;

    _registerCallbacks();
    return true;
  }

  /// Destroys the native engine and releases callback ports.
  void destroy() {
    if (_engine != nullptr) {
      _destroyEngine?.call(_engine);
      _engine = nullptr;
    }
    _positionCallable?.close();
    _stateCallable?.close();
    _errorCallable?.close();
    _positionCallable = null;
    _stateCallable = null;
    _errorCallable = null;
  }

  // ── Playback ───────────────────────────────────────────────────────────────

  /// Loads an absolute file [path]. Returns false when unavailable or undecodable.
  bool loadTrack(String path) {
    if (!_ready) return false;
    final ptr = path.toNativeUtf8();
    try {
      return _loadTrackFn!(_engine, ptr);
    } finally {
      calloc.free(ptr);
    }
  }

  void play() {
    if (_ready) _playFn?.call(_engine);
  }

  void pause() {
    if (_ready) _pauseFn?.call(_engine);
  }

  void stop() {
    if (_ready) _stopFn?.call(_engine);
  }

  void seek(int positionMs) {
    if (_ready) _seekFn?.call(_engine, positionMs);
  }

  /// Current position in milliseconds.
  int getPositionMs() => _ready ? _getPositionFn!(_engine) : 0;

  /// Duration of the loaded track in milliseconds.
  int getDurationMs() => _ready ? _getDurationFn!(_engine) : 0;

  bool get isPlaying => _ready && _isPlayingFn!(_engine);

  EngineState get state =>
      _ready ? EngineState.fromIndex(_getStateFn!(_engine)) : EngineState.idle;

  // ── DSP ────────────────────────────────────────────────────────────────────

  /// Sets EQ band [band] (0-9) to [gainDb] dB with quality factor [q].
  void setEqBand(int band, double gainDb, double q) {
    if (_ready) _setEqBandFn?.call(_engine, band, gainDb, q);
  }

  void setEqPreset(EqPreset preset) {
    if (_ready) _setEqPresetFn?.call(_engine, preset.index);
  }

  void resetEq() {
    if (_ready) _resetEqFn?.call(_engine);
  }

  void setEqEnabled(bool enabled) {
    if (_ready) _setEqEnabledFn?.call(_engine, enabled);
  }

  /// ReplayGain adjustment for the current track, in dB.
  void setReplayGain(double gainDb) {
    if (_ready) _setReplayGainFn?.call(_engine, gainDb);
  }

  /// Crossfade length in milliseconds (0-12000; 0 disables).
  void setCrossfade(int fadeMs) {
    if (_ready) _setCrossfadeFn?.call(_engine, fadeMs);
  }

  void setVolume(double volume) {
    if (_ready) _setVolumeFn?.call(_engine, volume);
  }

  void setSpeed(double speed) {
    if (_ready) _setSpeedFn?.call(_engine, speed);
  }

  // ── Analysis ───────────────────────────────────────────────────────────────

  /// Extracts the 6-dimension feature vector for [path], or null on failure.
  /// Layout: [tempo, energy, valence, danceability, loudness, acousticness].
  List<double>? analyzeFeatures(String path) {
    if (!_isAvailable || _analyzeFn == null) return null;
    final pathPtr = path.toNativeUtf8();
    final out = calloc<Float>(6);
    try {
      if (!_analyzeFn!(pathPtr, out, 6)) return null;
      return List<double>.generate(6, (i) => out[i].toDouble(), growable: false);
    } finally {
      calloc.free(pathPtr);
      calloc.free(out);
    }
  }

  /// Async wrapper matching the spec's `analyzeTrack` name.
  Future<List<double>?> analyzeTrack(String path) async => analyzeFeatures(path);

  /// Raw windowed sub-fingerprints for [path], or null on failure.
  List<int>? getFingerprintValues(String path, {int capacity = 128}) {
    if (!_isAvailable || _fingerprintFn == null) return null;
    final pathPtr = path.toNativeUtf8();
    final out = calloc<Uint32>(capacity);
    final sizePtr = calloc<Int32>()..value = capacity;
    try {
      if (!_fingerprintFn!(pathPtr, out, sizePtr)) return null;
      final count = sizePtr.value;
      if (count <= 0) return null;
      return List<int>.generate(count, (i) => out[i], growable: false);
    } finally {
      calloc.free(pathPtr);
      calloc.free(out);
      calloc.free(sizePtr);
    }
  }

  /// Hex fingerprint string. Kept for [DuplicateDetector], which compares
  /// fingerprints as strings.
  String? getFingerprint(String path) {
    final values = getFingerprintValues(path);
    if (values == null || values.isEmpty) return null;
    return values
        .map((v) => v.toRadixString(16).padLeft(8, '0'))
        .join();
  }

  // ── Build info ─────────────────────────────────────────────────────────────

  String get version {
    if (!_isAvailable || _versionFn == null) return 'unavailable';
    return _versionFn!().toDartString();
  }

  bool get hasFfmpeg => _isAvailable && (_hasFfmpegFn?.call() ?? false);

  // ── Private: binding ───────────────────────────────────────────────────────

  void _bindNative() {
    try {
      final lib = _loadLibrary();
      if (lib == null) return;

      _create = lib.lookupFunction<_CreateNative, _CreateDart>('aura_engine_create');
      _destroyEngine =
          lib.lookupFunction<_DestroyNative, _DestroyDart>('aura_engine_destroy');
      _loadTrackFn = lib
          .lookupFunction<_LoadTrackNative, _LoadTrackDart>('aura_engine_load_track');
      _playFn = lib.lookupFunction<_VoidBoolNative, _VoidBoolDart>('aura_engine_play');
      _pauseFn = lib.lookupFunction<_VoidBoolNative, _VoidBoolDart>('aura_engine_pause');
      _stopFn = lib.lookupFunction<_VoidBoolNative, _VoidBoolDart>('aura_engine_stop');
      _seekFn = lib.lookupFunction<_SeekNative, _SeekDart>('aura_engine_seek');
      _getPositionFn = lib
          .lookupFunction<_GetI64Native, _GetI64Dart>('aura_engine_get_position');
      _getDurationFn = lib
          .lookupFunction<_GetI64Native, _GetI64Dart>('aura_engine_get_duration');
      _isPlayingFn =
          lib.lookupFunction<_VoidBoolNative, _VoidBoolDart>('aura_engine_is_playing');
      _getStateFn =
          lib.lookupFunction<_GetI32Native, _GetI32Dart>('aura_engine_get_state');

      _setEqBandFn = lib
          .lookupFunction<_SetEqBandNative, _SetEqBandDart>('aura_engine_set_eq_band');
      _setEqPresetFn = lib
          .lookupFunction<_SetIntNative, _SetIntDart>('aura_engine_set_eq_preset');
      _resetEqFn = lib.lookupFunction<_VoidNative, _VoidDart>('aura_engine_reset_eq');
      _setEqEnabledFn = lib
          .lookupFunction<_SetBoolNative, _SetBoolDart>('aura_engine_set_eq_enabled');
      _setReplayGainFn = lib.lookupFunction<_SetFloatNative, _SetFloatDart>(
          'aura_engine_set_replay_gain');
      _setCrossfadeFn = lib
          .lookupFunction<_SetIntNative, _SetIntDart>('aura_engine_set_crossfade');
      _setVolumeFn =
          lib.lookupFunction<_SetFloatNative, _SetFloatDart>('aura_engine_set_volume');
      _setSpeedFn =
          lib.lookupFunction<_SetFloatNative, _SetFloatDart>('aura_engine_set_speed');

      _setPositionCb = lib.lookupFunction<_SetPositionCbNative, _SetPositionCbDart>(
          'aura_engine_set_position_callback');
      _setStateCb = lib.lookupFunction<_SetStateCbNative, _SetStateCbDart>(
          'aura_engine_set_state_callback');
      _setErrorCb = lib.lookupFunction<_SetErrorCbNative, _SetErrorCbDart>(
          'aura_engine_set_error_callback');

      _analyzeFn =
          lib.lookupFunction<_AnalyzeNative, _AnalyzeDart>('aura_analyze_track');
      _fingerprintFn = lib
          .lookupFunction<_FingerprintNative, _FingerprintDart>('aura_get_fingerprint');
      _versionFn =
          lib.lookupFunction<_VersionNative, _VersionDart>('aura_engine_version');
      _hasFfmpegFn =
          lib.lookupFunction<_HasFfmpegNative, _HasFfmpegDart>('aura_engine_has_ffmpeg');

      _isAvailable = true;
    } catch (_) {
      // Library missing or a symbol failed to resolve — stay in fallback mode.
      _isAvailable = false;
    }
  }

  DynamicLibrary? _loadLibrary() {
    try {
      if (Platform.isAndroid) {
        return DynamicLibrary.open('libaura_engine.so');
      }
      if (Platform.isIOS || Platform.isMacOS) {
        // Linked statically into the app binary via the CocoaPods spec.
        return DynamicLibrary.process();
      }
      if (Platform.isLinux) {
        return DynamicLibrary.open('libaura_engine.so');
      }
      if (Platform.isWindows) {
        return DynamicLibrary.open('aura_engine.dll');
      }
    } catch (_) {
      // Not compiled for this platform.
    }
    return null;
  }

  // ── Private: callbacks ─────────────────────────────────────────────────────

  NativeCallable<_PositionCbNative>? _positionCallable;
  NativeCallable<_StateCbNative>? _stateCallable;
  NativeCallable<_ErrorCbNative>? _errorCallable;

  void _registerCallbacks() {
    if (!_ready) return;

    _positionCallable = NativeCallable<_PositionCbNative>.listener(_onPosition);
    _stateCallable = NativeCallable<_StateCbNative>.listener(_onState);
    _errorCallable = NativeCallable<_ErrorCbNative>.listener(_onError);

    _setPositionCb?.call(_engine, _positionCallable!.nativeFunction, nullptr);
    _setStateCb?.call(_engine, _stateCallable!.nativeFunction, nullptr);
    _setErrorCb?.call(_engine, _errorCallable!.nativeFunction, nullptr);
  }

  // These run on the Dart event loop via the NativeCallable ports, so touching
  // controllers and Dart state here is safe.
  static void _onPosition(int positionMs, Pointer<Void> _) {
    final self = _instance;
    if (self == null) return;
    if (!self._positionController.isClosed) {
      self._positionController.add(Duration(milliseconds: positionMs));
    }
    self.onEngineEvent?.call(EngineEvent.position, positionMs);
  }

  static void _onState(int stateIndex, Pointer<Void> _) {
    final self = _instance;
    if (self == null) return;
    if (!self._stateController.isClosed) {
      self._stateController.add(EngineState.fromIndex(stateIndex));
    }
    self.onEngineEvent?.call(EngineEvent.stateChange, stateIndex);
  }

  static void _onError(Pointer<Utf8> message, Pointer<Void> _) {
    final self = _instance;
    if (self == null) return;
    final text = message == nullptr ? 'Unknown engine error' : message.toDartString();
    if (!self._errorController.isClosed) {
      self._errorController.add(text);
    }
    self.onEngineEvent?.call(EngineEvent.error, 0);
  }
}
