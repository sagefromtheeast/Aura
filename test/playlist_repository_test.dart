// test/playlist_repository_test.dart
// Aura — Step 2.8 playlist CRUD, duplicate handling and M3U round-trip.
//
// Runs against an in-memory SQLite database, so the composite primary key and
// position bookkeeping are exercised for real rather than through a fake.
//
//   flutter test test/playlist_repository_test.dart

import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura/data/database/app_database.dart';
import 'package:aura/data/playlists/m3u.dart';
import 'package:aura/data/repositories/local_playlist_repository.dart';
import 'package:aura/domain/entities/playlist.dart';

void main() {
  late AppDatabase db;
  late LocalPlaylistRepository repo;
  late Directory tempDir;

  /// Inserts a track and returns its id.
  Future<String> addTrack(
    String id, {
    String title = 'Song',
    String artist = 'Artist',
    String album = 'Album',
    int durationMs = 210000,
    String? path,
  }) async {
    await db.trackDao.upsertTrack(TracksTableCompanion.insert(
      id: id,
      title: title,
      artistName: artist,
      albumTitle: album,
      artistId: 'artist_$artist',
      albumId: 'album_$album',
      durationMs: durationMs,
      filePath: path ?? '/music/$id.flac',
      dateAddedMs: 0,
    ));
    return id;
  }

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = LocalPlaylistRepository(database: db);
    tempDir = await Directory.systemTemp.createTemp('aura_m3u_test');
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('CRUD', () {
    test('create, rename, delete', () async {
      final playlist =
          await repo.createPlaylist(name: 'Road Trip', description: 'Loud');

      expect(playlist.name, 'Road Trip');
      expect(playlist.description, 'Loud');
      expect(await repo.getAllPlaylists(), hasLength(1));

      await repo.renamePlaylist(playlist.id, 'Long Drive');
      expect((await repo.getPlaylistById(playlist.id))!.name, 'Long Drive');

      await repo.deletePlaylist(playlist.id);
      expect(await repo.getPlaylistById(playlist.id), isNull);
      expect(await repo.getAllPlaylists(), isEmpty);
    });

    test('deleting a playlist cascades to its membership rows', () async {
      final playlist = await repo.createPlaylist(name: 'Temp');
      await addTrack('t1');
      await repo.addTrack(playlist.id, 't1');

      await repo.deletePlaylist(playlist.id);

      final rows = await db
          .customSelect('SELECT COUNT(*) AS c FROM playlist_tracks')
          .getSingle();
      expect(rows.read<int>('c'), 0);
    });

    test('tracks keep insertion order', () async {
      final playlist = await repo.createPlaylist(name: 'Ordered');
      for (final id in ['c', 'a', 'b']) {
        await addTrack(id, title: 'Song $id');
      }
      await repo.addTrack(playlist.id, 'c');
      await repo.addTrack(playlist.id, 'a');
      await repo.addTrack(playlist.id, 'b');

      final tracks = await repo.getPlaylistTracks(playlist.id);
      expect(tracks.map((t) => t.id), ['c', 'a', 'b']);
    });

    test('reorderTracks replaces the order wholesale', () async {
      final playlist = await repo.createPlaylist(name: 'Shuffled');
      for (final id in ['a', 'b', 'c']) {
        await addTrack(id, title: 'Song $id');
      }
      await repo.addTracks(playlist.id, ['a', 'b', 'c']);

      await repo.reorderTracks(playlist.id, ['c', 'a', 'b']);

      final tracks = await repo.getPlaylistTracks(playlist.id);
      expect(tracks.map((t) => t.id), ['c', 'a', 'b']);
    });

    test('track count is reported without loading the tracks', () async {
      final playlist = await repo.createPlaylist(name: 'Counted');
      for (var i = 0; i < 5; i++) {
        await addTrack('t$i', title: 'Song $i');
      }
      await repo.addTracks(playlist.id, ['t0', 't1', 't2', 't3', 't4']);

      expect(await repo.getPlaylistTrackCount(playlist.id), 5);
    });

    test('an id whose track has been purged is skipped, not fatal', () async {
      final playlist = await repo.createPlaylist(name: 'Stale');
      await addTrack('here');
      await repo.addTracks(playlist.id, ['here', 'gone']);

      // The membership row survives; only the entity lookup comes up empty.
      expect(await repo.getPlaylistTrackCount(playlist.id), 2);
      final tracks = await repo.getPlaylistTracks(playlist.id);
      expect(tracks.map((t) => t.id), ['here']);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('Duplicate prevention', () {
    test('adding the same track twice returns false the second time',
        () async {
      final playlist = await repo.createPlaylist(name: 'Dupes');
      await addTrack('t1');

      expect(await repo.addTrack(playlist.id, 't1'), isTrue);
      expect(await repo.addTrack(playlist.id, 't1'), isFalse);
      expect(await repo.getPlaylistTrackCount(playlist.id), 1);
    });

    test('batch add skips what is already there and reports the real count',
        () async {
      final playlist = await repo.createPlaylist(name: 'Batch');
      for (final id in ['a', 'b', 'c']) {
        await addTrack(id, title: 'Song $id');
      }
      await repo.addTrack(playlist.id, 'a');

      expect(await repo.addTracks(playlist.id, ['a', 'b', 'c']), 2);
      expect(
        (await repo.getPlaylistTracks(playlist.id)).map((t) => t.id),
        ['a', 'b', 'c'],
      );
    });

    test('a batch containing the same id twice adds it once', () async {
      final playlist = await repo.createPlaylist(name: 'Repeats');
      await addTrack('a');

      expect(await repo.addTracks(playlist.id, ['a', 'a', 'a']), 1);
      expect(await repo.getPlaylistTrackCount(playlist.id), 1);
    });

    test('the composite key rejects a duplicate membership row outright',
        () async {
      final playlist = await repo.createPlaylist(name: 'Guard');
      await addTrack('t1');
      await repo.addTrack(playlist.id, 't1');

      // Bypassing the repository's own check must still fail at the database.
      Future<void> insertAgain() => db.into(db.playlistTracksTable).insert(
            PlaylistTracksTableCompanion.insert(
              playlistId: playlist.id,
              trackId: 't1',
              position: 99,
            ),
          );
      await expectLater(insertAgain(), throwsA(isA<Exception>()));
    });

    test('removing a track closes the gap in positions', () async {
      final playlist = await repo.createPlaylist(name: 'Gaps');
      for (final id in ['a', 'b', 'c']) {
        await addTrack(id, title: 'Song $id');
      }
      await repo.addTracks(playlist.id, ['a', 'b', 'c']);

      await repo.removeTrack(playlist.id, 'b');

      final rows = await db
          .customSelect(
            'SELECT track_id, position FROM playlist_tracks '
            'WHERE playlist_id = ? ORDER BY position',
            variables: [Variable.withString(playlist.id)],
          )
          .get();
      expect(rows.map((r) => r.read<int>('position')), [0, 1]);

      // A track added afterwards lands at the end, not into the old hole.
      await addTrack('d', title: 'Song d');
      await repo.addTrack(playlist.id, 'd');
      expect(
        (await repo.getPlaylistTracks(playlist.id)).map((t) => t.id),
        ['a', 'c', 'd'],
      );
    });

    test('removeTracks removes several at once', () async {
      final playlist = await repo.createPlaylist(name: 'Bulk');
      for (final id in ['a', 'b', 'c', 'd']) {
        await addTrack(id, title: 'Song $id');
      }
      await repo.addTracks(playlist.id, ['a', 'b', 'c', 'd']);

      await repo.removeTracks(playlist.id, ['b', 'd']);

      expect(
        (await repo.getPlaylistTracks(playlist.id)).map((t) => t.id),
        ['a', 'c'],
      );
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('Duplicate detection within a playlist', () {
    test('finds the same recording added as two different files', () async {
      final playlist = await repo.createPlaylist(name: 'Two copies');
      await addTrack('flac',
          title: 'Nights', artist: 'Frank Ocean', path: '/music/nights.flac');
      await addTrack('mp3',
          title: 'Nights', artist: 'Frank Ocean', path: '/music/nights.mp3');
      await addTrack('other', title: 'Solo', durationMs: 259000);
      await repo.addTracks(playlist.id, ['flac', 'mp3', 'other']);

      final dupes = await repo.getDuplicateTracks(playlist.id);

      // The first occurrence in playlist order is the keeper.
      expect(dupes.map((t) => t.id), ['mp3']);
    });

    test('keeps the first occurrence by playlist position, not by quality',
        () async {
      final playlist = await repo.createPlaylist(name: 'Order matters');
      await addTrack('mp3', title: 'Nights', artist: 'Frank Ocean');
      await addTrack('flac', title: 'Nights', artist: 'Frank Ocean');
      // The MP3 was placed first, so it stays even though the FLAC is better.
      await repo.addTracks(playlist.id, ['mp3', 'flac']);

      expect(
        (await repo.getDuplicateTracks(playlist.id)).map((t) => t.id),
        ['flac'],
      );
    });

    test('removeDuplicates deletes them and reports the count', () async {
      final playlist = await repo.createPlaylist(name: 'Tidy');
      await addTrack('a', title: 'Nights', artist: 'Frank Ocean');
      await addTrack('b', title: 'Nights', artist: 'Frank Ocean');
      await addTrack('c', title: 'Nights (Remastered)', artist: 'Frank Ocean');
      await addTrack('d', title: 'Pyramids', durationMs: 594000);
      await repo.addTracks(playlist.id, ['a', 'b', 'c', 'd']);

      expect(await repo.removeDuplicates(playlist.id), 2);
      expect(
        (await repo.getPlaylistTracks(playlist.id)).map((t) => t.id),
        ['a', 'd'],
      );

      // The tracks themselves are untouched — this only tidies the playlist.
      expect(await db.trackDao.getTrackById('b'), isNotNull);
    });

    test('a playlist with nothing to clean reports zero', () async {
      final playlist = await repo.createPlaylist(name: 'Clean');
      await addTrack('a', title: 'One');
      await addTrack('b', title: 'Two', durationMs: 400000);
      await repo.addTracks(playlist.id, ['a', 'b']);

      expect(await repo.getDuplicateTracks(playlist.id), isEmpty);
      expect(await repo.removeDuplicates(playlist.id), 0);
    });

    test('a playlist of fewer than two tracks is trivially clean', () async {
      final playlist = await repo.createPlaylist(name: 'Single');
      await addTrack('a');
      await repo.addTrack(playlist.id, 'a');

      expect(await repo.getDuplicateTracks(playlist.id), isEmpty);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('M3U parsing', () {
    test('reads EXTINF metadata and paths', () {
      final entries = parseM3u('''
#EXTM3U
#PLAYLIST:Late Night
#EXTINF:307,Frank Ocean - Nights
/music/nights.flac
#EXTINF:259,Solo
/music/solo.flac
''');

      expect(entries, hasLength(2));
      expect(entries[0].artist, 'Frank Ocean');
      expect(entries[0].title, 'Nights');
      expect(entries[0].durationSeconds, 307);
      expect(entries[0].path, '/music/nights.flac');
      // No " - " means the whole label is the title.
      expect(entries[1].artist, isNull);
      expect(entries[1].title, 'Solo');
    });

    test('survives CRLF, blank lines and a missing header', () {
      final entries = parseM3u('/music/a.flac\r\n\r\n/music/b.flac\r\n');
      expect(entries.map((e) => e.path), ['/music/a.flac', '/music/b.flac']);
    });

    test('a title containing " - " keeps its second half', () {
      final entries = parseM3u('#EXTINF:200,Artist - Song - Live\n/a.flac\n');
      expect(entries.single.artist, 'Artist');
      expect(entries.single.title, 'Song - Live');
    });

    test('a duration of -1 means unknown', () {
      final entries = parseM3u('#EXTINF:-1,Artist - Song\n/a.flac\n');
      expect(entries.single.durationSeconds, isNull);
      expect(entries.single.durationMs, isNull);
    });

    test('EXTINF applies only to the path that follows it', () {
      final entries = parseM3u('''
#EXTINF:100,A - One
/one.flac
/two.flac
''');
      expect(entries[0].title, 'One');
      expect(entries[1].title, isNull);
    });

    test('writes a header, a name and one EXTINF per entry', () {
      final content = writeM3u(
        const [
          M3uEntry(
            path: '/music/nights.flac',
            title: 'Nights',
            artist: 'Frank Ocean',
            durationSeconds: 307,
          ),
        ],
        playlistName: 'Late Night',
      );

      final lines = content.trim().split('\n');
      expect(lines[0], '#EXTM3U');
      expect(lines[1], '#PLAYLIST:Late Night');
      expect(lines[2], '#EXTINF:307,Frank Ocean - Nights');
      expect(lines[3], '/music/nights.flac');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('M3U import / export', () {
    test('round-trips a playlist through disk', () async {
      final source = await repo.createPlaylist(name: 'Evening');
      await addTrack('a',
          title: 'Nights', artist: 'Frank Ocean', path: '/music/a.flac');
      await addTrack('b',
          title: 'Solo', artist: 'Frank Ocean', path: '/music/b.flac');
      await repo.addTracks(source.id, ['a', 'b']);

      final file = '${tempDir.path}/evening.m3u8';
      await repo.exportM3u(source.id, file);
      expect(File(file).existsSync(), isTrue);

      final result = await repo.importM3u(file);

      expect(result.imported, 2);
      expect(result.unmatched, isEmpty);
      expect(result.playlist.name, 'Evening');
      expect(
        (await repo.getPlaylistTracks(result.playlist.id)).map((t) => t.id),
        ['a', 'b'],
      );
    });

    test('an explicit name overrides the file\'s own', () async {
      final source = await repo.createPlaylist(name: 'Original');
      await addTrack('a');
      await repo.addTrack(source.id, 'a');

      final file = '${tempDir.path}/x.m3u';
      await repo.exportM3u(source.id, file);

      final result = await repo.importM3u(file, playlistName: 'Renamed');
      expect(result.playlist.name, 'Renamed');
    });

    test('entries with no matching track are reported, not dropped silently',
        () async {
      await addTrack('a', path: '/music/a.flac');
      final file = File('${tempDir.path}/mixed.m3u');
      await file.writeAsString('''
#EXTM3U
/music/a.flac
/music/missing.flac
''');

      final result = await repo.importM3u(file.path);

      expect(result.imported, 1);
      expect(result.unmatched, ['/music/missing.flac']);
      expect(result.total, 2);
    });

    test('relative paths resolve against the playlist file', () async {
      await addTrack('a', path: '${tempDir.path}/songs/a.flac');
      final file = File('${tempDir.path}/rel.m3u');
      await file.writeAsString('#EXTM3U\nsongs/a.flac\n');

      final result = await repo.importM3u(file.path);
      expect(result.imported, 1);
      expect(result.unmatched, isEmpty);
    });

    test('a moved library still matches on filename', () async {
      // The file now lives elsewhere than the playlist says.
      await addTrack('a', path: '/new/root/nights.flac');
      final file = File('${tempDir.path}/moved.m3u');
      await file.writeAsString('#EXTM3U\n/old/root/nights.flac\n');

      final result = await repo.importM3u(file.path);
      expect(result.imported, 1);
    });

    test('metadata matching is the last resort', () async {
      await addTrack('a',
          title: 'Nights',
          artist: 'Frank Ocean',
          durationMs: 307000,
          path: '/music/track07.flac');
      final file = File('${tempDir.path}/meta.m3u');
      // Neither the path nor the filename matches; only the tags do.
      await file.writeAsString(
          '#EXTM3U\n#EXTINF:307,Frank Ocean - Nights\n/elsewhere/07.mp3\n');

      final result = await repo.importM3u(file.path);
      expect(result.imported, 1);
    });

    test('a wrong-duration metadata entry does not match', () async {
      await addTrack('a',
          title: 'Nights',
          artist: 'Frank Ocean',
          durationMs: 307000,
          path: '/music/x.flac');
      final file = File('${tempDir.path}/wrong.m3u');
      await file.writeAsString(
          '#EXTM3U\n#EXTINF:120,Frank Ocean - Nights\n/elsewhere/y.mp3\n');

      final result = await repo.importM3u(file.path);
      expect(result.imported, 0);
      expect(result.unmatched, hasLength(1));
    });

    test('exporting an unknown playlist is an error, not an empty file',
        () async {
      await expectLater(
        repo.exportM3u('nope', '${tempDir.path}/nope.m3u'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('an empty playlist exports just the header', () async {
      final playlist = await repo.createPlaylist(name: 'Empty');
      final file = '${tempDir.path}/empty.m3u';
      await repo.exportM3u(playlist.id, file);

      final content = await File(file).readAsString();
      expect(content.trim().split('\n'), ['#EXTM3U', '#PLAYLIST:Empty']);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('Smart mixes', () {
    test('upsertSmartMix replaces the previous contents', () async {
      for (final id in ['a', 'b', 'c']) {
        await addTrack(id, title: 'Song $id');
      }
      const mix = Playlist(
        id: 'mix_morning',
        name: 'Morning Mix',
        type: PlaylistType.smartMix,
        mood: MixMood.morning,
        trackIds: ['a', 'b'],
        createdAtMs: 0,
        updatedAtMs: 0,
      );

      await repo.upsertSmartMix(mix);
      expect(
        (await repo.getPlaylistTracks('mix_morning')).map((t) => t.id),
        ['a', 'b'],
      );

      await repo.upsertSmartMix(mix.copyWith(trackIds: const ['c']));
      expect(
        (await repo.getPlaylistTracks('mix_morning')).map((t) => t.id),
        ['c'],
      );
    });
  });
}
