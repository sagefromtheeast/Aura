// lib/data/scanner/folder_scanner.dart
// Aura — Filesystem fallback scanner.
//
// Recursively walks user-selected folders for supported audio files. Used when
// the platform media library is unavailable (desktop, denied permission) or to
// index folders MediaStore/MPMediaQuery doesn't cover.
//
// Pure `dart:io` + `path` — safe to run inside a background isolate.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../core/constants.dart';
import 'raw_track.dart';

class FolderScanner {
  const FolderScanner({this.maxDepth = kMaxScanDepth});

  /// Recursion depth limit (0 = only files directly in the root).
  final int maxDepth;

  /// Walks every path in [roots] and returns the audio files found.
  ///
  /// Hidden files/folders (leading `.`) are skipped, as are unreadable
  /// directories. [onFound] fires as each file is discovered so callers can
  /// report progress before the walk completes.
  Future<List<RawTrack>> scan(
    List<String> roots, {
    void Function(int found)? onFound,
  }) async {
    final results = <RawTrack>[];
    final seen = <String>{};

    for (final root in roots) {
      final dir = Directory(root);
      if (!await dir.exists()) continue;
      await _walk(dir, 0, results, seen, onFound);
    }
    return results;
  }

  Future<void> _walk(
    Directory dir,
    int depth,
    List<RawTrack> out,
    Set<String> seen,
    void Function(int found)? onFound,
  ) async {
    if (depth > maxDepth) return;
    if (_isHidden(dir.path)) return;

    final List<FileSystemEntity> entries;
    try {
      entries = await dir.list(followLinks: false).toList();
    } on FileSystemException catch (e) {
      // Permission denied / vanished mid-scan — skip this branch.
      debugPrint('FolderScanner: skipping ${dir.path} ($e)');
      return;
    }

    for (final entity in entries) {
      if (_isHidden(entity.path)) continue;

      if (entity is Directory) {
        await _walk(entity, depth + 1, out, seen, onFound);
      } else if (entity is File) {
        final ext = p.extension(entity.path);
        if (ext.isEmpty) continue;
        if (!kSupportedAudioExtensions.contains(ext.substring(1).toLowerCase())) {
          continue;
        }
        if (!seen.add(entity.path)) continue;

        int? size;
        int? modifiedMs;
        try {
          final stat = await entity.stat();
          size = stat.size;
          modifiedMs = stat.modified.millisecondsSinceEpoch;
        } on FileSystemException {
          // Keep the file; stats are best-effort.
        }

        out.add(RawTrack(
          filePath: entity.path,
          sizeBytes: size,
          dateAddedMs: modifiedMs,
        ));
        onFound?.call(out.length);
      }
    }
  }

  static bool _isHidden(String path) => p.basename(path).startsWith('.');
}
