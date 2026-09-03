// lib/data/database/app_database.dart
// Aura — Drift AppDatabase
// Architecture §3: "Drift (SQLite) for behavior, playlists, metadata"
//
// All migrations must be additive (AGENTS.md: "non-destructive schema changes").
// Never drop columns or tables; only add new ones.

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/tracks_table.dart';
import 'tables/albums_table.dart';
import 'tables/artists_table.dart';
import 'tables/playlists_table.dart';
import 'tables/playback_history_table.dart';
import 'tables/shuffle_state_table.dart';
import 'tables/audio_features_table.dart';
import 'daos/track_dao.dart';
import 'daos/behavior_dao.dart';
import 'daos/playlist_dao.dart';
import 'daos/shuffle_state_dao.dart';

part 'app_database.g.dart';

/// The single Drift database instance for Aura.
///
/// Registered as a singleton Riverpod provider in `shared/providers.dart`.
/// Uses `drift_flutter` which bundles sqlite3 for both Android and iOS.
@DriftDatabase(
  tables: [
    TracksTable,
    AlbumsTable,
    ArtistsTable,
    PlaylistsTable,
    PlaylistTracksTable,
    PlaybackHistoryTable,
    ShuffleStateTable,
    AudioFeaturesTable,
  ],
  daos: [
    TrackDao,
    BehaviorDao,
    PlaylistDao,
    ShuffleStateDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For testing: inject a custom [QueryExecutor] (e.g., in-memory SQLite).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          // Create all tables on first install.
          await m.createAll();

          // Seed indices for common query patterns.
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_tracks_artist ON tracks(artist_id)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_tracks_album ON tracks(album_id)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_history_track ON playback_history(track_id)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_history_played_at ON playback_history(played_at_ms)',
          );
          // One persisted shuffle state per context.
          await customStatement(
            'CREATE UNIQUE INDEX IF NOT EXISTS idx_shuffle_context '
            'ON shuffle_states(context_id)',
          );
        },
        onUpgrade: (m, from, to) async {
          // AGENTS.md: "All Drift migrations must remain non-destructive."
          // Only add columns/tables here; never drop.
          if (from < 2) {
            // v2: per-context shuffle persistence.
            await m.addColumn(
                shuffleStateTable, shuffleStateTable.contextId);
            await m.addColumn(
                shuffleStateTable, shuffleStateTable.updatedAtMs);
            await customStatement(
              'CREATE UNIQUE INDEX IF NOT EXISTS idx_shuffle_context '
              'ON shuffle_states(context_id)',
            );
          }
        },
        beforeOpen: (details) async {
          // Enable WAL mode for better concurrent read performance.
          await customStatement('PRAGMA journal_mode=WAL');
          // Enable foreign key enforcement.
          await customStatement('PRAGMA foreign_keys=ON');
        },
      );
}

/// Opens the SQLite connection using drift_flutter's bundled sqlite3.
QueryExecutor _openConnection() {
  return driftDatabase(name: 'aura');
}
