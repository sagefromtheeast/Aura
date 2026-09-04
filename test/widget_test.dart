// test/widget_test.dart
// Aura — smoke test: the app boots into the splash screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura/main.dart';
import 'package:aura/ui/screens/onboarding/splash_screen.dart';

void main() {
  testWidgets('AuraApp boots into the splash screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AuraApp()));
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);

    // The wordmark is drawn rather than laid out as a Text widget, so the
    // tagline and the CTA are what identify this screen. The previous
    // assertion, find.text('Aura'), matched nothing.
    expect(find.text('Your music, more alive.'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Get Started'), findsOneWidget);

    // Deliberately no pumpAndSettle and no advance into onboarding: the splash
    // waits for that button rather than a timer, and its ambient float
    // animation loops forever, so settling would time out by design.
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
