// lib/services/notification_service.dart
// Aura — Local notifications. Nothing here touches a network.
//
// Everything routes through [NotificationBackend] rather than calling
// flutter_local_notifications directly. The valuable logic — which categories
// are allowed, what quiet hours do to a scheduled time, how ids are allocated
// so an update replaces rather than stacks — is then testable without a
// platform channel, which is the part most likely to be wrong.
//
// SCOPE: this shows a media-style notification with artwork and progress. Its
// action buttons are not transport controls: real lock-screen scrubbing and
// Bluetooth/car controls need an Android MediaSession and iOS Now Playing
// info, which means running playback under audio_service. Until that lands,
// treat this as a status surface, not a remote control.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../data/settings/app_settings.dart';
import '../ui/screens/settings/settings_providers.dart' show settingsProvider;

// ─────────────────────────────────────────────────────────────────────────────
// Channels and ids
// ─────────────────────────────────────────────────────────────────────────────

abstract final class NotificationChannels {
  /// Low importance on purpose: an ongoing playback notification that pings
  /// on every track change would be intolerable.
  static const playback = 'aura_playback';
  static const playbackName = 'Playback';

  static const mixes = 'aura_mixes';
  static const mixesName = 'Daily Mixes';

  static const recap = 'aura_recap';
  static const recapName = 'Weekly Recap';

  static const milestones = 'aura_milestones';
  static const milestonesName = 'Milestones';

  static const library = 'aura_library';
  static const libraryName = 'Library';
}

/// Fixed ids, so an update replaces the existing notification instead of
/// stacking a new one beside it.
abstract final class NotificationIds {
  static const playback = 1001;
  static const dailyMix = 1002;
  static const weeklyRecap = 1003;
  static const library = 1004;

  /// Milestones are offset by type so two different achievements can coexist.
  static int milestone(int type) => 2000 + type;
}

// ─────────────────────────────────────────────────────────────────────────────
// Backend
// ─────────────────────────────────────────────────────────────────────────────

/// The platform surface [NotificationService] needs. Implemented for real by
/// [LocalNotificationBackend]; faked in tests.
abstract interface class NotificationBackend {
  Future<void> initialise();

  Future<void> show({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    bool ongoing = false,
    String? imagePath,
    int? progressMax,
    int? progressValue,
  });

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    required DateTime when,
  });

  Future<void> cancel(int id);
  Future<void> cancelAll();
}

