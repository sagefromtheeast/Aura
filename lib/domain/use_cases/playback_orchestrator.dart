// lib/domain/use_cases/playback_orchestrator.dart
// Aura — PlaybackOrchestrator
// Architecture §4.1: thin Dart wrapper coordinating AudioEngine, shuffle,
// and behavior recording.

import 'dart:async';
import '../entities/playback_state.dart';
import '../entities/track.dart';
import '../entities/shuffle_config.dart';
import '../repositories/behavior_repository.dart';
import '../repositories/music_repository.dart';
import 'intelli_shuffle_engine.dart';
import '../../core/constants.dart';
import '../../core/errors.dart';
import '../../native/audio_engine_ffi.dart';

/// Orchestrates playback: delegates to [AudioEngineFfi] for audio control,
/// [IntelliShuffleEngine] for queue management, and [BehaviorRepository]
/// for event recording.
///
/// State is published as a [Stream<PlaybackState>] which Riverpod providers
/// subscribe to (see `shared/providers.dart`).
class PlaybackOrchestrator {
  PlaybackOrchestrator({
    required AudioEngineFfi audioEngine,
    required IntelliShuffleEngine shuffleEngine,
    required MusicRepository musicRepository,
    required BehaviorRepository behaviorRepository,
  })  : _engine = audioEngine,
        _shuffleEngine = shuffleEngine,
        _musicRepo = musicRepository,
        _behaviorRepo = behaviorRepository;

  final AudioEngineFfi _engine;
  final IntelliShuffleEngine _shuffleEngine;
  final MusicRepository _musicRepo;
  final BehaviorRepository _behaviorRepo;
  final _stateController = StreamController<PlaybackState>.broadcast();

  PlaybackState _state = PlaybackState.initial;
  Track? _currentTrack;

  /// Recently played tracks, oldest first — backs [previous].
  final List<Track> _history = [];
  static const int _maxHistory = 50;

  /// Pressing "previous" within this window restarts the current track instead
  /// of jumping back, matching every other music player.
  static const int _restartThresholdMs = 3000;

  /// Current immutable snapshot.
  PlaybackState get state => _state;

  /// Reactive stream of playback state transitions.
  Stream<PlaybackState> get stateStream => _stateController.stream;

  // ── Playback Controls ──────────────────────────────────────────────────────

  /// Loads and plays [track].
  Future<void> playTrack(Track track) async {
    // Remember what we were playing so previous() can walk back.
    final outgoing = _currentTrack;
    if (outgoing != null && outgoing.id != track.id) {
      _history.add(outgoing);
      if (_history.length > _maxHistory) _history.removeAt(0);
    }
    _currentTrack = track;
    _engine.loadTrack(track.filePath);
    _engine.play();
    _updateState(_state.copyWith(
      status: EngineStatus.playing,
      currentTrack: track,
      positionMs: 0,
    ));
  }

  /// Pauses playback.
  void pause() {
    _engine.pause();
    _updateState(_state.copyWith(status: EngineStatus.paused));
  }

  /// Resumes playback.
  void resume() {
    _engine.play();
    _updateState(_state.copyWith(status: EngineStatus.playing));
  }

  /// Seeks to [positionMs] within the current track.
  void seek(int positionMs) {
    final track = _currentTrack;
    if (track != null && positionMs > track.durationMs) {
      throw SeekOutOfBoundsError(positionMs, track.durationMs);
    }
    _engine.seek(positionMs);
    _updateState(_state.copyWith(positionMs: positionMs));
  }

  /// Skips to the next track in the shuffle queue (or next in playlist).
  Future<void> skipNext() async {
    final track = _currentTrack;
    if (track != null) {
      await _behaviorRepo.recordEvent(PlayEvent(
        trackId: track.id,
        playedAtMs: DateTime.now().millisecondsSinceEpoch,
        durationPlayedMs: _state.positionMs,
        skipped: true,
        contextType: 'shuffle',
      ));
      _shuffleEngine.onSkip();
    }
    await _playNextFromShuffle();
  }

