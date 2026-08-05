// lib/main.dart
// Aura — App entry point.
// Initialises Riverpod ProviderScope, the Drift database, and the C++ audio engine FFI.
// Boots into SplashScreen with adaptive Material You / Liquid Glass theming.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'native/audio_engine_ffi.dart';
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

  runApp(
    const ProviderScope(
      child: AuraApp(),
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
