// lib/data/duplicate_provider.dart
// Aura — Duplicate scanning for the UI.
//
// The scan runs on a background isolate: layer 2 is quadratic within each
// duration bucket and layer 3 decodes 30 seconds of every remaining file, so
// neither belongs on the UI thread.
//
// Drift connections are not portable across isolates, so the split is:
//   • root isolate — load the track list, and later apply resolutions;
//   • background   — the three detection layers, reporting progress by port.

import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../domain/duplicate_detector/duplicate_detector.dart';
import '../domain/entities/track.dart';
import '../native/audio_engine_ffi.dart';
import '../shared/providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

enum DuplicateScanPhase { idle, scanning, done, failed }

@immutable
class DuplicateScanState {
  const DuplicateScanState({
    this.phase = DuplicateScanPhase.idle,
    this.groups = const [],
    this.reviewedGroupKeys = const {},
    this.progress,
    this.error,
  });

  final DuplicateScanPhase phase;

  /// Groups found so far, best-quality copy first within each.
  final List<DuplicateGroup> groups;

  /// Keys of groups the user has already resolved or dismissed this session.
  final Set<String> reviewedGroupKeys;

  final DuplicateScanProgress? progress;
  final Object? error;

  bool get isScanning => phase == DuplicateScanPhase.scanning;

  /// Groups still awaiting a decision.
  List<DuplicateGroup> get unresolved => groups
      .where((g) => !reviewedGroupKeys.contains(groupKey(g)))
      .toList(growable: false);

  /// Total bytes recoverable across every unresolved group.
  int get reclaimableBytes =>
      unresolved.fold(0, (sum, g) => sum + g.reclaimableBytes);

  /// Stable identity for a group — the sorted track ids. Survives a rebuild,
  /// unlike the list index, which shifts as groups are resolved.
  static String groupKey(DuplicateGroup group) {
    final ids = group.tracks.map((t) => t.id).toList()..sort();
    return ids.join('|');
  }

