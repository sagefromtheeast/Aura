// lib/ui/screens/widgets/widget_tutorial_screen.dart
// Aura — 4-step tutorial for adding a home-screen widget. Dark theme, glass
// cards, a progress bar, and a Done button on the final step.

import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';

class _Step {
  const _Step({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
}

const List<_Step> _kSteps = [
  _Step(
    icon: Icons.touch_app_rounded,
    title: 'Long-press on your Home Screen',
    body: 'Press and hold on an empty area until the icons start to jiggle.',
  ),
  _Step(
    icon: Icons.add_box_rounded,
    title: 'Tap the + button',
    body: 'It appears in the top corner — this opens the widget picker.',
  ),
  _Step(
    icon: Icons.search_rounded,
    title: 'Search for Aura',
    body: 'Type “Aura” to find all of Aura’s available home-screen widgets.',
  ),
  _Step(
    icon: Icons.widgets_rounded,
    title: 'Choose a widget and tap Add',
    body: 'Pick a size, then place it wherever you like. You’re all set!',
  ),
];

class WidgetTutorialScreen extends StatefulWidget {
  const WidgetTutorialScreen({super.key});

  @override
  State<WidgetTutorialScreen> createState() => _WidgetTutorialScreenState();
}

class _WidgetTutorialScreenState extends State<WidgetTutorialScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _index == _kSteps.length - 1;

  void _next() {
    if (_isLast) {
      Navigator.of(context).maybePop();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: DesignTokens.darkTextPrimary,
        title: const Text('Add a Widget'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Progress bar (4 steps).
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  for (int i = 0; i < _kSteps.length; i++)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: i <= _index
                              ? DesignTokens.primarySeed
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _kSteps.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => _StepCard(
                  step: _kSteps[i],
                  stepNumber: i + 1,
                  total: _kSteps.length,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spacing20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                    backgroundColor: DesignTokens.primarySeed,
                    foregroundColor: Colors.black,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(_isLast ? 'Done' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.stepNumber,
    required this.total,
  });

  final _Step step;
  final int stepNumber;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration in a glass card.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48),
            decoration: BoxDecoration(
              borderRadius: DesignTokens.radius32,
              color: DesignTokens.darkCardSurface,
              border: Border.all(color: DesignTokens.darkBorder),
            ),
            child: Column(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        DesignTokens.primarySeed.withValues(alpha: 0.35),
                        DesignTokens.accentSparkle.withValues(alpha: 0.20),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: DesignTokens.primarySeed.withValues(alpha: 0.35),
                        blurRadius: 40,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(step.icon,
                      size: 52, color: DesignTokens.primarySeed),
                ),
                const SizedBox(height: DesignTokens.spacing16),
                Text('STEP $stepNumber OF $total',
                    style: DesignTokens.labelMedium.copyWith(
                        color: DesignTokens.accentSparkle, letterSpacing: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spacing32),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: DesignTokens.headlineMedium
                .copyWith(color: DesignTokens.darkTextPrimary),
          ),
          const SizedBox(height: DesignTokens.spacing12),
          Text(
            step.body,
            textAlign: TextAlign.center,
            style: DesignTokens.bodyLarge
                .copyWith(color: DesignTokens.darkTextSecondary),
          ),
        ],
      ),
    );
  }
}
