// lib/domain/entities/playback_state.dart
// Aura — PlaybackState entity (freezed, immutable).
// Architecture §4.1: state emitted by C++ engine callbacks → Riverpod.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'track.dart';

part 'playback_state.freezed.dart';
part 'playback_state.g.dart';

/// Mirrors the native engine's playback states.
enum EngineStatus {
  /// Engine not yet initialised.
  idle,

  /// Track loaded and ready to play.
  ready,

  /// Currently playing.
  playing,

  /// Playback paused.
  paused,

  /// Buffering / loading track (should be near-instant for local files).
  loading,

  /// Playback finished; waiting for next track.
  completed,

  /// A fatal error occurred.
  error,
}

/// Repeat modes exposed to the UI.
enum RepeatMode { none, one, all }

/// Complete snapshot of the player's playback state.
/// Emitted by [PlaybackOrchestrator] as an immutable value.
@freezed
class PlaybackState with _$PlaybackState {
  const factory PlaybackState({
    /// Current engine status.
    @Default(EngineStatus.idle) EngineStatus status,

    /// Currently loaded track; null when idle.
    Track? currentTrack,

    /// Current playback position in milliseconds.
    @Default(0) int positionMs,

    /// Buffer position in milliseconds (for gapless pre-loading).
    @Default(0) int bufferedMs,

    /// Whether shuffle is active.
    @Default(false) bool isShuffleEnabled,

    /// Current repeat mode.
    @Default(RepeatMode.none) RepeatMode repeatMode,

    /// Playback speed multiplier (1.0 = normal).
    @Default(1.0) double playbackSpeed,

    /// Master volume 0.0–1.0.
    @Default(1.0) double volume,

    /// EQ band gains (10 bands, index 0 = 32Hz … 9 = 16kHz), dB offset.
    @Default([0, 0, 0, 0, 0, 0, 0, 0, 0, 0]) List<int> eqBandGains,

    /// Error message when [status] is [EngineStatus.error].
    String? errorMessage,

    /// Timestamp when this state was captured (for change detection).
    @Default(0) int timestampMs,
  }) = _PlaybackState;

  factory PlaybackState.fromJson(Map<String, dynamic> json) =>
      _$PlaybackStateFromJson(json);

  /// Convenience factory for the initial (idle) state.
  static const PlaybackState initial = PlaybackState();
}
