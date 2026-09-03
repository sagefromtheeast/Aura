// lib/data/scanner/platform_media_scanner.dart
// Aura — Native media-library scanner.
//
// Android: MainActivity.kt queries MediaStore.Audio.Media.
// iOS:     AppDelegate.swift queries MPMediaQuery.songs().
// Both answer `scanAllAudio` on the `com.aura/file_scanner` channel with a
// List<Map> whose keys are parsed by [RawTrack.fromPlatformMap].

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/constants.dart';
import 'raw_track.dart';

class PlatformMediaScanner {
  const PlatformMediaScanner({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(kFileScannerChannel);

  final MethodChannel _channel;

  /// True on platforms where a native media library exists.
  static bool get isSupported =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  /// Queries the native media library.
  ///
  /// Returns an empty list (rather than throwing) when the platform has no
  /// handler registered or the user denied media-library permission, so the
  /// caller can fall back to folder scanning.
  Future<List<RawTrack>> scan() async {
    if (!isSupported) return const [];
    try {
      final raw =
          await _channel.invokeMethod<List<Object?>>(kScanAllAudioMethod);
      if (raw == null) return const [];
      return raw
          .whereType<Map<Object?, Object?>>()
          .map(RawTrack.fromPlatformMap)
          .where((t) => t.filePath.isNotEmpty && t.isSupported)
          .toList(growable: false);
    } on MissingPluginException catch (e) {
      debugPrint('PlatformMediaScanner: no native handler ($e)');
      return const [];
    } on PlatformException catch (e) {
      // e.g. UNAVAILABLE when MPMediaLibrary authorization was denied.
      debugPrint('PlatformMediaScanner: platform scan failed (${e.code})');
      return const [];
    }
  }
}
