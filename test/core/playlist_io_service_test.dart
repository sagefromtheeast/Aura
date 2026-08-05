// test/core/playlist_io_service_test.dart
// Unit tests for M3U8 playlist export and import resolution.

import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/services/playlist_io_service.dart';
import 'package:aura/domain/entities/track.dart';

void main() {
  group('PlaylistIoService tests', () {
    final List<Track> sampleTracks = [
      const Track(
        id: '1',
        title: 'Midnight Oasis',
        artistName: 'Aetheria',
        albumTitle: 'Dreamscape',
        artistId: 'art_1',
        albumId: 'alb_1',
        durationMs: 240000, // 240 sec
        filePath: '/music/flac/midnight_oasis.flac',
        fileSizeBytes: 35000000,
        format: AudioFormat.flac,
        bitRateKbps: 1411,
        dateAddedMs: 1714000000000,
      ),
      const Track(
        id: '2',
        title: 'Solar Eclipse',
        artistName: 'Chronosphere',
        albumTitle: 'Orbit',
        artistId: 'art_2',
        albumId: 'alb_2',
        durationMs: 180000, // 180 sec
        filePath: '/music/hi_res/solar_eclipse.dsd',
        fileSizeBytes: 70000000,
        format: AudioFormat.dsd,
        bitRateKbps: 5644,
        dateAddedMs: 1714000000000,
      ),
    ];

    test('exportToM3u8 generates correct standard format', () {
      final output = PlaylistIoService.exportToM3u8(
        playlistName: 'Audiophile Gems',
        tracks: sampleTracks,
      );

      expect(output, contains('#EXTM3U'));
      expect(output, contains('#EXTPLAYLIST:Audiophile Gems'));
      expect(output, contains('#EXTINF:240,Aetheria - Midnight Oasis'));
      expect(output, contains('/music/flac/midnight_oasis.flac'));
      expect(output, contains('#EXTINF:180,Chronosphere - Solar Eclipse'));
      expect(output, contains('/music/hi_res/solar_eclipse.dsd'));
    });

    test('parseM3u8 parses valid M3U8 string into M3uEntry list', () {
      const input = '''
#EXTM3U
#EXTPLAYLIST:Morning Vibe
#EXTINF:240,Aetheria - Midnight Oasis
/music/flac/midnight_oasis.flac

#EXTINF:180,Chronosphere - Solar Eclipse
/music/hi_res/solar_eclipse.dsd

#EXTINF:-1,Unknown Stream
http://stream.audiophile.fm/live
''';

      final entries = PlaylistIoService.parseM3u8(input);
      expect(entries.length, equals(3));

      expect(entries[0].durationSeconds, equals(240));
      expect(entries[0].displayTitle, equals('Aetheria - Midnight Oasis'));
      expect(entries[0].filePath, equals('/music/flac/midnight_oasis.flac'));

      expect(entries[1].durationSeconds, equals(180));
      expect(entries[1].filePath, equals('/music/hi_res/solar_eclipse.dsd'));

      expect(entries[2].durationSeconds, equals(-1));
      expect(entries[2].displayTitle, equals('Unknown Stream'));
    });

    test('resolveTracks matches by file path correctly', () {
      const input = '''
#EXTM3U
#EXTINF:240,Aetheria - Midnight Oasis
/music/flac/midnight_oasis.flac
''';
      final entries = PlaylistIoService.parseM3u8(input);
      final resolved = PlaylistIoService.resolveTracks(entries, sampleTracks);

      expect(resolved.length, equals(1));
      expect(resolved.first.id, equals('1'));
      expect(resolved.first.title, equals('Midnight Oasis'));
    });

    test('resolveTracks fallbacks to artist and title matching when path differs', () {
      const input = '''
#EXTM3U
#EXTINF:180,Chronosphere - Solar Eclipse
/external_sd/music_backup/solar_eclipse_copy.dsd
''';
      final entries = PlaylistIoService.parseM3u8(input);
      final resolved = PlaylistIoService.resolveTracks(entries, sampleTracks);

      expect(resolved.length, equals(1));
      expect(resolved.first.id, equals('2'));
      expect(resolved.first.artistName, equals('Chronosphere'));
    });
  });
}
