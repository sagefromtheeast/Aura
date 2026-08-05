// lib/ui/screens/player/sleep_timer_sheet.dart
// Aura — Sleep Timer & Audio Fade-Out Modal Sheet.
// Complies with AGENTS.md vertical overflow rules and Liquid Material guidelines.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';

/// Modal bottom sheet allowing selection of duration or end-of-track sleep timers.
class SleepTimerSheet extends ConsumerStatefulWidget {
  const SleepTimerSheet({super.key});

  @override
  ConsumerState<SleepTimerSheet> createState() => _SleepTimerSheetState();
}

class _SleepTimerSheetState extends ConsumerState<SleepTimerSheet> {
  int? _selectedDurationMin;
  bool _fadeAudio = true;
  bool _endOfTrack = false;
  bool _timerActive = false;

  final List<int> _durations = [15, 30, 45, 60, 90, 120];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
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
                  child: Text(
                    'Sleep Timer',
                    style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22),
                  ),
                ),
                if (_timerActive)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _timerActive = false;
                        _selectedDurationMin = null;
                        _endOfTrack = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sleep timer cancelled')),
                      );
                    },
                    child: Text(
                      'Cancel Timer',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spacing16),
          Divider(color: colorScheme.onSurface.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: DesignTokens.spacing16),

          // Options List (Flexible + shrinkWrap per AGENTS.md)
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing24),
              children: [
                if (_timerActive) ...[
                  GlassCard(
                    borderRadius: 16.0,
                    padding: const EdgeInsets.all(DesignTokens.spacing16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.bedtime_rounded,
                          color: DesignTokens.primarySeed,
                          size: 28,
                        ),
                        const SizedBox(width: DesignTokens.spacing16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TIMER RUNNING',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: DesignTokens.primarySeed,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _endOfTrack
                                    ? 'Stopping after current track finishes'
                                    : 'Playback stopping in $_selectedDurationMin minutes',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing24),
                ],

                Text(
                  'SELECT DURATION',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacing12),

                // Duration Grid
                Wrap(
                  spacing: DesignTokens.spacing12,
                  runSpacing: DesignTokens.spacing12,
                  children: _durations.map((min) {
                    final isSelected = _selectedDurationMin == min && !_endOfTrack;
                    return Semantics(
                      label: 'Set sleep timer for $min minutes',
                      button: true,
                      selected: isSelected,
                      child: ChoiceChip(
                        label: Text('$min min'),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedDurationMin = min;
                              _endOfTrack = false;
                            });
                          }
                        },
                        selectedColor: DesignTokens.primarySeed,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: DesignTokens.spacing24),

                // End of Track Option
                GlassCard(
                  onTap: () {
                    setState(() {
                      _endOfTrack = !_endOfTrack;
                      if (_endOfTrack) _selectedDurationMin = null;
                    });
                  },
                  borderRadius: 12.0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacing16,
                    vertical: DesignTokens.spacing12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.album_rounded,
                        color: _endOfTrack ? DesignTokens.primarySeed : colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: DesignTokens.spacing16),
                      Expanded(
                        child: Text(
                          'Stop after end of current track',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: _endOfTrack ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      Checkbox(
                        value: _endOfTrack,
                        onChanged: (val) {
                          setState(() {
                            _endOfTrack = val == true;
                            if (_endOfTrack) _selectedDurationMin = null;
                          });
                        },
                        activeColor: DesignTokens.primarySeed,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DesignTokens.spacing16),

                // Audio Fade Toggle
                Row(
                  children: [
                    const Icon(Icons.volume_down_rounded, size: 20),
                    const SizedBox(width: DesignTokens.spacing12),
                    Expanded(
                      child: Text(
                        'Gentle 60s volume fade-out',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Switch(
                      value: _fadeAudio,
                      onChanged: (val) {
                        setState(() {
                          _fadeAudio = val;
                        });
                      },
                      activeThumbColor: DesignTokens.primarySeed,
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacing32),

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: (_selectedDurationMin != null || _endOfTrack)
                        ? () {
                            setState(() {
                              _timerActive = true;
                            });
                            final msg = _endOfTrack
                                ? 'Sleep timer set: stop at end of track'
                                : 'Sleep timer active for $_selectedDurationMin minutes';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(msg)),
                            );
                            Navigator.pop(context);
                          }
                        : null,
                    icon: const Icon(Icons.check),
                    label: const Text('Start Sleep Timer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignTokens.primarySeed,
                      foregroundColor: colorScheme.onPrimary,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: DesignTokens.radiusPill,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.spacing32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
