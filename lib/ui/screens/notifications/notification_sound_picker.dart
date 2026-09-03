// lib/ui/screens/notifications/notification_sound_picker.dart
// Aura — Pick the notification sound. Preview playback is stubbed (animated
// waveform + snackbar) until audio assets are wired in.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';
import 'notification_providers.dart';

class NotificationSoundPicker extends ConsumerStatefulWidget {
  const NotificationSoundPicker({super.key});

  @override
  ConsumerState<NotificationSoundPicker> createState() =>
      _NotificationSoundPickerState();
}

class _NotificationSoundPickerState
    extends ConsumerState<NotificationSoundPicker> {
  String? _playingId;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _preview(AuraSound sound) {
    _timer?.cancel();
    setState(() => _playingId = sound.id);
    _timer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _playingId = null);
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: const Duration(milliseconds: 1200),
        content: Text('Playing “${sound.name}”'),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(notificationSettingsProvider);
    final ctrl = ref.read(notificationSettingsProvider.notifier);
    final selected = kAuraSounds.firstWhere(
      (s) => s.id == settings.soundId,
      orElse: () => kAuraSounds.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Sound'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  for (final sound in kAuraSounds)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: DesignTokens.spacing12),
                      child: _SoundRow(
                        sound: sound,
                        selected: sound.id == settings.soundId,
                        playing: sound.id == _playingId,
                        onSelect: () => ctrl.setSound(sound.id),
                        onPreview: () => _preview(sound),
                      ),
                    ),
                ],
              ),
            ),
            // Bottom preview of the currently selected sound.
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spacing16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => _preview(selected),
                  style: FilledButton.styleFrom(
                    backgroundColor: DesignTokens.primarySeed,
                    foregroundColor: Colors.black,
                    shape: const StadiumBorder(),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text('Preview “${selected.name}”'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoundRow extends StatelessWidget {
  const _SoundRow({
    required this.sound,
    required this.selected,
    required this.playing,
    required this.onSelect,
    required this.onPreview,
  });

  final AuraSound sound;
  final bool selected;
  final bool playing;
  final VoidCallback onSelect;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onSelect,
      borderColor: selected
          ? DesignTokens.primarySeed.withValues(alpha: 0.6)
          : null,
      padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing12, vertical: DesignTokens.spacing8),
      child: Row(
        children: [
          // Waveform / animated-when-playing.
          SizedBox(
            width: 32,
            height: 32,
            child: playing
                ? const _AnimatedWaveform()
                : Icon(
                    sound.isSystemDefault
                        ? Icons.notifications_rounded
                        : Icons.graphic_eq_rounded,
                    color: _secondary(context),
                  ),
          ),
          const SizedBox(width: DesignTokens.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sound.name,
                    style: DesignTokens.bodyLarge.copyWith(
                        fontSize: 16, color: _primary(context))),
                if (sound.isSystemDefault)
                  Text('Current system default',
                      style: DesignTokens.caption
                          .copyWith(color: _secondary(context))),
              ],
            ),
          ),
          IconButton(
            onPressed: onPreview,
            icon: Icon(
              playing
                  ? Icons.volume_up_rounded
                  : Icons.play_circle_outline_rounded,
              color: DesignTokens.primarySeed,
            ),
            tooltip: 'Play preview',
          ),
          Radio<String>(
            value: sound.id,
            groupValue: selected ? sound.id : '__none__',
            activeColor: DesignTokens.primarySeed,
            onChanged: (_) => onSelect(),
          ),
        ],
      ),
    );
  }
}

/// Tiny looping equaliser used to indicate a sound is previewing.
class _AnimatedWaveform extends StatefulWidget {
  const _AnimatedWaveform();

  @override
  State<_AnimatedWaveform> createState() => _AnimatedWaveformState();
}

class _AnimatedWaveformState extends State<_AnimatedWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        double bar(int i) {
          final phase = (_c.value + i * 0.28) % 1.0;
          final v = (phase < 0.5 ? phase : 1 - phase) * 2; // 0..1 triangle
          return 6 + v * 18;
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (int i = 0; i < 4; i++) ...[
              Container(
                width: 3.5,
                height: bar(i),
                decoration: BoxDecoration(
                  color: DesignTokens.primarySeed,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (i < 3) const SizedBox(width: 2),
            ],
          ],
        );
      },
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
