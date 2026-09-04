// lib/domain/repositories/audio_feature_repository.dart
// Aura — Access to per-track acoustic features.
//
// Split out from MusicRepository (which exposes only a raw List<double>) so
// SmartMixGenerator can work with typed features including musical key.

import '../entities/audio_features.dart';

abstract interface class AudioFeatureRepository {
  /// Features for one track, or null when it has not been analysed.
  Future<AudioFeatures?> getFeatures(String trackId);

  /// Features for many tracks in one query. Tracks without a row are omitted.
  Future<Map<String, AudioFeatures>> getFeaturesFor(List<String> trackIds);

  /// Every analysed track. Used when a mix needs the whole feature space.
  Future<Map<String, AudioFeatures>> getAllFeatures();

  Future<void> upsert(AudioFeatures features);
}
