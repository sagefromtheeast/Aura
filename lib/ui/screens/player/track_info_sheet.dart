import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';

class TrackInfoSheet extends ConsumerWidget {
  const TrackInfoSheet({super.key});

  String _formatDuration(int ms) {
    if (ms <= 0) return '0:00';
    final seconds = (ms / 1000).truncate();
    final minutes = seconds ~/ 60;
    final remainingSec = seconds % 60;
    return '$minutes:${remainingSec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playbackStateProvider);
    final track = playback.currentTrack;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (track == null) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        child: const Text('No track playing'),
      );
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

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing24),
              children: [
                // Header
                Text(
                  'Track Info',
                  style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22),
                ),
                const SizedBox(height: DesignTokens.spacing24),

                // Primary Metadata
                Text(track.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: DesignTokens.spacing4),
                Text('${track.artistName} • ${track.albumTitle}', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.7))),
                const SizedBox(height: DesignTokens.spacing16),

                // Audio Quality Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing12, vertical: DesignTokens.spacing8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: DesignTokens.radius8,
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.high_quality, color: Colors.amber, size: 20),
                      const SizedBox(width: DesignTokens.spacing8),
                      Text(
                        'Hi-Res 96kHz / 24-bit',
                        style: theme.textTheme.labelMedium?.copyWith(color: Colors.amber, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DesignTokens.spacing24),

                // Secondary Metadata Grid
                GlassCard(
                  padding: const EdgeInsets.all(DesignTokens.spacing16),
                  borderRadius: 16.0,
                  child: Column(
                    children: [
                      _buildMetaRow(context, 'Year', '2023'), // Stub year
                      const Divider(height: 16),
                      _buildMetaRow(context, 'Genre', 'Electronic / Synthpop'), // Stub genre
                      const Divider(height: 16),
                      _buildMetaRow(context, 'Duration', _formatDuration(track.durationMs)),
                      const Divider(height: 16),
                      _buildMetaRow(context, 'Play Count', '124'),
                      const Divider(height: 16),
                      _buildMetaRow(context, 'Skip Count', '3'),
                    ],
                  ),
                ),
                const SizedBox(height: DesignTokens.spacing24),

                // Technical Metadata
                Text('File Information', style: theme.textTheme.titleMedium),
                const SizedBox(height: DesignTokens.spacing12),
                GlassCard(
                  padding: const EdgeInsets.all(DesignTokens.spacing16),
                  borderRadius: 16.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Format: FLAC', style: theme.textTheme.bodyMedium?.copyWith(fontFamily: DesignTokens.fontMono)),
                      const SizedBox(height: DesignTokens.spacing8),
                      Text('Size: 45.2 MB', style: theme.textTheme.bodyMedium?.copyWith(fontFamily: DesignTokens.fontMono)),
                      const SizedBox(height: DesignTokens.spacing8),
                      Text('Location: /storage/emulated/0/Music/Tame Impala/track.flac', 
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: DesignTokens.fontMono,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DesignTokens.spacing32),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('View Album'),
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spacing16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Edit Tags'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacing32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
