// lib/ui/screens/widgets/widget_gallery_screen.dart
// Aura — Widget gallery. Browse home-screen widgets and open the customization
// sheet to add one.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/widget_service.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';
import 'widget_customization_sheet.dart';
import 'widget_previews.dart';
import 'widget_tutorial_screen.dart';

class WidgetGalleryScreen extends ConsumerWidget {
  const WidgetGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 0, 32),
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Widgets',
                      style: DesignTokens.displayLarge.copyWith(
                          fontSize: 28, color: _primary(context))),
                  const SizedBox(height: DesignTokens.spacing4),
                  Text('Bring your music to your Home Screen.',
                      style: DesignTokens.bodyLarge
                          .copyWith(color: _secondary(context))),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.spacing24),

            // Horizontally scrollable gallery of preview cards.
            SizedBox(
              height: 296,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 16),
                itemCount: HomeWidgetType.values.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: DesignTokens.spacing16),
                itemBuilder: (context, i) => _WidgetCard(
                  type: HomeWidgetType.values[i],
                  onAdd: () => WidgetCustomizationSheet.show(
                      context, HomeWidgetType.values[i]),
                ),
              ),
            ),

            const SizedBox(height: DesignTokens.spacing24),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GlassCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const WidgetTutorialScreen(),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(DesignTokens.spacing12),
                      decoration: BoxDecoration(
                        color:
                            DesignTokens.accentSparkle.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.help_outline_rounded,
                          color: DesignTokens.accentSparkle, size: 24),
                    ),
                    const SizedBox(width: DesignTokens.spacing16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('How to add widgets',
                              style: DesignTokens.titleLarge
                                  .copyWith(color: _primary(context))),
                          const SizedBox(height: DesignTokens.spacing4),
                          Text('A quick 4-step walkthrough.',
                              style: DesignTokens.bodyMedium
                                  .copyWith(color: _secondary(context))),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 16, color: _secondary(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WidgetCard extends StatelessWidget {
  const _WidgetCard({required this.type, required this.onAdd});

  final HomeWidgetType type;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Home-screen preview (280×200) — frosted frame over faux wallpaper.
          ClipRRect(
            borderRadius: DesignTokens.radius24,
            child: SizedBox(
              width: 280,
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  WallpaperBackdrop(seed: type.index),
                  Padding(
                    padding: const EdgeInsets.all(DesignTokens.spacing20),
                    child: Center(
                      child: WidgetPreview(type: type),
                    ),
                  ),
                  if (type.iosOnly)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _Badge(text: 'iOS only'),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spacing12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type.label,
                        style: DesignTokens.titleLarge
                            .copyWith(fontSize: 16, color: _primary(context))),
                    Text('${type.size} widget',
                        style: DesignTokens.caption
                            .copyWith(color: _secondary(context))),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onAdd,
                style: FilledButton.styleFrom(
                  backgroundColor:
                      DesignTokens.primarySeed.withValues(alpha: 0.18),
                  foregroundColor: DesignTokens.primarySeed,
                  shape: const StadiumBorder(),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Widget'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: DesignTokens.radiusPill,
      ),
      child: Text(text,
          style: const TextStyle(color: Colors.white, fontSize: 10)),
    );
  }
}

Color _primary(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? DesignTokens.darkTextPrimary
        : DesignTokens.lightTextPrimary;

Color _secondary(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? DesignTokens.darkTextSecondary
        : DesignTokens.lightTextSecondary;
