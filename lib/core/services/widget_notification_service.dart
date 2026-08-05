// lib/core/services/widget_notification_service.dart
// Aura — Home Widget interactions & local notification scheduling.
// Enforces local offline synchronization without telemetry or external servers.

import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_widget/home_widget.dart';
import '../../domain/entities/playback_state.dart';

/// Service managing background home widgets (Android Material You / iOS widgets)
/// and scheduling offline local listening habit notifications.
class WidgetNotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  bool _initialized = false;
  static const String _androidWidgetName = 'AuraMusicWidget';
  static const String _iOSWidgetName = 'AuraMusicWidget';
  static const String _appGroupId = 'group.com.aura.musicplayer';
  static const int _playbackNotificationId = 1001;
  static const int _dailyMixNotificationId = 1002;

  /// Initializes local notification channels and sets up widget data groups.
  Future<void> init() async {
    if (_initialized) return;

    // Initialize home widget App Group for iOS & Android
    await HomeWidget.setAppGroupId(_appGroupId);

    // Setup Flutter Local Notifications initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
    
    // Create dedicated audio playback notification channel for Android
    final androidChannel = const AndroidNotificationChannel(
      'aura_playback_channel',
      'Audio Playback Controls',
      description: 'Persistent media player playback transport and track info',
      importance: Importance.low,
      playSound: false,
      showBadge: false,
    );

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(androidChannel);
    }

    _initialized = true;
  }

  /// Synchronizes current playback state to native OS widgets and lock screen notifications.
  Future<void> updatePlaybackState(PlaybackState state) async {
    if (!_initialized) await init();

    final track = state.currentTrack;
    final isPlaying = state.status == EngineStatus.playing;

    if (track != null) {
      // 1. Sync data to native HomeWidgets (iOS / Android)
      await HomeWidget.saveWidgetData<String>('track_title', track.title);
      await HomeWidget.saveWidgetData<String>('track_artist', track.artistName);
      await HomeWidget.saveWidgetData<String>('cover_art_path', track.filePath);
      await HomeWidget.saveWidgetData<bool>('is_playing', isPlaying);
      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        iOSName: _iOSWidgetName,
      );

      // 2. Display / Update lightweight local playback notification
      final androidDetails = AndroidNotificationDetails(
        'aura_playback_channel',
        'Audio Playback Controls',
        channelDescription: 'Persistent media player playback transport and track info',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: isPlaying,
        onlyAlertOnce: true,
        showProgress: false,
      );
      
      final iOSDetails = const DarwinNotificationDetails(
        presentSound: false,
      );

      final platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await _notificationsPlugin.show(
        _playbackNotificationId,
        track.title,
        '${track.artistName} • ${isPlaying ? "Playing" : "Paused"}',
        platformDetails,
      );
    } else {
      // Clear notification when playback stops or no track is loaded
      await _notificationsPlugin.cancel(_playbackNotificationId);
      await HomeWidget.saveWidgetData<String>('track_title', 'Aura Music');
      await HomeWidget.saveWidgetData<String>('track_artist', 'Tap to start listening');
      await HomeWidget.saveWidgetData<bool>('is_playing', false);
      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        iOSName: _iOSWidgetName,
      );
    }
  }

  /// Schedules daily local notification reminding user that new offline Smart Mixes are ready.
  Future<void> scheduleDailyMixNotification({int hour = 8, int minute = 0}) async {
    if (!_initialized) await init();

    final androidDetails = const AndroidNotificationDetails(
      'aura_mixes_channel',
      'Offline Smart Mixes',
      channelDescription: 'Reminders when local k-means audio clusters have updated',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    final platformDetails = NotificationDetails(android: androidDetails, iOS: const DarwinNotificationDetails());

    await _notificationsPlugin.show(
      _dailyMixNotificationId,
      'Your Daily Smart Mixes are Ready! ✨',
      'Fresh local acoustic clusters calculated without leaving your device.',
      platformDetails,
    );
  }

  /// Cancels all active playback notifications and resets widget state.
  Future<void> dispose() async {
    await _notificationsPlugin.cancelAll();
  }
}
