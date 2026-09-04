// lib/ui/screens/settings/duplicate_management_screen.dart
// Aura — Scan for and resolve duplicate tracks.
//
// The scan itself lives in [duplicateScanProvider], which runs the three
// detection layers on a background isolate; this screen only renders its state.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/duplicate_provider.dart';
import '../../../domain/duplicate_detector/duplicate_detector.dart';
import '../../../domain/entities/track.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';

/// Soft amber used to flag duplicate items.
const Color _kWarning = Color(0xFFFFB020);
const Color _kSuccess = Color(0xFF4ADE80);

class DuplicateManagementScreen extends ConsumerStatefulWidget {
  const DuplicateManagementScreen({super.key});

  @override
  ConsumerState<DuplicateManagementScreen> createState() =>
      _DuplicateManagementScreenState();
}

class _DuplicateManagementScreenState
    extends ConsumerState<DuplicateManagementScreen> {
  /// Per-group choice, keyed by [DuplicateScanState.groupKey] so it survives
  /// the list shifting as groups are resolved.
  final Map<String, DuplicateResolutionStrategy> _choices = {};

  /// Deep scans decode 30 seconds of every unmatched file, so they are opt-in.
  bool _deepScan = false;

  DuplicateResolutionStrategy _choiceFor(DuplicateGroup group) =>
      _choices[DuplicateScanState.groupKey(group)] ??
      DuplicateResolutionStrategy.keepHighestQuality;

  Future<void> _startScan() {
    return ref.read(duplicateScanProvider.notifier).scan(
          level: _deepScan
              ? DuplicateDetectionLevel.fingerprint
              : DuplicateDetectionLevel.fuzzy,
        );
  }

  Future<void> _resolve(
      DuplicateGroup group, DuplicateResolutionStrategy strategy) async {
    await ref.read(duplicateScanProvider.notifier).resolve(group, strategy);
    if (!mounted) return;

    final message = strategy == DuplicateResolutionStrategy.keepBoth
        ? 'Kept both copies'
        : 'Kept "${group.suggested.title}" · '
            '${_formatBytes(group.reclaimableBytes)} freed';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _resolveAll(DuplicateScanState state) async {
    final pending = state.unresolved;
    if (pending.isEmpty) return;

    final reclaimed = pending
        .where((g) => _choiceFor(g) != DuplicateResolutionStrategy.keepBoth)
        .fold<int>(0, (sum, g) => sum + g.reclaimableBytes);

    final notifier = ref.read(duplicateScanProvider.notifier);
    for (final group in pending) {
      await notifier.resolve(group, _choiceFor(group));
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Resolved ${pending.length} groups · '
            '${_formatBytes(reclaimed)} freed'),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(duplicateScanProvider);
    final unresolved = state.unresolved;

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
              child: _ScanControls(
                state: state,
                deepScan: _deepScan,
                onDeepScanChanged: (v) => setState(() => _deepScan = v),
                onScan: _startScan,
              ),
            ),
            Expanded(
              child: unresolved.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                      itemCount: unresolved.length,
                      itemBuilder: (context, i) {
                        final group = unresolved[i];
                        return _DupGroupCard(
                          group: group,
                          strategy: _choiceFor(group),
                          onStrategyChanged: (s) => setState(() {
                            _choices[DuplicateScanState.groupKey(group)] = s;
                          }),
                          onApply: () => _resolve(group, _choiceFor(group)),
                        );
                      },
                    )
                  : _EmptyOrIdle(state: state),
            ),
          ],
        ),
      ),
      bottomNavigationBar: unresolved.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.spacing16),
                child: SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: () => _resolveAll(state),
                    style: FilledButton.styleFrom(
                      backgroundColor: DesignTokens.primarySeed,
                      foregroundColor: Colors.black,
                      shape: const StadiumBorder(),
                    ),
                    child: Text('Resolve All (${unresolved.length}) · '
                        '${_formatBytes(state.reclaimableBytes)}'),
                  ),
                ),
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ScanControls extends StatelessWidget {
  const _ScanControls({
    required this.state,
    required this.deepScan,
    required this.onDeepScanChanged,
    required this.onScan,
  });

  final DuplicateScanState state;
  final bool deepScan;
  final ValueChanged<bool> onDeepScanChanged;
  final VoidCallback onScan;

  String get _statusLabel {
    final progress = state.progress;
    if (progress == null) return 'Preparing…';
    final percent = (progress.fraction * 100).round();
    return switch (progress.level) {
      DuplicateDetectionLevel.exact =>
        'Hashing library… $percent%',
      DuplicateDetectionLevel.fuzzy =>
        'Comparing titles and artists… $percent%',
      DuplicateDetectionLevel.fingerprint =>
        'Fingerprinting audio… $percent% '
            '(${progress.comparisonsDone}/${progress.comparisonsTotal})',
    };
  }

  @override
  Widget build(BuildContext context) {
    final scanned = state.phase == DuplicateScanPhase.done ||
        state.phase == DuplicateScanPhase.failed;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: state.isScanning ? null : onScan,
            style: FilledButton.styleFrom(
              backgroundColor: DesignTokens.primarySeed,
              foregroundColor: Colors.black,
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Icons.search_rounded),
            label: Text(scanned ? 'Scan Again' : 'Scan for Duplicates'),
          ),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: deepScan,
          onChanged: state.isScanning ? null : onDeepScanChanged,
          activeColor: DesignTokens.primarySeed,
          title: Text('Deep scan',
              style: DesignTokens.bodyLarge.copyWith(color: _primary(context))),
          subtitle: Text(
            'Also compares the audio itself, catching copies with different '
            'tags. Much slower.',
            style:
                DesignTokens.bodyMedium.copyWith(color: _secondary(context)),
          ),
        ),
        if (state.isScanning) ...[
          const SizedBox(height: DesignTokens.spacing8),
          ClipRRect(
            borderRadius: DesignTokens.radiusPill,
            child: LinearProgressIndicator(
              value: state.progress?.fraction,
              minHeight: 6,
              backgroundColor: Theme.of(context).dividerColor,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  DesignTokens.primarySeed),
            ),
          ),
          const SizedBox(height: DesignTokens.spacing8),
          Text(_statusLabel,
              style: DesignTokens.bodyMedium
                  .copyWith(color: _secondary(context))),
        ],
      ],
    );
  }
}

