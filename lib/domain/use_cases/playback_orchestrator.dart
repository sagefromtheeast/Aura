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
import '../repositories/shuffle_state_repository.dart';
import '../intelli_shuffle/intelli_shuffle_engine.dart';
import '../queue/queue_manager.dart';
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
    ShuffleStateRepository? shuffleStateRepository,
  })  : _engine = audioEngine,
        _shuffleEngine = shuffleEngine,
        _musicRepo = musicRepository,
        _behaviorRepo = behaviorRepository,
        _shuffleStateRepo = shuffleStateRepository;

  final AudioEngineFfi _engine;
  final IntelliShuffleEngine _shuffleEngine;
  final MusicRepository _musicRepo;
  final BehaviorRepository _behaviorRepo;

  /// Optional: when supplied, the shuffle queue survives restarts.
  final ShuffleStateRepository? _shuffleStateRepo;
  final _stateController = StreamController<PlaybackState>.broadcast();

  /// Playback context the shuffle state is stored under.
  static const String _shuffleContextId = 'all_songs';

  PlaybackState _state = PlaybackState.initial;
  Track? _currentTrack;

  /// Optional hook fired after a track finishes naturally. The sleep timer's
  /// "stop at end of track" mode registers here.
  void Function()? onTrackFinishedHook;

  /// Explicit user queues. When the active queue has tracks, it drives what
  /// plays next; otherwise the shuffle engine does. Empty by default, so
  /// nothing changes until the user adds to a queue or plays a collection.
  final QueueManager _queueManager = QueueManager();
  QueueManager get queueManager => _queueManager;

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
        completed: false,
        contextType: 'shuffle',
      ));
      _shuffleEngine.skip(track);
    }
    await _advanceNext();
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
        completed: isComplete,
        contextType: 'shuffle',
      ));
      if (isComplete) {
        await _musicRepo.recordPlay(track.id, durationPlayedMs: played);
      } else {
        await _musicRepo.recordSkip(track.id);
      }
      _shuffleEngine.onTrackFinished(track);
    }
    onTrackFinishedHook?.call();

    if (_state.repeatMode == RepeatMode.one && _currentTrack != null) {
      await playTrack(_currentTrack!);
    } else {
      await _advanceNext();
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
    await _shuffleEngine.generateShuffle(library);
    _updateState(_state.copyWith(isShuffleEnabled: true));
    await _persistShuffleState();
    await _playNextFromShuffle();
  }

  /// Restores a shuffle queue saved in a previous session.
  ///
  /// [library] hydrates the engine so it can hand back Track entities.
  /// Returns true when a queue was restored.
  Future<bool> restoreShuffleState(List<Track> library) async {
    final repo = _shuffleStateRepo;
    if (repo == null) return false;

    final json = await repo.load(_shuffleContextId);
    if (json == null || json.isEmpty) return false;

    _shuffleEngine.restoreState(json);
    _shuffleEngine.hydrate(library);
    if (!_shuffleEngine.hasQueue) return false;

    _updateState(_state.copyWith(isShuffleEnabled: true));
    return true;
  }

  /// Writes the queue to storage. Called once per track change, per PRD §6.3.
  Future<void> _persistShuffleState() async {
    final repo = _shuffleStateRepo;
    if (repo == null || !_shuffleEngine.hasQueue) return;
    await repo.save(_shuffleContextId, _shuffleEngine.serializeState());
  }

  void setRepeatMode(RepeatMode mode) {
    _updateState(_state.copyWith(repeatMode: mode));
  }

  /// Skips forward. Alias of [skipNext] for the transport-control API.
  Future<void> next() => skipNext();

  /// Goes back one track, or restarts the current one when playback has been
  /// running for more than [_restartThresholdMs].
  Future<void> previous() async {
    if (_state.positionMs > _restartThresholdMs) {
      seek(0);
      return;
    }
    // A live queue walks backwards through itself before falling back to the
    // cross-context play history.
    final queue = _queueManager.active;
    if (queue != null && !queue.isEmpty && queue.hasPrevious) {
      final prev = _queueManager.goBack();
      if (prev != null) {
        await playTrack(prev);
        return;
      }
    }
    if (_history.isEmpty) {
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

  /// Advances the active explicit queue when it has one, otherwise the shuffle
  /// engine. This is the single "what plays next" decision point.
  Future<void> _advanceNext() async {
    final queue = _queueManager.active;
    if (queue != null && !queue.isEmpty) {
      final next = _queueManager.advance();
      if (next != null) {
        await playTrack(next);
        return;
      }
      // The queue is spent; fall through to shuffle so playback continues.
    }
    await _playNextFromShuffle();
  }

  // ── Explicit queue operations ──────────────────────────────────────────────

  /// Plays [tracks] as the active queue, starting at [startIndex]. Used for
  /// "play this playlist / album / list".
  Future<void> playQueue(
    List<Track> tracks, {
    int startIndex = 0,
    String name = 'Queue',
    String? source,
  }) async {
    if (tracks.isEmpty) return;
    _queueManager.replaceWith(tracks,
        name: name, startIndex: startIndex, source: source);
    final current = _queueManager.current;
    if (current != null) await playTrack(current);
  }

  /// Appends [track] to the active queue (creating one if needed).
  void addToQueue(Track track) => _queueManager.addToQueue(track);

  /// Inserts [track] to play immediately after the current one.
  void playNextInQueue(Track track) => _queueManager.playNext(track);

  /// Saves [tracks] as an inactive named queue to return to later.
  void saveQueue(List<Track> tracks, {required String name, String? source}) {
    _queueManager.addQueue(tracks, name: name, source: source);
  }

  /// Jumps to [index] in the active queue and plays it.
  Future<void> playQueueIndex(int index) async {
    final track = _queueManager.jumpTo(index);
    if (track != null) await playTrack(track);
  }

  /// Switches the active queue and resumes it at its saved position.
  Future<void> switchQueue(String queueId) async {
    if (_queueManager.switchTo(queueId)) {
      final current = _queueManager.current;
      if (current != null) await playTrack(current);
    }
  }

  void removeFromQueue(int index) => _queueManager.removeAt(index);
  void reorderQueue(int oldIndex, int newIndex) =>
      _queueManager.reorder(oldIndex, newIndex);
  void renameQueue(String queueId, String name) =>
      _queueManager.renameQueue(queueId, name);
  void removeQueue(String queueId) => _queueManager.removeQueue(queueId);
  void removeAllOtherQueues() => _queueManager.removeAllButActive();

  Future<void> _playNextFromShuffle() async {
    if (!_shuffleEngine.hasQueue) return;
    // nextTrack() returns the entity directly, so no repository round-trip.
    final nextTrack = _shuffleEngine.nextTrack();
    if (nextTrack != null) {
      await playTrack(nextTrack);
      // Throttled by construction: one write per track change.
      await _persistShuffleState();
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