/// flutter_local_notifications, wrapped.
class LocalNotificationBackend implements NotificationBackend {
  LocalNotificationBackend([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialised = false;

  @override
  Future<void> initialise() async {
    if (_initialised) return;

    // zonedSchedule needs a real tz database and the device's actual zone;
    // without setLocalLocation everything schedules against UTC, so a "9 AM"
    // reminder fires at the wrong hour for most of the world.
    tz_data.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (error) {
      debugPrint('NotificationService: falling back to UTC: $error');
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        // Asked for explicitly at a moment the user understands, not on boot.
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings);

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.createNotificationChannel(const AndroidNotificationChannel(
        NotificationChannels.playback,
        NotificationChannels.playbackName,
        description: 'Now playing, with transport info',
        importance: Importance.low,
        playSound: false,
        showBadge: false,
      ));
      for (final channel in const [
        (NotificationChannels.mixes, NotificationChannels.mixesName,
            'Your daily mixes are ready'),
        (NotificationChannels.recap, NotificationChannels.recapName,
            'Your week in listening'),
        (NotificationChannels.milestones, NotificationChannels.milestonesName,
            'Listening milestones'),
        (NotificationChannels.library, NotificationChannels.libraryName,
            'Library scans and new music'),
      ]) {
        await android.createNotificationChannel(AndroidNotificationChannel(
          channel.$1,
          channel.$2,
          description: channel.$3,
          importance: Importance.defaultImportance,
        ));
      }
    }

    _initialised = true;
  }

  NotificationDetails _details({
    required String channelId,
    required String channelName,
    bool ongoing = false,
    String? imagePath,
    int? progressMax,
    int? progressValue,
  }) {
    final hasProgress = progressMax != null && progressValue != null;
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance:
            ongoing ? Importance.low : Importance.defaultImportance,
        priority: ongoing ? Priority.low : Priority.defaultPriority,
        ongoing: ongoing,
        // An ongoing notification the user can swipe away is a lie about the
        // app's state, so it is explicitly non-dismissible while playing.
        autoCancel: !ongoing,
        onlyAlertOnce: ongoing,
        showProgress: hasProgress,
        maxProgress: progressMax ?? 0,
        progress: progressValue ?? 0,
        largeIcon:
            imagePath != null && imagePath.isNotEmpty
                ? FilePathAndroidBitmap(imagePath)
                : null,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: !ongoing,
        presentSound: !ongoing,
        presentBadge: !ongoing,
        attachments: imagePath != null && imagePath.isNotEmpty
            ? [DarwinNotificationAttachment(imagePath)]
            : null,
      ),
    );
  }

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    bool ongoing = false,
    String? imagePath,
    int? progressMax,
    int? progressValue,
  }) async {
    await initialise();
    await _plugin.show(
      id,
      title,
      body,
      _details(
        channelId: channelId,
        channelName: channelName,
        ongoing: ongoing,
        imagePath: imagePath,
        progressMax: progressMax,
        progressValue: progressValue,
      ),
    );
  }

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    required DateTime when,
  }) async {
    await initialise();
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(when, tz.local),
      _details(channelId: channelId, channelName: channelName),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // Wall-clock time: a 9 AM reminder is 9 AM wherever the user wakes up,
      // not 9 AM in the zone the alarm was set in.
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );
  }

  @override
  Future<void> cancel(int id) async {
    await initialise();
    await _plugin.cancel(id);
  }

  @override
  Future<void> cancelAll() async {
    await initialise();
    await _plugin.cancelAll();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────

/// Reads the user's current preferences. Injected so the service can be tested
/// against a fixed settings object.
typedef SettingsReader = AppSettings Function();

class NotificationService {
  NotificationService({
    required SettingsReader readSettings,
    NotificationBackend? backend,
    DateTime Function()? now,
  })  : _readSettings = readSettings,
        _backend = backend ?? LocalNotificationBackend(),
        _now = now ?? DateTime.now;

  final SettingsReader _readSettings;
  final NotificationBackend _backend;
  final DateTime Function() _now;

  Future<void> init() => _backend.initialise();

  // ── Playback ───────────────────────────────────────────────────────────────

  /// Shows or updates the ongoing now-playing notification.
  ///
  /// Not gated on quiet hours: this notification makes no sound and appears
  /// only because the user pressed play. Silencing it would leave audio
  /// playing with no visible source.
  Future<bool> showPlaybackNotification({
    required String trackTitle,
    required String artistName,
    required String albumArtPath,
    required bool isPlaying,
    required Duration position,
    required Duration duration,
  }) async {
    final settings = _readSettings();
    if (!settings.isEnabled(NotificationKind.nowPlaying)) {
      // Turning the category off should take the existing one away too, not
      // just stop future updates.
      await cancelPlaybackNotification();
      return false;
    }

    return _guard(() => _backend.show(
          id: NotificationIds.playback,
          title: trackTitle,
          body: '$artistName · ${isPlaying ? 'Playing' : 'Paused'}',
          channelId: NotificationChannels.playback,
          channelName: NotificationChannels.playbackName,
          ongoing: isPlaying,
          imagePath: albumArtPath,
          progressMax: duration.inSeconds,
          progressValue: position.inSeconds.clamp(0, duration.inSeconds),
        ));
  }

  Future<bool> cancelPlaybackNotification() =>
      _guard(() => _backend.cancel(NotificationIds.playback));

  // ── Scheduled ──────────────────────────────────────────────────────────────

  Future<bool> scheduleDailyMixNotification({
    required String mixName,
    required int trackCount,
    required DateTime scheduledTime,
  }) {
    return _schedule(
      kind: NotificationKind.dailyMix,
      id: NotificationIds.dailyMix,
      title: 'Your $mixName is ready',
      body: '$trackCount tracks, picked from your library.',
      channelId: NotificationChannels.mixes,
      channelName: NotificationChannels.mixesName,
      when: scheduledTime,
    );
  }

  Future<bool> scheduleWeeklyRecap({
    required String totalTime,
    required String topArtist,
    DateTime? scheduledTime,
  }) {
    return _schedule(
      kind: NotificationKind.weeklyRecap,
      id: NotificationIds.weeklyRecap,
      title: 'Your week in music',
      body: '$totalTime of listening. Most played: $topArtist.',
      channelId: NotificationChannels.recap,
      channelName: NotificationChannels.recapName,
      when: scheduledTime ?? nextMondayMorning(_now()),
    );
  }

  /// Milestones are shown immediately — the moment they are earned is the
  /// point — but still respect quiet hours by deferring to the window's end.
  Future<bool> scheduleMilestoneNotification({
    required String message,
    required int milestoneType,
    DateTime? scheduledTime,
  }) {
    return _schedule(
      kind: NotificationKind.milestones,
      id: NotificationIds.milestone(milestoneType),
      title: 'Milestone reached',
      body: message,
      channelId: NotificationChannels.milestones,
      channelName: NotificationChannels.milestonesName,
      when: scheduledTime ?? _now(),
    );
  }

  Future<bool> showLibraryNotification({
    required String title,
    required String body,
  }) {
    return _schedule(
      kind: NotificationKind.libraryScan,
      id: NotificationIds.library,
      title: title,
      body: body,
      channelId: NotificationChannels.library,
      channelName: NotificationChannels.libraryName,
      when: _now(),
    );
  }

  Future<bool> cancelAllNotifications() => _guard(_backend.cancelAll);

  // ── Internals ──────────────────────────────────────────────────────────────

  /// Applies the user's preferences, then hands the notification to the
  /// backend — scheduled if it is in the future, shown now if it is not.
  Future<bool> _schedule({
    required NotificationKind kind,
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    required DateTime when,
  }) async {
    final settings = _readSettings();
    if (!settings.isEnabled(kind)) return false;

    final at = resolveDeliveryTime(settings, kind, when);
    if (at == null) return false;

    // A time at or before now cannot be scheduled, so show it directly. This
    // is also the common path: milestones and library events are "now".
    if (!at.isAfter(_now())) {
      return _guard(() => _backend.show(
            id: id,
            title: title,
            body: body,
            channelId: channelId,
            channelName: channelName,
          ));
    }

    return _guard(() => _backend.schedule(
          id: id,
          title: title,
          body: body,
          channelId: channelId,
          channelName: channelName,
          when: at,
        ));
  }

  /// Never let a notification failure surface as an app-level error.
  Future<bool> _guard(Future<void> Function() body) async {
    try {
      await body();
      return true;
    } catch (error) {
      debugPrint('NotificationService: skipped: $error');
      return false;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quiet-hours arithmetic
// ─────────────────────────────────────────────────────────────────────────────

/// When [kind] should actually be delivered, given [when] and the user's quiet
/// hours — or null when it should not be delivered at all.
///
/// A notification that lands inside quiet hours is deferred to the moment the
/// window ends rather than dropped: the user asked not to be disturbed until
/// 7 AM, not to never hear about it.
DateTime? resolveDeliveryTime(
  AppSettings settings,
  NotificationKind kind,
  DateTime when,
) {
  if (!settings.isEnabled(kind)) return null;

  final at = TimeOfDay(hour: when.hour, minute: when.minute);
  if (!settings.isWithinQuietHours(at)) return when;
  if (settings.quietHoursBypass.contains(kind)) return when;

  return _endOfQuietHours(settings, when);
}

/// The next moment quiet hours are over, at or after [when].
DateTime _endOfQuietHours(AppSettings settings, DateTime when) {
  final end = settings.quietHoursEnd;
  var candidate =
      DateTime(when.year, when.month, when.day, end.hour, end.minute);
  // A window that wraps midnight ends tomorrow when the notification arrives
  // in the evening half of it.
  if (!candidate.isAfter(when)) {
    candidate = DateTime(
        when.year, when.month, when.day + 1, end.hour, end.minute);
  }
  return candidate;
}

/// 9 AM on the next Monday strictly after [from].
///
/// Strictly after, so generating the recap on a Monday morning does not
/// schedule it for a moment that has already passed.
DateTime nextMondayMorning(DateTime from) {
  var daysAhead = DateTime.monday - from.weekday;
  if (daysAhead <= 0) daysAhead += 7;
  return DateTime(from.year, from.month, from.day + daysAhead, 9);
}

// ─────────────────────────────────────────────────────────────────────────────

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    readSettings: () => ref.read(settingsProvider),
  );
});
