// lib/main.dart
// Aura — App entry point.
// Initialises Riverpod ProviderScope, the Drift database, and the C++ audio engine FFI.
// Boots into SplashScreen with adaptive Material You / Liquid Glass theming.

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:audio_service/audio_service.dart';

import 'domain/smart_mix/mix_scheduler.dart';
import 'native/audio_engine_ffi.dart';
import 'services/media_session_handler.dart';
import 'shared/providers.dart';
import 'ui/screens/onboarding/splash_screen.dart';
import 'ui/theme/dynamic_theme_provider.dart';

void main() async {
  // Required for async work before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise the C++ audio engine (no-op in fallback if .so/.dylib absent).
  final engine = AudioEngineFfi.instance;
  final engineReady = engine.init();
  if (!engineReady) {
    debugPrint('[Aura] C++ audio engine unavailable — fallback mode active.');
  }

  // A container shared with the widget tree, so background regeneration and
  // the UI resolve the same repositories and database.
  final container = ProviderContainer();

  // Background Daily Mix regeneration. The callback is registered before
  // scheduling so a wake can never arrive with nothing to run.
  setMixRegenerationCallback(() async {
    await container.read(smartMixGeneratorProvider).regenerateStaleMixes();
  });
  await const MixScheduler().initialize(isInDebugMode: kDebugMode);

  // Media session: lock-screen / notification / Bluetooth / Android Auto
  // controls. Best-effort — a missing platform manifest entry must not stop
  // the app booting, so failures here are swallowed.
  try {
    await AudioService.init(
      builder: () =>
          AuraAudioHandler(container.read(playbackOrchestratorProvider)),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.aura.playback',
        androidNotificationChannelName: 'Aura playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
  } catch (error) {
    debugPrint('[Aura] Media session unavailable: $error');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AuraApp(),
    ),
  );
}

/// Root application widget featuring adaptive theming and SplashScreen bootstrapper.
class AuraApp extends ConsumerWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(dynamicThemeProvider);

    return MaterialApp(
      title: 'Aura Music',
      debugShowCheckedModeBanner: false,
      themeMode: themeState.mode,
      theme: AdaptiveThemeBuilder.buildLightTheme(themeState.accentColor, null),
      darkTheme: AdaptiveThemeBuilder.buildDarkTheme(themeState.accentColor, null),
      home: const SplashScreen(),
    );
  }
}
