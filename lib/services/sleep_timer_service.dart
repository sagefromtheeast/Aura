// lib/services/sleep_timer_service.dart
// Aura — Owns the live sleep timer and pauses playback when it fires.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/playback/sleep_timer.dart';
import '../shared/providers.dart';

class SleepTimerController extends StateNotifier<SleepTimerState> {
  SleepTimerController(this._ref) : super(SleepTimerState.off);

  final Ref _ref;
  Timer? _timer;

  /// Starts a countdown timer for [minutes].
  void startDuration(int minutes, {bool fadeOut = true}) {
    _timer?.cancel();
    final endsAt =
        DateTime.now().add(Duration(minutes: minutes)).millisecondsSinceEpoch;
    state = SleepTimerState(
      mode: SleepTimerMode.duration,
      endsAtMs: endsAt,
      fadeOut: fadeOut,
    );
    _timer = Timer(Duration(minutes: minutes), _fire);
  }

  /// Stops playback when the current track ends. The orchestrator checks
  /// [isEndOfTrackArmed] on completion.
  void startEndOfTrack({bool fadeOut = true}) {
    _timer?.cancel();
    _timer = null;
    state = SleepTimerState(mode: SleepTimerMode.endOfTrack, fadeOut: fadeOut);
    // Fire when the current track finishes, then unhook.
    _ref.read(playbackOrchestratorProvider).onTrackFinishedHook = _fire;
  }

  bool get isEndOfTrackArmed => state.mode == SleepTimerMode.endOfTrack;

  void cancel() {
    _timer?.cancel();
    _timer = null;
    try {
      _ref.read(playbackOrchestratorProvider).onTrackFinishedHook = null;
    } catch (_) {}
    state = SleepTimerState.off;
  }

  void _fire() {
    try {
      _ref.read(playbackOrchestratorProvider).pause();
    } catch (error) {
      debugPrint('SleepTimer: could not pause: $error');
    }
    cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final sleepTimerProvider =
    StateNotifierProvider<SleepTimerController, SleepTimerState>(
  SleepTimerController.new,
);
