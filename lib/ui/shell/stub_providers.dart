import 'package:flutter_riverpod/flutter_riverpod.dart';

// Dummy classes for playback state
class PlaybackState {
  final bool isPlaying;
  final DummyTrack? currentTrack;
  final double progress; // 0.0 to 1.0

  const PlaybackState({
    required this.isPlaying,
    this.currentTrack,
    this.progress = 0.0,
  });
}

class DummyTrack {
  final String id;
  final String title;
  final String artist;
  final String? albumArtUrl;

  const DummyTrack({
    required this.id,
    required this.title,
    required this.artist,
    this.albumArtUrl,
  });
}

final playbackStateProvider = Provider<PlaybackState>((ref) {
  // Stub with dummy data
  return const PlaybackState(
    isPlaying: true,
    currentTrack: DummyTrack(
      id: 'dummy_1',
      title: 'Aurora',
      artist: 'Hans Zimmer',
      albumArtUrl: null,
    ),
    progress: 0.35,
  );
});

final queueStateProvider = Provider<List<DummyTrack>>((ref) {
  // Returns empty queue as per requirements
  return [];
});
