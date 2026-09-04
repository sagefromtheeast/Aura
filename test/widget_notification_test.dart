// test/widget_notification_test.dart
// Aura — Step 2.10 widget data bridge, notifications and the update scheduler.
//
//   flutter test test/widget_notification_test.dart

import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';

import 'package:aura/data/settings/app_settings.dart';
import 'package:aura/services/notification_service.dart';
import 'package:aura/services/widget_service.dart';
import 'package:aura/services/widget_update_scheduler.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fakes
// ─────────────────────────────────────────────────────────────────────────────

/// Stands in for the platform's widget storage. Keeps the last value written
/// per key, exactly as SharedPreferences / UserDefaults would.
class FakeWidgetSink implements WidgetDataSink {
  final Map<String, Object?> data = {};
  int updateCount = 0;

  /// When set, every write throws — the "no widget host" case.
  bool failing = false;

  @override
  Future<void> saveString(String key, String value) async => _put(key, value);
  @override
  Future<void> saveBool(String key, bool value) async => _put(key, value);
  @override
  Future<void> saveInt(String key, int value) async => _put(key, value);

  @override
  Future<void> requestUpdate() async {
    if (failing) throw StateError('no widget host');
    updateCount++;
  }

  void _put(String key, Object? value) {
    if (failing) throw StateError('no widget host');
    data[key] = value;
  }
}

class RecordedNotification {
  RecordedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.channelId,
    this.ongoing = false,
    this.imagePath,
    this.progressMax,
    this.progressValue,
    this.when,
  });

  final int id;
  final String title;
  final String body;
  final String channelId;
  final bool ongoing;
  final String? imagePath;
  final int? progressMax;
  final int? progressValue;

  /// Null for an immediate show, set for a scheduled one.
  final DateTime? when;

  bool get isScheduled => when != null;
}

class FakeNotificationBackend implements NotificationBackend {
  final List<RecordedNotification> shown = [];
  final List<int> cancelled = [];
  int cancelAllCount = 0;
  bool initialised = false;

  RecordedNotification? get last => shown.isEmpty ? null : shown.last;

  @override
  Future<void> initialise() async => initialised = true;

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
    shown.add(RecordedNotification(
      id: id,
      title: title,
      body: body,
      channelId: channelId,
      ongoing: ongoing,
      imagePath: imagePath,
      progressMax: progressMax,
      progressValue: progressValue,
    ));
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
    shown.add(RecordedNotification(
      id: id,
      title: title,
      body: body,
      channelId: channelId,
      when: when,
    ));
  }

  @override
  Future<void> cancel(int id) async => cancelled.add(id);

  @override
  Future<void> cancelAll() async => cancelAllCount++;
}

