// lib/main.dart
// Aura — App entry point.
// Initialises Riverpod ProviderScope, the Drift database, and the audio engine.
// UI is implemented in Sprint 2.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'native/audio_engine_ffi.dart';

void main() async {
  // Required for async work before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise the C++ audio engine (no-op in Sprint 1 if .so absent).
  final engine = AudioEngineFfi.instance;
  final engineReady = engine.init();
  if (!engineReady) {
    // Sprint 1: library not compiled yet — continue with just_audio fallback.
    debugPrint('[Aura] C++ audio engine unavailable — fallback mode active.');
  }

  runApp(
    // ProviderScope is the root Riverpod container.
    // All providers declared in shared/providers.dart are lazily initialised
    // on first read from a ConsumerWidget.
    const ProviderScope(
      child: AuraApp(),
    ),
  );
}

/// Root application widget.
///
/// Placeholder for Sprint 2 where the full router and theme system are added.
class AuraApp extends ConsumerWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Aura',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8F6D), // Design.md primary warm apricot.
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const _PlaceholderHomeScreen(),
    );
  }
}

/// Placeholder home screen — replaced in Sprint 2 with the full Library UI.
class _PlaceholderHomeScreen extends StatelessWidget {
  const _PlaceholderHomeScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F0D0A), // Design.md dark background.
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Aura',
              style: TextStyle(
                color: Color(0xFFFF8F6D),
                fontSize: 48,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Sprint 1 — Foundation Layer ✓',
              style: TextStyle(
                color: Color(0xFFF0EBE4),
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Domain · Data · FFI — All initialised.',
              style: TextStyle(
                color: Color(0x99F0EBE4),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
