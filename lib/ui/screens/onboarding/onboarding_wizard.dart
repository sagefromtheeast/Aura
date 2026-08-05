import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../shared/providers.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';
import '../home/main_scaffold.dart';

/// Comprehensive 4-step Onboarding Wizard for Aura:
/// 1. Permission Pre-prompt (privacy-first explanation of offline storage access)
/// 2. Vibe Selection (Casual, Power User, Audiophile DSP Mode)
/// 3. Library Scanning Animation (connecting to MusicRepository.scanLibrary stream)
/// 4. Completion Celebration (featuring spring curve micro-interactions and transition to app)
class OnboardingWizard extends ConsumerStatefulWidget {
  const OnboardingWizard({super.key});

  @override
  ConsumerState<OnboardingWizard> createState() => _OnboardingWizardState();
}

class _OnboardingWizardState extends ConsumerState<OnboardingWizard>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  String _selectedVibe = 'Audiophile';
  int _discoveredTracks = 0;
  StreamSubscription<int>? _scanSub;

  // Spring animation controller for completion celebration and interactive cards
  late AnimationController _springController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _springController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scanSub?.cancel();
    _springController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      if (_currentStep == 2) {
        _startLibraryScan();
      } else if (_currentStep == 3) {
        _springController.forward(from: 0.0);
      }
    }
  }

  Future<void> _requestPermissionsAndContinue() async {
    // Proactively prompt for audio / media storage permissions without network flags
    try {
      if (await Permission.audio.isDenied || await Permission.storage.isDenied) {
        await [Permission.audio, Permission.storage].request();
      }
    } catch (_) {
      // Graceful fallback for simulator environments or testing harnesses
    }
    _nextStep();
  }

  void _startLibraryScan() {
    final musicRepo = ref.read(musicRepositoryProvider);
    _scanSub = musicRepo.scanLibrary().listen(
      (count) {
        setState(() => _discoveredTracks = count);
      },
      onDone: () {
        // Upon scanning completion, automatically advance to celebratory screen
        Future.delayed(const Duration(milliseconds: 800), _nextStep);
      },
      onError: (_) {
        // Fallback transition on simulation error
        Future.delayed(const Duration(milliseconds: 800), _nextStep);
      },
    );
  }

  void _launchApp() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => const MainScaffold(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacing24),
          child: Column(
            children: [
              // Wizard progress header
              LinearProgressIndicator(
                value: (_currentStep + 1) / 4.0,
                borderRadius: DesignTokens.radiusPill,
                backgroundColor: Theme.of(context).dividerColor,
                valueColor: const AlwaysStoppedAnimation<Color>(DesignTokens.primarySeed),
              ),
              const SizedBox(height: DesignTokens.spacing32),
              // Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildPermissionScreen(),
                    _buildVibeSelectionScreen(),
                    _buildScanningScreen(),
                    _buildCelebrationScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 1: Permission Pre-Prompt ──────────────────────────────────────────
  Widget _buildPermissionScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.shield_outlined, size: 80, color: DesignTokens.primarySeed),
        const SizedBox(height: DesignTokens.spacing24),
        Text(
          '100% Offline & Private',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DesignTokens.spacing16),
        Text(
          'Aura is engineered as an isolated digital enclave. We never connect to internet servers, stream telemetry, or expose your listening patterns.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DesignTokens.spacing24),
        GlassCard(
          child: Row(
            children: [
              const Icon(Icons.folder_open_rounded, color: DesignTokens.primarySeed),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Local Audio & Storage', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                    Text('Required solely to index your local hi-res lossless music files.', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacing16),
            backgroundColor: DesignTokens.primarySeed,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: DesignTokens.radius16),
          ),
          onPressed: _requestPermissionsAndContinue,
          child: const Text('Grant Access & Continue', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      ],
    );
  }

  // ── Step 2: Vibe Selection ────────────────────────────────────────────────
  Widget _buildVibeSelectionScreen() {
    final vibes = [
      ('Casual', 'Simple layouts with AI playlists & mood mixes.'),
      ('Power User', 'Metadata editing, custom smart rules, and stats.'),
      ('Audiophile', 'Parametric 10-band DSP equalizer, DSD/FLAC details.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Choose Your Vibe',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: DesignTokens.spacing8),
        Text(
          'Customize how Aura orchestrates your interface and audio engine.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: DesignTokens.spacing24),
        Expanded(
          child: ListView(
            children: vibes.map((vibe) {
              final isSelected = _selectedVibe == vibe.$1;
              return Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.spacing16),
                child: GlassCard(
                  onTap: () {
                    setState(() => _selectedVibe = vibe.$1);
                  },
                  borderColor: isSelected ? DesignTokens.primarySeed : null,
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                        color: isSelected ? DesignTokens.primarySeed : Theme.of(context).dividerColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(vibe.$1, style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 4),
                            Text(vibe.$2, style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacing16),
            backgroundColor: DesignTokens.primarySeed,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: DesignTokens.radius16),
          ),
          onPressed: _nextStep,
          child: const Text('Confirm & Scan Library', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      ],
    );
  }

  // ── Step 3: Library Scanning Animation ─────────────────────────────────────
  Widget _buildScanningScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            strokeWidth: 6,
            valueColor: AlwaysStoppedAnimation<Color>(DesignTokens.primarySeed),
          ),
        ),
        const SizedBox(height: DesignTokens.spacing32),
        Text(
          'Indexing Audio Files...',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: DesignTokens.spacing12),
        Text(
          'Discovered $_discoveredTracks tracks so far. Initializing offline acoustic signatures and Smart Mix clusters.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Step 4: Completion Celebration ─────────────────────────────────────────
  Widget _buildCelebrationScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        ScaleTransition(
          scale: _scaleAnimation,
          child: const Icon(
            Icons.celebration_rounded,
            size: 100,
            color: DesignTokens.accentSparkle,
          ),
        ),
        const SizedBox(height: DesignTokens.spacing24),
        Text(
          'Your Enclave is Ready!',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DesignTokens.spacing16),
        Text(
          'Your offline library has been mapped, clustered, and optimized for peak fidelity.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacing16),
            backgroundColor: DesignTokens.primarySeed,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: DesignTokens.radius16),
          ),
          onPressed: _launchApp,
          child: const Text('Launch Aura', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      ],
    );
  }
}
