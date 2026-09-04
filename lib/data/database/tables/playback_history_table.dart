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

  /// True when the user abandoned the track before [kListenCompletionRatio].
  BoolColumn get skipped => boolean().withDefault(const Constant(false))();

  /// True when the track was listened to past [kListenCompletionRatio].
  ///
  /// Not simply `!skipped`: a track can be neither, when playback stopped
  /// partway without the user skipping (the app was closed, the queue ended,
  /// a call came in). Only completed rows count toward listening totals, so
  /// the statistics engine needs the distinction the skip flag cannot make.
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  /// 'library', 'playlist', 'shuffle', 'mix'
  TextColumn get contextType =>
      text().withDefault(const Constant('library'))();
}
