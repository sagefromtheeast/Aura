// lib/ui/screens/player/lyrics_sheet.dart
// Aura — Synced Embedded Lyrics Viewer Modal Sheet.
// Complies with AGENTS.md vertical overflow rules and Liquid Material guidelines.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers.dart';
import '../../theme/design_tokens.dart';

/// Modal sheet displaying synchronized or plain text embedded audio lyrics.
class LyricsSheet extends ConsumerStatefulWidget {
  const LyricsSheet({super.key});

  @override
  ConsumerState<LyricsSheet> createState() => _LyricsSheetState();
}

class _LyricsSheetState extends ConsumerState<LyricsSheet> {
  int _currentLineIndex = 0;
  Timer? _syncTimer;

  final List<String> _simulatedLyrics = [
    'Refining spatial resonance across the spectrum',
    'Liquid quartz waves falling into deep calm',
    'On-device acoustic processing silently aligning',
    'Pure offline fidelity, zero cloud telemetry',
    'Every transient captured in crystal clarity',
    'Aura shines vibrant in fluid glass motion',
    '(Instrumental Solo)',
    'Fades gently into endless ambient memory...',
  ];

  @override
  void initState() {
    super.initState();
    _syncTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        setState(() {
          _currentLineIndex = (_currentLineIndex + 1) % _simulatedLyrics.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final playbackState = ref.watch(playbackStateProvider);
    final currentTrack = playbackState.currentTrack;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Synced Lyrics',
                        style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentTrack != null
                            ? '${currentTrack.title} • ${currentTrack.artistName}'
                            : 'No active track selection',
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacing12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.primarySeed.withValues(alpha: 0.2),
                    borderRadius: DesignTokens.radiusPill,
                  ),
                  child: Text(
                    'LRC SYNC',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: DesignTokens.primarySeed,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spacing16),
          Divider(color: colorScheme.onSurface.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: DesignTokens.spacing16),

          // Lyrics Body (Flexible to prevent bottom RenderFlex overflow per AGENTS.md)
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacing24,
                vertical: DesignTokens.spacing12,
              ),
              itemCount: _simulatedLyrics.length,
              itemBuilder: (context, index) {
                final isCurrent = index == _currentLineIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacing12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentLineIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(
                        vertical: DesignTokens.spacing12,
                        horizontal: DesignTokens.spacing16,
                      ),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? DesignTokens.primarySeed.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: DesignTokens.radius12,
                      ),
                      child: Text(
                        _simulatedLyrics[index],
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isCurrent
                              ? DesignTokens.primarySeed
                              : colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: DesignTokens.spacing24),
        ],
      ),
      ),
    );
  }
}
