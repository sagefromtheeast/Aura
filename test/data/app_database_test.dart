// test/data/app_database_test.dart
// Aura — Drift database tests against an in-memory SQLite instance.
//
// Requires a host `sqlite3` (available under `flutter test`). Run with:
//   flutter test test/data/app_database_test.dart
// (After any schema change: `dart run build_runner build
//  --delete-conflicting-outputs` first.)

// drift also exports isNull/isNotNull as SQL expression builders; hide them
// so the unqualified names here are flutter_test's matchers.
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura/data/database/app_database.dart';
import 'package:aura/data/repositories/local_shuffle_state_repository.dart';

void main() {
  late AppDatabase db;

  TracksTableCompanion track(String id, {String? path, String genre = 'Rock'}) {
    return TracksTableCompanion.insert(
      id: id,
      title: 'Song $id',
      artistName: 'Artist $id',
      albumTitle: 'Album $id',
      artistId: 'artist_$id',
      albumId: 'album_$id',
      durationMs: 210000,
      filePath: path ?? '/music/$id.flac',
      dateAddedMs: DateTime.now().millisecondsSinceEpoch,
      genre: Value(genre),
    );
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Track CRUD', () {
    test('upsert then read back by id and path', () async {
      await db.trackDao.upsertTrack(track('t1', path: '/music/one.flac'));

      final byId = await db.trackDao.getTrackById('t1');
      expect(byId, isNotNull);
      expect(byId!.title, 'Song t1');

      final byPath = await db.trackDao.getTrackByPath('/music/one.flac');
      expect(byPath?.id, 't1');

      final all = await db.trackDao.getAllTracks();
      expect(all, hasLength(1));
    });

    test('soft delete hides a track from getAllTracks', () async {
      await db.trackDao.upsertTrack(track('t1'));
      await db.trackDao.softDeleteTrack('t1');

      expect(await db.trackDao.getAllTracks(), isEmpty);
      // Row still exists (stats retained).
      expect(await db.trackDao.getTrackById('t1'), isNotNull);
    });

    test('findByGenre and search filter correctly', () async {
      await db.trackDao.upsertTrack(track('t1', genre: 'Jazz'));
      await db.trackDao.upsertTrack(track('t2', genre: 'Rock'));

      final jazz = await db.trackDao.findByGenre('Jazz');
      expect(jazz.map((t) => t.id), ['t1']);

      final hits = await db.trackDao.search('song t2');
      expect(hits.map((t) => t.id), contains('t2'));
    });
  });

  group('Playlist duplicate prevention (DB level)', () {
    test('composite PK rejects a duplicate membership row', () async {
      await db.into(db.playlistsTable).insert(
            PlaylistsTableCompanion.insert(
              id: 'p1',
              name: 'My Playlist',
              createdAtMs: 0,
              updatedAtMs: 0,
            ),
          );

      Future<void> addMembership() => db.into(db.playlistTracksTable).insert(
            PlaylistTracksTableCompanion.insert(
              playlistId: 'p1',
              trackId: 't1',
              position: 0,
            ),
          );

      await addMembership();
      // Second insert of the same {playlistId, trackId} violates the PK.
      await expectLater(addMembership(), throwsA(isA<Exception>()));

      final count = await db
          .customSelect('SELECT COUNT(*) AS c FROM playlist_tracks')
          .getSingle();
      expect(count.read<int>('c'), 1);
    });
  });

  group('ShuffleStateDao', () {
    test('save / load / clear round-trips per context', () async {
      await db.shuffleStateDao.save(
        contextId: 'all_songs',
        configJson: '{"favouriteBias":0.4}',
        shuffledIdsJson: '["t1","t2","t3"]',
        currentIndex: 1,
      );

      final loaded = await db.shuffleStateDao.load('all_songs');
      expect(loaded, isNotNull);
      expect(loaded!.currentIndex, 1);
      expect(loaded.shuffledIdsJson, contains('t2'));

      // Re-saving the same context overwrites (no duplicate rows).
      await db.shuffleStateDao.save(
        contextId: 'all_songs',
        configJson: '{}',
        shuffledIdsJson: '["t9"]',
        currentIndex: 0,
      );
      final again = await db.shuffleStateDao.load('all_songs');
      expect(again!.shuffledIdsJson, contains('t9'));

      await db.shuffleStateDao.clear('all_songs');
      expect(await db.shuffleStateDao.load('all_songs'), isNull);
    });

    test('stores the full engine state blob alongside the columns', () async {
      const blob =
          '{"version":2,"shuffledIds":["a","b"],"currentIndex":1,"config":{}}';
      await db.shuffleStateDao.save(
        contextId: 'playlist_42',
        configJson: '{}',
        shuffledIdsJson: '["a","b"]',
        currentIndex: 1,
        stateJson: blob,
      );

      final row = await db.shuffleStateDao.load('playlist_42');
      expect(row?.stateJson, blob);
      expect(row?.currentIndex, 1);
    });
  });

  group('LocalShuffleStateRepository', () {
    test('round-trips an engine blob and denormalises its columns', () async {
      final repo = LocalShuffleStateRepository(database: db);
      const blob =
          '{"version":2,"shuffledIds":["t1","t2","t3"],"currentIndex":2,'
          '"config":{"favouriteBias":0.4}}';

      await repo.save('all_songs', blob);
      expect(await repo.load('all_songs'), blob);

      // The denormalised columns are populated from the blob.
      final row = await db.shuffleStateDao.load('all_songs');
      expect(row?.currentIndex, 2);
      expect(row?.shuffledIdsJson, contains('t2'));

      await repo.clear('all_songs');
      expect(await repo.load('all_songs'), isNull);
    });

    test('a malformed blob is still stored rather than lost', () async {
      final repo = LocalShuffleStateRepository(database: db);
      await repo.save('ctx', 'not json at all');
      expect(await repo.load('ctx'), 'not json at all');
    });
  });
}