  DuplicateScanState copyWith({
    DuplicateScanPhase? phase,
    List<DuplicateGroup>? groups,
    Set<String>? reviewedGroupKeys,
    DuplicateScanProgress? progress,
    bool clearProgress = false,
    Object? error,
    bool clearError = false,
  }) {
    return DuplicateScanState(
      phase: phase ?? this.phase,
      groups: groups ?? this.groups,
      reviewedGroupKeys: reviewedGroupKeys ?? this.reviewedGroupKeys,
      progress: clearProgress ? null : (progress ?? this.progress),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Isolate plumbing
// ─────────────────────────────────────────────────────────────────────────────

/// Everything the background isolate needs. Kept to plain, sendable values.
class _ScanRequest {
  const _ScanRequest({
    required this.reply,
    required this.tracks,
    required this.level,
    required this.fuzzyThreshold,
  });

  final SendPort reply;
  final List<Track> tracks;
  final DuplicateDetectionLevel level;
  final double fuzzyThreshold;
}

/// Background entry point. Sends [DuplicateScanProgress] messages as it goes,
/// then a `List<DuplicateGroup>` on success or the error on failure.
@pragma('vm:entry-point')
Future<void> _scanIsolate(_ScanRequest request) async {
  try {
    final scanner = DuplicateScanner(
      audioFingerprinter: _nativeFingerprinter,
      // The native comparator needs the engine; when it is missing the
      // detector's own Dart fallback is used instead.
      compareFingerprints: AudioEngineFfi.instance.fingerprintBitErrorRate,
    );

    final groups = await scanner.scan(
      request.tracks,
      level: request.level,
      fuzzyThreshold: request.fuzzyThreshold,
      onProgress: request.reply.send,
    );

    request.reply.send(groups);
  } catch (error, stack) {
    request.reply.send(RemoteError(error.toString(), stack.toString()));
  }
}

/// Fingerprints via the C++ engine, or returns null when it is unavailable —
/// in which case layer 3 simply finds nothing rather than failing the scan.
Future<List<int>?> _nativeFingerprinter(String filePath) async {
  final engine = AudioEngineFfi.instance;
  if (!engine.isAvailable) return null;
  return engine.getFingerprintValues(filePath);
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class DuplicateScanNotifier extends StateNotifier<DuplicateScanState> {
  DuplicateScanNotifier(this._ref) : super(const DuplicateScanState());

  final Ref _ref;
  Isolate? _isolate;
  ReceivePort? _port;

  /// Starts a scan, replacing any results from a previous run.
  Future<void> scan({
    DuplicateDetectionLevel level = DuplicateDetectionLevel.fuzzy,
    double fuzzyThreshold = kFuzzyDuplicateThreshold,
  }) async {
    if (state.isScanning) return;

    state = const DuplicateScanState(phase: DuplicateScanPhase.scanning);

    final List<Track> tracks;
    try {
      tracks = (await _ref.read(musicRepositoryProvider).getAllTracks())
          .where((t) => !t.isDeleted)
          .toList(growable: false);
    } catch (error) {
      state = state.copyWith(phase: DuplicateScanPhase.failed, error: error);
      return;
    }

    // Nothing to compare: report a clean library rather than spawning an
    // isolate to discover the same thing.
    if (tracks.length < 2) {
      state = const DuplicateScanState(phase: DuplicateScanPhase.done);
      return;
    }

    final completer = Completer<void>();
    final port = ReceivePort();
    _port = port;

    port.listen((message) {
      if (message is DuplicateScanProgress) {
        if (mounted) state = state.copyWith(progress: message);
        return;
      }
      if (message is List<DuplicateGroup>) {
        if (mounted) {
          state = state.copyWith(
            phase: DuplicateScanPhase.done,
            groups: message,
            clearProgress: true,
          );
        }
      } else {
        // Either our own RemoteError, or the [error, stackTrace] pair the VM
        // sends to `onError` when the isolate dies uncaught.
        if (mounted) {
          state = state.copyWith(
            phase: DuplicateScanPhase.failed,
            error: message is List && message.isNotEmpty
                ? message.first
                : message,
            clearProgress: true,
          );
        }
      }
      _teardown();
      if (!completer.isCompleted) completer.complete();
    });

    try {
      _isolate = await Isolate.spawn(
        _scanIsolate,
        _ScanRequest(
          reply: port.sendPort,
          tracks: tracks,
          level: level,
          fuzzyThreshold: fuzzyThreshold,
        ),
        onError: port.sendPort,
        errorsAreFatal: true,
        debugName: 'aura-duplicate-scan',
      );
    } catch (error) {
      _teardown();
      state = state.copyWith(phase: DuplicateScanPhase.failed, error: error);
      return;
    }

    return completer.future;
  }

  /// Applies [strategy] to [group] and marks it reviewed.
  ///
  /// Removal is a soft delete — the copies are hidden from the library and
  /// their listening history is kept, and nothing is unlinked from disk.
  Future<void> resolve(
    DuplicateGroup group,
    DuplicateResolutionStrategy strategy, {
    Track? keep,
  }) async {
    final keeper = keep ?? group.suggested;
    final detector = _ref.read(duplicateDetectorProvider);

    try {
      await detector.resolveDuplicate(
        keepTrackId: keeper.id,
        removeTrackIds: group.tracks
            .where((t) => t.id != keeper.id)
            .map((t) => t.id)
            .toList(growable: false),
        strategy: strategy,
      );
    } catch (error) {
      if (mounted) state = state.copyWith(error: error);
      return;
    }

    if (!mounted) return;
    state = state.copyWith(
      reviewedGroupKeys: {
        ...state.reviewedGroupKeys,
        DuplicateScanState.groupKey(group),
      },
    );
  }

  /// Applies [strategy] to every group still awaiting a decision.
  Future<void> resolveAll(DuplicateResolutionStrategy strategy) async {
    for (final group in state.unresolved) {
      await resolve(group, strategy);
    }
  }

  void _teardown() {
    _port?.close();
    _port = null;
    // Kill rather than wait: a scan's results are worthless once nobody is
    // listening, and layer 3 can otherwise keep decoding for minutes.
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
  }

  @override
  void dispose() {
    _teardown();
    super.dispose();
  }
}

final duplicateScanProvider =
    StateNotifierProvider<DuplicateScanNotifier, DuplicateScanState>(
  DuplicateScanNotifier.new,
);
