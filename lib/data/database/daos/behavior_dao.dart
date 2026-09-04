// lib/data/database/daos/behavior_dao.dart
// Aura — BehaviorDao: playback history read/write.

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/playback_history_table.dart';
import '../tables/tracks_table.dart';

part 'behavior_dao.g.dart';

@DriftAccessor(tables: [PlaybackHistoryTable, TracksTable])
class BehaviorDao extends DatabaseAccessor<AppDatabase>
    with _$BehaviorDaoMixin {
  BehaviorDao(super.db);

  // ── Event Recording ────────────────────────────────────────────────────────

  Future<void> insertEvent(PlaybackHistoryTableCompanion event) =>
      into(playbackHistoryTable).insert(event);

  /// Records a completed/partial play event for [trackId].
  Future<void> recordPlay(
    String trackId, {
    required int durationPlayedMs,
    bool completed = true,
    String contextType = 'library',
    int? playedAtMs,
  }) =>
      insertEvent(PlaybackHistoryTableCompanion.insert(
        trackId: trackId,
        playedAtMs: playedAtMs ?? DateTime.now().millisecondsSinceEpoch,
        durationPlayedMs: durationPlayedMs,
        skipped: const Value(false),
        completed: Value(completed),
        contextType: Value(contextType),
      ));

  /// Records a skip event for [trackId].
  Future<void> recordSkip(
    String trackId, {
    int durationPlayedMs = 0,
    String contextType = 'library',
    int? playedAtMs,
  }) =>
      insertEvent(PlaybackHistoryTableCompanion.insert(
        trackId: trackId,
        playedAtMs: playedAtMs ?? DateTime.now().millisecondsSinceEpoch,
        durationPlayedMs: durationPlayedMs,
        skipped: const Value(true),
        completed: const Value(false),
        contextType: Value(contextType),
      ));

  /// Most recent play/skip events across all tracks, newest first.
  Future<List<PlaybackHistoryRow>> getRecentPlays({int limit = 50}) =>
      (select(playbackHistoryTable)
            ..orderBy([(h) => OrderingTerm.desc(h.playedAtMs)])
            ..limit(limit))
          .get();

  /// Alias for [getAggregatedStats] (play/skip/lastPlayed per track).
  Future<Map<String, ({int plays, int skips, int? lastPlayedMs})>> getStats(
          List<String> trackIds) =>
      getAggregatedStats(trackIds);

  // ── History Queries ────────────────────────────────────────────────────────

  /// Every event in `[startMs, endMs)`, oldest first.
  ///
  /// The statistics engine aggregates in Dart rather than SQL: the same rows
  /// feed a dozen different breakdowns (hour of day, day of week, streaks, top
  /// artists), and one scan plus in-memory grouping beats a dozen round trips.
  /// `idx_history_played_at` keeps the range scan cheap.
  Future<List<PlaybackHistoryRow>> getEventsInRange(
    int startMs,
    int endMs,
  ) =>
      (select(playbackHistoryTable)
            ..where((h) =>
                h.playedAtMs.isBiggerOrEqualValue(startMs) &
                h.playedAtMs.isSmallerThanValue(endMs))
            ..orderBy([(h) => OrderingTerm.asc(h.playedAtMs)]))
          .get();

  /// Epoch ms of each track's first ever play, keyed by track id.
  ///
  /// Backs "new discoveries": a track discovered in a period is one whose
  /// first play falls inside it. Aggregating in SQL keeps this one small
  /// result set rather than every historic row.
  Future<Map<String, int>> getFirstPlayMsPerTrack() async {
    final rows = await customSelect(
      'SELECT track_id, MIN(played_at_ms) AS first_ms '
      'FROM playback_history GROUP BY track_id',
      readsFrom: {playbackHistoryTable},
    ).get();
    return {
      for (final r in rows) r.read<String>('track_id'): r.read<int>('first_ms'),
    };
  }

  /// Epoch ms of the very first recorded event, or null when there is none.
  Future<int?> getFirstEventMs() async {
    final row = await customSelect(
      'SELECT MIN(played_at_ms) AS first_ms FROM playback_history',
      readsFrom: {playbackHistoryTable},
    ).getSingleOrNull();
    return row?.readNullable<int>('first_ms');
  }

  /// Returns history for a specific track, newest first.
  Future<List<PlaybackHistoryRow>> getHistoryForTrack(
    String trackId, {
    int limit = 100,
  }) =>
      (select(playbackHistoryTable)
            ..where((h) => h.trackId.equals(trackId))
            ..orderBy([(h) => OrderingTerm.desc(h.playedAtMs)])
            ..limit(limit))
          .get();

  /// Distinct track ids ordered by their most recent play, newest first.
  Future<List<String>> getRecentlyPlayedTrackIds({int limit = 200}) async {
    final rows = await customSelect(
      'SELECT track_id, MAX(played_at_ms) AS last_ms '
      'FROM playback_history WHERE skipped = 0 '
      'GROUP BY track_id ORDER BY last_ms DESC LIMIT ?',
      variables: [Variable.withInt(limit)],
      readsFrom: {playbackHistoryTable},
    ).get();
    return rows.map((r) => r.read<String>('track_id')).toList();
  }

  /// Returns the top-N most-played track IDs in the last [days] days.
  Future<List<String>> getTopPlayedTrackIds({
    int topN = 20,
    int days = 30,
  }) async {
    final since = DateTime.now()
        .subtract(Duration(days: days))
        .millisecondsSinceEpoch;

    final rows = await customSelect(
      'SELECT track_id, COUNT(*) as play_count '
      'FROM playback_history '
      'WHERE played_at_ms >= ? AND skipped = 0 '
      'GROUP BY track_id '
      'ORDER BY play_count DESC '
      'LIMIT ?',
      variables: [Variable.withInt(since), Variable.withInt(topN)],
      readsFrom: {playbackHistoryTable},
    ).get();

    return rows.map((r) => r.read<String>('track_id')).toList();
  }

  /// Returns play count and skip count per track from history.
  Future<Map<String, ({int plays, int skips, int? lastPlayedMs})>>
      getAggregatedStats(List<String> trackIds) async {
    if (trackIds.isEmpty) return {};

    final placeholders = List.filled(trackIds.length, '?').join(',');
    final rows = await customSelect(
      'SELECT track_id, '
      'SUM(CASE WHEN skipped = 0 THEN 1 ELSE 0 END) as plays, '
      'SUM(CASE WHEN skipped = 1 THEN 1 ELSE 0 END) as skips, '
      'MAX(played_at_ms) as last_played_ms '
      'FROM playback_history '
      'WHERE track_id IN ($placeholders) '
      'GROUP BY track_id',
      variables: trackIds.map(Variable.withString).toList(),
      readsFrom: {playbackHistoryTable},
    ).get();

    return {
      for (final r in rows)
        r.read<String>('track_id'): (
          plays: r.read<int>('plays'),
          skips: r.read<int>('skips'),
          lastPlayedMs: r.readNullable<int>('last_played_ms'),
        ),
    };
  }

  // ── Maintenance ────────────────────────────────────────────────────────────

  /// Deletes history entries older than [cutoffMs] (epoch ms).
  Future<int> pruneHistoryBefore(int cutoffMs) =>
      (delete(playbackHistoryTable)
            ..where((h) => h.playedAtMs.isSmallerThanValue(cutoffMs)))
          .go();
}
