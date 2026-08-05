// lib/data/database/tables/audio_features_table.dart
import 'package:drift/drift.dart';

/// Stores the 6-dimensional audio feature vector extracted by the C++ analyser.
/// Feature order: [tempo, energy, valence, danceability, loudness, acousticness]
/// All values are normalised to 0.0–1.0 except loudness (-1.0–0.0, dB normalised).
@DataClassName('AudioFeaturesRow')
class AudioFeaturesTable extends Table {
  @override
  String get tableName => 'audio_features';

  /// FK → tracks.id. One row per track.
  TextColumn get trackId => text()();

  /// Beat tempo normalised to [0, 1] (0 = 40 BPM, 1 = 220 BPM).
  RealColumn get tempo => real().withDefault(const Constant(0.0))();

  /// Overall energy level (RMS-based).
  RealColumn get energy => real().withDefault(const Constant(0.0))();

  /// Valence (musical positiveness, 0 = sad/angry, 1 = happy/euphoric).
  RealColumn get valence => real().withDefault(const Constant(0.0))();

  /// Danceability (rhythmic regularity).
  RealColumn get danceability => real().withDefault(const Constant(0.0))();

  /// Loudness normalised from dB (0 = quiet, 1 = loud).
  RealColumn get loudness => real().withDefault(const Constant(0.0))();

  /// Acousticness (1 = purely acoustic, 0 = fully electronic).
  RealColumn get acousticness => real().withDefault(const Constant(0.0))();

  /// Chromaprint fingerprint hash (hex string). Used by DuplicateDetector path 3.
  TextColumn get fingerprintHash => text().nullable()();

  @override
  Set<Column> get primaryKey => {trackId};
}
