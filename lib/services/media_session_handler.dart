// lib/services/media_session_handler.dart
// Aura — Bridges playback to the OS media session (audio_service).
//
// This is what puts controls on the lock screen, in the notification shade, and
// on Bluetooth / Android Auto / CarPlay, and lets those surfaces drive
// playback. Aura's PlaybackOrchestrator remains the single source of truth;
// this handler only translates:
//
//   orchestrator state  ──▶  audio_service PlaybackState + MediaItem  (out)
//   transport buttons   ──▶  orchestrator play/pause/next/seek        (in)
//
// PLATFORM SETUP (one-time, cannot be done from Dart):
//   • Android — declare the AudioService + MediaButtonReceiver in
//     AndroidManifest.xml (see android/app/src/main/AndroidManifest.xml).
//   • iOS — the "audio" UIBackgroundMode is already set (Info.plist, Step 2.5).
// Without those, this class still compiles and no-ops rather than crashing.

import 'dart:async';

import 'package:audio_service/audio_service.dart';

import '../domain/entities/playback_state.dart' as aura;
import '../domain/entities/track.dart';
import '../domain/use_cases/playback_orchestrator.dart';

class AuraAudioHandler extends BaseAudioHandler with SeekHandler {
  AuraAudioHandler(this._orchestrator) {
    // Push current state immediately, then follow the orchestrator's stream.
    _project(_orchestrator.state);
    _sub = _orchestrator.stateStream.listen(_project);
  }

  final PlaybackOrchestrator _orchestrator;
  late final StreamSubscription<aura.PlaybackState> _sub;

  // ── OS → orchestrator (transport buttons) ──────────────────────────────────

  @override
  Future<void> play() async => _orchestrator.resume();

  @override
  Future<void> pause() async => _orchestrator.pause();

  @override
  Future<void> skipToNext() => _orchestrator.next();

  @override
  Future<void> skipToPrevious() => _orchestrator.previous();

  @override
  Future<void> seek(Duration position) async =>
      _orchestrator.seek(position.inMilliseconds);

  @override
  Future<void> stop() async {
    _orchestrator.pause();
    await super.stop();
  }

  // ── Orchestrator → OS (state projection) ────────────────────────────────────

  void _project(aura.PlaybackState state) {
    final track = state.currentTrack;
    if (track != null) {
      mediaItem.add(_toMediaItem(track));
    }
    playbackState.add(_toPlaybackState(state));
  }

  MediaItem _toMediaItem(Track track) => MediaItem(
        id: track.id,
        title: track.title,
        artist: track.artistName,
        album: track.albumTitle,
        duration: Duration(milliseconds: track.durationMs),
        artUri: (track.coverArtPath != null && track.coverArtPath!.isNotEmpty)
            ? Uri.file(track.coverArtPath!)
            : null,
      );

  PlaybackState _toPlaybackState(aura.PlaybackState state) {
    final playing = state.status == aura.EngineStatus.playing;
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: switch (state.status) {
        aura.EngineStatus.idle => AudioProcessingState.idle,
        aura.EngineStatus.loading => AudioProcessingState.loading,
        aura.EngineStatus.error => AudioProcessingState.error,
        _ => AudioProcessingState.ready,
      },
      playing: playing,
      updatePosition: Duration(milliseconds: state.positionMs),
      repeatMode: switch (state.repeatMode) {
        aura.RepeatMode.none => AudioServiceRepeatMode.none,
        aura.RepeatMode.one => AudioServiceRepeatMode.one,
        aura.RepeatMode.all => AudioServiceRepeatMode.all,
      },
      shuffleMode: state.isShuffleEnabled
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
    );
  }

  Future<void> dispose() async {
    await _sub.cancel();
  }
}
