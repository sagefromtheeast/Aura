// lib/data/settings/app_settings.dart
// Aura — The single persisted settings model.
//
// Before this, settings lived in four independent in-memory notifiers
// (settingsProvider, notificationSettingsProvider, quietHoursProvider,
// equalizerProvider) with overlapping fields, so quiet hours and the
// notification toggles existed twice and could disagree. This is now the one
// source of truth; those notifiers project slices of it.
//
// Plain immutable class rather than freezed: the JSON here is hand-written on
// purpose, because it is a persistence format that must tolerate values
// written by older builds. Generated codec code throws on a missing or
// mistyped field, which for a settings file means the user loses every
// preference over one bad key.

import 'package:flutter/material.dart' show TimeOfDay, immutable;

import '../../domain/entities/shuffle_config.dart';

/// How the app picks its colours.
enum AuraThemeMode {
  /// Follow the platform light/dark setting with Aura's own palette.
  system,

  /// Material You, seeded from the wallpaper.
  dynamicColor,

  /// Seeded from the current track's album art.
  albumArt,

  /// A fixed accent chosen by the user.
  custom,
}

/// The notification categories Aura can send.
///
/// Stored by name, so reordering this enum cannot silently repoint a user's
/// saved toggles at the wrong category.
enum NotificationKind {
  nowPlaying,
  dailyMix,
  weeklyRecap,
  milestones,
  libraryScan,
  newMusic,
  inactivity,
}

/// Aura's default accent — DesignTokens.primarySeed.
const String kDefaultAccentHex = '#FF8F6D';

/// Ten-band equaliser gains in dB, flat.
const List<double> kFlatEqBands = <double>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

@immutable
class AppSettings {
  const AppSettings({
    // ── Appearance ──
    this.themeMode = AuraThemeMode.albumArt,
    this.glassIntensity = 0.7,
    this.accentColorHex = kDefaultAccentHex,

    // ── Shuffle ──
    this.shuffleConfig = ShuffleConfig.defaults,

    // ── Notifications ──
    this.notificationsEnabled = true,
    this.nowPlayingNotification = true,
    this.lockScreenControls = true,
    this.dailyMixNotifications = true,
    this.weeklyRecapNotifications = true,
    this.milestoneNotifications = false,
    this.libraryNotifications = true,
    this.newMusicNotifications = false,
    this.inactivityReminders = false,
    this.notificationSound = 'warm_chime',

    // ── Quiet hours ──
    this.quietHoursEnabled = true,
    this.quietHoursStart = const TimeOfDay(hour: 22, minute: 0),
    this.quietHoursEnd = const TimeOfDay(hour: 7, minute: 0),
    this.quietHoursBypass = const <NotificationKind>{},

    // ── Audio ──
    this.replayGainEnabled = true,
    this.crossfadeEnabled = true,
    this.crossfadeMs = 4000,
    this.eqEnabled = true,
    this.eqPreset = 'Flat',
    this.eqBands = kFlatEqBands,
    this.bassBoost = false,
    this.virtualizer = false,
    this.outputDevice = 'Phone Speaker',

    // ── Mixes ──
    this.dailyMixBalance = 0.5,

    // ── Backup ──
    this.autoBackupEnabled = false,
    this.backupPath = '',
  });

  // ── Appearance ─────────────────────────────────────────────────────────────

  final AuraThemeMode themeMode;

  /// Blur strength for glass surfaces, 0–1. The screens work in percent and
  /// convert; stored as a fraction so the unit is unambiguous on disk.
  final double glassIntensity;

  /// `#RRGGBB`. Only meaningful when [themeMode] is [AuraThemeMode.custom].
  final String accentColorHex;

  // ── Shuffle ────────────────────────────────────────────────────────────────

  final ShuffleConfig shuffleConfig;

  // ── Notifications ──────────────────────────────────────────────────────────

  /// Master switch. When false, nothing is delivered regardless of the
  /// per-category flags below.
  final bool notificationsEnabled;

  final bool nowPlayingNotification;
  final bool lockScreenControls;
  final bool dailyMixNotifications;
  final bool weeklyRecapNotifications;
  final bool milestoneNotifications;
  final bool libraryNotifications;
  final bool newMusicNotifications;
  final bool inactivityReminders;

  /// Id from `kAuraSounds`.
  final String notificationSound;

