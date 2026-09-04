// lib/ui/screens/settings/settings_providers.dart
// Aura — Providers backing the Settings screens.
//
//   • settingsProvider   → AppSettings, persisted by SettingsRepository
//   • equalizerProvider  → EqualizerState, a projection of the same settings
//
// The model itself lives in lib/data/settings/app_settings.dart; this file is
// the UI's view of it, plus the presets and labels the screens render. All
// state is local; nothing leaves the device.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/settings_repository.dart';
import '../../../data/settings/app_settings.dart';
import '../../../domain/entities/shuffle_config.dart';
import '../../../shared/providers.dart';

export '../../../data/settings/app_settings.dart'
    show AppSettings, AuraThemeMode, NotificationKind;


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

// ── Theme preset ↔ settings ───────────────────────────────────────────────────

/// The stored [AuraThemeMode] a preset implies. Presets that are just an
/// accent colour all map to [AuraThemeMode.custom] and differ by their accent.
extension ThemePresetSettings on ThemePreset {
  AuraThemeMode get themeMode => switch (this) {
        ThemePreset.dynamicColor => AuraThemeMode.dynamicColor,
        ThemePreset.albumArt => AuraThemeMode.albumArt,
        _ => AuraThemeMode.custom,
      };

  String get accentHex =>
      '#${accent.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
}

/// The preset a stored [AppSettings] corresponds to, for the picker's
/// selected state.
ThemePreset presetFor(AppSettings settings) {
  switch (settings.themeMode) {
    case AuraThemeMode.dynamicColor:
      return ThemePreset.dynamicColor;
    case AuraThemeMode.albumArt:
      return ThemePreset.albumArt;
    case AuraThemeMode.system:
    case AuraThemeMode.custom:
      for (final preset in ThemePreset.values) {
        if (preset.accentHex == settings.accentColorHex) return preset;
      }
      return ThemePreset.sunsetWarm;
  }
}

// ── Settings notifier ─────────────────────────────────────────────────────────

