// lib/services/widget_service.dart
// Aura — Home-screen widget data bridge.
//
// Flutter writes plain key/value data; the native widget reads it and renders.
//   • Android — home_widget persists to SharedPreferences, which
//     AuraMusicWidget (an es.antonborri.home_widget.HomeWidgetProvider) reads
//     in onUpdate.
//   • iOS — the same plugin writes to the App Group's UserDefaults, which a
//     WidgetKit timeline provider reads. The extension target itself has to be
//     added in Xcode; no plugin can do that for you.
//
// Every write goes through [WidgetDataSink] rather than calling HomeWidget
// directly, so the key names and payload shapes — the part that has to agree
// with native code — are testable without a platform channel.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

/// Keys the native widgets read. Changing one of these means changing
/// AuraMusicWidget.kt and the WidgetKit provider to match.
abstract final class WidgetKeys {
  // Now playing
  static const trackTitle = 'track_title';
  static const trackArtist = 'track_artist';
  static const coverArtPath = 'cover_art_path';
  static const isPlaying = 'is_playing';

  // Daily mixes — indexed, because SharedPreferences has no list type and
  // RemoteViews cannot iterate a JSON blob without a parser on the native side.
  static const mixCount = 'mix_count';
  static String mixId(int i) => 'mix_${i}_id';
  static String mixName(int i) => 'mix_${i}_name';
  static String mixGradient(int i) => 'mix_${i}_gradient';
  static String mixTrackCount(int i) => 'mix_${i}_track_count';

  // Stats
  static const statsListeningTime = 'stats_listening_time';
  static const statsTopArtist = 'stats_top_artist';
  static const statsStreak = 'stats_streak';

  // Library
  static const libraryTrackCount = 'library_track_count';
  static const libraryPlaylistCount = 'library_playlist_count';

  /// Epoch ms of the last successful write, so a widget can show staleness.
  static const lastUpdatedMs = 'last_updated_ms';

  /// Which widget the customisation sheet last configured.
  static const activeWidget = 'active_widget';
}

/// How many daily mixes the widget will show. More than four does not fit a
/// 2×2 tile, and every extra one is four more preference writes.
const int kMaxWidgetMixes = 4;

/// One daily mix, as the widget needs it.
@immutable
class WidgetMix {
  const WidgetMix({
    required this.id,
    required this.name,
    required this.gradientColorHex,
    required this.trackCount,
  });

  final String id;
  final String name;

  /// `#RRGGBB`, used as the tile's gradient seed.
  final String gradientColorHex;

  final int trackCount;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sink
// ─────────────────────────────────────────────────────────────────────────────

/// Where widget data goes. Implemented by [HomeWidgetSink] in the app and by a
/// fake in tests.
abstract interface class WidgetDataSink {
  Future<void> saveString(String key, String value);
  Future<void> saveBool(String key, bool value);
  Future<void> saveInt(String key, int value);

  /// Asks the OS to re-render the widgets.
  Future<void> requestUpdate();
}

/// The real sink, backed by the home_widget plugin.
class HomeWidgetSink implements WidgetDataSink {
  HomeWidgetSink({
    this.appGroupId = kAuraAppGroupId,
    this.androidWidgetName = kAndroidWidgetName,
    this.iOSWidgetName = kIOSWidgetName,
  });

  final String appGroupId;
  final String androidWidgetName;
  final String iOSWidgetName;

  bool _initialised = false;

  Future<void> _ensureInitialised() async {
    if (_initialised) return;
    await HomeWidget.setAppGroupId(appGroupId);
    _initialised = true;
  }

  @override
  Future<void> saveString(String key, String value) async {
    await _ensureInitialised();
    await HomeWidget.saveWidgetData<String>(key, value);
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    await _ensureInitialised();
    await HomeWidget.saveWidgetData<bool>(key, value);
  }

  @override
  Future<void> saveInt(String key, int value) async {
    await _ensureInitialised();
    await HomeWidget.saveWidgetData<int>(key, value);
  }

  @override
  Future<void> requestUpdate() async {
    await _ensureInitialised();
    await HomeWidget.updateWidget(
      name: androidWidgetName,
      iOSName: iOSWidgetName,
    );
  }
}

/// App Group id. Must match the entitlement on the iOS Runner *and* on the
/// WidgetKit extension target, or the two write to different containers.
const String kAuraAppGroupId = 'group.com.aura.musicplayer';

/// Must match the AuraMusicWidget receiver in AndroidManifest.xml.
const String kAndroidWidgetName = 'AuraMusicWidget';

/// Must match the WidgetKit widget's `kind` string.
const String kIOSWidgetName = 'AuraMusicWidget';

// ─────────────────────────────────────────────────────────────────────────────
// Widget catalogue
// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────

/// Pushes app state out to the home-screen widgets.
///
/// Every method swallows platform failures and reports false rather than
/// throwing: there is no widget host on desktop or in tests, and failing to
/// update a widget must never take down playback.
class WidgetService {
  WidgetService({WidgetDataSink? sink}) : _sink = sink ?? HomeWidgetSink();

