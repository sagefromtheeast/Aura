// lib/data/scanner/album_art_cache.dart
// Aura — Album art cache.
//
// Artwork extracted during a scan is written once to
//   [app_support]/art_cache/<albumId>.jpg
// and referenced by path from the DB (albums.coverArtPath / tracks.coverArtPath).
// A small LRU keeps recently-read bytes in memory for list scrolling.
//
// When a track has no embedded art we do NOT synthesise an image file; instead
// [placeholderColor] returns a deterministic colour the UI paints as a gradient
// tile. Once real art exists, [dominantColor] runs palette_generator over it so
// the player can tint itself to the cover.

import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
// Brings in Color, HSLColor and FileImage without pulling in the widget layer.
import 'package:flutter/painting.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/constants.dart';

class AlbumArtCache {
  AlbumArtCache({int maxMemoryEntries = 64})
      : _maxMemoryEntries = maxMemoryEntries;

  final int _maxMemoryEntries;

  /// Insertion-ordered LRU: re-reading moves the key to the end.
  final LinkedHashMap<String, Uint8List> _memory =
      LinkedHashMap<String, Uint8List>();

  Directory? _dir;

  /// Resolves (and creates on first use) the on-disk cache directory.
  Future<Directory> _cacheDir() async {
    final existing = _dir;
    if (existing != null) return existing;
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, kArtCacheDirName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return _dir = dir;
  }

  String _fileName(String albumId) => '$albumId.jpg';

  /// Absolute path artwork for [albumId] would occupy (may not exist).
  Future<String> pathFor(String albumId) async =>
      p.join((await _cacheDir()).path, _fileName(albumId));

  /// Returns the cached art path for [albumId], or null when absent.
  Future<String?> lookup(String albumId) async {
    final path = await pathFor(albumId);
    return await File(path).exists() ? path : null;
  }

  /// Writes [bytes] as the artwork for [albumId] and returns its path.
  /// Existing art is kept (first write wins) unless [overwrite] is set.
  Future<String?> store(
    String albumId,
    Uint8List bytes, {
    bool overwrite = false,
  }) async {
    if (bytes.isEmpty) return null;
    try {
      final path = await pathFor(albumId);
      final file = File(path);
      if (overwrite || !await file.exists()) {
        await file.writeAsBytes(bytes, flush: false);
      }
      _remember(albumId, bytes);
      return path;
    } on FileSystemException catch (e) {
      debugPrint('AlbumArtCache: write failed for $albumId ($e)');
      return null;
    }
  }

  /// Reads artwork bytes, preferring the in-memory LRU.
  Future<Uint8List?> readBytes(String albumId) async {
    final cached = _memory.remove(albumId);
    if (cached != null) {
      _memory[albumId] = cached; // move to most-recent
      return cached;
    }
    final path = await lookup(albumId);
    if (path == null) return null;
    try {
      final bytes = await File(path).readAsBytes();
      _remember(albumId, bytes);
      return bytes;
    } on FileSystemException {
      return null;
    }
  }

  void _remember(String albumId, Uint8List bytes) {
    _memory.remove(albumId);
    _memory[albumId] = bytes;
    while (_memory.length > _maxMemoryEntries) {
      _memory.remove(_memory.keys.first); // evict least-recently-used
    }
  }

  /// Deterministic placeholder colour for albums with no artwork.
  /// Stable across runs so a given album always looks the same.
  static Color placeholderColor(String seed) {
    final hash =
        seed.codeUnits.fold<int>(17, (acc, c) => (acc * 31 + c) & 0x7fffffff);
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1, hue, 0.45, 0.45).toColor();
  }

  /// Dominant/vibrant colour of cached artwork, for dynamic theming.
  /// Falls back to [placeholderColor] when art is missing or undecodable.
  Future<Color> dominantColor(String albumId) async {
    final path = await lookup(albumId);
    if (path == null) return placeholderColor(albumId);
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        FileImage(File(path)),
        maximumColorCount: 16,
      );
      return palette.vibrantColor?.color ??
          palette.dominantColor?.color ??
          placeholderColor(albumId);
    } catch (e) {
      debugPrint('AlbumArtCache: palette failed for $albumId ($e)');
      return placeholderColor(albumId);
    }
  }

  /// Removes every cached file. Used by "clear cache" in Settings.
  Future<void> clear() async {
    _memory.clear();
    final dir = await _cacheDir();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      _dir = null;
    }
  }
}
