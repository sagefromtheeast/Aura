// lib/ui/screens/player/queue_sheet.dart
// Aura — Up Next Interactive Queue Modal Sheet.
// Complies with AGENTS.md vertical overflow rules and Liquid Material guidelines.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/track.dart';
import '../../../shared/providers.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';

/// Displays the current playing track and an interactive reorderable play queue.
class QueueSheet extends ConsumerStatefulWidget {
  const QueueSheet({super.key});

  @override
  ConsumerState<QueueSheet> createState() => _QueueSheetState();
}

class _QueueSheetState extends ConsumerState<QueueSheet> {
  final List<Track> _queueTracks = [];
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final playbackState = ref.watch(playbackStateProvider);
    final allTracksAsync = ref.watch(allTracksProvider);

    if (!_initialized) {
      allTracksAsync.whenData((tracks) {
        if (tracks.isNotEmpty) {
          _queueTracks.clear();
          for (final t in tracks) {
            if (t.id != playbackState.currentTrack?.id) {
              _queueTracks.add(t);
            }
          }
          _initialized = true;
        }
      });
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: DesignTokens.spacing12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: DesignTokens.radius8,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Up Next & Queue',
                    style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _queueTracks.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Upcoming queue cleared')),
                    );
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spacing12),

          // Currently Playing Badge
          if (playbackState.currentTrack != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing24),
              child: GlassCard(
                borderRadius: 12.0,
                padding: const EdgeInsets.all(DesignTokens.spacing12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: DesignTokens.primarySeed.withValues(alpha: 0.2),
                        borderRadius: DesignTokens.radius8,
                      ),
                      child: const Icon(
                        Icons.graphic_eq,
                        color: DesignTokens.primarySeed,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NOW PLAYING',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: DesignTokens.primarySeed,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            playbackState.currentTrack!.title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.spacing12),
            Divider(color: colorScheme.onSurface.withValues(alpha: 0.1), height: 1),
          ],

          // Upcoming List
          Expanded(
            child: _queueTracks.isEmpty
                ? Center(
                    child: Text(
                      'No upcoming tracks in queue',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  )
                : ReorderableListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spacing24,
                      vertical: DesignTokens.spacing12,
                    ),
                    itemCount: _queueTracks.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        final item = _queueTracks.removeAt(oldIndex);
                        _queueTracks.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final track = _queueTracks[index];
                      return Dismissible(
                        key: ValueKey(track.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          setState(() {
                            _queueTracks.removeAt(index);
                          });
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: DesignTokens.spacing24),
                          color: colorScheme.error.withValues(alpha: 0.2),
                          child: Icon(
                            Icons.remove_circle_outline,
                            color: colorScheme.error,
                          ),
                        ),
                        child: Semantics(
                          label: 'Queue item: ${track.title} by ${track.artistName}',
                          button: true,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.drag_handle,
                              color: colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                            title: Text(
                              track.title,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              track.artistName,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.close,
                                size: 18,
                                color: colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                              onPressed: () {
                                setState(() {
                                  _queueTracks.removeAt(index);
                                });
                              },
                            ),
                            onTap: () {
                              ref.read(playbackOrchestratorProvider).playTrack(track);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: DesignTokens.spacing24),
        ],
      ),
    );
  }
}
