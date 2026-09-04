// lib/data/repositories/local_behavior_repository.dart
// Aura — LocalBehaviorRepository

import '../../domain/repositories/behavior_repository.dart';
import '../database/app_database.dart';
import 'package:drift/drift.dart';

class LocalBehaviorRepository implements BehaviorRepository {
  LocalBehaviorRepository({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  @override
  Future<void> recordEvent(PlayEvent event) =>
      _db.behaviorDao.insertEvent(
        PlaybackHistoryTableCompanion(
          trackId: Value(event.trackId),
          playedAtMs: Value(event.playedAtMs),
          durationPlayedMs: Value(event.durationPlayedMs),
          skipped: Value(event.skipped),
          completed: Value(event.completed),
          contextType: Value(event.contextType),
        ),
      );

  @override
  Future<Map<String, TrackBehaviorStats>> getBehaviorStats(
      List<String> trackIds) async {
    if (trackIds.isEmpty) return {};

    final aggregated = await _db.behaviorDao.getAggregatedStats(trackIds);

    return {
      for (final id in trackIds)
        id: TrackBehaviorStats(
          trackId: id,
          playCount: aggregated[id]?.plays ?? 0,
          skipCount: aggregated[id]?.skips ?? 0,
          rating: 0, // Rating stored on track row; fetched separately if needed.
          lastPlayedMs: aggregated[id]?.lastPlayedMs,
        ),
    };
  }

  @override
  Future<List<PlayEvent>> getPlayHistory(
    String trackId, {
    int limit = 100,
  }) async {
    final rows = await _db.behaviorDao.getHistoryForTrack(
      trackId,
      limit: limit,
    );
    return rows
        .map((r) => PlayEvent(
              trackId: r.trackId,
              playedAtMs: r.playedAtMs,
              durationPlayedMs: r.durationPlayedMs,
              skipped: r.skipped,
              completed: r.completed,
              contextType: r.contextType,
            ))
        .toList();
  }

  @override
  Future<List<PlayEvent>> getEventsInRange(int startMs, int endMs) async {
    final rows = await _db.behaviorDao.getEventsInRange(startMs, endMs);
    return rows
        .map((r) => PlayEvent(
              trackId: r.trackId,
              playedAtMs: r.playedAtMs,
              durationPlayedMs: r.durationPlayedMs,
              skipped: r.skipped,
              completed: r.completed,
              contextType: r.contextType,
            ))
        .toList();
  }

  @override
  Future<Map<String, int>> getFirstPlayMsPerTrack() =>
      _db.behaviorDao.getFirstPlayMsPerTrack();

  @override
  Future<int?> getFirstEventMs() => _db.behaviorDao.getFirstEventMs();

  @override
  Future<List<String>> getRecentlyPlayedTrackIds({int limit = 200}) =>
      _db.behaviorDao.getRecentlyPlayedTrackIds(limit: limit);

  @override
  Future<List<String>> getTopPlayedTrackIds({
    int topN = 20,
    int days = 30,
  }) =>
      _db.behaviorDao.getTopPlayedTrackIds(topN: topN, days: days);

  @override
  Future<void> pruneHistory(Duration retainDuration) {
    final cutoff = DateTime.now()
        .subtract(retainDuration)
        .millisecondsSinceEpoch;
    return _db.behaviorDao.pruneHistoryBefore(cutoff);
  }
}
