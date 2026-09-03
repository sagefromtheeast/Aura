// lib/ui/screens/settings/settings_providers.dart
// Aura — Stub providers backing the Settings screens.
//
//   • settingsProvider     → AppSettings (all user preferences)
//   • equalizerProvider    → EqualizerState (EQ band values + presets)
//
// The shuffle screens reuse the existing `shuffleConfigProvider`
// (lib/shared/providers.dart). All state is local; nothing leaves the device.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/design_tokens.dart';

// ── Theme presets ─────────────────────────────────────────────────────────────

enum ThemePreset {
  dynamicColor('Dynamic', 'From wallpaper'),
  albumArt('Album Art', 'Driven by artwork'),
  sunsetWarm('Sunset Warm', 'Warm apricot glow'),
  oceanCool('Ocean Cool', 'Cool cyan depths'),
  amoledDark('AMOLED Dark', 'True black OLED'),
  pureLight('Pure Light', 'Bright parchment');

  const ThemePreset(this.label, this.blurb);
  final String label;
  final String blurb;

  /// Representative swatch colours for the circular preview.
  List<Color> get swatch {
    switch (this) {
      case ThemePreset.dynamicColor:
        return const [Color(0xFF8E7CFF), Color(0xFF3BC9FF)];
      case ThemePreset.albumArt:
        return const [Color(0xFFFF8F6D), Color(0xFFFFD36E)];
      case ThemePreset.sunsetWarm:
        return const [Color(0xFFFF7E5F), Color(0xFFFFB88C)];
      case ThemePreset.oceanCool:
        return const [Color(0xFF2E3192), Color(0xFF1BFFFF)];
      case ThemePreset.amoledDark:
        return const [Color(0xFF0F0D0A), Color(0xFF2B2622)];
      case ThemePreset.pureLight:
        return const [Color(0xFFFBF9F6), Color(0xFFE7E2DA)];
    }
  }

  /// Accent colour applied to [dynamicThemeProvider] when this preset is chosen.
  Color get accent => swatch.first;
}

// ── App settings model ────────────────────────────────────────────────────────

@immutable
class AppSettings {
  const AppSettings({
    this.outputDevice = 'Phone Speaker',
    this.normalizationEnabled = true,
    this.crossfadeSeconds = 4,
    this.dailyMixBalance = 0.5, // 0 = favourites … 1 = discovery
    this.themePreset = ThemePreset.albumArt,
    this.glassIntensity = 70, // 0–100
    // Notifications — Playback
    this.nowPlayingNotification = true,
    this.lockScreenControls = true,
    // Notifications — Discover
    this.dailyMixReady = true,
    this.weeklyRecap = true,
    this.milestones = false,
    // Notifications — Library
    this.scanComplete = true,
    this.newMusicAdded = false,
    // Notifications — Reminders
    this.inactiveReminder = false,
    this.quietHoursEnabled = true,
    this.quietStart = const TimeOfDay(hour: 22, minute: 0),
    this.quietEnd = const TimeOfDay(hour: 7, minute: 0),
  });

  final String outputDevice;
  final bool normalizationEnabled;
  final double crossfadeSeconds;
  final double dailyMixBalance;
  final ThemePreset themePreset;
  final double glassIntensity;

  final bool nowPlayingNotification;
  final bool lockScreenControls;
  final bool dailyMixReady;
  final bool weeklyRecap;
  final bool milestones;
  final bool scanComplete;
  final bool newMusicAdded;
  final bool inactiveReminder;
  final bool quietHoursEnabled;
  final TimeOfDay quietStart;
  final TimeOfDay quietEnd;

