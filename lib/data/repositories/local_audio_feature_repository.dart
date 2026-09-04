// lib/data/repositories/local_audio_feature_repository.dart
// Aura — Drift-backed AudioFeatureRepository.

import 'package:drift/drift.dart';

import '../../domain/entities/audio_features.dart';
import '../../domain/repositories/audio_feature_repository.dart';
import '../database/app_database.dart';

class LocalAudioFeatureRepository implements AudioFeatureRepository {
  LocalAudioFeatureRepository({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  @override
  Future<AudioFeatures?> getFeatures(String trackId) async {
    final row = await _db.trackDao.getAudioFeatures(trackId);
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<Map<String, AudioFeatures>> getFeaturesFor(
      List<String> trackIds) async {
    if (trackIds.isEmpty) return const {};
    final rows = await _db.trackDao.getAudioFeaturesFor(trackIds);
    return {for (final r in rows) r.trackId: _toEntity(r)};
  }

  @override
  Future<Map<String, AudioFeatures>> getAllFeatures() async {
    final rows = await _db.trackDao.getAllAudioFeatures();
    return {for (final r in rows) r.trackId: _toEntity(r)};
  }

  @override
  Future<void> upsert(AudioFeatures features) {
    return _db.trackDao.upsertAudioFeatures(
      AudioFeaturesTableCompanion(
        trackId: Value(features.trackId),
        tempo: Value(features.tempo),
        energy: Value(features.energy),
        valence: Value(features.valence),
        danceability: Value(features.danceability),
        loudness: Value(features.loudness),
        acousticness: Value(features.acousticness),
        musicalKey: Value(features.musicalKey),
        keyName: Value(features.keyName),
      ),
    );
  }

  static AudioFeatures _toEntity(AudioFeaturesRow row) => AudioFeatures(
        trackId: row.trackId,
        tempo: row.tempo,
        energy: row.energy,
        valence: row.valence,
        danceability: row.danceability,
        loudness: row.loudness,
        acousticness: row.acousticness,
        musicalKey: row.musicalKey,
        keyName: row.keyName,
      );
}
