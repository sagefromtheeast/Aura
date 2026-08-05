import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../domain/entities/playlist.dart';
import '../../../domain/entities/track.dart';
import '../../../shared/providers.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';

final _playlistTracksResolverProvider = FutureProvider.family<List<Track>, Playlist>((ref, playlist) async {
  final musicRepo = ref.watch(musicRepositoryProvider);
  final tracks = <Track>[];
  for (final id in playlist.trackIds) {
    final track = await musicRepo.getTrackById(id);
    if (track != null) {
      tracks.add(track);
    }
  }
  // Fallback: If trackIds is empty in mock/demo, fetch some sample tracks
  if (tracks.isEmpty) {
    final all = await musicRepo.getAllTracks();
    return all.take(10).toList();
  }
  return tracks;
});

/// Playlist Deep View providing track ordering, playback orchestration, and
/// offline M3U/M3U8 file exporting capabilities.
class PlaylistDetailScreen extends ConsumerStatefulWidget {
  final Playlist playlist;
  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  ConsumerState<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends ConsumerState<PlaylistDetailScreen> {
  late List<String> _trackIds;
  bool _isReordering = false;

  @override
  void initState() {
    super.initState();
    _trackIds = List.from(widget.playlist.trackIds);
  }

  Future<void> _exportM3u() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final file = File('${docsDir.path}/${widget.playlist.name.replaceAll(" ", "_")}.m3u8');
      
      final buffer = StringBuffer();
      buffer.writeln('#EXTM3U');
      buffer.writeln('# PLAYLIST: ${widget.playlist.name}');
      buffer.writeln('# EXPORTED BY AURA MUSIC PLAYER');
      for (final trackId in _trackIds) {
        buffer.writeln('#EXTINF:-1,$trackId');
        buffer.writeln(trackId);
      }

      await file.writeAsString(buffer.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported playlist to M3U8: ${file.path}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export M3U8: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tracksAsync = ref.watch(_playlistTracksResolverProvider(widget.playlist));

    return Semantics(
      label: 'Playlist Detail Screen for ${widget.playlist.name}',
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // ── Top Bar ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(DesignTokens.spacing16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Back to library',
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(_isReordering ? Icons.check_circle_rounded : Icons.sort_rounded),
                      color: _isReordering ? DesignTokens.primarySeed : Theme.of(context).iconTheme.color,
                      onPressed: () {
                        setState(() => _isReordering = !_isReordering);
                      },
                      tooltip: _isReordering ? 'Finish Reorder' : 'Reorder Tracks',
                    ),
                    IconButton(
                      icon: const Icon(Icons.file_download_rounded, color: DesignTokens.primarySeed),
                      onPressed: _exportM3u,
                      tooltip: 'Export to M3U8',
                    ),
                  ],
                ),
              ),

              // ── Playlist Header ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: DesignTokens.radius16,
                            color: DesignTokens.primarySeed.withValues(alpha: 0.2),
                          ),
                          child: const Icon(Icons.queue_music_rounded, size: 44, color: DesignTokens.primarySeed),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.playlist.name,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.playlist.description.isNotEmpty ? widget.playlist.description : 'Offline User Collection',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).disabledColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.spacing16),
                    Row(
                      children: [
                        _buildTypeBadge(context),
                        const SizedBox(width: 12),
                        Text(
                          '${widget.playlist.trackIds.length} Tracks · Local Playable',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontFamily: DesignTokens.fontMono),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.spacing16),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.primarySeed,
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: DesignTokens.radius24),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 26),
                      label: const Text('START PLAYLIST', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      onPressed: () {
                        tracksAsync.whenData((tracks) {
                          if (tracks.isNotEmpty) {
                            ref.read(playbackOrchestratorProvider).playTrack(tracks.first);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.spacing8),

              // ── Track List / Reorderable View ───────────────────────────────
              Expanded(
                child: tracksAsync.when(
                  data: (tracks) {
                    if (tracks.isEmpty) {
                      return Center(
                        child: Text(
                          'This playlist has no tracks yet.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).disabledColor),
                        ),
                      );
                    }

                    if (_isReordering) {
                      return ReorderableListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        itemCount: tracks.length,
                        onReorder: (oldIndex, newIndex) {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final list = List<String>.from(widget.playlist.trackIds);
                          if (oldIndex < list.length && newIndex <= list.length) {
                            final item = list.removeAt(oldIndex);
                            list.insert(newIndex, item);
                            ref.read(playlistRepositoryProvider).reorderTracks(widget.playlist.id, list);
                          }
                        },
                        itemBuilder: (context, index) {
                          final track = tracks[index];
                          return GlassCard(
                            key: ValueKey(track.id),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.drag_handle_rounded, color: DesignTokens.primarySeed),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(track.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                      itemCount: tracks.length,
                      itemBuilder: (context, index) {
                        final track = tracks[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GlassCard(
                            onTap: () => ref.read(playbackOrchestratorProvider).playTrack(track),
                            child: Row(
                              children: [
                                const Icon(Icons.music_note_rounded, color: DesignTokens.primarySeed),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(track.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                                      Text(track.artistName, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).disabledColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.play_circle_fill_rounded, color: DesignTokens.primarySeed),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error resolving playlist: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(BuildContext context) {
    String label = 'USER PLAYLIST';
    if (widget.playlist.type == PlaylistType.smartMix) {
      label = 'INTELLI-MIX';
    } else if (widget.playlist.type == PlaylistType.autoGenerated) {
      label = 'AUTO-SYSTEM';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: DesignTokens.primarySeed.withValues(alpha: 0.15),
        borderRadius: DesignTokens.radius12,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: DesignTokens.primarySeed,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}