  AppSettings copyWith({
    String? outputDevice,
    bool? normalizationEnabled,
    double? crossfadeSeconds,
    double? dailyMixBalance,
    ThemePreset? themePreset,
    double? glassIntensity,
    bool? nowPlayingNotification,
    bool? lockScreenControls,
    bool? dailyMixReady,
    bool? weeklyRecap,
    bool? milestones,
    bool? scanComplete,
    bool? newMusicAdded,
    bool? inactiveReminder,
    bool? quietHoursEnabled,
    TimeOfDay? quietStart,
    TimeOfDay? quietEnd,
  }) {
    return AppSettings(
      outputDevice: outputDevice ?? this.outputDevice,
      normalizationEnabled: normalizationEnabled ?? this.normalizationEnabled,
      crossfadeSeconds: crossfadeSeconds ?? this.crossfadeSeconds,
      dailyMixBalance: dailyMixBalance ?? this.dailyMixBalance,
      themePreset: themePreset ?? this.themePreset,
      glassIntensity: glassIntensity ?? this.glassIntensity,
      nowPlayingNotification:
          nowPlayingNotification ?? this.nowPlayingNotification,
      lockScreenControls: lockScreenControls ?? this.lockScreenControls,
      dailyMixReady: dailyMixReady ?? this.dailyMixReady,
      weeklyRecap: weeklyRecap ?? this.weeklyRecap,
      milestones: milestones ?? this.milestones,
      scanComplete: scanComplete ?? this.scanComplete,
      newMusicAdded: newMusicAdded ?? this.newMusicAdded,
      inactiveReminder: inactiveReminder ?? this.inactiveReminder,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietStart: quietStart ?? this.quietStart,
      quietEnd: quietEnd ?? this.quietEnd,
    );
  }
}

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController() : super(const AppSettings());

  void setOutputDevice(String device) =>
      state = state.copyWith(outputDevice: device);
  void setNormalization(bool v) =>
      state = state.copyWith(normalizationEnabled: v);
  void setCrossfade(double seconds) =>
      state = state.copyWith(crossfadeSeconds: seconds);
  void setDailyMixBalance(double v) =>
      state = state.copyWith(dailyMixBalance: v);
  void setThemePreset(ThemePreset p) => state = state.copyWith(themePreset: p);
  void setGlassIntensity(double v) => state = state.copyWith(glassIntensity: v);

  // Notification setters
  void setNowPlaying(bool v) => state = state.copyWith(nowPlayingNotification: v);
  void setLockScreen(bool v) => state = state.copyWith(lockScreenControls: v);
  void setDailyMixReady(bool v) => state = state.copyWith(dailyMixReady: v);
  void setWeeklyRecap(bool v) => state = state.copyWith(weeklyRecap: v);
  void setMilestones(bool v) => state = state.copyWith(milestones: v);
  void setScanComplete(bool v) => state = state.copyWith(scanComplete: v);
  void setNewMusicAdded(bool v) => state = state.copyWith(newMusicAdded: v);
  void setInactiveReminder(bool v) =>
      state = state.copyWith(inactiveReminder: v);
  void setQuietHoursEnabled(bool v) =>
      state = state.copyWith(quietHoursEnabled: v);
  void setQuietStart(TimeOfDay t) => state = state.copyWith(quietStart: t);
  void setQuietEnd(TimeOfDay t) => state = state.copyWith(quietEnd: t);
}

/// All user preferences (stub-backed, in-memory).
final settingsProvider =
    StateNotifierProvider<SettingsController, AppSettings>((ref) {
  return SettingsController();
});

// ── Equalizer model ───────────────────────────────────────────────────────────

/// Canonical 10-band centre frequencies (Hz) shown beneath each slider.
const List<String> kEqFrequencyLabels = <String>[
  '60',
  '150',
  '400',
  '1k',
  '2.4k',
  '6k',
  '12k',
  '14k',
  '16k',
  '20k',
];

/// Built-in EQ presets. Values are per-band gains in dB (-12…+12).
const Map<String, List<double>> kEqPresets = <String, List<double>>{
  'Flat': <double>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  'Rock': <double>[5, 4, 2, 0, -1, -1, 1, 3, 4, 4],
  'Pop': <double>[-1, 1, 3, 4, 4, 2, 0, -1, -1, -1],
  'Jazz': <double>[3, 2, 1, 2, -1, -1, 0, 1, 2, 3],
  'Classical': <double>[4, 3, 2, 0, -1, -1, 0, 2, 3, 4],
};

/// Preset chips in display order (Custom is derived, not a fixed curve).
const List<String> kEqPresetOrder = <String>[
  'Rock',
  'Pop',
  'Jazz',
  'Classical',
  'Flat',
  'Custom',
];

@immutable
class EqualizerState {
  const EqualizerState({
    required this.bands,
    this.preset = 'Flat',
    this.bassBoost = false,
    this.virtualizer = false,
    this.enabled = true,
  });

  /// Ten per-band gains in dB.
  final List<double> bands;
  final String preset;
  final bool bassBoost;
  final bool virtualizer;
  final bool enabled;

  factory EqualizerState.initial() =>
      EqualizerState(bands: List<double>.from(kEqPresets['Flat']!));

  EqualizerState copyWith({
    List<double>? bands,
    String? preset,
    bool? bassBoost,
    bool? virtualizer,
    bool? enabled,
  }) {
    return EqualizerState(
      bands: bands ?? this.bands,
      preset: preset ?? this.preset,
      bassBoost: bassBoost ?? this.bassBoost,
      virtualizer: virtualizer ?? this.virtualizer,
      enabled: enabled ?? this.enabled,
    );
  }
}

class EqualizerController extends StateNotifier<EqualizerState> {
  EqualizerController() : super(EqualizerState.initial());

  static const double minGain = -12;
  static const double maxGain = 12;

  void setBand(int index, double gain) {
    final next = List<double>.from(state.bands);
    next[index] = gain;
    // Manual edits flip the active preset to "Custom".
    state = state.copyWith(bands: next, preset: 'Custom');
  }

  void applyPreset(String name) {
    if (name == 'Custom') {
      state = state.copyWith(preset: 'Custom');
      return;
    }
    final curve = kEqPresets[name];
    if (curve == null) return;
    state = state.copyWith(bands: List<double>.from(curve), preset: name);
  }

  void setBassBoost(bool v) => state = state.copyWith(bassBoost: v);
  void setVirtualizer(bool v) => state = state.copyWith(virtualizer: v);
  void setEnabled(bool v) => state = state.copyWith(enabled: v);
}

/// EQ band values and presets (stub-backed, in-memory).
final equalizerProvider =
    StateNotifierProvider<EqualizerController, EqualizerState>((ref) {
  return EqualizerController();
});
