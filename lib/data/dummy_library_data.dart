import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

// --- Models ---

class DummyAlbum {
  final String id;
  final String title;
  final String artistName;
  final Color coverColor;
  final int year;

  const DummyAlbum({
    required this.id,
    required this.title,
    required this.artistName,
    required this.coverColor,
    required this.year,
  });
}

class DummyArtist {
  final String id;
  final String name;
  final int trackCount;
  final int albumCount;
  final Color imageColor;

  const DummyArtist({
    required this.id,
    required this.name,
    required this.trackCount,
    required this.albumCount,
    required this.imageColor,
  });
}

class DummyPlaylist {
  final String id;
  final String title;
  final int trackCount;
  final bool isDailyMix;
  final List<Color> coverColors;

  const DummyPlaylist({
    required this.id,
    required this.title,
    required this.trackCount,
    this.isDailyMix = false,
    required this.coverColors,
  });
}

class DummyFolder {
  final String id;
  final String name;
  final String path;
  final int trackCount;

  const DummyFolder({
    required this.id,
    required this.name,
    required this.path,
    required this.trackCount,
  });
}

class DummyTrack {
  final String id;
  final String title;
  final String artistName;
  final String albumTitle;
  final Duration duration;

  const DummyTrack({
    required this.id,
    required this.title,
    required this.artistName,
    required this.albumTitle,
    required this.duration,
  });
}

// --- Data Generator ---

class DummyDataGenerator {
  static final List<Color> _colors = [
    Colors.redAccent, Colors.blueAccent, Colors.greenAccent, 
    Colors.orangeAccent, Colors.purpleAccent, Colors.tealAccent,
    Colors.pinkAccent, Colors.indigoAccent, Colors.amberAccent,
    Colors.deepOrangeAccent, Colors.cyanAccent, Colors.limeAccent,
  ];

  static Color _getColor(int index) => _colors[index % _colors.length];

  static List<DummyAlbum> generateAlbums() {
    return List.generate(24, (index) => DummyAlbum(
      id: 'album_$index',
      title: 'Album Title ${index + 1}',
      artistName: 'Artist ${(index % 10) + 1}',
      coverColor: _getColor(index),
      year: 2020 + (index % 5),
    ));
  }

  static List<DummyArtist> generateArtists() {
    final artists = List.generate(30, (index) {
      final letter = String.fromCharCode(65 + (index % 26)); // A-Z
      return DummyArtist(
        id: 'artist_$index',
        name: '$letter - Artist Name ${index + 1}',
        trackCount: (index + 1) * 3,
        albumCount: (index % 5) + 1,
        imageColor: _getColor(index * 2),
      );
    });
    // Sort alphabetically for the index list
    artists.sort((a, b) => a.name.compareTo(b.name));
    return artists;
  }

  static List<DummyPlaylist> generatePlaylists() {
    final dailyMixes = List.generate(5, (index) => DummyPlaylist(
      id: 'mix_$index',
      title: 'Daily Mix ${index + 1}',
      trackCount: 30,
      isDailyMix: true,
      coverColors: [_getColor(index), _getColor(index + 3)],
    ));
    
    final userPlaylists = List.generate(15, (index) => DummyPlaylist(
      id: 'playlist_$index',
      title: 'Vibe Playlist ${index + 1}',
      trackCount: 15 + index,
      coverColors: [
        _getColor(index), _getColor(index + 1), 
        _getColor(index + 2), _getColor(index + 3)
      ],
    ));
    
    return [...dailyMixes, ...userPlaylists];
  }

  static List<DummyFolder> generateFolders() {
    return List.generate(12, (index) => DummyFolder(
      id: 'folder_$index',
      name: index == 0 ? 'Downloads' : index == 1 ? 'Music' : 'Folder ${index + 1}',
      path: '/storage/emulated/0/${index == 0 ? 'Downloads' : 'Music/Folder $index'}',
      trackCount: (index + 1) * 10,
    ));
  }

  static List<DummyTrack> generateTracksForAlbum(String albumId) {
    return List.generate(12, (index) => DummyTrack(
      id: '${albumId}_track_$index',
      title: 'Track Title ${index + 1}',
      artistName: 'Artist Name', // We'll keep it simple for dummy data
      albumTitle: 'Album Title',
      duration: Duration(minutes: 3, seconds: 15 + (index * 7) % 60),
    ));
  }

  static List<DummyTrack> generateTopTracksForArtist(String artistId) {
    return List.generate(5, (index) => DummyTrack(
      id: '${artistId}_top_track_$index',
      title: 'Top Hit ${index + 1}',
      artistName: 'Artist Name',
      albumTitle: 'Album Title',
      duration: Duration(minutes: 2, seconds: 45 + (index * 12) % 60),
    ));
  }
}

// --- Riverpod Providers ---

final dummyAlbumsProvider = FutureProvider<List<DummyAlbum>>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 500)); // Simulate DB fetch
  return DummyDataGenerator.generateAlbums();
});

final dummyArtistsProvider = FutureProvider<List<DummyArtist>>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return DummyDataGenerator.generateArtists();
});

final dummyPlaylistsProvider = FutureProvider<List<DummyPlaylist>>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return DummyDataGenerator.generatePlaylists();
});

final dummyFoldersProvider = FutureProvider<List<DummyFolder>>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return DummyDataGenerator.generateFolders();
});

final dummyAlbumTracksProvider = FutureProvider.family<List<DummyTrack>, String>((ref, albumId) async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return DummyDataGenerator.generateTracksForAlbum(albumId);
});

final dummyArtistTopTracksProvider = FutureProvider.family<List<DummyTrack>, String>((ref, artistId) async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return DummyDataGenerator.generateTopTracksForArtist(artistId);
});
