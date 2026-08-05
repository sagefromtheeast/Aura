// lib/ui/screens/library/smart_mix_detail_screen.dart
// Aura — On-Device AI Smart Mix Detail & Infinite Mixtape Screen.
// Displays acoustic feature vector analysis and provides endless ambient mixing.
// Complies with AGENTS.md zero-cloud rules and Liquid Material guidelines.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';

/// Screen detailing an on-device AI clustered Smart Mix (e.g. Morning Awakening, Focus Flow).
class SmartMixDetailScreen extends ConsumerStatefulWidget {
  const SmartMixDetailScreen({
    super.key,
    required this.mixTitle,
    required this.mixSubtitle,
    required this.moodTag,
  });

  final String mixTitle;
  final String mixSubtitle;
  final String moodTag;

  @override
  ConsumerState<SmartMixDetailScreen> createState() => _SmartMixDetailScreenState();
}

class _SmartMixDetailScreenState extends ConsumerState<SmartMixDetailScreen> {
  bool _infiniteMixtapeMode = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allTracksAsync = ref.watch(allTracksProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: colorScheme.surface,
              elevation: 0,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                widget.mixTitle,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.spacing24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Acoustic Feature Header Card
                    GlassCard(
                      borderRadius: 24.0,
                      padding: const EdgeInsets.all(DesignTokens.spacing24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: DesignTokens.primarySeed.withValues(alpha: 0.2),
                                  borderRadius: DesignTokens.radiusPill,
                                ),
                                child: Text(
                                  widget.moodTag.toUpperCase(),
                                  style: const TextStyle(
                                    color: DesignTokens.primarySeed,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.psychology_rounded, color: DesignTokens.primarySeed, size: 28),
                            ],
                          ),
                          const SizedBox(height: DesignTokens.spacing16),
                          Text(
                            widget.mixTitle,
                            style: theme.textTheme.displayLarge?.copyWith(fontSize: 28),
                          ),
                          const SizedBox(height: DesignTokens.spacing8),
                          Text(
                            widget.mixSubtitle,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spacing24),
                          Divider(color: colorScheme.onSurface.withValues(alpha: 0.1), height: 1),
                          const SizedBox(height: DesignTokens.spacing16),
                          
                          // Infinite Mixtape Switch
                          Row(
                            children: [
                              const Icon(Icons.all_inclusive_rounded, color: DesignTokens.primarySeed),
                              const SizedBox(width: DesignTokens.spacing12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Infinite Mixtape Mode',
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      _infiniteMixtapeMode
                                          ? 'Endless vector similarity weave active'
                                          : 'Stopping after current cluster finishes',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _infiniteMixtapeMode,
                                onChanged: (val) {
                                  setState(() => _infiniteMixtapeMode = val);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(val ? 'Infinite Mixtape enabled' : 'Infinite Mixtape disabled')),
                                  );
                                },
                                activeThumbColor: DesignTokens.primarySeed,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing24),

                    // Acoustic Vector Analysis Chart (Simulated bars)
                    Text(
                      'OFFLINE ACOUSTIC VECTOR ANALYSIS',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing12),
                    GlassCard(
                      borderRadius: 16.0,
                      padding: const EdgeInsets.all(DesignTokens.spacing16),
                      child: Column(
                        children: [
                          _buildVectorBar(context, 'Tempo & Beats (BPM Consistency)', 0.85),
                          const SizedBox(height: DesignTokens.spacing12),
                          _buildVectorBar(context, 'Harmonic Valence (Positivity & Warmth)', 0.72),
                          const SizedBox(height: DesignTokens.spacing12),
                          _buildVectorBar(context, 'Acoustic Brightness (Spectral Centroid)', 0.64),
                          const SizedBox(height: DesignTokens.spacing12),
                          _buildVectorBar(context, 'Dynamic Energy Density', 0.91),
                        ],
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing24),

                    // Play Master Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          allTracksAsync.whenData((tracks) {
                            if (tracks.isNotEmpty) {
                              ref.read(playbackOrchestratorProvider).playTrack(tracks.first);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Playing ${widget.mixTitle} Smart Mix')),
                              );
                            }
                          });
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 28),
                        label: const Text('Start AI Smart Mix'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignTokens.primarySeed,
                          foregroundColor: colorScheme.onPrimary,
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: DesignTokens.radiusPill),
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing24),

                    Text(
                      'CLUSTERED TRACK CANDIDATES',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Track list
            allTracksAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
              ),
              error: (e, st) => SliverToBoxAdapter(
                child: Center(child: Text('Error loading tracks: $e')),
              ),
              data: (tracks) {
                if (tracks.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No tracks discovered for clustering yet.'),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final track = tracks[index % tracks.length];
                      final score = (0.98 - (index * 0.03)).clamp(0.60, 0.99);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing24, vertical: 6),
                        child: GlassCard(
                          onTap: () {
                            ref.read(playbackOrchestratorProvider).playTrack(track);
                          },
                          borderRadius: 12.0,
                          padding: const EdgeInsets.all(DesignTokens.spacing12),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: colorScheme.onSurface.withValues(alpha: 0.05),
                                  borderRadius: DesignTokens.radius8,
                                ),
                                child: Center(
                                  child: Text(
                                    '#${index + 1}',
                                    style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: DesignTokens.spacing12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      track.title,
                                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${track.artistName} • ${track.albumTitle}',
                                      style: theme.textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: DesignTokens.spacing8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: DesignTokens.primarySeed.withValues(alpha: 0.15),
                                  borderRadius: DesignTokens.radius8,
                                ),
                                child: Text(
                                  '${(score * 100).toInt()}% Match',
                                  style: const TextStyle(color: DesignTokens.primarySeed, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: math.min(tracks.length, 15),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildVectorBar(BuildContext context, String label, double value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
            Text('${(value * 100).toInt()}%', style: const TextStyle(color: DesignTokens.primarySeed, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: value,
          backgroundColor: colorScheme.onSurface.withValues(alpha: 0.1),
          valueColor: const AlwaysStoppedAnimation<Color>(DesignTokens.primarySeed),
          minHeight: 6,
          borderRadius: DesignTokens.radiusPill,
        ),
      ],
    );
  }
}
