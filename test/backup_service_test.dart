// test/backup_service_test.dart
// Backup/restore round-trip against in-memory SQLite + mock prefs.

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aura/data/backup/backup_service.dart';
import 'package:aura/data/database/app_database.dart';
import 'package:aura/data/repositories/local_music_repository.dart';
import 'package:aura/data/repositories/local_playlist_repository.dart';
import 'package:aura/data/repositories/settings_repository.dart';
import 'package:aura/data/settings/app_settings.dart';

void main() {
  late AppDatabase db;
  late LocalMusicRepository music;
  late LocalPlaylistRepository playlists;
  late SettingsRepository settings;
  late BackupService backup;

  Future<void> addTrack(String id,
      {String path = '', int rating = 0, int playCount = 0}) async {
    await db.trackDao.upsertTrack(TracksTableCompanion.insert(
      id: id,
      title: 'Song $id',
      artistName: 'Artist $id',
      albumTitle: 'Album $id',
      artistId: 'a_$id',
      albumId: 'al_$id',
      durationMs: 200000,
      filePath: path.isEmpty ? '/music/$id.flac' : path,
      dateAddedMs: 0,
      rating: Value(rating),
      playCount: Value(playCount),
    ));
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    music = LocalMusicRepository(database: db);
    playlists = LocalPlaylistRepository(database: db);
    settings = SettingsRepository(database: db);
    backup = BackupService(
      musicRepository: music,
      playlistRepository: playlists,
      settingsRepository: settings,
    );
  });

  tearDown(() async => db.close());

  test('archive captures favourites, stats, playlists and settings', () async {
    await addTrack('a', rating: 5, playCount: 12);
    await addTrack('b', playCount: 3);
    await addTrack('c');
    final pl = await playlists.createPlaylist(name: 'Road Trip');
    await playlists.addTracks(pl.id, ['a', 'c']);
    await settings.save(AppSettings.defaults.copyWith(glassIntensity: 0.3));

    final archive = await backup.buildArchive();

    expect(archive['version'], kBackupVersion);
    expect((archive['trackStats'] as List), hasLength(2)); // a and b only
    expect((archive['playlists'] as List), hasLength(1));
    expect((archive['playlists'] as List).first['trackPaths'],
        ['/music/a.flac', '/music/c.flac']);
    expect((archive['settings'] as Map)['glassIntensity'], 0.3);
  });

  test('restore reconnects by file path after a rescan changes ids', () async {
    // Build an archive from a "previous install".
    await addTrack('old_a', path: '/music/nights.flac', rating: 5, playCount: 9);
    final pl = await playlists.createPlaylist(name: 'Faves');
    await playlists.addTracks(pl.id, ['old_a']);
    final archive = await backup.buildArchive();

    // Simulate a rescan: same files, brand-new ids, no playlists, no stats.
    await (db.delete(db.playlistsTable)).go();
    await (db.delete(db.tracksTable)).go();
    await addTrack('new_a', path: '/music/nights.flac');
    await addTrack('new_b', path: '/music/missing-not-in-backup.flac');

    final result = await backup.restoreArchive(archive);

    expect(result.tracksReconnected, 1);
    expect(result.playlistsRestored, 1);

    // Stats re-applied to the NEW id via the stable path.
    final reconnected = await music.getTrackByPath('/music/nights.flac');
    expect(reconnected!.rating, 5);
    expect(reconnected.playCount, 9);

    // The playlist points at the new id.
    final restoredPlaylists = await playlists.getAllPlaylists();
    expect(restoredPlaylists.map((p) => p.name), contains('Faves'));
    final faves =
        restoredPlaylists.firstWhere((p) => p.name == 'Faves');
    expect(faves.trackIds, ['new_a']);
  });

  test('a path no longer in the library is counted as missing', () async {
    await addTrack('a', path: '/music/a.flac', rating: 5);
    final pl = await playlists.createPlaylist(name: 'P');
    await playlists.addTracks(pl.id, ['a']);
    final archive = await backup.buildArchive();

    await (db.delete(db.tracksTable)).go(); // library emptied

    final result = await backup.restoreArchive(archive);
    expect(result.tracksReconnected, 0);
    expect(result.tracksMissing, greaterThan(0));
  });

  test('a newer-version archive is refused', () async {
    await expectLater(
      backup.restoreArchive({'version': kBackupVersion + 1}),
      throwsA(isA<FormatException>()),
    );
  });
}
