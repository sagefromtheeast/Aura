// lib/ui/screens/settings/notification_settings_screen.dart
// Aura — Notification preferences with a simulated lock-screen preview.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';
import '../notifications/notification_preview_screen.dart';
import '../notifications/notification_sound_picker.dart';
import '../notifications/quiet_hours_screen.dart';
import 'settings_providers.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final c = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            // Simulated lock-screen preview.
            const _LockScreenPreview(),
            const SizedBox(height: DesignTokens.spacing24),

            _Section(title: 'Playback', children: [
              _ToggleRow(
                icon: Icons.play_circle_outline_rounded,
                title: 'Now Playing notification',
                value: s.nowPlayingNotification,
                onChanged: c.setNowPlaying,
              ),
              _ToggleRow(
                icon: Icons.lock_outline_rounded,
                title: 'Lock screen controls',
                value: s.lockScreenControls,
                onChanged: c.setLockScreen,
              ),
            ]),

            _Section(title: 'Discover', children: [
              _ToggleRow(
                icon: Icons.auto_awesome_rounded,
                title: 'Daily Mix Ready',
                value: s.dailyMixReady,
                onChanged: c.setDailyMixReady,
              ),
              _ToggleRow(
                icon: Icons.calendar_view_week_rounded,
                title: 'Weekly Recap',
                value: s.weeklyRecap,
                onChanged: c.setWeeklyRecap,
              ),
              _ToggleRow(
                icon: Icons.emoji_events_rounded,
                title: 'Milestones',
                value: s.milestones,
                onChanged: c.setMilestones,
              ),
            ]),

            _Section(title: 'Library', children: [
              _ToggleRow(
                icon: Icons.check_circle_outline_rounded,
                title: 'Scan Complete',
                value: s.scanComplete,
                onChanged: c.setScanComplete,
              ),
              _ToggleRow(
                icon: Icons.library_add_check_outlined,
                title: 'New Music Added',
                value: s.newMusicAdded,
                onChanged: c.setNewMusicAdded,
              ),
            ]),

            _Section(title: 'Reminders', children: [
              _ToggleRow(
                icon: Icons.notifications_paused_rounded,
                title: 'Inactive for 3 days',
                value: s.inactiveReminder,
                onChanged: c.setInactiveReminder,
              ),
              _ToggleRow(
                icon: Icons.nightlight_round,
                title: 'Quiet Hours',
                value: s.quietHoursEnabled,
                onChanged: c.setQuietHoursEnabled,
              ),
              if (s.quietHoursEnabled)
                _QuietHoursRow(
                  start: s.quietStart,
                  end: s.quietEnd,
                  onStart: c.setQuietStart,
                  onEnd: c.setQuietEnd,
                ),
            ]),

            _Section(title: 'More', children: [
              _NavRow(
                icon: Icons.nightlight_round,
                title: 'Quiet Hours',
                onTap: () => _push(context, const QuietHoursScreen()),
              ),
              _NavRow(
                icon: Icons.music_note_rounded,
                title: 'Notification Sound',
                onTap: () => _push(context, const NotificationSoundPicker()),
              ),
              _NavRow(
                icon: Icons.preview_rounded,
                title: 'See example notification',
                onTap: () =>
                    _push(context, const NotificationPreviewScreen()),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _LockScreenPreview extends StatelessWidget {
  const _LockScreenPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing20),
      decoration: BoxDecoration(
        borderRadius: DesignTokens.radius24,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF241C17), Color(0xFF0F0D0A)],
        ),
        border: Border.all(color: DesignTokens.darkBorder),
      ),
      child: Column(
        children: [
          Text('9:41',
              style: DesignTokens.displayLarge
                  .copyWith(color: Colors.white, fontSize: 40)),
          Text('Monday, February 16',
              style: DesignTokens.bodyMedium.copyWith(color: Colors.white60)),
          const SizedBox(height: DesignTokens.spacing16),
          // Simulated notification.
          Container(
            padding: const EdgeInsets.all(DesignTokens.spacing12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: DesignTokens.radius16,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: DesignTokens.radius8,
                    gradient: const LinearGradient(
                      colors: [
                        DesignTokens.primarySeed,
                        DesignTokens.accentSparkle
                      ],
                    ),
                  ),
                  child: const Icon(Icons.music_note_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: DesignTokens.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('AURA',
                              style: DesignTokens.caption
                                  .copyWith(color: Colors.white70)),
                          const Spacer(),
                          Text('now',
                              style: DesignTokens.caption
                                  .copyWith(color: Colors.white38)),
                        ],
                      ),
                      Text('Borderline · Tame Impala',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DesignTokens.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      Text('Tap to open Now Playing',
                          style: DesignTokens.caption
                              .copyWith(color: Colors.white54)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: DesignTokens.spacing4, bottom: DesignTokens.spacing8),
            child: Text(
              title.toUpperCase(),
              style: DesignTokens.labelMedium.copyWith(
                  color: DesignTokens.primarySeed, letterSpacing: 1.2),
            ),
          ),
          GlassCard(
            padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacing8,
                vertical: DesignTokens.spacing4),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

void _push(BuildContext context, Widget screen) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => screen),
  );
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, color: DesignTokens.primarySeed),
      title: Text(title,
          style: DesignTokens.bodyLarge
              .copyWith(fontSize: 16, color: _primary(context))),
      trailing: Icon(Icons.chevron_right_rounded, color: _secondary(context)),
      onTap: onTap,
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      secondary: Icon(icon, color: DesignTokens.primarySeed),
      title: Text(title,
          style: DesignTokens.bodyLarge
              .copyWith(fontSize: 16, color: _primary(context))),
      value: value,
      activeThumbColor: DesignTokens.primarySeed,
      onChanged: onChanged,
    );
  }
}

class _QuietHoursRow extends StatelessWidget {
  const _QuietHoursRow({
    required this.start,
    required this.end,
    required this.onStart,
    required this.onEnd,
  });

  final TimeOfDay start;
  final TimeOfDay end;
  final ValueChanged<TimeOfDay> onStart;
  final ValueChanged<TimeOfDay> onEnd;

  Future<void> _pick(
      BuildContext context, TimeOfDay initial, ValueChanged<TimeOfDay> cb) async {
    final picked =
        await showTimePicker(context: context, initialTime: initial);
    if (picked != null) cb(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
      child: Row(
        children: [
          const Icon(Icons.nightlight_round,
              color: DesignTokens.accentSparkle, size: 20),
          const SizedBox(width: DesignTokens.spacing12),
          Expanded(
            child: _TimeChip(
              label: 'Start',
              time: start,
              onTap: () => _pick(context, start, onStart),
            ),
          ),
          const SizedBox(width: DesignTokens.spacing8),
          Expanded(
            child: _TimeChip(
              label: 'End',
              time: end,
              onTap: () => _pick(context, end, onEnd),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return InkWell(
      onTap: onTap,
      borderRadius: DesignTokens.radius12,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing12, vertical: DesignTokens.spacing8),
        decoration: BoxDecoration(
          borderRadius: DesignTokens.radius12,
          border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: DesignTokens.bodyMedium
                    .copyWith(color: _secondary(context))),
            Text(
              '$hh:$mm',
              style: const TextStyle(
                fontFamily: DesignTokens.fontMono,
                fontFamilyFallback: <String>['monospace'],
                fontWeight: FontWeight.w700,
                color: DesignTokens.primarySeed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _primary(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? DesignTokens.darkTextPrimary
        : DesignTokens.lightTextPrimary;

Color _secondary(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? DesignTokens.darkTextSecondary
        : DesignTokens.lightTextSecondary;
