// lib/domain/smart_mix/mix_scheduler.dart
// Aura — Background regeneration of Daily Mixes.
//
// Android: workmanager runs a periodic job; the OS decides exact timing, so we
//          schedule it to first fire at ~5 AM local and repeat daily.
// iOS:     BGProcessingTask, registered in AppDelegate.swift, calls back over
//          the `com.aura/mix_scheduler` channel.
//
// Both paths converge on [runMixRegeneration], which only does work when a mix
// is actually stale (>24h), so a spurious wake is cheap.

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:workmanager/workmanager.dart';

/// Channel the iOS BGProcessingTask uses to reach Dart.
const String kMixSchedulerChannel = 'com.aura/mix_scheduler';

/// workmanager task identifier. Must match the iOS BGTaskScheduler id in
/// Info.plist so both platforms name the same job.
const String kDailyMixTaskName = 'com.aura.dailyMixRegeneration';

/// Hour of day (local) the daily regeneration should aim for.
const int kDailyMixHour = 5;

/// Injected by main.dart so the isolate entry point can rebuild mixes without
/// this file depending on Riverpod or the data layer.
typedef MixRegenerationCallback = Future<void> Function();

MixRegenerationCallback? _regenerationCallback;

/// Registers what background wakes should actually do.
void setMixRegenerationCallback(MixRegenerationCallback callback) {
  _regenerationCallback = callback;
}

/// Entry point shared by the Android worker and the iOS BG task.
Future<bool> runMixRegeneration() async {
  final callback = _regenerationCallback;
  if (callback == null) {
    debugPrint('[Aura] Mix regeneration requested with no callback registered');
    return false;
  }
  try {
    await callback();
    return true;
  } catch (e) {
    debugPrint('[Aura] Mix regeneration failed: $e');
    return false;
  }
}

/// workmanager's isolate entry point.
///
/// Must be a top-level function annotated with @pragma('vm:entry-point') so
/// the AOT compiler keeps it and the background isolate can find it.
@pragma('vm:entry-point')
void mixSchedulerDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != kDailyMixTaskName) return true;
    return runMixRegeneration();
  });
}

class MixScheduler {
  const MixScheduler();

  /// Wires up background regeneration for the current platform.
  ///
  /// Safe to call on every launch: both platforms replace an existing job
  /// rather than stacking duplicates.
  Future<void> initialize({bool isInDebugMode = false}) async {
    if (kIsWeb) return;
    try {
      if (Platform.isAndroid) {
        await _initAndroid(isInDebugMode: isInDebugMode);
      } else if (Platform.isIOS) {
        await _initIOS();
      }
    } catch (e) {
      // Background scheduling is best-effort; the app still works without it.
      debugPrint('[Aura] Mix scheduling unavailable: $e');
    }
  }

  Future<void> _initAndroid({required bool isInDebugMode}) async {
    await Workmanager().initialize(
      mixSchedulerDispatcher,
      isInDebugMode: isInDebugMode,
    );
    await Workmanager().registerPeriodicTask(
      kDailyMixTaskName,
      kDailyMixTaskName,
      frequency: const Duration(hours: 24),
      initialDelay: _delayUntilNextRun(),
      // Periodic tasks take ExistingPeriodicWorkPolicy (not ExistingWorkPolicy).
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      // No network constraint: everything Aura does is on-device. The
      // NetworkType enum has been renamed across workmanager versions, so we
      // deliberately leave it at the default rather than pin a spelling.
      constraints: Constraints(requiresBatteryNotLow: true),
    );
  }

  Future<void> _initIOS() async {
    // The BGProcessingTask is registered natively in AppDelegate.swift; this
    // just opens the channel it calls back on.
    const channel = MethodChannel(kMixSchedulerChannel);
    channel.setMethodCallHandler((call) async {
      if (call.method == 'regenerateMixes') {
        return runMixRegeneration();
      }
      return null;
    });
    await channel.invokeMethod<void>('scheduleDailyMixTask', {
      'hour': kDailyMixHour,
    });
  }

  /// Time from now until the next [kDailyMixHour] local.
  static Duration _delayUntilNextRun([DateTime? now]) {
    final current = now ?? DateTime.now();
    var next = DateTime(current.year, current.month, current.day, kDailyMixHour);
    if (!next.isAfter(current)) {
      next = next.add(const Duration(days: 1));
    }
    return next.difference(current);
  }

  /// Exposed for tests.
  @visibleForTesting
  static Duration delayUntilNextRunForTest(DateTime now) =>
      _delayUntilNextRun(now);

  /// Cancels the scheduled job (e.g. the user disabled Daily Mixes).
  Future<void> cancel() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await Workmanager().cancelByUniqueName(kDailyMixTaskName);
    } catch (e) {
      debugPrint('[Aura] Failed to cancel mix job: $e');
    }
  }
}
