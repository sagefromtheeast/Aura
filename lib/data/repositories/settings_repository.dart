// lib/data/repositories/settings_repository.dart
// Aura — Persistent settings storage.
//
// Two stores, split by when the value is needed:
//
//   • shared_preferences — scalars. Readable before the database opens, which
//     is what lets the very first frame paint with the user's own theme and
//     glass intensity instead of flashing the defaults.
//   • Drift `settings` table — the structured values (equaliser curve, shuffle
//     config, quiet-hours bypass list), stored as JSON with an updated_at
//     stamp.
//
// Nothing here is secret: Aura has no accounts, tokens or credentials, so
// there is no secure-storage tier. When encrypted backup lands, its key is the
// first thing that will need one.

import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/shuffle_config.dart';
import '../database/app_database.dart';
import '../settings/app_settings.dart';

/// Preference keys. Namespaced so a future package cannot collide with them.
abstract final class SettingsKeys {
  static const themeMode = 'aura.theme.mode';
  static const glassIntensity = 'aura.theme.glass';
  static const accentColorHex = 'aura.theme.accent';

  static const notificationsEnabled = 'aura.notify.enabled';
  static const nowPlaying = 'aura.notify.nowPlaying';
  static const lockScreenControls = 'aura.notify.lockScreen';
  static const dailyMix = 'aura.notify.dailyMix';
  static const weeklyRecap = 'aura.notify.weeklyRecap';
  static const milestones = 'aura.notify.milestones';
  static const library = 'aura.notify.library';
  static const newMusic = 'aura.notify.newMusic';
  static const inactivity = 'aura.notify.inactivity';
  static const notificationSound = 'aura.notify.sound';

  static const quietHoursEnabled = 'aura.quiet.enabled';
  static const quietHoursStart = 'aura.quiet.start';
  static const quietHoursEnd = 'aura.quiet.end';

  static const replayGain = 'aura.audio.replayGain';
  static const crossfadeEnabled = 'aura.audio.crossfadeEnabled';
  static const crossfadeMs = 'aura.audio.crossfadeMs';
  static const eqEnabled = 'aura.audio.eqEnabled';
  static const eqPreset = 'aura.audio.eqPreset';
  static const bassBoost = 'aura.audio.bassBoost';
  static const virtualizer = 'aura.audio.virtualizer';
  static const outputDevice = 'aura.audio.outputDevice';

  static const dailyMixBalance = 'aura.mix.balance';

  static const autoBackupEnabled = 'aura.backup.enabled';
  static const backupPath = 'aura.backup.path';

  /// Drift keys — structured values that do not belong in preferences.
  static const dbShuffleConfig = 'shuffle_config';
  static const dbEqBands = 'eq_bands';
  static const dbQuietHoursBypass = 'quiet_hours_bypass';
}

/// Reads and writes [AppSettings].
class SettingsRepository {
  SettingsRepository({
    required AppDatabase database,
    SharedPreferences? preferences,
  })  : _db = database,
        _prefs = preferences;

  final AppDatabase _db;
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async =>
      _prefs ??= await SharedPreferences.getInstance();

  // ── Load ───────────────────────────────────────────────────────────────────

