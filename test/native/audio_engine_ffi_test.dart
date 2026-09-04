// test/native/audio_engine_ffi_test.dart
// Aura — FFI wrapper tests.
//
// These run on the host, where libaura_engine is normally NOT loadable, so
// they mainly pin down the graceful-degradation contract: every method must be
// a safe no-op rather than throwing or crashing when the native library is
// missing. That contract is what keeps the just_audio fallback viable.
//
// The DSP itself is verified natively — see cpp/audio_engine/tests/.
//
// Run: flutter test test/native/audio_engine_ffi_test.dart

import 'package:flutter_test/flutter_test.dart';

import 'package:aura/native/audio_engine_ffi.dart';

void main() {
  group('EngineState', () {
    test('indices match the native AuraPlaybackState enum', () {
      expect(EngineState.idle.index, 0);
      expect(EngineState.ready.index, 1);
      expect(EngineState.playing.index, 2);
      expect(EngineState.paused.index, 3);
      expect(EngineState.loading.index, 4);
      expect(EngineState.completed.index, 5);
      expect(EngineState.error.index, 6);
    });

    test('fromIndex maps valid values and clamps invalid ones', () {
      expect(EngineState.fromIndex(2), EngineState.playing);
      expect(EngineState.fromIndex(-1), EngineState.idle);
      expect(EngineState.fromIndex(99), EngineState.idle);
    });
  });

  group('EqPreset', () {
    test('indices match the native AuraEqPreset enum and Dart preset order', () {
      expect(EqPreset.flat.index, 0);
      expect(EqPreset.rock.index, 1);
      expect(EqPreset.pop.index, 2);
      expect(EqPreset.jazz.index, 3);
      expect(EqPreset.classical.index, 4);
      expect(EqPreset.custom.index, 5);
    });

    test('fromName is case-insensitive and defaults to flat', () {
      expect(EqPreset.fromName('Rock'), EqPreset.rock);
      expect(EqPreset.fromName('CLASSICAL'), EqPreset.classical);
      expect(EqPreset.fromName('Custom'), EqPreset.custom);
      expect(EqPreset.fromName('nonsense'), EqPreset.flat);
    });
  });

  group('EngineEvent', () {
    test('discriminators are stable', () {
      expect(EngineEvent.position, 0);
      expect(EngineEvent.stateChange, 1);
      expect(EngineEvent.error, 2);
    });
  });

  group('AudioEngineFfi graceful degradation', () {
    late AudioEngineFfi engine;

    setUp(() {
      AudioEngineFfi.resetForTesting();
      engine = AudioEngineFfi.instance;
    });

    tearDown(AudioEngineFfi.resetForTesting);

    test('exposes a singleton', () {
      expect(identical(AudioEngineFfi.instance, AudioEngineFfi.instance), isTrue);
    });

    test('init() reports availability without throwing', () {
      // True only if libaura_engine happens to be loadable on this host.
      expect(() => engine.init(), returnsNormally);
      if (!engine.isAvailable) {
        expect(engine.init(), isFalse);
      }
    });

    test('playback controls are safe no-ops when unavailable', () {
      if (engine.isAvailable) return; // Native library present; skip.

      expect(engine.loadTrack('/nonexistent.mp3'), isFalse);
      expect(() => engine.play(), returnsNormally);
      expect(() => engine.pause(), returnsNormally);
      expect(() => engine.stop(), returnsNormally);
      expect(() => engine.seek(1000), returnsNormally);
      expect(engine.getPositionMs(), 0);
      expect(engine.getDurationMs(), 0);
      expect(engine.isPlaying, isFalse);
      expect(engine.state, EngineState.idle);
    });

    test('DSP setters are safe no-ops when unavailable', () {
      if (engine.isAvailable) return;

      expect(() => engine.setEqBand(0, 6.0, 1.0), returnsNormally);
      expect(() => engine.setEqPreset(EqPreset.rock), returnsNormally);
      expect(() => engine.resetEq(), returnsNormally);
      expect(() => engine.setEqEnabled(true), returnsNormally);
      expect(() => engine.setReplayGain(-3.0), returnsNormally);
      expect(() => engine.setCrossfade(5000), returnsNormally);
      expect(() => engine.setVolume(0.5), returnsNormally);
      expect(() => engine.setSpeed(1.25), returnsNormally);
    });

    test('analysis returns null rather than throwing when unavailable', () {
      if (engine.isAvailable) return;

      expect(engine.analyzeFeatures('/nonexistent.mp3'), isNull);
      expect(engine.getFingerprint('/nonexistent.mp3'), isNull);
      expect(engine.getFingerprintValues('/nonexistent.mp3'), isNull);
    });

    test('streams are broadcast and outlive having no listeners', () async {
      // Broadcast streams must accept multiple simultaneous listeners.
      final posA = engine.positionStream.listen((_) {});
      final posB = engine.positionStream.listen((_) {});
      final state = engine.stateStream.listen((_) {});
      final err = engine.errorStream.listen((_) {});

      expect(engine.positionStream.isBroadcast, isTrue);
      expect(engine.stateStream.isBroadcast, isTrue);
      expect(engine.errorStream.isBroadcast, isTrue);

      await posA.cancel();
      await posB.cancel();
      await state.cancel();
      await err.cancel();
    });

    test('destroy() is idempotent', () {
      expect(() => engine.destroy(), returnsNormally);
      expect(() => engine.destroy(), returnsNormally);
    });

    test('version reports unavailable without the native library', () {
      if (engine.isAvailable) return;
      expect(engine.version, 'unavailable');
      expect(engine.hasFfmpeg, isFalse);
    });
  });
}
