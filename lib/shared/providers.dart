// lib/shared/providers.dart
// Aura — Root Riverpod providers.
// All providers are defined here and consumed by UI layers in Sprint 2.

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notification_service.dart';
import '../services/widget_service.dart';
import '../data/database/database_provider.dart';
import '../data/repositories/local_music_repository.dart';
import '../data/repositories/local_behavior_repository.dart';
import '../data/repositories/local_playlist_repository.dart';
import '../data/repositories/local_audio_feature_repository.dart';
import '../data/repositories/local_shuffle_state_repository.dart';
import '../domain/repositories/music_repository.dart';
import '../domain/repositories/behavior_repository.dart';
import '../domain/repositories/playlist_repository.dart';
import '../domain/repositories/audio_feature_repository.dart';
import '../domain/repositories/shuffle_state_repository.dart';
import '../domain/intelli_shuffle/intelli_shuffle_engine.dart';
import '../domain/smart_mix/smart_mix_generator.dart';
import '../domain/duplicate_detector/duplicate_detector.dart';
import '../domain/stats/stats_calculator.dart';
import '../domain/use_cases/playback_orchestrator.dart';
import '../domain/entities/playback_state.dart';
import '../domain/entities/track.dart';
import '../domain/entities/shuffle_config.dart';
import '../data/repositories/settings_repository.dart';
import '../data/backup/backup_service.dart';
import '../native/audio_engine_ffi.dart';

// ── Database ──────────────────────────────────────────────────────────────────

// The canonical database + DAO providers live in
// `data/database/database_provider.dart`. Re-exported here so existing
// consumers (`ref.watch(appDatabaseProvider)`) keep their import path.
export '../data/database/database_provider.dart'
    show
        appDatabaseProvider,
        trackDaoProvider,
        behaviorDaoProvider,
        playlistDaoProvider,
        shuffleStateDaoProvider;

// ── Repositories ──────────────────────────────────────────────────────────────

final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  return LocalMusicRepository(database: ref.watch(appDatabaseProvider));
});

final behaviorRepositoryProvider = Provider<BehaviorRepository>((ref) {
  return LocalBehaviorRepository(database: ref.watch(appDatabaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(database: ref.watch(appDatabaseProvider));
});

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return LocalPlaylistRepository(database: ref.watch(appDatabaseProvider));
});

final shuffleStateRepositoryProvider = Provider<ShuffleStateRepository>((ref) {
  return LocalShuffleStateRepository(database: ref.watch(appDatabaseProvider));
});

final audioFeatureRepositoryProvider = Provider<AudioFeatureRepository>((ref) {
  return LocalAudioFeatureRepository(database: ref.watch(appDatabaseProvider));
});

// ── Native Engine ─────────────────────────────────────────────────────────────

/// The FFI audio engine singleton.
final audioEngineFfiProvider = Provider<AudioEngineFfi>((ref) {
  final engine = AudioEngineFfi.instance;
  ref.onDispose(engine.destroy);
  return engine;
});

// ── Use Cases ─────────────────────────────────────────────────────────────────

final shuffleConfigProvider = StateProvider<ShuffleConfig>((ref) {
  return ShuffleConfig.defaults;
});

final intelliShuffleEngineProvider = Provider<IntelliShuffleEngine>((ref) {
  return IntelliShuffleEngine(
    config: ref.watch(shuffleConfigProvider),
    trackRepository: ref.watch(musicRepositoryProvider),
    behaviorRepository: ref.watch(behaviorRepositoryProvider),
  );
});

final smartMixGeneratorProvider = Provider<SmartMixGenerator>((ref) {
  return SmartMixGenerator(
    trackRepository: ref.watch(musicRepositoryProvider),
    behaviorRepository: ref.watch(behaviorRepositoryProvider),
    audioFeatureRepository: ref.watch(audioFeatureRepositoryProvider),
    playlistRepository: ref.watch(playlistRepositoryProvider),
  );
});

final duplicateDetectorProvider = Provider<DuplicateDetector>((ref) {
  return DuplicateDetector(
    trackRepository: ref.watch(musicRepositoryProvider),
    // Fingerprinting decodes audio, so it only runs on the background isolate
    // the scan provider spawns; this instance exists for findDuplicates() calls
    // that stop at the metadata layers, and for resolveDuplicate().
    audioFingerprinter: (path) async =>
        AudioEngineFfi.instance.isAvailable
            ? AudioEngineFfi.instance.getFingerprintValues(path)
            : null,
  );
});

