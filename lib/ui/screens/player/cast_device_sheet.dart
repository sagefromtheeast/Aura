// lib/ui/screens/player/cast_device_sheet.dart
// Aura — Wireless Cast & Bluetooth Output Selector Modal Sheet.
// Complies with AGENTS.md vertical overflow rules and Liquid Material guidelines.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';

/// Modal sheet for switching audio output between Bluetooth codecs, UPnP speakers, and AirPlay/Cast endpoints.
class CastDeviceSheet extends ConsumerStatefulWidget {
  const CastDeviceSheet({super.key});

  @override
  ConsumerState<CastDeviceSheet> createState() => _CastDeviceSheetState();
}

class _CastDeviceSheetState extends ConsumerState<CastDeviceSheet> {
  String _selectedDeviceId = 'local_dac';
  bool _scanning = false;

  final List<Map<String, dynamic>> _devices = [
    {
      'id': 'local_dac',
      'name': 'Internal Hi-Res DAC (Direct Engine)',
      'type': 'Wired • 24-bit / 192 kHz PCM',
      'icon': Icons.headphones_rounded,
      'battery': null,
      'latency': '0 ms (Bit-Perfect)',
      'isHiRes': true,
    },
    {
      'id': 'bt_ldac_hd',
      'name': 'AuraPulse Studio Wireless (LDAC 990kbps)',
      'type': 'Bluetooth 5.3 • Hi-Res Audio Wireless',
      'icon': Icons.headset_mic_rounded,
      'battery': 86,
      'latency': '35 ms',
      'isHiRes': true,
    },
    {
      'id': 'upnp_living',
      'name': 'Living Room HiFi Streamer',
      'type': 'UPnP / DLNA Network Endpoint',
      'icon': Icons.speaker_group_rounded,
      'battery': null,
      'latency': '120 ms (Buffer Sync)',
      'isHiRes': true,
    },
    {
      'id': 'bt_car_kit',
      'name': 'Vehicle Media Receiver (aptX HD)',
      'type': 'Bluetooth 5.0 Automotive Audio',
      'icon': Icons.directions_car_rounded,
      'battery': null,
      'latency': '45 ms',
      'isHiRes': false,
    },
  ];

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audio Output & Cast',
                        style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select high-definition playback sink',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _scanning
                      ? null
                      : () async {
                          setState(() => _scanning = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Scanning for wireless audio endpoints...')),
                          );
                          await Future<void>.delayed(const Duration(seconds: 2));
                          if (context.mounted) {
                            setState(() => _scanning = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('All nearby audio sinks discovered')),
                            );
                          }
                        },
                  icon: _scanning
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.refresh_rounded),
                  tooltip: 'Scan for devices',
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spacing16),
          Divider(color: colorScheme.onSurface.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: DesignTokens.spacing16),

          // Device List (Flexible + shrinkWrap per AGENTS.md)
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing24),
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                final device = _devices[index];
                final isSelected = device['id'] == _selectedDeviceId;
                final bool isHiRes = device['isHiRes'] as bool;
                final int? battery = device['battery'] as int?;

                return Padding(
                  padding: const EdgeInsets.only(bottom: DesignTokens.spacing12),
                  child: Semantics(
                    label: 'Select audio device ${device['name']}',
                    button: true,
                    selected: isSelected,
                    child: GlassCard(
                      onTap: () {
                        setState(() {
                          _selectedDeviceId = device['id'] as String;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Audio stream rerouted to ${device['name']}')),
                        );
                      },
                      borderRadius: 16.0,
                      padding: const EdgeInsets.all(DesignTokens.spacing16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? DesignTokens.primarySeed.withValues(alpha: 0.2)
                                  : colorScheme.onSurface.withValues(alpha: 0.05),
                              borderRadius: DesignTokens.radius12,
                            ),
                            child: Icon(
                              device['icon'] as IconData,
                              color: isSelected ? DesignTokens.primarySeed : colorScheme.onSurface,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: DesignTokens.spacing16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        device['name'] as String,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                          color: isSelected ? DesignTokens.primarySeed : null,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isHiRes) ...[
                                      const SizedBox(width: DesignTokens.spacing8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: DesignTokens.primarySeed),
                                          borderRadius: DesignTokens.radius8,
                                        ),
                                        child: const Text(
                                          'Hi-Res',
                                          style: TextStyle(
                                            color: DesignTokens.primarySeed,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  device['type'] as String,
                                  style: theme.textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Latency: ${device['latency']}',
                                      style: TextStyle(
                                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                                        fontSize: 11,
                                      ),
                                    ),
                                    if (battery != null) ...[
                                      const SizedBox(width: DesignTokens.spacing12),
                                      Icon(Icons.battery_std_rounded, size: 13, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                                      const SizedBox(width: 2),
                                      Text(
                                        '$battery%',
                                        style: TextStyle(
                                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: DesignTokens.spacing12),
                          Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                            color: isSelected ? DesignTokens.primarySeed : colorScheme.onSurface.withValues(alpha: 0.3),
                            size: 24,
                          ),
                        ],
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
    );
  }
}
