// lib/data/repositories/local_shuffle_state_repository.dart
// Aura — Drift-backed ShuffleStateRepository.
//
// Stores the engine's full state blob in `shuffle_states.state_json`, and
// denormalises config/ids/index into their own columns so the row stays
// inspectable from SQL.

import 'dart:convert';

import '../../domain/repositories/shuffle_state_repository.dart';
import '../database/app_database.dart';

class LocalShuffleStateRepository implements ShuffleStateRepository {
  LocalShuffleStateRepository({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  @override
  Future<String?> load(String contextId) async {
    final row = await _db.shuffleStateDao.load(contextId);
    final blob = row?.stateJson;
    return (blob == null || blob.isEmpty) ? null : blob;
  }

  @override
  Future<void> save(String contextId, String stateJson) async {
    // Pull out the denormalised columns; a malformed blob still gets stored so
    // the caller's state is never silently lost.
    var configJson = '{}';
    var shuffledIdsJson = '[]';
    var currentIndex = 0;
    try {
      final decoded = jsonDecode(stateJson);
      if (decoded is Map) {
        configJson = jsonEncode(decoded['config'] ?? const {});
        shuffledIdsJson = jsonEncode(decoded['shuffledIds'] ?? const []);
        currentIndex = (decoded['currentIndex'] as num?)?.toInt() ?? 0;
      }
    } catch (_) {
      // Keep the defaults above.
    }

    await _db.shuffleStateDao.save(
      contextId: contextId,
      configJson: configJson,
      shuffledIdsJson: shuffledIdsJson,
      currentIndex: currentIndex,
      stateJson: stateJson,
    );
  }

  @override
  Future<void> clear(String contextId) => _db.shuffleStateDao.clear(contextId);
}