  final WidgetDataSink _sink;

  /// Set by [updateNowPlayingWidget] and read by the scheduler to pick its
  /// interval — a playing app refreshes more often than an idle one.
  bool get isPlaying => _isPlaying;
  bool _isPlaying = false;

  Future<bool> updateNowPlayingWidget({
    required String trackTitle,
    required String artistName,
    required String albumArtPath,
    required bool isPlaying,
  }) async {
    _isPlaying = isPlaying;
    return _write(() async {
      await _sink.saveString(WidgetKeys.trackTitle, trackTitle);
      await _sink.saveString(WidgetKeys.trackArtist, artistName);
      await _sink.saveString(WidgetKeys.coverArtPath, albumArtPath);
      await _sink.saveBool(WidgetKeys.isPlaying, isPlaying);
    });
  }

  /// Clears the now-playing tile back to its idle copy.
  ///
  /// Not the same as leaving the last track on screen: a widget still showing
  /// a paused track hours later reads as broken.
  Future<bool> clearNowPlayingWidget() {
    _isPlaying = false;
    return updateNowPlayingWidget(
      trackTitle: 'Aura Music',
      artistName: 'Tap to start listening',
      albumArtPath: '',
      isPlaying: false,
    );
  }

  Future<bool> updateDailyMixWidget({required List<WidgetMix> mixes}) {
    final shown = mixes.take(kMaxWidgetMixes).toList();
    return _write(() async {
      await _sink.saveInt(WidgetKeys.mixCount, shown.length);
      for (var i = 0; i < shown.length; i++) {
        await _sink.saveString(WidgetKeys.mixId(i), shown[i].id);
        await _sink.saveString(WidgetKeys.mixName(i), shown[i].name);
        await _sink.saveString(
            WidgetKeys.mixGradient(i), shown[i].gradientColorHex);
        await _sink.saveInt(WidgetKeys.mixTrackCount(i), shown[i].trackCount);
      }
      // Blank the slots beyond the new count, or yesterday's mixes linger in
      // preferences and reappear if the count ever grows again.
      for (var i = shown.length; i < kMaxWidgetMixes; i++) {
        await _sink.saveString(WidgetKeys.mixId(i), '');
        await _sink.saveString(WidgetKeys.mixName(i), '');
        await _sink.saveString(WidgetKeys.mixGradient(i), '');
        await _sink.saveInt(WidgetKeys.mixTrackCount(i), 0);
      }
    });
  }

  Future<bool> updateStatsWidget({
    required String listeningTime,
    required String topArtist,
    required String streak,
  }) {
    return _write(() async {
      await _sink.saveString(WidgetKeys.statsListeningTime, listeningTime);
      await _sink.saveString(WidgetKeys.statsTopArtist, topArtist);
      await _sink.saveString(WidgetKeys.statsStreak, streak);
    });
  }

  Future<bool> updateLibraryWidget({
    required int totalTracks,
    required int totalPlaylists,
  }) {
    return _write(() async {
      await _sink.saveInt(WidgetKeys.libraryTrackCount, totalTracks);
      await _sink.saveInt(WidgetKeys.libraryPlaylistCount, totalPlaylists);
    });
  }

  /// Records which widget the customisation sheet configured, and stores its
  /// options under keys namespaced by widget id.
  Future<bool> addWidget(
    HomeWidgetType type,
    Map<String, Object?> config,
  ) {
    return _write(() async {
      await _sink.saveString(WidgetKeys.activeWidget, type.id);
      for (final entry in config.entries) {
        await _saveDynamic('${type.id}_${entry.key}', entry.value);
      }
    });
  }

  Future<void> _saveDynamic(String key, Object? value) async {
    switch (value) {
      case null:
        await _sink.saveString(key, '');
      case String v:
        await _sink.saveString(key, v);
      case bool v:
        await _sink.saveBool(key, v);
      case int v:
        await _sink.saveInt(key, v);
      case double v:
        // No float accessor on the native side; a string keeps full precision
        // and the widget parses it if it cares.
        await _sink.saveString(key, v.toString());
      case Iterable<Object?> v:
        await _sink.saveString(key, v.join(','));
      default:
        await _sink.saveString(key, value.toString());
    }
  }

  /// Runs [body], stamps the write, and asks the OS to re-render.
  Future<bool> _write(Future<void> Function() body) async {
    try {
      await body();
      await _sink.saveInt(
          WidgetKeys.lastUpdatedMs, DateTime.now().millisecondsSinceEpoch);
      await _sink.requestUpdate();
      return true;
    } catch (error) {
      // No widget host (desktop, tests) or a channel failure. Widgets are
      // decorative; playback must not care.
      debugPrint('WidgetService: update skipped: $error');
      return false;
    }
  }
}

/// App-wide singleton service.
final widgetServiceProvider = Provider<WidgetService>((ref) => WidgetService());