/// Holds [AppSettings] and writes every change through to disk.
///
/// Starts from [AppSettings.defaults] and replaces them once the stored values
/// load, so the first frame renders immediately rather than waiting on I/O.
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._repository) : super(AppSettings.defaults) {
    _loaded = _loadFromDisk();
  }

  final SettingsRepository _repository;

  /// Completes when the initial load has finished. Tests await it; the UI does
  /// not need to, because the defaults are already a valid state.
  late final Future<void> _loaded;
  Future<void> get whenLoaded => _loaded;

  Future<void> _loadFromDisk() async {
    try {
      final stored = await _repository.load();
      if (mounted) state = stored;
    } catch (_) {
      // Unreadable storage must not stop the app booting; the user sees
      // defaults and can set them again.
    }
  }

  /// Applies [next] and persists it.
  Future<void> _update(AppSettings next) async {
    state = next;
    await _repository.save(next);
  }

  // ── Appearance ──

  Future<void> updateThemeMode(AuraThemeMode mode) =>
      _update(state.copyWith(themeMode: mode));

  Future<void> setThemePreset(ThemePreset preset) => _update(state.copyWith(
        themeMode: preset.themeMode,
        accentColorHex: preset.accentHex,
      ));

  /// Screens work in percent (0–100); storage is a 0–1 fraction.
  Future<void> setGlassIntensity(double percent) =>
      _update(state.copyWith(glassIntensity: (percent / 100).clamp(0.0, 1.0)));

  Future<void> setAccentColorHex(String hex) =>
      _update(state.copyWith(accentColorHex: hex));

  // ── Shuffle ──

  Future<void> updateShuffleConfig(ShuffleConfig config) =>
      _update(state.copyWith(shuffleConfig: config));

  // ── Notifications ──

  Future<void> setNotificationsEnabled(bool v) =>
      _update(state.copyWith(notificationsEnabled: v));

  /// Toggles one category by [kind], per the spec's `toggleNotification`.
  Future<void> toggleNotification(NotificationKind kind, bool enabled) {
    return _update(switch (kind) {
      NotificationKind.nowPlaying =>
        state.copyWith(nowPlayingNotification: enabled),
      NotificationKind.dailyMix =>
        state.copyWith(dailyMixNotifications: enabled),
      NotificationKind.weeklyRecap =>
        state.copyWith(weeklyRecapNotifications: enabled),
      NotificationKind.milestones =>
        state.copyWith(milestoneNotifications: enabled),
      NotificationKind.libraryScan =>
        state.copyWith(libraryNotifications: enabled),
      NotificationKind.newMusic =>
        state.copyWith(newMusicNotifications: enabled),
      NotificationKind.inactivity =>
        state.copyWith(inactivityReminders: enabled),
    });
  }

  Future<void> setNowPlaying(bool v) =>
      toggleNotification(NotificationKind.nowPlaying, v);
  Future<void> setLockScreen(bool v) =>
      _update(state.copyWith(lockScreenControls: v));
  Future<void> setDailyMixReady(bool v) =>
      toggleNotification(NotificationKind.dailyMix, v);
  Future<void> setWeeklyRecap(bool v) =>
      toggleNotification(NotificationKind.weeklyRecap, v);
  Future<void> setMilestones(bool v) =>
      toggleNotification(NotificationKind.milestones, v);
  Future<void> setScanComplete(bool v) =>
      toggleNotification(NotificationKind.libraryScan, v);
  Future<void> setNewMusicAdded(bool v) =>
      toggleNotification(NotificationKind.newMusic, v);
  Future<void> setInactiveReminder(bool v) =>
      toggleNotification(NotificationKind.inactivity, v);

  Future<void> setNotificationSound(String soundId) =>
      _update(state.copyWith(notificationSound: soundId));

  // ── Quiet hours ──

  Future<void> setQuietHours({
    required bool enabled,
    TimeOfDay? start,
    TimeOfDay? end,
    Set<NotificationKind>? bypass,
  }) =>
      _update(state.copyWith(
        quietHoursEnabled: enabled,
        quietHoursStart: start,
        quietHoursEnd: end,
        quietHoursBypass: bypass,
      ));

  Future<void> setQuietHoursEnabled(bool v) =>
      _update(state.copyWith(quietHoursEnabled: v));
  Future<void> setQuietStart(TimeOfDay t) =>
      _update(state.copyWith(quietHoursStart: t));
  Future<void> setQuietEnd(TimeOfDay t) =>
      _update(state.copyWith(quietHoursEnd: t));

  Future<void> setQuietHoursBypass(NotificationKind kind, bool bypass) {
    final next = Set<NotificationKind>.of(state.quietHoursBypass);
    bypass ? next.add(kind) : next.remove(kind);
    return _update(state.copyWith(quietHoursBypass: next));
  }

  // ── Audio ──

  Future<void> setNormalization(bool v) =>
      _update(state.copyWith(replayGainEnabled: v));

  /// The main settings screen's slider is in seconds; the engine takes ms.
  Future<void> setCrossfade(double seconds) => updateCrossfade(
        enabled: seconds > 0,
        ms: (seconds * 1000).round(),
      );

  Future<void> updateCrossfade({required bool enabled, required int ms}) =>
      _update(state.copyWith(
        crossfadeEnabled: enabled,
        crossfadeMs: ms.clamp(0, 12000),
      ));

  Future<void> updateEqualizerPreset(String preset) {
    final curve = kEqPresets[preset];
    return _update(state.copyWith(
      eqPreset: preset,
      eqBands: curve == null ? null : List<double>.from(curve),
    ));
  }

  Future<void> setEqBand(int index, double gain) {
    final next = List<double>.from(state.eqBands);
    if (index < 0 || index >= next.length) return Future.value();
    next[index] = gain.clamp(-12.0, 12.0);
    // A manual edit is no longer any named preset.
    return _update(state.copyWith(eqBands: next, eqPreset: 'Custom'));
  }

  Future<void> setEqEnabled(bool v) => _update(state.copyWith(eqEnabled: v));
  Future<void> setBassBoost(bool v) => _update(state.copyWith(bassBoost: v));
  Future<void> setVirtualizer(bool v) =>
      _update(state.copyWith(virtualizer: v));

  Future<void> setOutputDevice(String device) =>
      _update(state.copyWith(outputDevice: device));

  // ── Mixes ──

  Future<void> setDailyMixBalance(double v) =>
      _update(state.copyWith(dailyMixBalance: v));

  // ── Backup ──

  Future<void> setAutoBackup({required bool enabled, String? path}) =>
      _update(state.copyWith(autoBackupEnabled: enabled, backupPath: path));

  // ── Whole-object operations ──

  Future<void> exportSettings(String path) =>
      _repository.exportSettings(path, state);

  Future<void> importSettings(String path) async {
    final imported = await _repository.importSettings(path);
    if (mounted) state = imported;
  }

  /// Back to shipped defaults, on disk as well as in memory.
  Future<void> resetToDefaults() async {
    await _repository.clear();
    if (mounted) state = AppSettings.defaults;
  }
}

/// All user preferences, persisted.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.watch(settingsRepositoryProvider));
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

  /// The equaliser slice of the persisted settings.
  factory EqualizerState.from(AppSettings settings) => EqualizerState(
        bands: settings.eqBands,
        preset: settings.eqPreset,
        bassBoost: settings.bassBoost,
        virtualizer: settings.virtualizer,
        enabled: settings.eqEnabled,
      );
}

/// Writes straight through to [settingsProvider], which owns the storage.
class EqualizerController {
  const EqualizerController(this._settings);

  final SettingsNotifier _settings;

  static const double minGain = -12;
  static const double maxGain = 12;

  Future<void> setBand(int index, double gain) =>
      _settings.setEqBand(index, gain);

  Future<void> applyPreset(String name) =>
      _settings.updateEqualizerPreset(name);

  Future<void> setBassBoost(bool v) => _settings.setBassBoost(v);
  Future<void> setVirtualizer(bool v) => _settings.setVirtualizer(v);
  Future<void> setEnabled(bool v) => _settings.setEqEnabled(v);
}

/// EQ band values and presets, projected from the persisted settings.
final equalizerProvider = Provider<EqualizerState>((ref) {
  return EqualizerState.from(ref.watch(settingsProvider));
});

/// Mutations for the equaliser screen.
final equalizerControllerProvider = Provider<EqualizerController>((ref) {
  return EqualizerController(ref.watch(settingsProvider.notifier));
});
