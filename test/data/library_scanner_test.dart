// test/data/library_scanner_test.dart
// Aura — Scanner tests that need no plugins:
//   • FolderScanner  — pure dart:io traversal rules.
//   • LibraryScanner.reconcile — DB mapping against an in-memory database.
//
// Collection via MediaStore/MPMediaQuery and tag extraction are plugin-backed
// and covered by integration tests instead.
//
// Run: flutter test test/data/library_scanner_test.dart
// (After a schema change run `dart run build_runner build
//  --delete-conflicting-outputs` first.)

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura/data/database/app_database.dart';
import 'package:aura/data/scanner/folder_scanner.dart';
import 'package:aura/data/scanner/library_scanner.dart';
import 'package:aura/data/scanner/raw_track.dart';

void main() {
  group('FolderScanner', () {
    late Directory root;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('aura_scan_test');
      await File('${root.path}/song.mp3').writeAsString('x');
      await File('${root.path}/notes.txt').writeAsString('x');
      await File('${root.path}/.hidden.flac').writeAsString('x');
      final sub = await Directory('${root.path}/sub').create();
      await File('${sub.path}/deep.flac').writeAsString('x');
      final hiddenDir = await Directory('${root.path}/.hidden_dir').create();
      await File('${hiddenDir.path}/nope.mp3').writeAsString('x');
    });

    tearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });

    test('finds supported audio, skipping hidden files, dirs and non-audio',
        () async {
      final found = await const FolderScanner().scan([root.path]);
      final names = found.map((t) => t.filePath.split('/').last).toSet();

      expect(names, containsAll(<String>{'song.mp3', 'deep.flac'}));
      expect(names, isNot(contains('notes.txt')));
      expect(names, isNot(contains('.hidden.flac')));
      expect(names, isNot(contains('nope.mp3')));
      expect(found, hasLength(2));
    });

    test('respects the recursion depth limit', () async {
      // maxDepth 0 => only files directly in the root.
      final found = await const FolderScanner(maxDepth: 0).scan([root.path]);
      expect(found.map((t) => t.filePath.split('/').last), ['song.mp3']);
    });

    test('missing roots are ignored, not fatal', () async {
      final found =
          await const FolderScanner().scan(['${root.path}/does_not_exist']);
      expect(found, isEmpty);
    });
  });

  group('LibraryScanner.reconcile', () {
    late AppDatabase db;
    late LibraryScanner scanner;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      scanner = LibraryScanner(database: db);
    });

    tearDown(() async => db.close());

    RawTrack raw(String path,
            {String? title, String? artist, String? album, int duration = 200000}) =>
        RawTrack(
          filePath: path,
          title: title,
          artist: artist,
          album: album,
          durationMs: duration,
        );

    test('creates tracks plus their artist and album rows', () async {
      final result = await scanner.reconcile([
        raw('/m/a.mp3', title: 'Alpha', artist: 'Tame Impala', album: 'Currents'),
        raw('/m/b.mp3', title: 'Beta', artist: 'Tame Impala', album: 'Currents'),
        raw('/m/c.mp3', title: 'Gamma', artist: 'Radiohead', album: 'In Rainbows'),
      ]);

      expect(result.tracksFound, 3);
      expect(result.tracksAdded, 3);

      expect(await db.trackDao.getAllTracks(), hasLength(3));
      // Two distinct artists, two distinct albums.
      expect(await db.trackDao.getAllArtists(), hasLength(2));
      expect(await db.trackDao.getAllAlbums(), hasLength(2));
    });

    test('re-scanning the same paths updates rather than duplicates', () async {
      final tracks = [
        raw('/m/a.mp3', title: 'Alpha', artist: 'A', album: 'Rec'),
      ];
      await scanner.reconcile(tracks);
      final second = await scanner.reconcile(tracks);

      expect(second.tracksAdded, 0, reason: 'path already known');
      expect(await db.trackDao.getAllTracks(), hasLength(1));
    });

    test('counts duplicate recordings across different paths', () async {
      final result = await scanner.reconcile([
        raw('/m/a.mp3', title: 'Alpha', artist: 'A', album: 'Rec'),
        // Same song, different file/encode — duration within the 2s bucket.
        raw('/m/a_copy.flac',
            title: 'alpha!', artist: 'A', album: 'Rec', duration: 200500),
      ]);

      expect(result.tracksFound, 2);
      expect(result.duplicatesFound, 1);
    });

    test('falls back to the filename when no title tag is present', () async {
      await scanner.reconcile([raw('/m/Some Song.mp3')]);

      final rows = await db.trackDao.getAllTracks();
      expect(rows.single.title, 'Some Song');
      expect(rows.single.artistName, 'Unknown Artist');
      expect(rows.single.albumTitle, 'Unknown Album');
    });
  });
}
