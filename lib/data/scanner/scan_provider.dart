// lib/data/scanner/scan_provider.dart
// Aura — Scan orchestration for the UI.
//
// Collection + tag extraction run on a background isolate so the UI thread
// stays free (PRD §7). Database writes happen back on the root isolate, which
// keeps the single Drift connection on one thread.
//
// Progress is throttled to one update per [kScanProgressThrottle] (≥10/sec).

import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'
    show RootIsolateToken, BackgroundIsolateBinaryMessenger;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../database/database_provider.dart';
import 'library_scanner.dart';
import 'raw_track.dart';

enum ScanPhase { idle, collecting, writing, done, failed }

@immutable
class ScanState {
  const ScanState({
    this.phase = ScanPhase.idle,
    this.found = 0,
    this.total = 0,
    this.currentLabel,
    this.result,
    this.error,
  });

  final ScanPhase phase;

  /// Files discovered so far (collecting) or rows written (writing).
  final int found;

  /// Total to process; 0 while still discovering.
  final int total;

  /// e.g. the artist/album currently being written.
  final String? currentLabel;

  final ScanResult? result;
  final Object? error;

  bool get isRunning =>
      phase == ScanPhase.collecting || phase == ScanPhase.writing;

  /// 0..1 progress, or null while the total is still unknown.
  double? get progress =>
      total > 0 ? (found / total).clamp(0.0, 1.0) : null;

  ScanState copyWith({
    ScanPhase? phase,
    int? found,
    int? total,
    String? currentLabel,
    ScanResult? result,
    Object? error,
  }) {
    return ScanState(
      phase: phase ?? this.phase,
      found: found ?? this.found,
      total: total ?? this.total,
      currentLabel: currentLabel ?? this.currentLabel,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }
}

class ScanNotifier extends AsyncNotifier<ScanState> {
  DateTime _lastEmit = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  Future<ScanState> build() async => const ScanState();

  /// Emits at most one update per throttle window so 20k tracks don't cause
  /// 20k rebuilds. [force] bypasses throttling for phase transitions.
  void _emit(ScanState next, {bool force = false}) {
    final now = DateTime.now();
    if (!force && now.difference(_lastEmit) < kScanProgressThrottle) return;
    _lastEmit = now;
    state = AsyncData(next);
  }

  ScanState get _current => state.valueOrNull ?? const ScanState();

  /// Runs a full library scan.
  ///
  /// [extraFolders] are walked in addition to the native media library.
  /// Set [useIsolate] to false in tests (plugins are unavailable off the root
  /// isolate under `flutter_test`).
  Future<ScanResult> startScan({
    List<String> extraFolders = const [],
    bool useIsolate = true,
  }) async {
    if (_current.isRunning) return ScanResult.empty;

    final db = ref.read(appDatabaseProvider);
    final scanner = LibraryScanner(database: db);

    _emit(const ScanState(phase: ScanPhase.collecting), force: true);

    try {
      // ── 1+2: collect + extract tags (background isolate) ──────────────────
      final List<RawTrack> found;
      if (useIsolate && !kIsWeb) {
        found = await _collectInIsolate(extraFolders);
      } else {
        found = await scanner.collect(
          extraFolders: extraFolders,
          onFound: (n) => _emit(_current.copyWith(
            phase: ScanPhase.collecting,
            found: n,
          )),
        );
      }

      _emit(
        _current.copyWith(
          phase: ScanPhase.writing,
          found: 0,
          total: found.length,
        ),
        force: true,
      );

      // ── 3: database reconciliation (root isolate) ─────────────────────────
      final sw = Stopwatch()..start();
      final partial = await scanner.reconcile(
        found,
        onProgress: (processed, total) => _emit(_current.copyWith(
          phase: ScanPhase.writing,
          found: processed,
          total: total,
        )),
      );
      sw.stop();

      final result = ScanResult(
        tracksFound: partial.tracksFound,
        tracksAdded: partial.tracksAdded,
        tracksRemoved: partial.tracksRemoved,
        duplicatesFound: partial.duplicatesFound,
        scanDuration: sw.elapsed,
      );

      _emit(
        ScanState(
          phase: ScanPhase.done,
          found: result.tracksFound,
          total: result.tracksFound,
          result: result,
        ),
        force: true,
      );
      return result;
    } catch (e, st) {
      debugPrint('ScanNotifier: scan failed — $e');
      state = AsyncError(e, st);
      return ScanResult.empty;
    }
  }

  /// Runs collection on a worker isolate.
  ///
  /// [RootIsolateToken] + [BackgroundIsolateBinaryMessenger] let the worker
  /// call plugins (flutter_media_metadata, path_provider) off the main thread.
  /// Results cross the boundary as plain maps.
  Future<List<RawTrack>> _collectInIsolate(List<String> extraFolders) async {
    final token = RootIsolateToken.instance;
    if (token == null) {
      // No root isolate (unusual) — fall back to inline collection.
      return LibraryScanner(database: ref.read(appDatabaseProvider))
          .collect(extraFolders: extraFolders);
    }

    final maps = await Isolate.run<List<Map<String, Object?>>>(() async {
      // Lets the worker call plugins (metadata, path_provider) off-thread.
      BackgroundIsolateBinaryMessenger.ensureInitialized(token);
      final tracks =
          await LibraryScanner.collectOnly(extraFolders: extraFolders);
      return tracks.map((t) => t.toMap()).toList(growable: false);
    });

    return maps.map(RawTrack.fromPlatformMap).toList(growable: false);
  }
}

/// Scan state + controls for the UI.
final scanProvider =
    AsyncNotifierProvider<ScanNotifier, ScanState>(ScanNotifier.new);

/// Convenience: the scanner bound to the app database (non-isolate use).
final libraryScannerProvider = Provider<LibraryScanner>(
  (ref) => LibraryScanner(database: ref.watch(appDatabaseProvider)),
);
