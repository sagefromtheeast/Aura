// lib/ui/screens/notifications/notification_providers.dart
// Aura — Notification screens' view of the persisted settings.
//
//   • notificationSettingsProvider — master switch, per-type toggles, sound
//   • quietHoursProvider           — quiet-hours window + per-type bypass
//
// Both are projections of [settingsProvider], not stores of their own. They
// used to hold independent in-memory state, which meant the quiet-hours window
// and the notification toggles existed twice and could disagree — the settings
// screen and the notifications screen would show different answers for the
// same preference. Everything is local; nothing leaves the device.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/settings/app_settings.dart';
import '../settings/settings_providers.dart';

/// The notification categories Aura can send.
enum NotifType {
  nowPlaying('Now Playing', locked: true),
  dailyMix('Daily Mix Ready'),
  weeklyRecap('Weekly Recap'),
  milestones('Milestones');

  const NotifType(this.label, {this.locked = false});

  final String label;

  /// Locked types are always delivered and cannot be toggled/blocked.
  final bool locked;

  /// The persisted category this screen-level type stores against.
  NotificationKind get kind => switch (this) {
        NotifType.nowPlaying => NotificationKind.nowPlaying,
        NotifType.dailyMix => NotificationKind.dailyMix,
        NotifType.weeklyRecap => NotificationKind.weeklyRecap,
        NotifType.milestones => NotificationKind.milestones,
      };
}

/// A selectable notification sound.
class AuraSound {
  const AuraSound(this.id, this.name, {this.isSystemDefault = false});
  final String id;
  final String name;
  final bool isSystemDefault;
}

const List<AuraSound> kAuraSounds = [
  AuraSound('warm_chime', 'Warm Chime'),
  AuraSound('soft_resonance', 'Soft Resonance'),
  AuraSound('vinyl_pop', 'Vintage Vinyl Pop'),
  AuraSound('ambient_pulse', 'Ambient Pulse'),
  AuraSound('classic_bell', 'Classic Bell'),
  AuraSound('system_default', 'System Default', isSystemDefault: true),
];

// ── Notification settings ─────────────────────────────────────────────────────

@immutable
class NotificationSettings {
  const NotificationSettings({
    this.enabled = true,
    this.types = const {
      NotifType.nowPlaying: true,
      NotifType.dailyMix: true,
      NotifType.weeklyRecap: true,
      NotifType.milestones: false,
    },
    this.soundId = 'warm_chime',
  });

  final bool enabled;
  final Map<NotifType, bool> types;
  final String soundId;

  bool isOn(NotifType t) => t.locked ? true : (types[t] ?? false);

  NotificationSettings copyWith({
    bool? enabled,
    Map<NotifType, bool>? types,
    String? soundId,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      types: types ?? this.types,
      soundId: soundId ?? this.soundId,
    );
  }
}

/// The notification slice of the persisted settings.
final notificationSettingsProvider = Provider<NotificationSettings>((ref) {
  final settings = ref.watch(settingsProvider);
  return NotificationSettings(
    enabled: settings.notificationsEnabled,
    types: {
      for (final type in NotifType.values)
        type: switch (type) {
          NotifType.nowPlaying => settings.nowPlayingNotification,
          NotifType.dailyMix => settings.dailyMixNotifications,
          NotifType.weeklyRecap => settings.weeklyRecapNotifications,
          NotifType.milestones => settings.milestoneNotifications,
        },
    },
    soundId: settings.notificationSound,
  );
});

/// Mutations for the notification screens, writing through to settings.
class NotificationSettingsController {
  const NotificationSettingsController(this._settings);

  final SettingsNotifier _settings;

  Future<void> setEnabled(bool v) => _settings.setNotificationsEnabled(v);

  Future<void> setType(NotifType type, bool enabled) {
    // A locked type is always delivered; the UI does not offer the switch, and
    // this guards against it being called anyway.
    if (type.locked) return Future.value();
    return _settings.toggleNotification(type.kind, enabled);
  }

  Future<void> setSound(String soundId) =>
      _settings.setNotificationSound(soundId);
}

final notificationSettingsControllerProvider =
    Provider<NotificationSettingsController>((ref) {
  return NotificationSettingsController(ref.watch(settingsProvider.notifier));
});

// ── Quiet hours ───────────────────────────────────────────────────────────────

@immutable
class QuietHoursConfig {
  const QuietHoursConfig({
    this.enabled = true,
    this.start = const TimeOfDay(hour: 22, minute: 0),
    this.end = const TimeOfDay(hour: 7, minute: 0),
    this.bypass = const {NotifType.nowPlaying},
  });

  final bool enabled;
  final TimeOfDay start;
  final TimeOfDay end;

  /// Types that may still be delivered during quiet hours.
  final Set<NotifType> bypass;

  bool bypasses(NotifType t) => t.locked || bypass.contains(t);
}

/// The quiet-hours slice of the persisted settings.
final quietHoursProvider = Provider<QuietHoursConfig>((ref) {
  final settings = ref.watch(settingsProvider);
  return QuietHoursConfig(
    enabled: settings.quietHoursEnabled,
    start: settings.quietHoursStart,
    end: settings.quietHoursEnd,
    bypass: {
      for (final type in NotifType.values)
        if (settings.quietHoursBypass.contains(type.kind)) type,
    },
  );
});

/// Mutations for the quiet-hours screen, writing through to settings.
class QuietHoursController {
  const QuietHoursController(this._settings, this._config);

  final SettingsNotifier _settings;
  final QuietHoursConfig _config;

  Future<void> setEnabled(bool v) => _settings.setQuietHoursEnabled(v);
  Future<void> setStart(TimeOfDay t) => _settings.setQuietStart(t);
  Future<void> setEnd(TimeOfDay t) => _settings.setQuietEnd(t);

  Future<void> toggleBypass(NotifType t) {
    if (t.locked) return Future.value(); // always allowed; cannot change
    return _settings.setQuietHoursBypass(t.kind, !_config.bypass.contains(t));
  }
}

final quietHoursControllerProvider = Provider<QuietHoursController>((ref) {
  return QuietHoursController(
    ref.watch(settingsProvider.notifier),
    ref.watch(quietHoursProvider),
  );
});