void main() {
  // ───────────────────────────────────────────────────────────────────────────
  group('WidgetService — now playing', () {
    test('writes the keys the native widget reads', () async {
      final sink = FakeWidgetSink();
      final service = WidgetService(sink: sink);

      final ok = await service.updateNowPlayingWidget(
        trackTitle: 'Nights',
        artistName: 'Frank Ocean',
        albumArtPath: '/art/blonde.jpg',
        isPlaying: true,
      );

      expect(ok, isTrue);
      // These key names are a contract with AuraMusicWidget.kt.
      expect(sink.data[WidgetKeys.trackTitle], 'Nights');
      expect(sink.data[WidgetKeys.trackArtist], 'Frank Ocean');
      expect(sink.data[WidgetKeys.coverArtPath], '/art/blonde.jpg');
      expect(sink.data[WidgetKeys.isPlaying], isTrue);
      expect(sink.updateCount, 1);
    });

    test('stamps every write so a widget can show staleness', () async {
      final sink = FakeWidgetSink();
      final before = DateTime.now().millisecondsSinceEpoch;

      await WidgetService(sink: sink).updateStatsWidget(
        listeningTime: '24h 36m',
        topArtist: 'Tame Impala',
        streak: '7 days',
      );

      expect(sink.data[WidgetKeys.lastUpdatedMs],
          greaterThanOrEqualTo(before));
    });

    test('clearing resets to the idle copy', () async {
      final sink = FakeWidgetSink();
      final service = WidgetService(sink: sink);
      await service.updateNowPlayingWidget(
        trackTitle: 'Nights',
        artistName: 'Frank Ocean',
        albumArtPath: '/art.jpg',
        isPlaying: true,
      );

      await service.clearNowPlayingWidget();

      expect(sink.data[WidgetKeys.trackTitle], 'Aura Music');
      expect(sink.data[WidgetKeys.isPlaying], isFalse);
      expect(service.isPlaying, isFalse);
    });

    test('a host without widgets reports false instead of throwing', () async {
      final sink = FakeWidgetSink()..failing = true;

      final ok = await WidgetService(sink: sink).updateNowPlayingWidget(
        trackTitle: 'x',
        artistName: 'y',
        albumArtPath: '',
        isPlaying: false,
      );

      expect(ok, isFalse);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('WidgetService — daily mixes', () {
    WidgetMix mix(String id) => WidgetMix(
          id: id,
          name: 'Mix $id',
          gradientColorHex: '#FF8F6D',
          trackCount: 30,
        );

    test('writes one indexed group per mix', () async {
      final sink = FakeWidgetSink();

      await WidgetService(sink: sink)
          .updateDailyMixWidget(mixes: [mix('a'), mix('b')]);

      expect(sink.data[WidgetKeys.mixCount], 2);
      expect(sink.data[WidgetKeys.mixId(0)], 'a');
      expect(sink.data[WidgetKeys.mixName(1)], 'Mix b');
      expect(sink.data[WidgetKeys.mixTrackCount(0)], 30);
    });

    test('caps at what the tile can show', () async {
      final sink = FakeWidgetSink();

      await WidgetService(sink: sink).updateDailyMixWidget(
        mixes: [for (var i = 0; i < 10; i++) mix('$i')],
      );

      expect(sink.data[WidgetKeys.mixCount], kMaxWidgetMixes);
    });

    test('blanks the slots a shorter list leaves behind', () async {
      final sink = FakeWidgetSink();
      final service = WidgetService(sink: sink);

      await service.updateDailyMixWidget(
          mixes: [mix('a'), mix('b'), mix('c')]);
      await service.updateDailyMixWidget(mixes: [mix('a')]);

      expect(sink.data[WidgetKeys.mixCount], 1);
      // Yesterday's second and third mixes must not linger.
      expect(sink.data[WidgetKeys.mixId(1)], '');
      expect(sink.data[WidgetKeys.mixName(2)], '');
      expect(sink.data[WidgetKeys.mixTrackCount(1)], 0);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('WidgetService — library and customisation', () {
    test('library counts are written as ints', () async {
      final sink = FakeWidgetSink();

      await WidgetService(sink: sink)
          .updateLibraryWidget(totalTracks: 4821, totalPlaylists: 17);

      expect(sink.data[WidgetKeys.libraryTrackCount], 4821);
      expect(sink.data[WidgetKeys.libraryPlaylistCount], 17);
    });

    test('addWidget namespaces its config by widget id', () async {
      final sink = FakeWidgetSink();

      await WidgetService(sink: sink).addWidget(
        HomeWidgetType.dailyMixHub,
        {'accent': '#FFD36E', 'compact': true, 'columns': 2},
      );

      expect(sink.data[WidgetKeys.activeWidget], 'daily_mix_hub');
      expect(sink.data['daily_mix_hub_accent'], '#FFD36E');
      expect(sink.data['daily_mix_hub_compact'], isTrue);
      expect(sink.data['daily_mix_hub_columns'], 2);
    });

    test('unsupported value types degrade to strings, not crashes', () async {
      final sink = FakeWidgetSink();

      await WidgetService(sink: sink).addWidget(
        HomeWidgetType.miniPlayer,
        {'opacity': 0.5, 'tags': ['a', 'b'], 'missing': null},
      );

      expect(sink.data['mini_player_opacity'], '0.5');
      expect(sink.data['mini_player_tags'], 'a,b');
      expect(sink.data['mini_player_missing'], '');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('NotificationService — playback', () {
    late FakeNotificationBackend backend;
    NotificationService serviceWith(AppSettings settings) =>
        NotificationService(
          readSettings: () => settings,
          backend: backend,
        );

    setUp(() => backend = FakeNotificationBackend());

    test('shows an ongoing notification with artwork and progress', () async {
      final ok = await serviceWith(AppSettings.defaults)
          .showPlaybackNotification(
        trackTitle: 'Nights',
        artistName: 'Frank Ocean',
        albumArtPath: '/art/blonde.jpg',
        isPlaying: true,
        position: const Duration(minutes: 2),
        duration: const Duration(minutes: 5),
      );

      expect(ok, isTrue);
      final shown = backend.last!;
      expect(shown.id, NotificationIds.playback);
      expect(shown.title, 'Nights');
      expect(shown.body, contains('Playing'));
      expect(shown.ongoing, isTrue, reason: 'cannot be swiped away');
      expect(shown.imagePath, '/art/blonde.jpg');
      expect(shown.progressValue, 120);
      expect(shown.progressMax, 300);
    });

    test('a paused track is no longer ongoing', () async {
      await serviceWith(AppSettings.defaults).showPlaybackNotification(
        trackTitle: 'Nights',
        artistName: 'Frank Ocean',
        albumArtPath: '',
        isPlaying: false,
        position: Duration.zero,
        duration: const Duration(minutes: 5),
      );

      expect(backend.last!.ongoing, isFalse);
      expect(backend.last!.body, contains('Paused'));
    });

    test('position is clamped to the track length', () async {
      // A stale position past the end would otherwise overflow the bar.
      await serviceWith(AppSettings.defaults).showPlaybackNotification(
        trackTitle: 'x',
        artistName: 'y',
        albumArtPath: '',
        isPlaying: true,
        position: const Duration(minutes: 9),
        duration: const Duration(minutes: 5),
      );

      expect(backend.last!.progressValue, 300);
    });

    test('repeated updates reuse one id rather than stacking', () async {
      final service = serviceWith(AppSettings.defaults);
      for (var i = 0; i < 3; i++) {
        await service.showPlaybackNotification(
          trackTitle: 'Track $i',
          artistName: 'Artist',
          albumArtPath: '',
          isPlaying: true,
          position: Duration(seconds: i),
          duration: const Duration(minutes: 5),
        );
      }

      expect(backend.shown, hasLength(3));
      expect(backend.shown.map((n) => n.id).toSet(),
          {NotificationIds.playback});
    });

    test('turning the category off also removes the existing one', () async {
      final ok = await serviceWith(
        AppSettings.defaults.copyWith(nowPlayingNotification: false),
      ).showPlaybackNotification(
        trackTitle: 'x',
        artistName: 'y',
        albumArtPath: '',
        isPlaying: true,
        position: Duration.zero,
        duration: const Duration(minutes: 3),
      );

      expect(ok, isFalse);
      expect(backend.shown, isEmpty);
      expect(backend.cancelled, [NotificationIds.playback]);
    });

    test('quiet hours do not silence now-playing', () async {
      // It makes no sound and only exists because the user pressed play;
      // hiding it would leave audio playing with no visible source.
      final service = serviceWith(const AppSettings(
        quietHoursStart: TimeOfDay(hour: 0, minute: 0),
        quietHoursEnd: TimeOfDay(hour: 23, minute: 59),
      ));

      final ok = await service.showPlaybackNotification(
        trackTitle: 'x',
        artistName: 'y',
        albumArtPath: '',
        isPlaying: true,
        position: Duration.zero,
        duration: const Duration(minutes: 3),
      );

      expect(ok, isTrue);
    });

    test('cancel works', () async {
      await serviceWith(AppSettings.defaults).cancelPlaybackNotification();
      expect(backend.cancelled, [NotificationIds.playback]);
    });

    test('cancelAll works', () async {
      await serviceWith(AppSettings.defaults).cancelAllNotifications();
      expect(backend.cancelAllCount, 1);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('NotificationService — scheduling', () {
    late FakeNotificationBackend backend;
    final now = DateTime(2026, 2, 14, 12); // A Saturday, midday.

    NotificationService serviceWith(AppSettings settings) =>
        NotificationService(
          readSettings: () => settings,
          backend: backend,
          now: () => now,
        );

    setUp(() => backend = FakeNotificationBackend());

    test('a future daily mix is scheduled, not shown', () async {
      final at = DateTime(2026, 2, 15, 8);

      final ok = await serviceWith(AppSettings.defaults)
          .scheduleDailyMixNotification(
        mixName: 'Morning Mix',
        trackCount: 30,
        scheduledTime: at,
      );

      expect(ok, isTrue);
      expect(backend.last!.isScheduled, isTrue);
      expect(backend.last!.when, at);
      expect(backend.last!.title, contains('Morning Mix'));
      expect(backend.last!.body, contains('30 tracks'));
    });

    test('a time that has passed is shown immediately', () async {
      await serviceWith(AppSettings.defaults).scheduleDailyMixNotification(
        mixName: 'Mix',
        trackCount: 1,
        scheduledTime: now.subtract(const Duration(hours: 1)),
      );

      expect(backend.last!.isScheduled, isFalse);
    });

    test('a disabled category schedules nothing', () async {
      final ok = await serviceWith(
        AppSettings.defaults.copyWith(dailyMixNotifications: false),
      ).scheduleDailyMixNotification(
        mixName: 'Mix',
        trackCount: 1,
        scheduledTime: DateTime(2026, 2, 15, 8),
      );

      expect(ok, isFalse);
      expect(backend.shown, isEmpty);
    });

    test('the master switch overrides an enabled category', () async {
      final ok = await serviceWith(
        AppSettings.defaults.copyWith(notificationsEnabled: false),
      ).scheduleDailyMixNotification(
        mixName: 'Mix',
        trackCount: 1,
        scheduledTime: DateTime(2026, 2, 15, 8),
      );

      expect(ok, isFalse);
    });

    test('milestones default to off', () async {
      final ok = await serviceWith(AppSettings.defaults)
          .scheduleMilestoneNotification(
              message: '1000 tracks played', milestoneType: 1);

      expect(ok, isFalse);
    });

    test('an enabled milestone shows immediately and is keyed by type',
        () async {
      final service = serviceWith(
          AppSettings.defaults.copyWith(milestoneNotifications: true));

      await service.scheduleMilestoneNotification(
          message: 'a', milestoneType: 1);
      await service.scheduleMilestoneNotification(
          message: 'b', milestoneType: 2);

      expect(backend.shown.map((n) => n.id),
          [NotificationIds.milestone(1), NotificationIds.milestone(2)]);
      expect(backend.shown.every((n) => !n.isScheduled), isTrue);
    });

    test('the weekly recap defaults to the next Monday morning', () async {
      await serviceWith(AppSettings.defaults)
          .scheduleWeeklyRecap(totalTime: '24h 36m', topArtist: 'Tame Impala');

      // Saturday the 14th → Monday the 16th at 09:00.
      expect(backend.last!.when, DateTime(2026, 2, 16, 9));
      expect(backend.last!.body, contains('24h 36m'));
      expect(backend.last!.body, contains('Tame Impala'));
    });

    test('nextMondayMorning is strictly in the future', () {
      // A Monday must roll forward a week, not schedule for this morning.
      expect(nextMondayMorning(DateTime(2026, 2, 16, 11)),
          DateTime(2026, 2, 23, 9));
      expect(nextMondayMorning(DateTime(2026, 2, 15, 23)),
          DateTime(2026, 2, 16, 9));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('Quiet hours deferral', () {
    const settings = AppSettings(
      dailyMixNotifications: true,
      quietHoursStart: TimeOfDay(hour: 22, minute: 0),
      quietHoursEnd: TimeOfDay(hour: 7, minute: 0),
    );

    test('a notification outside the window keeps its time', () {
      final at = DateTime(2026, 2, 14, 12);
      expect(resolveDeliveryTime(settings, NotificationKind.dailyMix, at), at);
    });

    test('one late in the evening defers to the next morning', () {
      final at = DateTime(2026, 2, 14, 23, 30);
      expect(
        resolveDeliveryTime(settings, NotificationKind.dailyMix, at),
        DateTime(2026, 2, 15, 7),
      );
    });

    test('one in the small hours defers to the same morning', () {
      final at = DateTime(2026, 2, 14, 3);
      expect(
        resolveDeliveryTime(settings, NotificationKind.dailyMix, at),
        DateTime(2026, 2, 14, 7),
      );
    });

    test('a bypassing category is delivered on time', () {
      final at = DateTime(2026, 2, 14, 23, 30);
      final bypassing = settings
          .copyWith(quietHoursBypass: {NotificationKind.dailyMix});
      expect(
          resolveDeliveryTime(bypassing, NotificationKind.dailyMix, at), at);
    });

    test('a disabled category resolves to nothing', () {
      expect(
        resolveDeliveryTime(settings, NotificationKind.milestones,
            DateTime(2026, 2, 14, 12)),
        isNull,
      );
    });

    test('the service actually applies the deferral', () async {
      final backend = FakeNotificationBackend();
      final at = DateTime(2026, 2, 14, 23, 30);
      final service = NotificationService(
        readSettings: () => settings,
        backend: backend,
        now: () => DateTime(2026, 2, 14, 23, 0),
      );

      await service.scheduleDailyMixNotification(
        mixName: 'Mix',
        trackCount: 10,
        scheduledTime: at,
      );

      expect(backend.last!.when, DateTime(2026, 2, 15, 7));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('WidgetUpdateScheduler', () {
    test('refreshes immediately on start', () async {
      var calls = 0;
      final scheduler = WidgetUpdateScheduler(
        onRefresh: () async {
          calls++;
          return true;
        },
        isPlaying: () => false,
        observeLifecycle: false,
      );

      await scheduler.start();

      expect(calls, 1);
      expect(scheduler.isRunning, isTrue);
      scheduler.stop();
    });

    test('uses the playing interval while playing, idle otherwise', () {
      var playing = false;
      final scheduler = WidgetUpdateScheduler(
        onRefresh: () async => true,
        isPlaying: () => playing,
        observeLifecycle: false,
      );

      expect(scheduler.interval, kWidgetIntervalIdle);
      playing = true;
      expect(scheduler.interval, kWidgetIntervalPlaying);
    });

    test('ticks on the idle schedule when nothing is playing', () {
      fakeAsync((async) {
        var calls = 0;
        final scheduler = WidgetUpdateScheduler(
          onRefresh: () async {
            calls++;
            return true;
          },
          isPlaying: () => false,
          observeLifecycle: false,
        );

        scheduler.start();
        async.flushMicrotasks();
        expect(calls, 1, reason: 'the immediate refresh');

        async.elapse(const Duration(minutes: 29));
        expect(calls, 1, reason: 'not yet due');

        async.elapse(const Duration(minutes: 2));
        expect(calls, 2);

        async.elapse(const Duration(minutes: 30));
        expect(calls, 3);

        scheduler.stop();
      });
    });

    test('ticks twice as often while playing', () {
      fakeAsync((async) {
        var calls = 0;
        final scheduler = WidgetUpdateScheduler(
          onRefresh: () async {
            calls++;
            return true;
          },
          isPlaying: () => true,
          observeLifecycle: false,
        );

        scheduler.start();
        async.flushMicrotasks();
        async.elapse(const Duration(minutes: 31));

        // 15-minute interval: two ticks in half an hour, plus the initial one.
        expect(calls, 3);
        scheduler.stop();
      });
    });

    test('a playback change re-arms at the new interval immediately', () {
      fakeAsync((async) {
        var playing = false;
        var calls = 0;
        final scheduler = WidgetUpdateScheduler(
          onRefresh: () async {
            calls++;
            return true;
          },
          isPlaying: () => playing,
          observeLifecycle: false,
        );

        scheduler.start();
        async.flushMicrotasks();
        calls = 0;

        // Ten minutes into a 30-minute idle wait, playback starts.
        async.elapse(const Duration(minutes: 10));
        playing = true;
        scheduler.onPlaybackStateChanged();

        // The new 15-minute timer starts now; without the re-arm the user
        // would wait another 20 minutes for a stale tile.
        async.elapse(const Duration(minutes: 14));
        expect(calls, 0);
        async.elapse(const Duration(minutes: 2));
        expect(calls, 1);

        scheduler.stop();
      });
    });

    test('stopping cancels the timer', () {
      fakeAsync((async) {
        var calls = 0;
        final scheduler = WidgetUpdateScheduler(
          onRefresh: () async {
            calls++;
            return true;
          },
          isPlaying: () => false,
          observeLifecycle: false,
        );

        scheduler.start();
        async.flushMicrotasks();
        scheduler.stop();
        calls = 0;

        async.elapse(const Duration(hours: 2));
        expect(calls, 0);
        expect(scheduler.isRunning, isFalse);
      });
    });

    test('a failing refresh does not stop the schedule', () {
      fakeAsync((async) {
        var calls = 0;
        final scheduler = WidgetUpdateScheduler(
          onRefresh: () async {
            calls++;
            throw StateError('no widget host');
          },
          isPlaying: () => false,
          observeLifecycle: false,
        );

        scheduler.start();
        async.flushMicrotasks();
        async.elapse(const Duration(minutes: 61));

        expect(calls, greaterThan(1));
        expect(scheduler.isRunning, isTrue);
        scheduler.stop();
      });
    });

    test('starting twice is a no-op', () async {
      var calls = 0;
      final scheduler = WidgetUpdateScheduler(
        onRefresh: () async {
          calls++;
          return true;
        },
        isPlaying: () => false,
        observeLifecycle: false,
      );

      await scheduler.start();
      await scheduler.start();

      expect(calls, 1);
      scheduler.stop();
    });
  });
}
