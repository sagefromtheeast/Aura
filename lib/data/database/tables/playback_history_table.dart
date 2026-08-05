// lib/data/database/tables/playback_history_table.dart
import 'package:drift/drift.dart';

/// Records every play/skip event. Used by BehaviorRepository and StatsCalculator.
@DataClassName('PlaybackHistoryRow')
class PlaybackHistoryTable extends Table {
  @override
  String get tableName => 'playback_history';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get trackId => text()();

  /// Epoch ms when playback started.
  IntColumn get playedAtMs => integer()();

  /// How many ms were actually played.
  IntColumn get durationPlayedMs => integer()();

  BoolColumn get skipped => boolean().withDefault(const Constant(false))();

  /// 'library', 'playlist', 'shuffle', 'mix'
  TextColumn get contextType =>
      text().withDefault(const Constant('library'))();
}
