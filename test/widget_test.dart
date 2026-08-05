// This is a basic Flutter widget test for Aura Music Player.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/main.dart';

void main() {
  testWidgets('AuraApp smoke test with splash screen transition', (WidgetTester tester) async {
    // Build our app and trigger an initial frame showing SplashScreen.
    await tester.pumpWidget(const ProviderScope(child: AuraApp()));
    await tester.pump();

    // Verify that Aura title text is shown on the splash screen.
    expect(find.text('Aura'), findsOneWidget);

    // Advance time past the splash timer (2600ms) and onboarding fade transition (600ms)
    await tester.pumpAndSettle(const Duration(seconds: 4));
  });
}