  /// Reads the stored settings, falling back to defaults field by field.
  ///
  /// A missing store is not an error: a first launch has nothing saved, and
  /// every unread field simply keeps its default.
  Future<AppSettings> load() async {
    final prefs = await _preferences;
    final structured = await _db.settingsDao.readAll();
    const d = AppSettings.defaults;

    return AppSettings(
      themeMode: _enumByName(AuraThemeMode.values,
          prefs.getString(SettingsKeys.themeMode), d.themeMode),
      glassIntensity:
          (prefs.getDouble(SettingsKeys.glassIntensity) ?? d.glassIntensity)
              .clamp(0.0, 1.0),
      accentColorHex:
          prefs.getString(SettingsKeys.accentColorHex) ?? d.accentColorHex,
      shuffleConfig: _decodeShuffle(structured[SettingsKeys.dbShuffleConfig]),
      notificationsEnabled:
          prefs.getBool(SettingsKeys.notificationsEnabled) ??
              d.notificationsEnabled,
      nowPlayingNotification:
          prefs.getBool(SettingsKeys.nowPlaying) ?? d.nowPlayingNotification,
      lockScreenControls: prefs.getBool(SettingsKeys.lockScreenControls) ??
          d.lockScreenControls,
      dailyMixNotifications:
          prefs.getBool(SettingsKeys.dailyMix) ?? d.dailyMixNotifications,
      weeklyRecapNotifications: prefs.getBool(SettingsKeys.weeklyRecap) ??
          d.weeklyRecapNotifications,
      milestoneNotifications:
          prefs.getBool(SettingsKeys.milestones) ?? d.milestoneNotifications,
      libraryNotifications:
          prefs.getBool(SettingsKeys.library) ?? d.libraryNotifications,
      newMusicNotifications:
          prefs.getBool(SettingsKeys.newMusic) ?? d.newMusicNotifications,
      inactivityReminders:
          prefs.getBool(SettingsKeys.inactivity) ?? d.inactivityReminders,
      notificationSound:
          prefs.getString(SettingsKeys.notificationSound) ??
              d.notificationSound,
      quietHoursEnabled:
          prefs.getBool(SettingsKeys.quietHoursEnabled) ?? d.quietHoursEnabled,
      quietHoursStart:
          decodeTimeOfDay(prefs.getString(SettingsKeys.quietHoursStart)) ??
              d.quietHoursStart,
      quietHoursEnd:
          decodeTimeOfDay(prefs.getString(SettingsKeys.quietHoursEnd)) ??
              d.quietHoursEnd,
      quietHoursBypass:
          _decodeBypass(structured[SettingsKeys.dbQuietHoursBypass]),
      replayGainEnabled:
          prefs.getBool(SettingsKeys.replayGain) ?? d.replayGainEnabled,
      crossfadeEnabled:
          prefs.getBool(SettingsKeys.crossfadeEnabled) ?? d.crossfadeEnabled,
      crossfadeMs: prefs.getInt(SettingsKeys.crossfadeMs) ?? d.crossfadeMs,
      eqEnabled: prefs.getBool(SettingsKeys.eqEnabled) ?? d.eqEnabled,
      eqPreset: prefs.getString(SettingsKeys.eqPreset) ?? d.eqPreset,
      eqBands: _decodeBands(structured[SettingsKeys.dbEqBands]),
      bassBoost: prefs.getBool(SettingsKeys.bassBoost) ?? d.bassBoost,
      virtualizer: prefs.getBool(SettingsKeys.virtualizer) ?? d.virtualizer,
      outputDevice:
          prefs.getString(SettingsKeys.outputDevice) ?? d.outputDevice,
      dailyMixBalance:
          (prefs.getDouble(SettingsKeys.dailyMixBalance) ?? d.dailyMixBalance)
              .clamp(0.0, 1.0),
      autoBackupEnabled:
          prefs.getBool(SettingsKeys.autoBackupEnabled) ?? d.autoBackupEnabled,
      backupPath: prefs.getString(SettingsKeys.backupPath) ?? d.backupPath,
    );
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  /// Writes the whole object.
  ///
  /// Whole-object rather than per-field: a settings write happens when a human
  /// moves a slider, so the cost is irrelevant, and it removes any chance of
  /// the two stores drifting apart after a partial failure.
  Future<void> save(AppSettings settings) async {
    final prefs = await _preferences;

    await Future.wait([
      prefs.setString(SettingsKeys.themeMode, settings.themeMode.name),
      prefs.setDouble(SettingsKeys.glassIntensity, settings.glassIntensity),
      prefs.setString(SettingsKeys.accentColorHex, settings.accentColorHex),
      prefs.setBool(
          SettingsKeys.notificationsEnabled, settings.notificationsEnabled),
      prefs.setBool(SettingsKeys.nowPlaying, settings.nowPlayingNotification),
      prefs.setBool(
          SettingsKeys.lockScreenControls, settings.lockScreenControls),
      prefs.setBool(SettingsKeys.dailyMix, settings.dailyMixNotifications),
      prefs.setBool(
          SettingsKeys.weeklyRecap, settings.weeklyRecapNotifications),
      prefs.setBool(SettingsKeys.milestones, settings.milestoneNotifications),
      prefs.setBool(SettingsKeys.library, settings.libraryNotifications),
      prefs.setBool(SettingsKeys.newMusic, settings.newMusicNotifications),
      prefs.setBool(SettingsKeys.inactivity, settings.inactivityReminders),
      prefs.setString(
          SettingsKeys.notificationSound, settings.notificationSound),
      prefs.setBool(
          SettingsKeys.quietHoursEnabled, settings.quietHoursEnabled),
      prefs.setString(SettingsKeys.quietHoursStart,
          encodeTimeOfDay(settings.quietHoursStart)),
      prefs.setString(
          SettingsKeys.quietHoursEnd, encodeTimeOfDay(settings.quietHoursEnd)),
      prefs.setBool(SettingsKeys.replayGain, settings.replayGainEnabled),
      prefs.setBool(SettingsKeys.crossfadeEnabled, settings.crossfadeEnabled),
      prefs.setInt(SettingsKeys.crossfadeMs, settings.crossfadeMs),
      prefs.setBool(SettingsKeys.eqEnabled, settings.eqEnabled),
      prefs.setString(SettingsKeys.eqPreset, settings.eqPreset),
      prefs.setBool(SettingsKeys.bassBoost, settings.bassBoost),
      prefs.setBool(SettingsKeys.virtualizer, settings.virtualizer),
      prefs.setString(SettingsKeys.outputDevice, settings.outputDevice),
      prefs.setDouble(SettingsKeys.dailyMixBalance, settings.dailyMixBalance),
      prefs.setBool(
          SettingsKeys.autoBackupEnabled, settings.autoBackupEnabled),
      prefs.setString(SettingsKeys.backupPath, settings.backupPath),
    ]);

    await _db.settingsDao.writeAll({
      SettingsKeys.dbShuffleConfig: jsonEncode(settings.shuffleConfig.toJson()),
      SettingsKeys.dbEqBands: jsonEncode(settings.eqBands),
      SettingsKeys.dbQuietHoursBypass:
          jsonEncode([for (final k in settings.quietHoursBypass) k.name]),
    });
  }

  /// Epoch ms of the last structured write, or null when nothing is stored.
  Future<int?> lastUpdatedMs() => _db.settingsDao.lastUpdatedMs();

  /// Wipes both stores. Used by "reset to defaults" and by tests.
  Future<void> clear() async {
    final prefs = await _preferences;
    for (final key in prefs.getKeys().toList()) {
      if (key.startsWith('aura.')) await prefs.remove(key);
    }
    await _db.settingsDao.clear();
  }

  // ── Export / import ────────────────────────────────────────────────────────

  /// Writes settings to [path] as pretty-printed JSON.
  ///
  /// Versioned so a future format change can migrate rather than guess.
  Future<void> exportSettings(String path, AppSettings settings) async {
    final payload = {
      'version': kSettingsExportVersion,
      'exportedAtMs': DateTime.now().millisecondsSinceEpoch,
      'settings': settings.toJson(),
    };
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(payload));
  }