  // ── Quiet hours ────────────────────────────────────────────────────────────

  final bool quietHoursEnabled;
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;

  /// Categories allowed through during quiet hours.
  final Set<NotificationKind> quietHoursBypass;

  // ── Audio ──────────────────────────────────────────────────────────────────

  final bool replayGainEnabled;
  final bool crossfadeEnabled;

  /// Crossfade length in milliseconds. The engine's C API takes ms, so this is
  /// stored in the unit it is finally used in.
  final int crossfadeMs;

  final bool eqEnabled;

  /// Preset name, or 'Custom' once a band has been moved by hand.
  final String eqPreset;

  /// Ten per-band gains in dB (-12…+12).
  final List<double> eqBands;

  final bool bassBoost;
  final bool virtualizer;
  final String outputDevice;

  // ── Mixes ──────────────────────────────────────────────────────────────────

  /// 0 = favourites … 1 = discovery.
  final double dailyMixBalance;

  // ── Backup ─────────────────────────────────────────────────────────────────

  final bool autoBackupEnabled;
  final String backupPath;

  // ── Derived ────────────────────────────────────────────────────────────────

  /// Whether [kind] would be delivered right now, ignoring quiet hours.
  bool isEnabled(NotificationKind kind) {
    if (!notificationsEnabled) return false;
    return switch (kind) {
      NotificationKind.nowPlaying => nowPlayingNotification,
      NotificationKind.dailyMix => dailyMixNotifications,
      NotificationKind.weeklyRecap => weeklyRecapNotifications,
      NotificationKind.milestones => milestoneNotifications,
      NotificationKind.libraryScan => libraryNotifications,
      NotificationKind.newMusic => newMusicNotifications,
      NotificationKind.inactivity => inactivityReminders,
    };
  }

  /// Whether [at] falls inside the quiet-hours window.
  ///
  /// The window normally wraps midnight (22:00 → 07:00), so the comparison is
  /// not a simple "between": inside a wrapping window means at-or-after the
  /// start OR before the end.
  bool isWithinQuietHours(TimeOfDay at) {
    if (!quietHoursEnabled) return false;
    final now = at.hour * 60 + at.minute;
    final start = quietHoursStart.hour * 60 + quietHoursStart.minute;
    final end = quietHoursEnd.hour * 60 + quietHoursEnd.minute;
    if (start == end) return false; // A zero-length window silences nothing.
    return start < end ? now >= start && now < end : now >= start || now < end;
  }

  /// Whether [kind] would actually be delivered at [at].
  bool wouldDeliver(NotificationKind kind, TimeOfDay at) {
    if (!isEnabled(kind)) return false;
    if (!isWithinQuietHours(at)) return true;
    return quietHoursBypass.contains(kind);
  }

  AppSettings copyWith({
    AuraThemeMode? themeMode,
    double? glassIntensity,
    String? accentColorHex,
    ShuffleConfig? shuffleConfig,
    bool? notificationsEnabled,
    bool? nowPlayingNotification,
    bool? lockScreenControls,
    bool? dailyMixNotifications,
    bool? weeklyRecapNotifications,
    bool? milestoneNotifications,
    bool? libraryNotifications,
    bool? newMusicNotifications,
    bool? inactivityReminders,
    String? notificationSound,
    bool? quietHoursEnabled,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
    Set<NotificationKind>? quietHoursBypass,
    bool? replayGainEnabled,
    bool? crossfadeEnabled,
    int? crossfadeMs,
    bool? eqEnabled,
    String? eqPreset,
    List<double>? eqBands,
    bool? bassBoost,
    bool? virtualizer,
    String? outputDevice,
    double? dailyMixBalance,
    bool? autoBackupEnabled,
    String? backupPath,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      glassIntensity: glassIntensity ?? this.glassIntensity,
      accentColorHex: accentColorHex ?? this.accentColorHex,
      shuffleConfig: shuffleConfig ?? this.shuffleConfig,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      nowPlayingNotification:
          nowPlayingNotification ?? this.nowPlayingNotification,
      lockScreenControls: lockScreenControls ?? this.lockScreenControls,
      dailyMixNotifications:
          dailyMixNotifications ?? this.dailyMixNotifications,
      weeklyRecapNotifications:
          weeklyRecapNotifications ?? this.weeklyRecapNotifications,
      milestoneNotifications:
          milestoneNotifications ?? this.milestoneNotifications,
      libraryNotifications: libraryNotifications ?? this.libraryNotifications,
      newMusicNotifications:
          newMusicNotifications ?? this.newMusicNotifications,
      inactivityReminders: inactivityReminders ?? this.inactivityReminders,
      notificationSound: notificationSound ?? this.notificationSound,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      quietHoursBypass: quietHoursBypass ?? this.quietHoursBypass,
      replayGainEnabled: replayGainEnabled ?? this.replayGainEnabled,
      crossfadeEnabled: crossfadeEnabled ?? this.crossfadeEnabled,
      crossfadeMs: crossfadeMs ?? this.crossfadeMs,
      eqEnabled: eqEnabled ?? this.eqEnabled,
      eqPreset: eqPreset ?? this.eqPreset,
      eqBands: eqBands ?? this.eqBands,
      bassBoost: bassBoost ?? this.bassBoost,
      virtualizer: virtualizer ?? this.virtualizer,
      outputDevice: outputDevice ?? this.outputDevice,
      dailyMixBalance: dailyMixBalance ?? this.dailyMixBalance,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      backupPath: backupPath ?? this.backupPath,
    );
  }

