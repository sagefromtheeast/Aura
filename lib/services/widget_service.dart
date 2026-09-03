// lib/services/widget_service.dart
// Aura — Home-screen widget data sync (STUB).
//
// Bridges Flutter → native home-screen widgets:
//   • Android: home_widget plugin persists to SharedPreferences; the native
//     AppWidgetProvider reads those keys.
//   • iOS: the same plugin shares data through an App Group's UserDefaults,
//     read by the WidgetKit extension.
//
// For now this only writes DUMMY data — real playback/stats sync arrives with
// the backend. Every call is guarded so it is a no-op (returning false) on
// platforms/tests where no native widget host is registered.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

/// The catalogue of widgets Aura offers on the home screen.
enum HomeWidgetType {
  miniPlayer(
    id: 'mini_player',
    label: 'Mini Player',
    size: '4×1',
    iosOnly: false,
  ),
  dailyMixHub(
    id: 'daily_mix_hub',
    label: 'Daily Mix Hub',
    size: '2×2',
    iosOnly: false,
  ),
  listeningStats(
    id: 'listening_stats',
    label: 'Listening Stats',
    size: '4×2',
    iosOnly: false,
  ),
  smartStack(
    id: 'smart_stack',
    label: 'Smart Stack',
    size: '2×2',
    iosOnly: true,
  );

  const HomeWidgetType({
    required this.id,
    required this.label,
    required this.size,
    required this.iosOnly,
  });

  final String id;
  final String label;
  final String size;
  final bool iosOnly;
}

/// Handles data sync to native home-screen widgets. Stub implementation.
class WidgetService {
  WidgetService();

  static const String _appGroupId = 'group.com.aura.musicplayer';
  static const String _androidWidgetName = 'AuraMusicWidget';
  static const String _iOSWidgetName = 'AuraMusicWidget';

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
      _initialized = true;
    } catch (e) {
      debugPrint('WidgetService.init skipped: $e');
    }
  }

  /// Persist a widget's configuration and ask the OS to refresh it.
  ///
  /// Returns true when the data was handed to the native side. On a host
  /// without the widget extension (desktop, tests) it returns false instead of
  /// throwing.
  Future<bool> addWidget(
    HomeWidgetType type,
    Map<String, Object?> config,
  ) async {
    await init();
    try {
      // Namespaced keys so multiple widget kinds can coexist.
      await HomeWidget.saveWidgetData<String>('active_widget', type.id);
      for (final entry in _flatten(type, config).entries) {
        await _save(entry.key, entry.value);
      }
      // Always include some dummy playback context so the preview isn't empty.
      await HomeWidget.saveWidgetData<String>('track_title', 'Borderline');
      await HomeWidget.saveWidgetData<String>('track_artist', 'Tame Impala');
      await HomeWidget.saveWidgetData<bool>('is_playing', false);

      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        iOSName: _iOSWidgetName,
      );
      return true;
    } catch (e) {
      debugPrint('WidgetService.addWidget(${type.id}) no-op: $e');
      return false;
    }
  }

  Map<String, Object?> _flatten(
      HomeWidgetType type, Map<String, Object?> config) {
    return {for (final e in config.entries) '${type.id}_${e.key}': e.value};
  }

  Future<void> _save(String key, Object? value) async {
    switch (value) {
      case null:
        await HomeWidget.saveWidgetData<String>(key, '');
      case String v:
        await HomeWidget.saveWidgetData<String>(key, v);
      case bool v:
        await HomeWidget.saveWidgetData<bool>(key, v);
      case int v:
        await HomeWidget.saveWidgetData<int>(key, v);
      case double v:
        await HomeWidget.saveWidgetData<double>(key, v);
      case Iterable<Object?> v:
        await HomeWidget.saveWidgetData<String>(key, v.join(','));
      default:
        await HomeWidget.saveWidgetData<String>(key, value.toString());
    }
  }
}

/// App-wide singleton service.
final widgetServiceProvider = Provider<WidgetService>((ref) => WidgetService());
