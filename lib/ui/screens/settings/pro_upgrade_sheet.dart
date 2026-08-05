import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';

/// Pro Tier Upgrade Modal showcasing audiophile DSP capabilities, one-time
/// sovereign licensing, and feature comparison against standard playback.
class ProUpgradeSheet extends StatelessWidget {
  const ProUpgradeSheet({super.key});

  /// Open as an overflow-safe modal bottom sheet.
  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const ProUpgradeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    // Strict adherence to Modal Bottom Sheet Vertical Overflow Prevention rule
    return Container(
      constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.88),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: mediaQuery.viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DesignTokens.primarySeed.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.diamond_rounded, size: 28, color: DesignTokens.primarySeed),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aura Pro Enclave',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Audiophile-Grade 64-Bit DSP Engine',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).disabledColor),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing16),

          Flexible(
            child: ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DesignTokens.primarySeed.withValues(alpha: 0.12),
                    borderRadius: DesignTokens.radius16,
                    border: Border.all(color: DesignTokens.primarySeed.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.security_rounded, color: DesignTokens.primarySeed),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sovereign One-Time Purchase. No Cloud Subscriptions. Your data never leaves this device.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DesignTokens.spacing20),

                Text('PRO AUDIOPHILE FEATURES', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: DesignTokens.primarySeed, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 12),

                _buildFeatureItem(context, Icons.graphic_eq_rounded, '64-Bit Floating-Point FFI Engine', 'Bit-perfect audio resampling without precision clipping or digital jitter.'),
                const SizedBox(height: 12),
                _buildFeatureItem(context, Icons.tune_rounded, '10-Band Parametric Equalizer', 'Full shelf filtering and precise Q-factor acoustic adjustments.'),
                const SizedBox(height: 12),
                _buildFeatureItem(context, Icons.compare_arrows_rounded, 'Smart Acoustic Crossfade & LUFS', 'Zero-silence onset detection with EBU R128 volume normalisation.'),
                const SizedBox(height: 12),
                _buildFeatureItem(context, Icons.file_copy_rounded, 'Bit-Exact Duplicate Cleanup', 'SHA-256 hash detection across multi-format lossless imports.'),
                const SizedBox(height: 24),
              ],
            ),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primarySeed,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: DesignTokens.radius24),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Welcome to Aura Pro! Sovereign 64-bit engine activated.'),
                  duration: Duration(seconds: 4),
                ),
              );
            },
            child: const Text(
              'UNLOCK LIFETIME ENCLAVE — \$19.99',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Restore Existing Sovereign Purchase',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).disabledColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String subtitle) {
    return GlassCard(
      child: Row(
        children: [
          Icon(icon, size: 28, color: DesignTokens.primarySeed),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).disabledColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