class _DupGroupCard extends StatelessWidget {
  const _DupGroupCard({
    required this.group,
    required this.strategy,
    required this.onStrategyChanged,
    required this.onApply,
  });

  final DuplicateGroup group;
  final DuplicateResolutionStrategy strategy;
  final ValueChanged<DuplicateResolutionStrategy> onStrategyChanged;
  final VoidCallback onApply;

  String get _matchLabel => switch (group.type) {
        DuplicateType.exact => 'Identical tags',
        DuplicateType.fuzzyMetadata =>
          'Similar tags · ${(group.confidence * 100).round()}% match',
        DuplicateType.audioFingerprint =>
          'Same audio · ${(group.confidence * 100).round()}% match',
      };

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacing16),
      borderColor: _kWarning.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: _kWarning, size: 20),
              const SizedBox(width: DesignTokens.spacing8),
              Expanded(
                child: Text(_matchLabel,
                    style: DesignTokens.labelMedium
                        .copyWith(color: _kWarning)),
              ),
              Text(_formatBytes(group.reclaimableBytes),
                  style: TextStyle(
                    fontFamily: DesignTokens.fontMono,
                    fontFamilyFallback: const <String>['monospace'],
                    color: _secondary(context),
                    fontSize: 12,
                  )),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing12),
          for (var i = 0; i < group.tracks.length; i++) ...[
            if (i > 0) const SizedBox(height: DesignTokens.spacing8),
            _TrackRow(track: group.tracks[i], isSuggested: i == 0),
          ],
          const SizedBox(height: DesignTokens.spacing12),
          DropdownButtonFormField<DuplicateResolutionStrategy>(
            value: strategy,
            isExpanded: true,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              labelText: 'Resolution',
            ),
            style: DesignTokens.bodyMedium.copyWith(color: _primary(context)),
            items: const [
              DropdownMenuItem(
                value: DuplicateResolutionStrategy.keepHighestQuality,
                child: Text('Keep highest quality'),
              ),
              DropdownMenuItem(
                value: DuplicateResolutionStrategy.keepMostPlayed,
                child: Text('Keep most played'),
              ),
              DropdownMenuItem(
                value: DuplicateResolutionStrategy.merge,
                child: Text('Merge play counts, keep best'),
              ),
              DropdownMenuItem(
                value: DuplicateResolutionStrategy.keepFirst,
                child: Text('Keep the first copy'),
              ),
              DropdownMenuItem(
                value: DuplicateResolutionStrategy.keepBoth,
                child: Text('Keep both (not a duplicate)'),
              ),
            ],
            onChanged: (v) => v == null ? null : onStrategyChanged(v),
          ),
          const SizedBox(height: DesignTokens.spacing8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onApply,
              child: Text(
                strategy == DuplicateResolutionStrategy.keepBoth
                    ? 'Dismiss'
                    : 'Apply',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({required this.track, required this.isSuggested});

  final Track track;
  final bool isSuggested;

  String get _quality {
    final format = track.format == AudioFormat.unknown
        ? 'Audio'
        : track.format.name.toUpperCase();
    if (track.bitRateKbps > 0) return '$format · ${track.bitRateKbps}kbps';
    return '$format · ${(track.sampleRateHz / 1000).toStringAsFixed(1)}kHz';
  }

  String _fmtDuration(int ms) {
    final total = ms ~/ 1000;
    final m = total ~/ 60;
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
                (isSuggested ? _kSuccess : _kWarning).withValues(alpha: 0.4),
                DesignTokens.primarySeed.withValues(alpha: 0.4),
              ],
            ),
          ),
          child: Icon(
            isSuggested ? Icons.star_rounded : Icons.file_copy_outlined,
            size: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: DesignTokens.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DesignTokens.bodyLarge.copyWith(
                      color: _primary(context),
                      fontWeight: FontWeight.w600)),
              Text(
                '${track.artistName} · $_quality'
                '${track.playCount > 0 ? ' · ${track.playCount} plays' : ''}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DesignTokens.bodyMedium
                    .copyWith(color: _secondary(context)),
              ),
            ],
          ),
        ),
        const SizedBox(width: DesignTokens.spacing8),
        Text(_fmtDuration(track.durationMs),
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
  const _EmptyOrIdle({required this.state});

  final DuplicateScanState state;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color colour, String message) = switch (state.phase) {
      DuplicateScanPhase.idle => (
          Icons.file_copy_outlined,
          _secondary(context),
          'Scan your library to find duplicate tracks.',
        ),
      DuplicateScanPhase.scanning => (
          Icons.hourglass_empty_rounded,
          _secondary(context),
          'Scanning…',
        ),
      DuplicateScanPhase.failed => (
          Icons.error_outline_rounded,
          _kWarning,
          'The scan failed: ${state.error}',
        ),
      DuplicateScanPhase.done => state.groups.isEmpty
          ? (
              Icons.verified_rounded,
              _kSuccess,
              'No duplicates found — your library is clean.',
            )
          : (
              Icons.verified_rounded,
              _kSuccess,
              'All ${state.groups.length} groups resolved.',
            ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: colour),
            const SizedBox(height: DesignTokens.spacing16),
            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  DesignTokens.bodyLarge.copyWith(color: _secondary(context)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

String _formatBytes(int bytes) {
  if (bytes <= 0) return '0 MB';
  const mb = 1024 * 1024;
  if (bytes < mb) return '${(bytes / 1024).round()} KB';
  if (bytes < 1024 * mb) return '${(bytes / mb).toStringAsFixed(1)} MB';
  return '${(bytes / (1024 * mb)).toStringAsFixed(2)} GB';
}

Color _primary(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? DesignTokens.darkTextPrimary
        : DesignTokens.lightTextPrimary;

Color _secondary(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? DesignTokens.darkTextSecondary
        : DesignTokens.lightTextSecondary;