  /// Reads settings from [path] and persists them.
  ///
  /// Throws [FormatException] when the file is not an Aura settings export;
  /// individual unknown or malformed *fields* are tolerated and fall back to
  /// their defaults, because losing every preference over one bad key is the
  /// worse failure.
  Future<AppSettings> importSettings(String path) async {
    final raw = await File(path).readAsString();

    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      throw const FormatException('Not a valid Aura settings file');
    }
    if (decoded is! Map || decoded['settings'] is! Map) {
      throw const FormatException('Not a valid Aura settings file');
    }

    final version = decoded['version'];
    if (version is int && version > kSettingsExportVersion) {
      throw FormatException(
        'Settings file is from a newer version of Aura (v$version)',
      );
    }

    final settings = AppSettings.fromJson(
        Map<String, dynamic>.from(decoded['settings'] as Map));
    await save(settings);
    return settings;
  }

  // ── Decoding ───────────────────────────────────────────────────────────────

  static ShuffleConfig _decodeShuffle(String? json) {
    if (json == null || json.isEmpty) return ShuffleConfig.defaults;
    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map) return ShuffleConfig.defaults;
      return ShuffleConfig.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return ShuffleConfig.defaults;
    }
  }

  static List<double> _decodeBands(String? json) {
    if (json == null || json.isEmpty) return kFlatEqBands;
    try {
      final decoded = jsonDecode(json);
      if (decoded is! List || decoded.length != kFlatEqBands.length) {
        return kFlatEqBands;
      }
      return [
        for (final value in decoded)
          if (value is num) value.toDouble().clamp(-12.0, 12.0) else 0.0,
      ];
    } catch (_) {
      return kFlatEqBands;
    }
  }

  static Set<NotificationKind> _decodeBypass(String? json) {
    if (json == null || json.isEmpty) return const {};
    try {
      final decoded = jsonDecode(json);
      if (decoded is! List) return const {};
      return {
        for (final entry in decoded)
          for (final kind in NotificationKind.values)
            if (kind.name == entry) kind,
      };
    } catch (_) {
      return const {};
    }
  }

  static T _enumByName<T extends Enum>(
      List<T> values, String? raw, T fallback) {
    if (raw == null) return fallback;
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return fallback;
  }
}

/// Bumped when the exported shape changes incompatibly.
const int kSettingsExportVersion = 1;
