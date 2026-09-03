// lib/ui/screens/settings/duplicate_management_screen.dart
// Aura — Scan for and resolve duplicate tracks. Stub scan + local resolution.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';

/// Soft amber used to flag duplicate items.
const Color _kWarning = Color(0xFFFFB020);

enum _Resolution { keepFirst, keepBoth, merge }

class _DupTrack {
  const _DupTrack({
    required this.title,
    required this.artist,
    required this.durationMs,
    required this.quality,
  });
  final String title;
  final String artist;
  final int durationMs;
  final String quality;
}

class _DupGroup {
  _DupGroup({required this.a, required this.b});
  final _DupTrack a;
  final _DupTrack b;
  _Resolution resolution = _Resolution.keepFirst;
  bool resolved = false;
}

class DuplicateManagementScreen extends ConsumerStatefulWidget {
  const DuplicateManagementScreen({super.key});

  @override
  ConsumerState<DuplicateManagementScreen> createState() =>
      _DuplicateManagementScreenState();
}

class _DuplicateManagementScreenState
    extends ConsumerState<DuplicateManagementScreen> {
  bool _scanning = false;
  double _progress = 0;
  bool _scanned = false;
  Timer? _timer;
  final List<_DupGroup> _groups = [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startScan() {
    setState(() {
      _scanning = true;
      _progress = 0;
      _scanned = false;
      _groups.clear();
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 90), (t) {
      setState(() => _progress += 0.06);
      if (_progress >= 1.0) {
        t.cancel();
        setState(() {
          _scanning = false;
          _scanned = true;
          _groups.addAll(_stubResults());
        });
      }
    });
  }

  List<_DupGroup> _stubResults() => [
        _DupGroup(
          a: const _DupTrack(
            title: 'The Less I Know The Better',
            artist: 'Tame Impala',
            durationMs: 216000,
            quality: 'FLAC · 1041kbps',
          ),
          b: const _DupTrack(
            title: 'The Less I Know The Better',
            artist: 'Tame Impala',
            durationMs: 216000,
            quality: 'MP3 · 320kbps',
          ),
        ),
        _DupGroup(
          a: const _DupTrack(
            title: 'Redbone',
            artist: 'Childish Gambino',
            durationMs: 327000,
            quality: 'ALAC · 900kbps',
          ),
          b: const _DupTrack(
            title: 'Redbone (Album Version)',
            artist: 'Childish Gambino',
            durationMs: 326000,
            quality: 'MP3 · 256kbps',
          ),
        ),
        _DupGroup(
          a: const _DupTrack(
            title: 'Nights',
            artist: 'Frank Ocean',
            durationMs: 307000,
            quality: 'FLAC · 998kbps',
          ),
          b: const _DupTrack(
            title: 'Nights',
            artist: 'Frank Ocean',
            durationMs: 307000,
            quality: 'AAC · 256kbps',
          ),
        ),
      ];

  void _resolveAll() {
    setState(() {
      for (final g in _groups) {
        g.resolved = true;
      }
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Resolved ${_groups.length} duplicate groups')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final unresolved = _groups.where((g) => !g.resolved).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duplicate Management'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spacing16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _scanning ? null : _startScan,
                      style: FilledButton.styleFrom(
                        backgroundColor: DesignTokens.primarySeed,
                        foregroundColor: Colors.black,
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(Icons.search_rounded),
                      label: Text(_scanned
                          ? 'Scan Again'
                          : 'Scan for Duplicates'),
                    ),
                  ),
                  if (_scanning) ...[
                    const SizedBox(height: DesignTokens.spacing16),
                    ClipRRect(
                      borderRadius: DesignTokens.radiusPill,
                      child: LinearProgressIndicator(
                        value: _progress.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: Theme.of(context).dividerColor,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            DesignTokens.primarySeed),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing8),
                    Text(
                      'Hashing library… ${(_progress.clamp(0.0, 1.0) * 100).round()}%',
                      style: DesignTokens.bodyMedium
                          .copyWith(color: _secondary(context)),
                    ),
                  ],
                ],
              ),
            ),

            // Results
            Expanded(
              child: _scanned && _groups.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                      itemCount: _groups.length,
                      itemBuilder: (context, i) => _DupGroupCard(
                        group: _groups[i],
                        onResolution: (r) =>
                            setState(() => _groups[i].resolution = r),
                      ),
                    )
                  : _EmptyOrIdle(scanned: _scanned),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (_scanned && unresolved > 0)
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.spacing16),
                child: SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: _resolveAll,
                    style: FilledButton.styleFrom(
                      backgroundColor: DesignTokens.primarySeed,
                      foregroundColor: Colors.black,
                      shape: const StadiumBorder(),
                    ),
                    child: Text('Resolve All ($unresolved)'),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _DupGroupCard extends StatelessWidget {
  const _DupGroupCard({required this.group, required this.onResolution});

  final _DupGroup group;
  final ValueChanged<_Resolution> onResolution;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacing16),
      borderColor: group.resolved
          ? const Color(0xFF4ADE80).withValues(alpha: 0.5)
          : _kWarning.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                group.resolved
                    ? Icons.check_circle_rounded
                    : Icons.warning_amber_rounded,
                color: group.resolved ? const Color(0xFF4ADE80) : _kWarning,
                size: 20,
              ),
              const SizedBox(width: DesignTokens.spacing8),
              Text(
                group.resolved ? 'Resolved' : 'Possible duplicate',
                style: DesignTokens.labelMedium.copyWith(
                  color: group.resolved ? const Color(0xFF4ADE80) : _kWarning,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing12),
          _TrackRow(track: group.a, tag: 'A'),
          const SizedBox(height: DesignTokens.spacing8),
          _TrackRow(track: group.b, tag: 'B'),
          if (!group.resolved) ...[
            const SizedBox(height: DesignTokens.spacing12),
            SegmentedButton<_Resolution>(
              segments: const [
                ButtonSegment(
                    value: _Resolution.keepFirst, label: Text('Keep First')),
                ButtonSegment(
                    value: _Resolution.keepBoth, label: Text('Keep Both')),
                ButtonSegment(value: _Resolution.merge, label: Text('Merge')),
              ],
              selected: {group.resolution},
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStatePropertyAll(
                  DesignTokens.bodyMedium.copyWith(fontSize: 12),
                ),
              ),
              onSelectionChanged: (s) => onResolution(s.first),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrackRow extends StatefulWidget {
  const _TrackRow({required this.track, required this.tag});
  final _DupTrack track;
  final String tag;

  @override
  State<_TrackRow> createState() => _TrackRowState();
}

class _TrackRowState extends State<_TrackRow> {
  bool _checked = false;

  String _fmt(int ms) {
    final total = ms ~/ 1000;
    final m = total ~/ 60;
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.track;
    return Row(
      children: [
        Checkbox(
          value: _checked,
          activeColor: DesignTokens.primarySeed,
          onChanged: (v) => setState(() => _checked = v ?? false),
        ),
        // Album art placeholder
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: DesignTokens.radius8,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _kWarning.withValues(alpha: 0.4),
                DesignTokens.primarySeed.withValues(alpha: 0.4),
              ],
            ),
          ),
          child: Text(widget.tag,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: DesignTokens.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DesignTokens.bodyLarge.copyWith(
                      color: _primary(context), fontWeight: FontWeight.w600)),
              Text('${t.artist} · ${t.quality}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DesignTokens.bodyMedium
                      .copyWith(color: _secondary(context))),
            ],
          ),
        ),
        const SizedBox(width: DesignTokens.spacing8),
        Text(_fmt(t.durationMs),
            style: TextStyle(
              fontFamily: DesignTokens.fontMono,
              fontFamilyFallback: const <String>['monospace'],
              color: _secondary(context),
              fontSize: 12,
            )),
      ],
    );
  }
}

class _EmptyOrIdle extends StatelessWidget {
  const _EmptyOrIdle({required this.scanned});
  final bool scanned;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              scanned ? Icons.verified_rounded : Icons.file_copy_outlined,
              size: 56,
              color: scanned ? const Color(0xFF4ADE80) : _secondary(context),
            ),
            const SizedBox(height: DesignTokens.spacing16),
            Text(
              scanned
                  ? 'No duplicates found — your library is clean.'
                  : 'Scan your library to find duplicate tracks.',
              textAlign: TextAlign.center,
              style: DesignTokens.bodyLarge.copyWith(color: _secondary(context)),
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
