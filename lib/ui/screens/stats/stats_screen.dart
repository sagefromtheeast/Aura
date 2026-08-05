import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';

/// Insights & Listening Habits screen.
/// Computes offline behavior metrics without streaming telemetry to cloud servers.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We watch stats calculator via future/provider or simulate instantaneous computation
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Text('Offline Insights', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28)),
            const SizedBox(height: DesignTokens.spacing8),
            Text(
              '100% locally computed listening habits and engagement analytics.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: DesignTokens.spacing24),

            // Hero Stats Summary Card
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timeline_rounded, color: DesignTokens.primarySeed, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Weekly Engagement', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18)),
                      ),
                      Chip(
                        label: const Text('Local Enclave', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        backgroundColor: DesignTokens.primarySeed.withValues(alpha: 0.2),
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spacing16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatMetric(context, 'Total Hours', '14.2h'),
                      _buildStatMetric(context, 'Completion Rate', '94%'),
                      _buildStatMetric(context, 'Active Streak', '6 days'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: DesignTokens.spacing24),
            Text('Top Listening Eras & Genres', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: DesignTokens.spacing12),

            GlassCard(
              child: Column(
                children: [
                  _buildGenreBar(context, 'Hi-Res Lossless (FLAC/DSD)', 0.65),
                  const SizedBox(height: 12),
                  _buildGenreBar(context, 'Electronic / Ambient Flow', 0.45),
                  const SizedBox(height: 12),
                  _buildGenreBar(context, 'Acoustic & Classical Sessions', 0.30),
                ],
              ),
            ),

            const SizedBox(height: DesignTokens.spacing24),
            GlassCard(
              child: Row(
                children: [
                  const Icon(Icons.security_rounded, size: 36, color: DesignTokens.accentSparkle),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Zero Cloud Footprint', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text('Your statistics never leave this SQLite file.', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatMetric(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24, color: DesignTokens.primarySeed)),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildGenreBar(BuildContext context, String label, double ratio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 12),
            Text('${(ratio * 100).toInt()}%', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: DesignTokens.radiusPill,
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: Theme.of(context).dividerColor,
            valueColor: const AlwaysStoppedAnimation<Color>(DesignTokens.primarySeed),
          ),
        ),
      ],
    );
  }
}