final statsCalculatorProvider = Provider<StatsCalculator>((ref) {
  return StatsCalculator(
    historyRepository: ref.watch(behaviorRepositoryProvider),
    trackRepository: ref.watch(musicRepositoryProvider),
  );
});

final playbackOrchestratorProvider = Provider<PlaybackOrchestrator>((ref) {
  final engine = ref.watch(audioEngineFfiProvider);
  final shuffleEngine = ref.watch(intelliShuffleEngineProvider);
  final musicRepo = ref.watch(musicRepositoryProvider);
  final behaviorRepo = ref.watch(behaviorRepositoryProvider);

  final orchestrator = PlaybackOrchestrator(
    audioEngine: engine,
    shuffleEngine: shuffleEngine,
    musicRepository: musicRepo,
    behaviorRepository: behaviorRepo,
    shuffleStateRepository: ref.watch(shuffleStateRepositoryProvider),
  );

  // Wire engine callbacks → orchestrator.
  engine.onEngineEvent = (eventType, value) {
    if (eventType == EngineEvent.position) {
      orchestrator.onPositionUpdate(value);
    }
  };

  ref.onDispose(() => orchestrator.dispose());
  return orchestrator;
});

/// Pushes playback state to the home-screen widget and the ongoing
/// notification. Replaces the old combined WidgetNotificationService, which
/// did both jobs and could not be tested without a platform channel.
class PlaybackPresenter {
  PlaybackPresenter({
    required WidgetService widgets,
    required NotificationService notifications,
  })  : _widgets = widgets,
        _notifications = notifications;

  final WidgetService _widgets;
  final NotificationService _notifications;

  Future<void> update(PlaybackState state) async {
    final track = state.currentTrack;
    if (track == null) {
      await _widgets.clearNowPlayingWidget();
      await _notifications.cancelPlaybackNotification();
      return;
    }

    final isPlaying = state.status == EngineStatus.playing;
    await _widgets.updateNowPlayingWidget(
      trackTitle: track.title,
      artistName: track.artistName,
      albumArtPath: track.coverArtPath ?? '',
      isPlaying: isPlaying,
    );
    await _notifications.showPlaybackNotification(
      trackTitle: track.title,
      artistName: track.artistName,
      albumArtPath: track.coverArtPath ?? '',
      isPlaying: isPlaying,
      position: Duration(milliseconds: state.positionMs),
      duration: Duration(milliseconds: track.durationMs),
    );
  }
}

final playbackPresenterProvider = Provider<PlaybackPresenter>((ref) {
  final notifications = ref.watch(notificationServiceProvider);
  unawaited(notifications.init());
  return PlaybackPresenter(
    widgets: ref.watch(widgetServiceProvider),
    notifications: notifications,
  );
});

class PlaybackStateController extends StateNotifier<PlaybackState> {
  PlaybackStateController(this._orchestrator, this._presenter)
      : super(_orchestrator.state) {
    _subscription = _orchestrator.stateStream.listen((newState) {
      state = newState;
      unawaited(_presenter.update(newState));
    });
  }

  final PlaybackOrchestrator _orchestrator;
  final PlaybackPresenter _presenter;
  late final StreamSubscription<PlaybackState> _subscription;

  // ── Transport controls (delegate to the orchestrator) ──────────────────────

