// lib/ui/screens/settings/settings_main_screen.dart
// Aura — Settings home. Grouped glass-card list linking every settings surface.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/design_tokens.dart';
import '../../../services/sleep_timer_service.dart';
import '../player/sleep_timer_sheet.dart';
import '../../widgets/aura_slider.dart';
import '../../widgets/glass_card.dart';
import 'duplicate_management_screen.dart';
import 'equalizer_screen.dart';
import 'notification_settings_screen.dart';
import 'settings_providers.dart';
import 'shuffle_settings_screen.dart';
import 'theme_picker_screen.dart';
import '../widgets/widget_gallery_screen.dart';

class SettingsMainScreen extends ConsumerWidget {
  const SettingsMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Text(
              'Settings',
              style: DesignTokens.displayLarge.copyWith(
                fontSize: 28,
                color: _primary(context),
              ),
            ),
            const SizedBox(height: DesignTokens.spacing24),

            // ── Audio ────────────────────────────────────────────────────────
            _SectionLabel('Audio'),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.graphic_eq_rounded,
                    title: 'Equalizer',
                    onTap: () => _push(context, const EqualizerScreen()),
                  ),
                  const _RowDivider(),
                  _SettingsRow(
                    icon: Icons.speaker_rounded,
                    title: 'Output Device',
                    trailingText: settings.outputDevice,
                    onTap: () => _showOutputDeviceSheet(context, ref),
                  ),
                  const _RowDivider(),
                  _SettingsRow(
                    icon: Icons.equalizer_rounded,
                    title: 'Normalization',
                    subtitle: 'ReplayGain volume levelling',
                    trailing: Switch(
                      value: settings.replayGainEnabled,
                      activeThumbColor: DesignTokens.primarySeed,
                      onChanged: controller.setNormalization,
                    ),
                  ),
                  const _RowDivider(),
                  _CrossfadeRow(
                    // The slider is in seconds; storage is in milliseconds.
                    seconds: settings.crossfadeMs / 1000,
                    onChanged: controller.setCrossfade,
                  ),
                  const _RowDivider(),
                  Consumer(builder: (context, ref, _) {
                    final active = ref.watch(sleepTimerProvider).isActive;
                    return _SettingsRow(
                      icon: Icons.bedtime_rounded,
                      title: 'Sleep Timer',
                      trailingText: active ? 'On' : 'Off',
                      onTap: () => SleepTimerSheet.show(context),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.spacing24),

            // ── Personalization ──────────────────────────────────────────────
            _SectionLabel('Personalization'),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.shuffle_rounded,
                    title: 'Shuffle Preferences',
                    onTap: () =>
                        _push(context, const ShuffleSettingsScreen()),
                  ),
                  const _RowDivider(),
                  _DailyMixRow(
                    balance: settings.dailyMixBalance,
                    onChanged: controller.setDailyMixBalance,
                  ),
                  const _RowDivider(),
                  _SettingsRow(
                    icon: Icons.palette_rounded,
                    title: 'Theme Customization',
                    onTap: () => _push(context, const ThemePickerScreen()),
                  ),
                  const _RowDivider(),
                  _SettingsRow(
                    icon: Icons.widgets_rounded,
                    title: 'Home Screen Widgets',
                    onTap: () => _push(context, const WidgetGalleryScreen()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.spacing24),

            // ── Library ──────────────────────────────────────────────────────
            _SectionLabel('Library'),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.sync_rounded,
                    title: 'Rescan Library',
                    onTap: () => _snack(context, 'Library rescan started'),
                  ),
                  const _RowDivider(),
                  _SettingsRow(
                    icon: Icons.file_copy_rounded,
                    title: 'Duplicate Management',
                    onTap: () =>
                        _push(context, const DuplicateManagementScreen()),
                  ),
                  const _RowDivider(),
                  _SettingsRow(
                    icon: Icons.backup_rounded,
                    title: 'Backup & Restore',
                    onTap: () => _snack(context, 'Backup & Restore coming soon'),
                  ),
                  const _RowDivider(),
                  _SettingsRow(
                    icon: Icons.notifications_rounded,
                    title: 'Notifications',
                    onTap: () =>
                        _push(context, const NotificationSettingsScreen()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.spacing24),

            // ── About ────────────────────────────────────────────────────────
            _SectionLabel('About'),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.info_outline_rounded,
                    title: 'Version',
                    trailingText: '1.0.0',
                    showChevron: false,
                  ),
                  const _RowDivider(),
                  _SettingsRow(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () =>
                        _snack(context, 'Aura collects nothing. 100% offline.'),
                  ),
                  const _RowDivider(),
                  _SettingsRow(
                    icon: Icons.support_agent_rounded,
                    title: 'Contact Support',
                    onTap: () => _snack(context, 'support@aura.app'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showOutputDeviceSheet(BuildContext context, WidgetRef ref) {
    const devices = <(IconData, String)>[
      (Icons.phone_android_rounded, 'Phone Speaker'),
      (Icons.headphones_rounded, 'Wired Headphones'),
      (Icons.bluetooth_audio_rounded, 'AirPods Pro'),
      (Icons.speaker_group_rounded, 'Living Room Speaker'),
    ];
    final current = ref.read(settingsProvider).outputDevice;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: DesignTokens.spacing16),
            Text('Output Device',
                style: DesignTokens.titleLarge.copyWith(color: _primary(sheetContext))),
            const SizedBox(height: DesignTokens.spacing8),
            for (final (icon, name) in devices)
              ListTile(
                leading: Icon(icon,
                    color: name == current
                        ? DesignTokens.primarySeed
                        : _secondary(sheetContext)),
                title: Text(name),
                trailing: name == current
                    ? const Icon(Icons.check_rounded,
                        color: DesignTokens.primarySeed)
                    : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).setOutputDevice(name);
                  Navigator.of(sheetContext).pop();
                },
              ),
            const SizedBox(height: DesignTokens.spacing8),
          ],
        ),
      ),
    );
  }
}

