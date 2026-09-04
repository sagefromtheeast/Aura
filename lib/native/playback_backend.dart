// lib/native/playback_backend.dart
// Aura — Playback backend abstraction.
//
// The C++ engine is the primary backend (gapless, 64-bit float DSP, parametric
// EQ, ReplayGain, crossfade). When it is unavailable — the shared library was
// not compiled for this platform, or a symbol failed to resolve — we fall back
// to the just_audio package so playback still works, minus the DSP features.
//
// PRD "Risks & Mitigations": "fallback to just_audio if engine fails".

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' as ja;

import 'audio_engine_ffi.dart';

/// Common surface both backends implement, so callers never branch on which
/// engine is live.
abstract interface class PlaybackBackend {
  /// Human-readable backend name, for diagnostics ("ffi" / "just_audio").
  String get name;

  /// False when EQ / ReplayGain / crossfade are no-ops on this backend.
  bool get supportsDsp;

  Future<bool> load(String path);
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);

  Duration get position;
  Duration get duration;
  bool get isPlaying;

  Stream<Duration> get positionStream;
  Stream<EngineState> get stateStream;
  Stream<String> get errorStream;

  void setVolume(double volume);
  void setSpeed(double speed);

  void setEqBand(int band, double gainDb, double q);
  void setEqPreset(EqPreset preset);
  void setReplayGain(double gainDb);
  void setCrossfade(int fadeMs);

  Future<void> dispose();
}

// ── Primary: C++ engine over FFI ──────────────────────────────────────────────

class FfiPlaybackBackend implements PlaybackBackend {
  FfiPlaybackBackend(this._engine);

  final AudioEngineFfi _engine;

  @override
  String get name => 'ffi';

  @override
  bool get supportsDsp => true;

  @override
  Future<bool> load(String path) async => _engine.loadTrack(path);

  @override
  Future<void> play() async => _engine.play();

  @override
  Future<void> pause() async => _engine.pause();

  @override
  Future<void> stop() async => _engine.stop();

  @override
  Future<void> seek(Duration position) async =>
      _engine.seek(position.inMilliseconds);

  @override
  Duration get position => Duration(milliseconds: _engine.getPositionMs());

  @override
  Duration get duration => Duration(milliseconds: _engine.getDurationMs());

  @override
  bool get isPlaying => _engine.isPlaying;

  @override
  Stream<Duration> get positionStream => _engine.positionStream;

  @override
  Stream<EngineState> get stateStream => _engine.stateStream;

  @override
  Stream<String> get errorStream => _engine.errorStream;

  @override
  void setVolume(double volume) => _engine.setVolume(volume);

  @override
  void setSpeed(double speed) => _engine.setSpeed(speed);

  @override
  void setEqBand(int band, double gainDb, double q) =>
      _engine.setEqBand(band, gainDb, q);

  @override
  void setEqPreset(EqPreset preset) => _engine.setEqPreset(preset);

  @override
  void setReplayGain(double gainDb) => _engine.setReplayGain(gainDb);

  @override
  void setCrossfade(int fadeMs) => _engine.setCrossfade(fadeMs);

  @override
  Future<void> dispose() async => _engine.destroy();
}

// ── Fallback: just_audio ──────────────────────────────────────────────────────

class JustAudioPlaybackBackend implements PlaybackBackend {
  JustAudioPlaybackBackend([ja.AudioPlayer? player])
      : _player = player ?? ja.AudioPlayer() {
    _stateSub = _player.playerStateStream.listen(
      (s) => _stateController.add(_mapState(s)),
      onError: (Object e) => _errorController.add(e.toString()),
    );
  }

  final ja.AudioPlayer _player;
  final _stateController = StreamController<EngineState>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  late final StreamSubscription<ja.PlayerState> _stateSub;

  static EngineState _mapState(ja.PlayerState s) {
    switch (s.processingState) {
      case ja.ProcessingState.idle:
        return EngineState.idle;
      case ja.ProcessingState.loading:
      case ja.ProcessingState.buffering:
        return EngineState.loading;
      case ja.ProcessingState.ready:
        return s.playing ? EngineState.playing : EngineState.paused;
      case ja.ProcessingState.completed:
        return EngineState.completed;
    }
  }

  @override
  String get name => 'just_audio';

  /// just_audio exposes no parametric EQ / ReplayGain / crossfade.
  @override
  bool get supportsDsp => false;

  @override
  Future<bool> load(String path) async {
    try {
      await _player.setFilePath(path);
      return true;
    } catch (e) {
      _errorController.add('just_audio failed to load: $e');
      return false;
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Duration get position => _player.position;

  @override
  Duration get duration => _player.duration ?? Duration.zero;

  @override
  bool get isPlaying => _player.playing;

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<EngineState> get stateStream => _stateController.stream;

  @override
  Stream<String> get errorStream => _errorController.stream;

  @override
  void setVolume(double volume) => _player.setVolume(volume);

  @override
  void setSpeed(double speed) => _player.setSpeed(speed);

  // DSP is unsupported here; calls are accepted and ignored so callers don't
  // have to branch. `supportsDsp` lets the UI grey out the Equalizer instead.
  @override
  void setEqBand(int band, double gainDb, double q) {}

  @override
  void setEqPreset(EqPreset preset) {}

  @override
  void setReplayGain(double gainDb) {}

  @override
  void setCrossfade(int fadeMs) {}

  @override
  Future<void> dispose() async {
    await _stateSub.cancel();
    await _stateController.close();
    await _errorController.close();
    await _player.dispose();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

/// Selects the C++ engine when it initialises, otherwise just_audio.
///
/// Reading this provider is what actually boots the native engine, so consume
/// it once at app start (main.dart) and share the instance.
final playbackBackendProvider = Provider<PlaybackBackend>((ref) {
  final engine = AudioEngineFfi.instance;

  if (engine.isAvailable && engine.init()) {
    debugPrint('[Aura] Using C++ audio engine v${engine.version} '
        '(ffmpeg: ${engine.hasFfmpeg})');
    final backend = FfiPlaybackBackend(engine);
    ref.onDispose(backend.dispose);
    return backend;
  }

  debugPrint('[Aura] C++ engine unavailable — falling back to just_audio.');
  final backend = JustAudioPlaybackBackend();
  ref.onDispose(backend.dispose);
  return backend;
});
