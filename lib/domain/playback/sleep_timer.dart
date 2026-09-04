// lib/domain/playback/sleep_timer.dart
// Aura — Sleep timer state.
//
// Pure timing logic, no Flutter and no engine: it holds a deadline and reports
// how long is left. The service that owns it does the actual pause when it
// fires. "End of track" mode carries no deadline — playback stops when the
// current track finishes instead.

enum SleepTimerMode { off, duration, endOfTrack }

class SleepTimerState {
  const SleepTimerState({
    this.mode = SleepTimerMode.off,
    this.endsAtMs,
    this.fadeOut = true,
  });

  final SleepTimerMode mode;

  /// Epoch ms the timer fires at, for [SleepTimerMode.duration].
  final int? endsAtMs;

  /// Whether to fade the volume out over the final seconds.
  final bool fadeOut;

  bool get isActive => mode != SleepTimerMode.off;

  Duration remaining(int nowMs) {
    if (endsAtMs == null) return Duration.zero;
    final ms = endsAtMs! - nowMs;
    return ms <= 0 ? Duration.zero : Duration(milliseconds: ms);
  }

  static const SleepTimerState off = SleepTimerState();
}
