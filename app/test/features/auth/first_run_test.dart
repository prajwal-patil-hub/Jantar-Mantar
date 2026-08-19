import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/features/auth/application/auth_providers.dart';
import 'package:jantar_mantar_sahayata/features/auth/presentation/auth_choice_screen.dart';
import 'package:jantar_mantar_sahayata/features/auth/presentation/onboarding_screen.dart';

import '../../support/l10n_harness.dart';

class _FirstRun extends FirstRunNotifier {
  _FirstRun(this.done);

  final bool done;

  @override
  Future<bool> build() async => done;
}

void main() {
  Widget host(Widget child, {bool done = false}) => ProviderScope(
    overrides: [firstRunProvider.overrideWith(() => _FirstRun(done))],
    child: MaterialApp(
      theme: testAppTheme(),
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      home: child,
    ),
  );

  testWidgets('every onboarding slide can be skipped, not just the last', (
    tester,
  ) async {
    // The rule this pins: someone opening the app because they need water in
    // ten minutes must never be held inside an intro carousel.
    await tester.pumpWidget(host(OnboardingScreen(onDone: () {})));
    await tester.pumpAndSettle();

    expect(find.text('Skip'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    // Skipping lands on the sign-in choice, which is itself dismissible.
    expect(find.byType(AuthChoiceScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('anonymous is the primary action on the sign-in choice', (
    tester,
  ) async {
    var continued = false;
    await tester.pumpWidget(
      host(AuthChoiceScreen(onContinue: () => continued = true)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Continue anonymously'), findsOneWidget);
    expect(find.text('Verify with phone number'), findsOneWidget);

    // Anonymous is the FilledButton (primary); phone is the OutlinedButton.
    // Ranking is the ADR-4 position expressed in the layout, so it is worth
    // pinning rather than leaving to whoever next edits this screen.
    expect(
      find.descendant(
        of: find.byType(FilledButton),
        matching: find.text('Continue anonymously'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(OutlinedButton),
        matching: find.text('Verify with phone number'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Continue anonymously'));
    await tester.pumpAndSettle();
    expect(continued, isTrue, reason: 'anonymous must not require a network');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the trade-off sheet says SMS fails when it matters', (
    tester,
  ) async {
    await tester.pumpWidget(host(AuthChoiceScreen(onContinue: () {})));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Which should I choose?'));
    await tester.pumpAndSettle();

    // The one row that decides the choice for this app's users.
    expect(find.text('If SMS is blocked'), findsOneWidget);
    expect(find.text('Does not work'), findsOneWidget);
    expect(find.text('Still works'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