  /// The shipped defaults. Named per the spec.
  static const AppSettings defaults = AppSettings();

  // ── JSON ───────────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'glassIntensity': glassIntensity,
        'accentColorHex': accentColorHex,
        'shuffleConfig': shuffleConfig.toJson(),
        'notificationsEnabled': notificationsEnabled,
        'nowPlayingNotification': nowPlayingNotification,
        'lockScreenControls': lockScreenControls,
        'dailyMixNotifications': dailyMixNotifications,
        'weeklyRecapNotifications': weeklyRecapNotifications,
        'milestoneNotifications': milestoneNotifications,
        'libraryNotifications': libraryNotifications,
        'newMusicNotifications': newMusicNotifications,
        'inactivityReminders': inactivityReminders,
        'notificationSound': notificationSound,
        'quietHoursEnabled': quietHoursEnabled,
        'quietHoursStart': encodeTimeOfDay(quietHoursStart),
        'quietHoursEnd': encodeTimeOfDay(quietHoursEnd),
        'quietHoursBypass': [for (final k in quietHoursBypass) k.name],
        'replayGainEnabled': replayGainEnabled,
        'crossfadeEnabled': crossfadeEnabled,
        'crossfadeMs': crossfadeMs,
        'eqEnabled': eqEnabled,
        'eqPreset': eqPreset,
        'eqBands': eqBands,
        'bassBoost': bassBoost,
        'virtualizer': virtualizer,
        'outputDevice': outputDevice,
        'dailyMixBalance': dailyMixBalance,
        'autoBackupEnabled': autoBackupEnabled,
        'backupPath': backupPath,
      };

  /// Rebuilds settings from [json], falling back to the default for any field
  /// that is missing or the wrong type.
  ///
  /// Deliberately total: a settings file written by an older build, or edited
  /// by hand, must not cost the user every other preference.
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    const d = AppSettings.defaults;
    return AppSettings(
      themeMode: _enumByName(
          AuraThemeMode.values, json['themeMode'], d.themeMode),
      glassIntensity:
          _double(json['glassIntensity'], d.glassIntensity).clamp(0.0, 1.0),
      accentColorHex: _hexColor(json['accentColorHex'], d.accentColorHex),
      shuffleConfig: _shuffleConfig(json['shuffleConfig'], d.shuffleConfig),
      notificationsEnabled:
          _bool(json['notificationsEnabled'], d.notificationsEnabled),
      nowPlayingNotification:
          _bool(json['nowPlayingNotification'], d.nowPlayingNotification),
      lockScreenControls:
          _bool(json['lockScreenControls'], d.lockScreenControls),
      dailyMixNotifications:
          _bool(json['dailyMixNotifications'], d.dailyMixNotifications),
      weeklyRecapNotifications:
          _bool(json['weeklyRecapNotifications'], d.weeklyRecapNotifications),
      milestoneNotifications:
          _bool(json['milestoneNotifications'], d.milestoneNotifications),
      libraryNotifications:
          _bool(json['libraryNotifications'], d.libraryNotifications),
      newMusicNotifications:
          _bool(json['newMusicNotifications'], d.newMusicNotifications),
      inactivityReminders:
          _bool(json['inactivityReminders'], d.inactivityReminders),
      notificationSound:
          _string(json['notificationSound'], d.notificationSound),
      quietHoursEnabled: _bool(json['quietHoursEnabled'], d.quietHoursEnabled),
      quietHoursStart:
          decodeTimeOfDay(json['quietHoursStart']) ?? d.quietHoursStart,
      quietHoursEnd: decodeTimeOfDay(json['quietHoursEnd']) ?? d.quietHoursEnd,
      quietHoursBypass: _kindSet(json['quietHoursBypass'], d.quietHoursBypass),
      replayGainEnabled: _bool(json['replayGainEnabled'], d.replayGainEnabled),
      crossfadeEnabled: _bool(json['crossfadeEnabled'], d.crossfadeEnabled),
      crossfadeMs: _int(json['crossfadeMs'], d.crossfadeMs).clamp(0, 12000),
      eqEnabled: _bool(json['eqEnabled'], d.eqEnabled),
      eqPreset: _string(json['eqPreset'], d.eqPreset),
      eqBands: _bands(json['eqBands'], d.eqBands),
      bassBoost: _bool(json['bassBoost'], d.bassBoost),
      virtualizer: _bool(json['virtualizer'], d.virtualizer),
      outputDevice: _string(json['outputDevice'], d.outputDevice),
      dailyMixBalance:
          _double(json['dailyMixBalance'], d.dailyMixBalance).clamp(0.0, 1.0),
      autoBackupEnabled: _bool(json['autoBackupEnabled'], d.autoBackupEnabled),
      backupPath: _string(json['backupPath'], d.backupPath),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Codecs
// ─────────────────────────────────────────────────────────────────────────────

/// TimeOfDay as "HH:mm" — readable in an exported file, and unambiguous.
String encodeTimeOfDay(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:'
    '${time.minute.toString().padLeft(2, '0')}';

/// Parses "HH:mm"; returns null on anything else, including out-of-range
/// values, so the caller can fall back to its default.
TimeOfDay? decodeTimeOfDay(Object? raw) {
  if (raw is! String) return null;
  final parts = raw.split(':');
  if (parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
  return TimeOfDay(hour: hour, minute: minute);
}

bool _bool(Object? raw, bool fallback) => raw is bool ? raw : fallback;

String _string(Object? raw, String fallback) => raw is String ? raw : fallback;

int _int(Object? raw, int fallback) =>
    raw is int ? raw : (raw is num ? raw.toInt() : fallback);

double _double(Object? raw, double fallback) =>
    raw is num ? raw.toDouble() : fallback;

T _enumByName<T extends Enum>(List<T> values, Object? raw, T fallback) {
  if (raw is! String) return fallback;
  for (final value in values) {
    if (value.name == raw) return value;
  }
  return fallback;
}

/// Accepts `#RRGGBB`; anything else falls back rather than producing a colour
/// the theme cannot parse.
String _hexColor(Object? raw, String fallback) {
  if (raw is! String) return fallback;
  final match = RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(raw);
  return match ? raw.toUpperCase() : fallback;
}

Set<NotificationKind> _kindSet(Object? raw, Set<NotificationKind> fallback) {
  if (raw is! List) return fallback;
  final kinds = <NotificationKind>{};
  for (final entry in raw) {
    if (entry is! String) continue;
    for (final kind in NotificationKind.values) {
      if (kind.name == entry) kinds.add(kind);
    }
  }
  return kinds;
}

/// Exactly ten gains, each clamped to the engine's range. A curve of the wrong
/// length would desynchronise the sliders from the DSP bands.
List<double> _bands(Object? raw, List<double> fallback) {
  if (raw is! List || raw.length != kFlatEqBands.length) return fallback;
  return [
    for (final value in raw)
      if (value is num) value.toDouble().clamp(-12.0, 12.0) else 0.0,
  ];
}

ShuffleConfig _shuffleConfig(Object? raw, ShuffleConfig fallback) {
  if (raw is! Map) return fallback;
  try {
    return ShuffleConfig.fromJson(Map<String, dynamic>.from(raw));
  } catch (_) {
    // Generated fromJson throws on a mistyped field; one bad value must not
    // cost the user every other setting.
    return fallback;
  }
}
