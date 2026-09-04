// lib/shared/providers.dart
// Aura — Root Riverpod providers.
// All providers are defined here and consumed by UI layers in Sprint 2.

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/widget_notification_service.dart';
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
import '../domain/use_cases/duplicate_detector.dart';
import '../domain/use_cases/stats_calculator.dart';
import '../domain/use_cases/playback_orchestrator.dart';
import '../domain/entities/playback_state.dart';
import '../domain/entities/track.dart';
import '../domain/entities/shuffle_config.dart';
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
  return const DuplicateDetector();
});

final statsCalculatorProvider = Provider<StatsCalculator>((ref) {
  return StatsCalculator(
    behaviorRepository: ref.watch(behaviorRepositoryProvider),
    musicRepository: ref.watch(musicRepositoryProvider),
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

final widgetNotificationServiceProvider = Provider<WidgetNotificationService>((ref) {
  final service = WidgetNotificationService();
  service.init();
  return service;
});

class PlaybackStateController extends StateNotifier<PlaybackState> {
  PlaybackStateController(this._orchestrator, this._widgetService) : super(_orchestrator.state) {
    _subscription = _orchestrator.stateStream.listen((newState) {
      state = newState;
      _widgetService.updatePlaybackState(newState);
    });
  }

  final PlaybackOrchestrator _orchestrator;
  final WidgetNotificationService _widgetService;
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
  final widgetService = ref.watch(widgetNotificationServiceProvider);
  return PlaybackStateController(orchestrator, widgetService);
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