// ── Section + row primitives ──────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: DesignTokens.spacing4,
        bottom: DesignTokens.spacing12,
      ),
      child: Text(
        text.toUpperCase(),
        style: DesignTokens.labelMedium.copyWith(
          color: DesignTokens.primarySeed,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
    );
  }
}

/// Standard tappable settings row: 24px icon, 16px title, optional trailing.
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.trailingText,
    this.onTap,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String? trailingText;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final chevron =
        (onTap != null && showChevron && trailing == null)
            ? Icon(Icons.chevron_right_rounded,
                color: _secondary(context), size: 22)
            : null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing16,
          vertical: DesignTokens.spacing12,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: DesignTokens.primarySeed),
            const SizedBox(width: DesignTokens.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DesignTokens.bodyLarge.copyWith(
                      fontSize: 16,
                      color: _primary(context),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: DesignTokens.bodyMedium
                          .copyWith(color: _secondary(context)),
                    ),
                ],
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: DesignTokens.bodyMedium.copyWith(
                  color: _secondary(context),
                ),
              ),
              const SizedBox(width: DesignTokens.spacing8),
            ],
            if (trailing != null) trailing!,
            if (chevron != null) chevron,
          ],
        ),
      ),
    );
  }
}

/// Crossfade row with an inline 0–12s slider.
class _CrossfadeRow extends StatelessWidget {
  const _CrossfadeRow({required this.seconds, required this.onChanged});

  final double seconds;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spacing16,
        DesignTokens.spacing12,
        DesignTokens.spacing16,
        DesignTokens.spacing8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.multitrack_audio_rounded,
                  size: 24, color: DesignTokens.primarySeed),
              const SizedBox(width: DesignTokens.spacing16),
              Expanded(
                child: Text('Crossfade',
                    style: DesignTokens.bodyLarge
                        .copyWith(fontSize: 16, color: _primary(context))),
              ),
              MonoValueLabel(
                text: seconds < 0.5 ? 'Off' : '${seconds.round()}s',
              ),
            ],
          ),
          AuraSliderTheme(
            child: Slider(
              value: seconds,
              min: 0,
              max: 12,
              divisions: 12,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// Daily Mix tuning row: discovery ⟷ favourites balance.
class _DailyMixRow extends StatelessWidget {
  const _DailyMixRow({required this.balance, required this.onChanged});

  final double balance; // 0 = favourites, 1 = discovery
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spacing16,
        DesignTokens.spacing12,
        DesignTokens.spacing16,
        DesignTokens.spacing8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded,
                  size: 24, color: DesignTokens.primarySeed),
              const SizedBox(width: DesignTokens.spacing16),
              Expanded(
                child: Text('Daily Mix Tuning',
                    style: DesignTokens.bodyLarge
                        .copyWith(fontSize: 16, color: _primary(context))),
              ),
              MonoValueLabel(text: '${(balance * 100).round()}%'),
            ],
          ),
          AuraSliderTheme(
            child: Slider(
              value: balance,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Favourites',
                  style: DesignTokens.caption.copyWith(color: _secondary(context))),
              Text('Discovery',
                  style: DesignTokens.caption.copyWith(color: _secondary(context))),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared colour helpers ─────────────────────────────────────────────────────

Color _primary(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? DesignTokens.darkTextPrimary
        : DesignTokens.lightTextPrimary;

Color _secondary(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? DesignTokens.darkTextSecondary
        : DesignTokens.lightTextSecondary;
