// lib/ui/sheets/track_actions_sheet.dart
// Aura — The per-track overflow menu.
//
// Before this, a track row's only action was "play". This is the standard
// context menu both reference players carry, surfaced from a long-press or the
// ⋯ button and reused everywhere a track appears.
//
// Every action here is wired to something real; nothing is a placeholder. The
// queue actions are added by the caller (they need a queue backend), and
// "Remove" only appears when a caller supplies an onRemove — e.g. from inside a
// playlist.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/track.dart';
import '../../shared/providers.dart';
import '../screens/library/tag_editor_sheet.dart';
import '../theme/design_tokens.dart';
import 'add_to_playlist_sheet.dart';

/// An extra action a caller can inject (e.g. "Add to queue", "Play next").
class TrackAction {
  const TrackAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
}

class TrackActionsSheet extends ConsumerWidget {
  const TrackActionsSheet({
    super.key,
    required this.track,
    this.extraActions = const [],
    this.onRemove,
  });

  final Track track;

  /// Caller-supplied actions shown above the standard set.
  final List<TrackAction> extraActions;

  /// When non-null, a "Remove from this list" action is shown.
  final VoidCallback? onRemove;

  static Future<void> show(
    BuildContext context,
    Track track, {
    List<TrackAction> extraActions = const [],
    VoidCallback? onRemove,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => TrackActionsSheet(
        track: track,
        extraActions: extraActions,
        onRemove: onRemove,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favourites = ref.watch(favouriteIdsProvider);
    final isFavourite = favourites.contains(track.id);

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            // Header
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: DesignTokens.radius8,
                  gradient: LinearGradient(colors: [
                    DesignTokens.primarySeed.withValues(alpha: 0.4),
                    DesignTokens.accentSparkle.withValues(alpha: 0.4),
                  ]),
                ),
                child: const Icon(Icons.music_note_rounded,
                    color: Colors.white),
              ),
              title: Text(track.title,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(track.artistName,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const Divider(height: 1),

            _action(
              context,
              icon: Icons.play_arrow_rounded,
              label: 'Play',
              onTap: () {
                Navigator.of(context).pop();
                ref.read(playbackOrchestratorProvider).playTrack(track);
              },
            ),

            for (final extra in extraActions)
              _action(
                context,
                icon: extra.icon,
                label: extra.label,
                destructive: extra.isDestructive,
                onTap: () {
                  Navigator.of(context).pop();
                  extra.onTap();
                },
              ),

            _action(
              context,
              icon: Icons.playlist_play_rounded,
              label: 'Play next',
              onTap: () {
                Navigator.of(context).pop();
                ref
                    .read(playbackOrchestratorProvider)
                    .playNextInQueue(track);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${track.title}" plays next')),
                );
              },
            ),

            _action(
              context,
              icon: Icons.queue_music_rounded,
              label: 'Add to queue',
              onTap: () {
                Navigator.of(context).pop();
                ref.read(playbackOrchestratorProvider).addToQueue(track);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added "${track.title}" to queue')),
                );
              },
            ),

            _action(
              context,
              icon: isFavourite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              label: isFavourite ? 'Remove from favourites' : 'Add to favourites',
              iconColor: isFavourite ? Colors.pinkAccent : null,
              onTap: () async {
                Navigator.of(context).pop();
                await ref
                    .read(favouriteIdsProvider.notifier)
                    .toggle(track.id);
              },
            ),

            _action(
              context,
              icon: Icons.playlist_add_rounded,
              label: 'Add to playlist',
              onTap: () {
                Navigator.of(context).pop();
                AddToPlaylistSheet.showForTrack(context, track);
              },
            ),

            _action(
              context,
              icon: Icons.edit_note_rounded,
              label: 'Edit tags',
              onTap: () {
                Navigator.of(context).pop();
                TagEditorSheet.show(context, [track]);
              },
            ),

            if (onRemove != null)
              _action(
                context,
                icon: Icons.remove_circle_outline_rounded,
                label: 'Remove from this list',
                destructive: true,
                onTap: () {
                  Navigator.of(context).pop();
                  onRemove!();
                },
              ),

            const SizedBox(height: DesignTokens.spacing8),
          ],
        ),
      ),
    );
  }

  Widget _action(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool destructive = false,
    Color? iconColor,
  }) {
    final color = destructive
        ? Theme.of(context).colorScheme.error
        : (iconColor ?? Theme.of(context).iconTheme.color);
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label,
          style: destructive
              ? TextStyle(color: Theme.of(context).colorScheme.error)
              : null),
      onTap: onTap,
    );
  }
}
