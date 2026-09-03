// lib/data/database/database_provider.dart
// Aura — Canonical Riverpod wiring for the Drift database and its DAOs.
//
// [AppDatabase] is a long-lived singleton. Schema migrations are declared on
// AppDatabase.migration (schemaVersion 2) and applied automatically on open by
// drift_flutter. `lib/shared/providers.dart` re-exports `appDatabaseProvider`
// from here so existing consumers keep their import unchanged.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'daos/behavior_dao.dart';
import 'daos/playlist_dao.dart';
import 'daos/shuffle_state_dao.dart';
import 'daos/track_dao.dart';

/// Singleton Drift database. Closed when the ProviderContainer is disposed
/// (never during a normal app lifecycle; intentionally long-lived).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// ── DAO providers ─────────────────────────────────────────────────────────────

final trackDaoProvider = Provider<TrackDao>(
    (ref) => ref.watch(appDatabaseProvider).trackDao);

final behaviorDaoProvider = Provider<BehaviorDao>(
    (ref) => ref.watch(appDatabaseProvider).behaviorDao);

final playlistDaoProvider = Provider<PlaylistDao>(
    (ref) => ref.watch(appDatabaseProvider).playlistDao);

final shuffleStateDaoProvider = Provider<ShuffleStateDao>(
    (ref) => ref.watch(appDatabaseProvider).shuffleStateDao);
