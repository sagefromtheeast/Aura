import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/design_tokens.dart';
import '../../theme/dynamic_theme_provider.dart';
import '../../widgets/glass_card.dart';
import 'duplicate_wizard_sheet.dart';
import 'intelli_shuffle_sheet.dart';
import 'pro_upgrade_sheet.dart';
import '../onboarding/onboarding_wizard.dart';

/// Settings and Enclave Preferences view.
/// Features platform-adaptive theme switching, duplicate management wizard trigger, IntelliShuffle customization, Pro Upgrade, and privacy audits.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(dynamicThemeProvider);
    final themeController = ref.read(dynamicThemeProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Text('Settings & Preferences', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26)),
            const SizedBox(height: DesignTokens.spacing8),
            Text('Configure visual Liquid Glass effects, playback algorithms, and library management.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: DesignTokens.spacing24),

            // ── Engine & Membership ─────────────────────────────────────────────
            Text('Engine & Membership', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: DesignTokens.spacing12),
            GlassCard(
              onTap: () => IntelliShuffleSheet.show(context),
              child: Row(
                children: [
                  const Icon(Icons.psychology_rounded, color: DesignTokens.primarySeed, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('IntelliShuffle Algorithmic Weights', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                        Text('Customize tempo, rating, and artist variance factors', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.spacing12),
            GlassCard(
              onTap: () => ProUpgradeSheet.show(context),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium_rounded, color: DesignTokens.accentSparkle, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Aura Pro Enclave Upgrade', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, color: DesignTokens.accentSparkle)),
                        Text('Unlock DSD/FLAC bypass, acoustic cleaning & infinite mixes', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                ],
              ),
            ),

            const SizedBox(height: DesignTokens.spacing24),

            // ── Theme Mode Picker ──────────────────────────────────────────────
            Text('Visual Theme', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: DesignTokens.spacing12),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildThemeOption(
                    context: context,
                    label: 'OLED Dark Liquid Glass (Recommended)',
                    isSelected: themeState.mode == ThemeMode.dark,
                    onTap: () => themeController.setThemeMode(ThemeMode.dark),
                  ),
                  const SizedBox(height: 8),
                  _buildThemeOption(
                    context: context,
                    label: 'Parchment Light Mode',
                    isSelected: themeState.mode == ThemeMode.light,
                    onTap: () => themeController.setThemeMode(ThemeMode.light),
                  ),
                  const SizedBox(height: 8),
                  _buildThemeOption(
                    context: context,
                    label: 'System Adaptive',
                    isSelected: themeState.mode == ThemeMode.system,
                    onTap: () => themeController.setThemeMode(ThemeMode.system),
                  ),
                  const Divider(height: 24),
                  SwitchListTile(
                    title: const Text('Material You Dynamic Color'),
                    subtitle: const Text('Extract interface accents from album art'),
                    value: themeState.isMaterialYouEnabled,
                    activeThumbColor: DesignTokens.primarySeed,
                    onChanged: (val) => themeController.toggleMaterialYou(val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: DesignTokens.spacing24),
            Text('Library Maintenance', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: DesignTokens.spacing12),

            // ── Duplicate Maintenance Trigger ─────────────────────────────────
            GlassCard(
              onTap: () => DuplicateWizardSheet.show(context),
              child: Row(
                children: [
                  const Icon(Icons.file_copy_rounded, color: DesignTokens.primarySeed, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Manage Duplicate Recordings', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                        Text('Launch 3-tier hash & fuzzy acoustic cleaner', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                ],
              ),
            ),

            const SizedBox(height: DesignTokens.spacing12),
            GlassCard(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const OnboardingWizard()),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.restore_rounded, color: DesignTokens.accentSparkle, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Re-run Onboarding & Vibe Selector', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                        Text('Switch between Casual, Power, or Audiophile modes', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                ],
              ),
            ),

            const SizedBox(height: DesignTokens.spacing24),
            Center(
              child: Text(
                'Aura v1.0.0 (Offline Enclave Build)\nZero Network Permissions Declared',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: DesignTokens.radius16,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? DesignTokens.primarySeed : Theme.of(context).disabledColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? DesignTokens.primarySeed : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
