// lib/services/widget_update_scheduler.dart
// Aura — Keeps home-screen widget data fresh while the app is alive.
//
// Home-screen widgets go stale silently: nothing tells the user the numbers
// are from yesterday. A periodic push keeps them roughly honest for as long as
// the process lives.
//
// It refreshes faster while something is playing, because the now-playing tile
// is the one a user actually looks at, and slower when idle, because every
// wake-up costs battery for data nobody is watching.
//
// This is deliberately NOT a background job. It runs only while the process is
// alive and stops when the app is killed — the daily-mix regeneration in
// mix_scheduler.dart is the one thing that earns a real background task.

import 'dart:async';

import 'package:flutter/widgets.dart';

/// How often to refresh while a track is playing.
const Duration kWidgetIntervalPlaying = Duration(minutes: 15);

/// How often to refresh while idle.
const Duration kWidgetIntervalIdle = Duration(minutes: 30);

/// Supplies the data for one refresh. Returns false when the update could not
/// be delivered, which the scheduler records but does not treat as fatal.
typedef WidgetRefresh = Future<bool> Function();

/// Answers "is audio playing right now?" — decides which interval applies.
typedef PlaybackProbe = bool Function();

/// Drives periodic widget refreshes.
class WidgetUpdateScheduler with WidgetsBindingObserver {
  WidgetUpdateScheduler({
    required WidgetRefresh onRefresh,
    required PlaybackProbe isPlaying,
    Duration playingInterval = kWidgetIntervalPlaying,
    Duration idleInterval = kWidgetIntervalIdle,
    bool observeLifecycle = true,
  })  : _onRefresh = onRefresh,
        _isPlaying = isPlaying,
        _playingInterval = playingInterval,
        _idleInterval = idleInterval,
        _observeLifecycle = observeLifecycle;

  final WidgetRefresh _onRefresh;
  final PlaybackProbe _isPlaying;
  final Duration _playingInterval;
  final Duration _idleInterval;
  final bool _observeLifecycle;

  Timer? _timer;
  bool _running = false;

  /// Refreshes performed since [start]. Exposed for tests and diagnostics.
  int get refreshCount => _refreshCount;
  int _refreshCount = 0;

  bool get isRunning => _running;

  /// The interval currently in force.
  Duration get interval => _isPlaying() ? _playingInterval : _idleInterval;

  /// Starts refreshing, immediately and then periodically.
  ///
  /// The immediate refresh matters: the widget is most likely to be wrong
  /// right after launch, having sat untouched since the app was last killed.
  Future<void> start() async {
    if (_running) return;
    _running = true;
    if (_observeLifecycle) {
      WidgetsBinding.instance.addObserver(this);
    }
    await refreshNow();
    _arm();
  }

  /// Stops refreshing and releases the timer.
  void stop() {
    if (!_running) return;
    _running = false;
    _timer?.cancel();
    _timer = null;
    if (_observeLifecycle) {
      WidgetsBinding.instance.removeObserver(this);
    }
  }

  /// Refreshes once, out of band.
  Future<bool> refreshNow() async {
    _refreshCount++;
    try {
      return await _onRefresh();
    } catch (error) {
      debugPrint('WidgetUpdateScheduler: refresh failed: $error');
      return false;
    }
  }

  /// (Re)arms the timer at whichever interval currently applies.
  ///
  /// Re-armed after every tick rather than using a fixed periodic timer,
  /// because the interval depends on playback state, which changes.
  void _arm() {
    _timer?.cancel();
    if (!_running) return;
    _timer = Timer(interval, () async {
      await refreshNow();
      _arm();
    });
  }

  /// Playback started or stopped: re-arm so the new interval applies now
  /// rather than after the old one finally expires.
  void onPlaybackStateChanged() {
    if (_running) _arm();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // Coming back to the foreground is the moment the user is most likely
        // to glance at a widget, so refresh rather than wait for the tick.
        if (_running) unawaited(refreshNow());
      case AppLifecycleState.detached:
        // The process is going away; nothing left to refresh into.
        stop();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void dispose() => stop();
}
