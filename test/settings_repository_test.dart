// test/settings_repository_test.dart
// Aura — Step 2.9 settings persistence, JSON codecs and export/import.
//
//   flutter test test/settings_repository_test.dart

import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aura/data/database/app_database.dart';
import 'package:aura/data/repositories/settings_repository.dart';
import 'package:aura/data/settings/app_settings.dart';
import 'package:aura/domain/entities/shuffle_config.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repo;
  late Directory tempDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SettingsRepository(database: db);
    tempDir = await Directory.systemTemp.createTemp('aura_settings_test');
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('Defaults', () {
    test('an empty store loads the shipped defaults', () async {
      final settings = await repo.load();

      expect(settings.themeMode, AuraThemeMode.albumArt);
      expect(settings.glassIntensity, 0.7);
      expect(settings.accentColorHex, '#FF8F6D');
      expect(settings.crossfadeMs, 4000);
      expect(settings.replayGainEnabled, isTrue);
      expect(settings.eqPreset, 'Flat');
      expect(settings.eqBands, kFlatEqBands);
      expect(settings.quietHoursStart, const TimeOfDay(hour: 22, minute: 0));
      expect(settings.quietHoursEnd, const TimeOfDay(hour: 7, minute: 0));
      expect(settings.shuffleConfig, ShuffleConfig.defaults);
    });

    test('the accent default matches the design token', () {
      // DesignTokens.primarySeed is 0xFFFF8F6D.
      expect(kDefaultAccentHex, '#FF8F6D');
      expect(AppSettings.defaults.accentColorHex, kDefaultAccentHex);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('Persistence', () {
    test('settings survive a restart', () async {
      const changed = AppSettings(
        themeMode: AuraThemeMode.custom,
        glassIntensity: 0.25,
        accentColorHex: '#3BC9FF',
        crossfadeMs: 8000,
        crossfadeEnabled: false,
        replayGainEnabled: false,
        milestoneNotifications: true,
        notificationSound: 'vinyl_pop',
        quietHoursEnabled: false,
        quietHoursStart: TimeOfDay(hour: 1, minute: 30),
        quietHoursEnd: TimeOfDay(hour: 6, minute: 45),
        eqPreset: 'Rock',
        eqBands: [5, 4, 2, 0, -1, -1, 1, 3, 4, 4],
        outputDevice: 'Studio Monitors',
        autoBackupEnabled: true,
        backupPath: '/backups/aura',
      );
      await repo.save(changed);

      // A fresh repository over the same stores stands in for a restart.
      final reloaded = await SettingsRepository(database: db).load();

      expect(reloaded.themeMode, AuraThemeMode.custom);
      expect(reloaded.glassIntensity, 0.25);
      expect(reloaded.accentColorHex, '#3BC9FF');
      expect(reloaded.crossfadeMs, 8000);
      expect(reloaded.crossfadeEnabled, isFalse);
      expect(reloaded.replayGainEnabled, isFalse);
      expect(reloaded.milestoneNotifications, isTrue);
      expect(reloaded.notificationSound, 'vinyl_pop');
      expect(reloaded.quietHoursEnabled, isFalse);
      expect(reloaded.quietHoursStart, const TimeOfDay(hour: 1, minute: 30));
      expect(reloaded.quietHoursEnd, const TimeOfDay(hour: 6, minute: 45));
      expect(reloaded.eqPreset, 'Rock');
      expect(reloaded.eqBands, [5, 4, 2, 0, -1, -1, 1, 3, 4, 4]);
      expect(reloaded.outputDevice, 'Studio Monitors');
      expect(reloaded.autoBackupEnabled, isTrue);
      expect(reloaded.backupPath, '/backups/aura');
    });

    test('the shuffle config round-trips through the database', () async {
      const config = ShuffleConfig(
        favouriteBias: 0.9,
        recencyAvoidance: 0.1,
        discovery: 0.6,
        artistSpacing: 7,
        albumSpacing: 9,
        moodMatching: true,
        seed: 1234,
      );
      await repo.save(
          AppSettings.defaults.copyWith(shuffleConfig: config));

      final reloaded = await repo.load();
      expect(reloaded.shuffleConfig, config);
    });

    test('the quiet-hours bypass set round-trips', () async {
      await repo.save(AppSettings.defaults.copyWith(
        quietHoursBypass: {
          NotificationKind.nowPlaying,
          NotificationKind.milestones,
        },
      ));

      final reloaded = await repo.load();
      expect(reloaded.quietHoursBypass, {
        NotificationKind.nowPlaying,
        NotificationKind.milestones,
      });
    });

    test('clear() restores defaults on disk', () async {
      await repo.save(
          AppSettings.defaults.copyWith(glassIntensity: 0.1, eqPreset: 'Jazz'));
      await repo.clear();

      final reloaded = await repo.load();
      expect(reloaded.glassIntensity, 0.7);
      expect(reloaded.eqPreset, 'Flat');
    });

    test('structured writes carry a timestamp', () async {
      expect(await repo.lastUpdatedMs(), isNull);

      final before = DateTime.now().millisecondsSinceEpoch;
      await repo.save(AppSettings.defaults);
      final stamp = await repo.lastUpdatedMs();

      expect(stamp, isNotNull);
      expect(stamp, greaterThanOrEqualTo(before));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('JSON codecs', () {
    test('TimeOfDay is stored as zero-padded HH:mm', () {
      expect(encodeTimeOfDay(const TimeOfDay(hour: 7, minute: 5)), '07:05');
      expect(encodeTimeOfDay(const TimeOfDay(hour: 22, minute: 0)), '22:00');
      expect(decodeTimeOfDay('07:05'), const TimeOfDay(hour: 7, minute: 5));
    });

    test('a malformed or out-of-range time decodes to null', () {
      expect(decodeTimeOfDay('nonsense'), isNull);
      expect(decodeTimeOfDay('25:00'), isNull);
      expect(decodeTimeOfDay('12:99'), isNull);
      expect(decodeTimeOfDay('12'), isNull);
      expect(decodeTimeOfDay(42), isNull);
      expect(decodeTimeOfDay(null), isNull);
    });

    test('a full settings object round-trips through JSON', () {
      const original = AppSettings(
        themeMode: AuraThemeMode.dynamicColor,
        glassIntensity: 0.42,
        accentColorHex: '#123ABC',
        notificationsEnabled: false,
        weeklyRecapNotifications: false,
        notificationSound: 'ambient_pulse',
        quietHoursBypass: {NotificationKind.dailyMix},
        crossfadeMs: 1500,
        eqPreset: 'Custom',
        eqBands: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        dailyMixBalance: 0.8,
      );

      final decoded = AppSettings.fromJson(
          jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>);

      expect(decoded.themeMode, original.themeMode);
      expect(decoded.glassIntensity, original.glassIntensity);
      expect(decoded.accentColorHex, original.accentColorHex);
      expect(decoded.notificationsEnabled, isFalse);
      expect(decoded.weeklyRecapNotifications, isFalse);
      expect(decoded.notificationSound, 'ambient_pulse');
      expect(decoded.quietHoursBypass, {NotificationKind.dailyMix});
      expect(decoded.crossfadeMs, 1500);
      expect(decoded.eqBands, original.eqBands);
      expect(decoded.dailyMixBalance, 0.8);
    });

    test('unknown and mistyped fields fall back rather than throwing', () {
      final decoded = AppSettings.fromJson({
        'themeMode': 'not_a_mode',
        'glassIntensity': 'loud',
        'accentColorHex': 'purple',
        'crossfadeMs': 'lots',
        'eqBands': [1, 2, 3], // wrong length
        'quietHoursStart': '99:99',
        'unknownFutureField': true,
      });

      expect(decoded.themeMode, AppSettings.defaults.themeMode);
      expect(decoded.glassIntensity, AppSettings.defaults.glassIntensity);
      expect(decoded.accentColorHex, kDefaultAccentHex);
      expect(decoded.crossfadeMs, AppSettings.defaults.crossfadeMs);
      expect(decoded.eqBands, kFlatEqBands);
      expect(decoded.quietHoursStart, AppSettings.defaults.quietHoursStart);
    });

    test('out-of-range values are clamped, not accepted', () {
      final decoded = AppSettings.fromJson({
        'glassIntensity': 5.0,
        'dailyMixBalance': -3.0,
        'eqBands': [99, -99, 0, 0, 0, 0, 0, 0, 0, 0],
      });

      expect(decoded.glassIntensity, 1.0);
      expect(decoded.dailyMixBalance, 0.0);
      expect(decoded.eqBands[0], 12.0);
      expect(decoded.eqBands[1], -12.0);
    });

    test('a lowercase hex accent is normalised', () {
      expect(AppSettings.fromJson({'accentColorHex': '#ff8f6d'})
          .accentColorHex, '#FF8F6D');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('Quiet hours logic', () {
    const settings = AppSettings(
      quietHoursStart: TimeOfDay(hour: 22, minute: 0),
      quietHoursEnd: TimeOfDay(hour: 7, minute: 0),
    );

    test('a window that wraps midnight is handled', () {
      expect(settings.isWithinQuietHours(const TimeOfDay(hour: 23, minute: 0)),
          isTrue);
      expect(settings.isWithinQuietHours(const TimeOfDay(hour: 3, minute: 0)),
          isTrue);
      expect(settings.isWithinQuietHours(const TimeOfDay(hour: 22, minute: 0)),
          isTrue, reason: 'the start is inclusive');
      expect(settings.isWithinQuietHours(const TimeOfDay(hour: 7, minute: 0)),
          isFalse, reason: 'the end is exclusive');
      expect(settings.isWithinQuietHours(const TimeOfDay(hour: 12, minute: 0)),
          isFalse);
    });

    test('a same-day window is handled', () {
      const daytime = AppSettings(
        quietHoursStart: TimeOfDay(hour: 9, minute: 0),
        quietHoursEnd: TimeOfDay(hour: 17, minute: 0),
      );
      expect(daytime.isWithinQuietHours(const TimeOfDay(hour: 12, minute: 0)),
          isTrue);
      expect(daytime.isWithinQuietHours(const TimeOfDay(hour: 20, minute: 0)),
          isFalse);
    });

    test('a zero-length window silences nothing', () {
      const zero = AppSettings(
        quietHoursStart: TimeOfDay(hour: 9, minute: 0),
        quietHoursEnd: TimeOfDay(hour: 9, minute: 0),
      );
      expect(zero.isWithinQuietHours(const TimeOfDay(hour: 9, minute: 0)),
          isFalse);
    });

    test('disabled quiet hours never apply', () {
      const off = AppSettings(quietHoursEnabled: false);
      expect(off.isWithinQuietHours(const TimeOfDay(hour: 23, minute: 0)),
          isFalse);
    });

    test('delivery honours the master switch, the category and the window', () {
      const at = TimeOfDay(hour: 23, minute: 30);

      expect(settings.wouldDeliver(NotificationKind.dailyMix, at), isFalse,
          reason: 'inside quiet hours without a bypass');

      expect(
        settings
            .copyWith(quietHoursBypass: {NotificationKind.dailyMix})
            .wouldDeliver(NotificationKind.dailyMix, at),
        isTrue,
      );

      expect(
        settings.wouldDeliver(
            NotificationKind.dailyMix, const TimeOfDay(hour: 12, minute: 0)),
        isTrue,
      );

      expect(
        settings
            .copyWith(notificationsEnabled: false)
            .wouldDeliver(
                NotificationKind.dailyMix, const TimeOfDay(hour: 12, minute: 0)),
        isFalse,
        reason: 'the master switch overrides everything',
      );

      expect(
        settings.wouldDeliver(
            NotificationKind.milestones, const TimeOfDay(hour: 12, minute: 0)),
        isFalse,
        reason: 'milestones default to off',
      );
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('Export / import', () {
    test('round-trips through a file', () async {
      const original = AppSettings(
        themeMode: AuraThemeMode.custom,
        glassIntensity: 0.33,
        accentColorHex: '#1BFFFF',
        crossfadeMs: 6000,
        eqPreset: 'Jazz',
        eqBands: [3, 2, 1, 2, -1, -1, 0, 1, 2, 3],
        quietHoursStart: TimeOfDay(hour: 23, minute: 15),
        quietHoursBypass: {NotificationKind.nowPlaying},
      );
      final path = '${tempDir.path}/aura-settings.json';

      await repo.exportSettings(path, original);
      expect(File(path).existsSync(), isTrue);

      // Wipe, then import: the file alone must restore everything.
      await repo.clear();
      expect((await repo.load()).glassIntensity, 0.7);

      final imported = await repo.importSettings(path);

      expect(imported.themeMode, AuraThemeMode.custom);
      expect(imported.glassIntensity, 0.33);
      expect(imported.accentColorHex, '#1BFFFF');
      expect(imported.crossfadeMs, 6000);
      expect(imported.eqPreset, 'Jazz');
      expect(imported.eqBands, [3, 2, 1, 2, -1, -1, 0, 1, 2, 3]);
      expect(imported.quietHoursStart, const TimeOfDay(hour: 23, minute: 15));
      expect(imported.quietHoursBypass, {NotificationKind.nowPlaying});

      // Import persists, so the next load agrees.
      expect((await repo.load()).glassIntensity, 0.33);
    });

    test('the export is versioned and human-readable', () async {
      final path = '${tempDir.path}/versioned.json';
      await repo.exportSettings(path, AppSettings.defaults);

      final decoded = jsonDecode(await File(path).readAsString()) as Map;
      expect(decoded['version'], kSettingsExportVersion);
      expect(decoded['exportedAtMs'], isA<int>());
      expect(decoded['settings'], isA<Map>());
      // Indented, so a user can read and edit it.
      expect(await File(path).readAsString(), contains('\n  "'));
    });

    test('a file from a newer version is refused', () async {
      final path = '${tempDir.path}/future.json';
      await File(path).writeAsString(jsonEncode({
        'version': kSettingsExportVersion + 1,
        'settings': AppSettings.defaults.toJson(),
      }));

      await expectLater(
        repo.importSettings(path),
        throwsA(isA<FormatException>()),
      );
    });

    test('a file that is not settings at all is refused', () async {
      final path = '${tempDir.path}/junk.json';
      await File(path).writeAsString('this is not json');

      await expectLater(
        repo.importSettings(path),
        throwsA(isA<FormatException>()),
      );
    });

    test('one bad field does not cost every other preference', () async {
      final path = '${tempDir.path}/partial.json';
      await File(path).writeAsString(jsonEncode({
        'version': kSettingsExportVersion,
        'settings': {
          'glassIntensity': 0.9,
          'crossfadeMs': 'not a number',
          'eqPreset': 'Rock',
        },
      }));

      final imported = await repo.importSettings(path);

      expect(imported.glassIntensity, 0.9);
      expect(imported.eqPreset, 'Rock');
      expect(imported.crossfadeMs, AppSettings.defaults.crossfadeMs);
    });
  });
}
