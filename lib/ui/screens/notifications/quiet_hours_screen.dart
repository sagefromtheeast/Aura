// lib/ui/screens/notifications/quiet_hours_screen.dart
// Aura — Quiet Hours configuration with a night-time indigo/gold palette.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';
import 'notification_providers.dart';

// Night-time palette.
const Color _indigo = Color(0xFF4F46E5);
const Color _indigoDeep = Color(0xFF1E1B4B);
const Color _gold = Color(0xFFD9B65C);

class QuietHoursScreen extends ConsumerWidget {
  const QuietHoursScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cfg = ref.watch(quietHoursProvider);
    final ctrl = ref.read(quietHoursProvider.notifier);

    return Scaffold(
      backgroundColor: _indigoDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Quiet Hours'),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.8),
            radius: 1.3,
            colors: [Color(0xFF312E81), _indigoDeep],
          ),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              // Master toggle.
              _glass(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.nightlight_round, color: _gold),
                  title: const Text('Quiet Hours',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    cfg.enabled ? 'On' : 'Off',
                    style: const TextStyle(color: Colors.white60),
                  ),
                  value: cfg.enabled,
                  activeThumbColor: _gold,
                  onChanged: ctrl.setEnabled,
                ),
              ),

              // Time pickers (only when enabled).
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: cfg.enabled
                    ? Column(
                        children: [
                          const SizedBox(height: DesignTokens.spacing16),
                          _glass(
                            child: Row(
                              children: [
                                const Icon(Icons.bedtime_rounded, color: _gold),
                                const SizedBox(width: DesignTokens.spacing12),
                                Expanded(
                                  child: _TimeField(
                                    label: 'Start',
                                    time: cfg.start,
                                    onPick: ctrl.setStart,
                                  ),
                                ),
                                const SizedBox(width: DesignTokens.spacing8),
                                const Icon(Icons.arrow_forward_rounded,
                                    color: Colors.white38, size: 18),
                                const SizedBox(width: DesignTokens.spacing8),
                                Expanded(
                                  child: _TimeField(
                                    label: 'End',
                                    time: cfg.end,
                                    onPick: ctrl.setEnd,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: DesignTokens.spacing24),
              _sectionLabel('Allowed during quiet hours'),
              const SizedBox(height: DesignTokens.spacing8),
              _glass(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    for (final t in NotifType.values)
                      CheckboxListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: _gold,
                        checkColor: Colors.black,
                        value: cfg.bypasses(t),
                        onChanged: t.locked
                            ? null
                            : (_) => ctrl.toggleBypass(t),
                        title: Row(
                          children: [
                            Text(t.label,
                                style: const TextStyle(color: Colors.white)),
                            if (t.locked) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.lock_rounded,
                                  size: 14, color: Colors.white38),
                            ],
                          ],
                        ),
                        subtitle: t.locked
                            ? const Text('Always allowed',
                                style: TextStyle(color: Colors.white38))
                            : null,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: DesignTokens.spacing24),
              _sectionLabel('Preview'),
              const SizedBox(height: DesignTokens.spacing8),
              _QuietTimeline(cfg: cfg),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _glass({required Widget child, EdgeInsetsGeometry? padding}) {
    return GlassCard(
      surfaceColor: Colors.white.withValues(alpha: 0.06),
      borderColor: _indigo.withValues(alpha: 0.5),
      padding: padding ?? const EdgeInsets.all(DesignTokens.spacing16),
      child: child,
    );
  }

  static Widget _sectionLabel(String text) => Text(
        text.toUpperCase(),
        style: DesignTokens.labelMedium.copyWith(color: _gold, letterSpacing: 1.2),
      );
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.time,
    required this.onPick,
  });

  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onPick;

  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(context: context, initialTime: time);
    if (picked != null) onPick(picked);
  }

  @override
  Widget build(BuildContext context) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return InkWell(
      onTap: () => _pick(context),
      borderRadius: DesignTokens.radius12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: DesignTokens.radius12,
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 2),
            Text('$hh:$mm',
                style: const TextStyle(
                  fontFamily: DesignTokens.fontMono,
                  fontFamilyFallback: <String>['monospace'],
                  color: _gold,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ),
    );
  }
}

/// 24-hour timeline with the quiet window shaded, plus blocked/allowed chips.
class _QuietTimeline extends StatelessWidget {
  const _QuietTimeline({required this.cfg});
  final QuietHoursConfig cfg;

  @override
  Widget build(BuildContext context) {
    final blocked = [
      for (final t in NotifType.values)
        if (!cfg.bypasses(t)) t,
    ];
    final allowed = [
      for (final t in NotifType.values)
        if (cfg.bypasses(t)) t,
    ];

    return QuietHoursScreen._glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The bar.
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final segments = _windowSegments(cfg.start, cfg.end);
              return SizedBox(
                height: 44,
                child: Stack(
                  children: [
                    // Base day track.
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: DesignTokens.radiusPill,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    // Quiet window(s).
                    if (cfg.enabled)
                      for (final seg in segments)
                        Positioned(
                          left: seg.$1 * w,
                          width: (seg.$2 - seg.$1) * w,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: DesignTokens.radiusPill,
                              gradient: LinearGradient(colors: [
                                _indigo.withValues(alpha: 0.9),
                                const Color(0xFF6D28D9).withValues(alpha: 0.9),
                              ]),
                            ),
                            child: const Center(
                              child: Icon(Icons.nightlight_round,
                                  color: _gold, size: 18),
                            ),
                          ),
                        ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('12 AM', style: TextStyle(color: Colors.white38, fontSize: 10)),
              Text('12 PM', style: TextStyle(color: Colors.white38, fontSize: 10)),
              Text('12 AM', style: TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing16),
          if (cfg.enabled) ...[
            _legend('Blocked during quiet hours', blocked,
                const Color(0xFF64748B)),
            const SizedBox(height: DesignTokens.spacing8),
            _legend('Still delivered', allowed, _gold),
          ] else
            const Text('Quiet Hours is off — all notifications are delivered.',
                style: TextStyle(color: Colors.white60)),
        ],
      ),
    );
  }

  Widget _legend(String title, List<NotifType> types, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            if (types.isEmpty)
              const Text('—', style: TextStyle(color: Colors.white38))
            else
              for (final t in types)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: DesignTokens.radiusPill,
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Text(t.label,
                      style: TextStyle(color: color, fontSize: 12)),
                ),
          ],
        ),
      ],
    );
  }

  /// Returns 1–2 normalized (start,end) fractions of a 24h day for the quiet
  /// window, splitting across midnight when needed.
  List<(double, double)> _windowSegments(TimeOfDay s, TimeOfDay e) {
    final startF = (s.hour * 60 + s.minute) / 1440.0;
    final endF = (e.hour * 60 + e.minute) / 1440.0;
    if (endF > startF) return [(startF, endF)];
    // Wraps midnight.
    return [(startF, 1.0), (0.0, endF)];
  }
}
