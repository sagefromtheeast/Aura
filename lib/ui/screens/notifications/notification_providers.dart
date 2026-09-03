// lib/ui/screens/notifications/notification_providers.dart
// Aura — Stub providers for the notification screens.
//   • notificationSettingsProvider — master switch, per-type toggles, sound
//   • quietHoursProvider           — quiet-hours window + per-type bypass
// All in-memory; nothing leaves the device.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class NotificationSettingsController
    extends StateNotifier<NotificationSettings> {
  NotificationSettingsController() : super(const NotificationSettings());

  void setEnabled(bool v) => state = state.copyWith(enabled: v);

  void setType(NotifType t, bool v) {
    if (t.locked) return;
    state = state.copyWith(types: {...state.types, t: v});
  }

  void setSound(String id) => state = state.copyWith(soundId: id);
}

/// All notification preferences (stub-backed).
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsController, NotificationSettings>(
        (ref) => NotificationSettingsController());

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

  QuietHoursConfig copyWith({
    bool? enabled,
    TimeOfDay? start,
    TimeOfDay? end,
    Set<NotifType>? bypass,
  }) {
    return QuietHoursConfig(
      enabled: enabled ?? this.enabled,
      start: start ?? this.start,
      end: end ?? this.end,
      bypass: bypass ?? this.bypass,
    );
  }
}

class QuietHoursController extends StateNotifier<QuietHoursConfig> {
  QuietHoursController() : super(const QuietHoursConfig());

  void setEnabled(bool v) => state = state.copyWith(enabled: v);
  void setStart(TimeOfDay t) => state = state.copyWith(start: t);
  void setEnd(TimeOfDay t) => state = state.copyWith(end: t);

  void toggleBypass(NotifType t) {
    if (t.locked) return; // always allowed; cannot change
    final next = {...state.bypass};
    if (next.contains(t)) {
      next.remove(t);
    } else {
      next.add(t);
    }
    state = state.copyWith(bypass: next);
  }
}

/// Quiet-hours configuration (stub-backed).
final quietHoursProvider =
    StateNotifierProvider<QuietHoursController, QuietHoursConfig>(
        (ref) => QuietHoursController());
