// lib/ui/screens/library/track_list_screen.dart
// Aura — A reusable "list of tracks" screen.
//
// Backs every derived system playlist (Recently Played, Most Played, Recently
// Added, Not Played) and genre detail: they differ only in title and which
// provider supplies the tracks.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/track.dart';
import '../../../shared/providers.dart';
import '../../sheets/add_to_playlist_sheet.dart';
import '../../sheets/track_actions_sheet.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';

class TrackListScreen extends ConsumerWidget {
  const TrackListScreen({
    super.key,
    required this.title,
    required this.provider,
    this.emptyMessage = 'Nothing here yet.',
    this.leadingIcon = Icons.music_note_rounded,
  });

  final String title;
  final ProviderListenable<AsyncValue<List<Track>>> provider;
  final String emptyMessage;
  final IconData leadingIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        actions: [
          tracksAsync.maybeWhen(
            data: (tracks) => tracks.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.playlist_add_rounded),
                    tooltip: 'Add all to playlist',
                    onPressed: () =>
                        AddToPlaylistSheet.showForTracks(context, tracks),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: tracksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tracks) {
          if (tracks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.spacing32),
                child: Text(emptyMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge),
              ),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(DesignTokens.spacing16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => ref
                        .read(playbackOrchestratorProvider)
                        .playTrack(tracks.first),
                    style: FilledButton.styleFrom(
                      backgroundColor: DesignTokens.primarySeed,
                      foregroundColor: Colors.black,
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text('Play all (${tracks.length})'),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  itemCount: tracks.length,
                  itemBuilder: (context, i) => _TrackRow(
                    track: tracks[i],
                    leadingIcon: leadingIcon,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TrackRow extends ConsumerWidget {
  const _TrackRow({required this.track, required this.leadingIcon});

  final Track track;
  final IconData leadingIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacing12),
      child: GlassCard(
        onTap: () => ref.read(playbackOrchestratorProvider).playTrack(track),
        onLongPress: () => TrackActionsSheet.show(context, track),
        child: Row(
          children: [
            Icon(leadingIcon, color: DesignTokens.primarySeed),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(track.artistName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert_rounded, size: 22),
              onPressed: () => TrackActionsSheet.show(context, track),
            ),
          ],
        ),
      ),
    );
  }
}
