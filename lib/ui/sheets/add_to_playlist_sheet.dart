// lib/ui/sheets/add_to_playlist_sheet.dart
// Aura — Destination picker for "Add to playlist".
//
// The playlist repository has always supported adding tracks; this is the UI
// that was missing. Calls PlaylistRepository.addTrack/addTracks, honours the
// bool it returns to tell the user "Already in playlist" rather than silently
// no-op, and offers an inline "New playlist" path.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/playlist.dart';
import '../../domain/entities/track.dart';
import '../../shared/providers.dart';
import '../theme/design_tokens.dart';

class AddToPlaylistSheet extends ConsumerWidget {
  const AddToPlaylistSheet({super.key, required this.trackIds, this.label});

  /// The tracks to add — one from a track menu, many from a batch action.
  final List<String> trackIds;

  /// Optional description shown in the header ("Nights", "12 tracks").
  final String? label;

  /// Opens the sheet for a single track.
  static Future<void> showForTrack(BuildContext context, Track track) {
    return _show(context, [track.id], track.title);
  }

  /// Opens the sheet for many tracks (e.g. a whole album).
  static Future<void> showForTracks(
      BuildContext context, List<Track> tracks) {
    return _show(context, tracks.map((t) => t.id).toList(),
        '${tracks.length} tracks');
  }

  static Future<void> _show(
      BuildContext context, List<String> ids, String? label) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddToPlaylistSheet(trackIds: ids, label: label),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(allPlaylistsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: DesignTokens.spacing12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: DesignTokens.radiusPill,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(DesignTokens.spacing16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Add to playlist',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          if (label != null)
                            Text(label!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: DesignTokens.primarySeed,
                  child: Icon(Icons.add_rounded, color: Colors.black),
                ),
                title: const Text('New playlist'),
                onTap: () => _createAndAdd(context, ref),
              ),
              const Divider(height: 1),
              Expanded(
                child: playlistsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (playlists) {
                    // Smart mixes are generated; adding to them by hand would be
                    // overwritten on the next regeneration, so they are hidden.
                    final editable = playlists
                        .where((p) => p.type == PlaylistType.userCreated)
                        .toList();
                    if (editable.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(DesignTokens.spacing32),
                          child: Text(
                            'No playlists yet. Create one above.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: editable.length,
                      itemBuilder: (context, i) {
                        final playlist = editable[i];
                        return ListTile(
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: DesignTokens.radius8,
                              gradient: LinearGradient(
                                colors: [
                                  DesignTokens.primarySeed
                                      .withValues(alpha: 0.4),
                                  DesignTokens.accentSparkle
                                      .withValues(alpha: 0.4),
                                ],
                              ),
                            ),
                            child: const Icon(Icons.queue_music_rounded,
                                color: Colors.white),
                          ),
                          title: Text(playlist.name,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('${playlist.trackIds.length} tracks'),
                          onTap: () => _addTo(context, ref, playlist),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addTo(
      BuildContext context, WidgetRef ref, Playlist playlist) async {
    final repo = ref.read(playlistRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final String message;
    if (trackIds.length == 1) {
      final added = await repo.addTrack(playlist.id, trackIds.first);
      message = added
          ? 'Added to "${playlist.name}"'
          : 'Already in "${playlist.name}"';
    } else {
      final added = await repo.addTracks(playlist.id, trackIds);
      final skipped = trackIds.length - added;
      message = skipped == 0
          ? 'Added $added tracks to "${playlist.name}"'
          : 'Added $added · $skipped already there';
    }

    ref.invalidate(allPlaylistsProvider);
    navigator.pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _createAndAdd(BuildContext context, WidgetRef ref) async {
    final name = await _promptForName(context);
    if (name == null || name.trim().isEmpty) return;
    if (!context.mounted) return;

    final repo = ref.read(playlistRepositoryProvider);
    final playlist = await repo.createPlaylist(name: name.trim());
    await repo.addTracks(playlist.id, trackIds);

    ref.invalidate(allPlaylistsProvider);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text('Created "${name.trim()}" with '
              '${trackIds.length} ${trackIds.length == 1 ? 'track' : 'tracks'}')));
  }

  Future<String?> _promptForName(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Playlist name'),
          onSubmitted: (v) => Navigator.of(context).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