  Future<void> playTrack(Track track) => _orchestrator.playTrack(track);
  void pause() => _orchestrator.pause();
  void resume() => _orchestrator.resume();
  void seek(Duration position) => _orchestrator.seek(position.inMilliseconds);
  Future<void> next() => _orchestrator.next();
  Future<void> previous() => _orchestrator.previous();
  Future<bool> toggleLike() => _orchestrator.toggleLike();
  void setRepeatMode(RepeatMode mode) => _orchestrator.setRepeatMode(mode);
  void toggleShuffle() => _orchestrator.toggleShuffle();
  void setEqBand(int band, int gainDb) => _orchestrator.setEqBand(band, gainDb);

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final playbackStateProvider = StateNotifierProvider<PlaybackStateController, PlaybackState>((ref) {
  final orchestrator = ref.watch(playbackOrchestratorProvider);
  return PlaybackStateController(orchestrator, ref.watch(playbackPresenterProvider));
});

// ── Library Data ──────────────────────────────────────────────────────────────

/// Async provider for all tracks. Rebuilds on invalidation (after scan).
final allTracksProvider = FutureProvider((ref) {
  return ref.watch(musicRepositoryProvider).getAllTracks();
});

final allAlbumsProvider = FutureProvider((ref) {
  return ref.watch(musicRepositoryProvider).getAllAlbums();
});

final allArtistsProvider = FutureProvider((ref) {
  return ref.watch(musicRepositoryProvider).getAllArtists();
});

final allPlaylistsProvider = FutureProvider((ref) {
  return ref.watch(playlistRepositoryProvider).getAllPlaylists();
});

final favouriteTracksProvider = FutureProvider((ref) {
  // Rebuilds when a favourite is toggled (the notifier invalidates it).
  ref.watch(favouriteIdsProvider);
  return ref.watch(musicRepositoryProvider).getFavouriteTracks();
});

final genresProvider = FutureProvider((ref) {
  return ref.watch(musicRepositoryProvider).getGenres();
});

/// Tracks belonging to one genre.
final genreTracksProvider =
    FutureProvider.family<List<Track>, String>((ref, genre) {
  return ref.watch(musicRepositoryProvider).findTracksByGenre(genre);
});

/// The set of favourited track ids, held in memory so hearts across the app
/// update the instant one is toggled — without a database round trip per read.
class FavouriteIdsNotifier extends StateNotifier<Set<String>> {
  FavouriteIdsNotifier(this._ref) : super(const {}) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    try {
      final favourites =
          await _ref.read(musicRepositoryProvider).getFavouriteTracks();
      if (mounted) state = {for (final t in favourites) t.id};
    } catch (_) {
      // A cold library simply has no favourites yet.
    }
  }

  bool isFavourite(String trackId) => state.contains(trackId);

  /// Toggles [trackId] and returns the new state. Optimistic: the in-memory
  /// set updates first so the UI reacts immediately, then the write persists.
  Future<bool> toggle(String trackId) async {
    final next = state.contains(trackId);
    state = next
        ? (Set<String>.of(state)..remove(trackId))
        : (Set<String>.of(state)..add(trackId));
    await _ref
        .read(musicRepositoryProvider)
        .setFavourite(trackId, !next);
    _ref.invalidate(favouriteTracksProvider);
    _ref.invalidate(allTracksProvider);
    return !next;
  }

  Future<void> set(String trackId, bool favourite) async {
    if (state.contains(trackId) == favourite) return;
    await toggle(trackId);
  }
}

final favouriteIdsProvider =
    StateNotifierProvider<FavouriteIdsNotifier, Set<String>>(
  FavouriteIdsNotifier.new,
);

// ── System playlists (derived, read-only) ─────────────────────────────────────

/// Most recently played distinct tracks.
final recentlyPlayedTracksProvider = FutureProvider<List<Track>>((ref) async {
  final ids = await ref
      .watch(behaviorRepositoryProvider)
      .getRecentlyPlayedTrackIds(limit: 200);
  return ref.watch(musicRepositoryProvider).getTracksByIds(ids);
});

/// Most played distinct tracks (all time).
final mostPlayedTracksProvider = FutureProvider<List<Track>>((ref) async {
  final ids = await ref
      .watch(behaviorRepositoryProvider)
      .getTopPlayedTrackIds(topN: 200, days: 36500);
  return ref.watch(musicRepositoryProvider).getTracksByIds(ids);
});

/// Most recently added tracks.
final recentlyAddedTracksProvider = FutureProvider<List<Track>>((ref) {
  return ref.watch(musicRepositoryProvider).getRecentlyAddedTracks(limit: 200);
});

/// Tracks never played — discovery through exclusion.
final notPlayedTracksProvider = FutureProvider<List<Track>>((ref) {
  return ref.watch(musicRepositoryProvider).getNeverPlayedTracks();
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(
    musicRepository: ref.watch(musicRepositoryProvider),
    playlistRepository: ref.watch(playlistRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
  );
});