  /// Called by the engine callback when a track completes naturally.
  Future<void> onTrackCompleted() async {
    final track = _currentTrack;
    if (track != null) {
      final played = _state.positionMs;
      final isComplete = played >= (track.durationMs * kListenCompletionRatio);
      await _behaviorRepo.recordEvent(PlayEvent(
        trackId: track.id,
        playedAtMs: DateTime.now().millisecondsSinceEpoch,
        durationPlayedMs: played,
        skipped: !isComplete,
        contextType: 'shuffle',
      ));
      if (isComplete) {
        await _musicRepo.recordPlay(track.id, durationPlayedMs: played);
      } else {
        await _musicRepo.recordSkip(track.id);
      }
      _shuffleEngine.onTrackFinished(track.id);
    }

    if (_state.repeatMode == RepeatMode.one && _currentTrack != null) {
      await playTrack(_currentTrack!);
    } else {
      await _playNextFromShuffle();
    }
  }

  // ── EQ ─────────────────────────────────────────────────────────────────────

  /// Sets the gain for EQ band [band] (0–9) to [gainDb] decibels.
  void setEqBand(int band, int gainDb) {
    assert(band >= 0 && band <= 9, 'EQ band must be 0–9');
    _engine.setEqBand(band, gainDb.toDouble(), 1.0);
    final newBands = List<int>.from(_state.eqBandGains);
    newBands[band] = gainDb;
    _updateState(_state.copyWith(eqBandGains: newBands));
  }

  // ── Shuffle & Repeat ───────────────────────────────────────────────────────

  Future<void> enableShuffle(List<Track> library, ShuffleConfig config) async {
    await _shuffleEngine.generate(library);
    _updateState(_state.copyWith(isShuffleEnabled: true));
    await _playNextFromShuffle();
  }

  void setRepeatMode(RepeatMode mode) {
    _updateState(_state.copyWith(repeatMode: mode));
  }

  /// Skips forward. Alias of [skipNext] for the transport-control API.
  Future<void> next() => skipNext();

  /// Goes back one track, or restarts the current one when playback has been
  /// running for more than [_restartThresholdMs].
  Future<void> previous() async {
    if (_state.positionMs > _restartThresholdMs || _history.isEmpty) {
      seek(0);
      return;
    }
    final target = _history.removeLast();
    // playTrack would push the current track onto the history we're unwinding,
    // so clear it first to avoid ping-ponging between two tracks.
    final current = _currentTrack;
    _currentTrack = null;
    await playTrack(target);
    if (current != null && _history.isNotEmpty && _history.last.id == current.id) {
      _history.removeLast();
    }
  }

  /// Toggles the current track between "loved" (rating 5) and unrated.
  /// Returns the new liked state, or false when nothing is playing.
  Future<bool> toggleLike() async {
    final track = _currentTrack;
    if (track == null) return false;
    final liked = track.rating >= 5;
    final newRating = liked ? 0 : 5;
    await _musicRepo.setRating(track.id, newRating);
    _currentTrack = track.copyWith(rating: newRating);
    _updateState(_state.copyWith(currentTrack: _currentTrack));
    return !liked;
  }

  /// Flips shuffle on/off without disturbing the current track.
  void toggleShuffle() {
    _updateState(_state.copyWith(isShuffleEnabled: !_state.isShuffleEnabled));
  }

  // ── Position Updates (called from engine callback) ─────────────────────────

  /// Called by the FFI callback port when the engine emits a position tick.
  void onPositionUpdate(int positionMs) {
    _updateState(_state.copyWith(
      positionMs: positionMs,
      timestampMs: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  // ── Private ────────────────────────────────────────────────────────────────

  Future<void> _playNextFromShuffle() async {
    if (!_shuffleEngine.hasQueue) return;
    final nextId = _shuffleEngine.nextTrack();
    final nextTrack = await _musicRepo.getTrackById(nextId);
    if (nextTrack != null) {
      await playTrack(nextTrack);
    }
  }

  void _updateState(PlaybackState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  void dispose() {
    _stateController.close();
  }
}
