import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/features/auth/application/auth_providers.dart';
import 'package:jantar_mantar_sahayata/features/auth/presentation/auth_choice_screen.dart';
import 'package:jantar_mantar_sahayata/features/auth/presentation/first_run_gate.dart';
import 'package:jantar_mantar_sahayata/features/auth/presentation/onboarding_screen.dart';
import 'package:jantar_mantar_sahayata/features/shell/home_shell.dart';

import '../../support/l10n_harness.dart';

class _FreshInstall extends FirstRunNotifier {
  @override
  Future<bool> build() async => false;

  // The real one writes to SharedPreferences, which has no binding here. The
  // state change is the part under test.
  @override
  Future<void> complete() async => state = const AsyncValue.data(true);
}

/// End-to-end through the REAL [FirstRunGate], not the leaf screens.
///
/// The bug these exist for: the first version wired onboarding to the auth
/// screen with `pushReplacement`. FirstRunGate is `MaterialApp.home`, so it IS
/// the root route's widget — replacing that route unmounted the gate, and the
/// `onDone` callback it had handed down then bailed on its own
/// `context.mounted` check. "Continue anonymously" did nothing at all.
///
/// Every earlier test passed because they mounted `AuthChoiceScreen` directly
/// with a local callback, so the navigation wiring was never exercised. A
/// screen that works in isolation and is dead in the app is exactly what an
/// integration test is for.
void main() {
  Widget app() => ProviderScope(
    overrides: [firstRunProvider.overrideWith(_FreshInstall.new)],
    child: MaterialApp(
      theme: testAppTheme(),
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      home: const FirstRunGate(),
    ),
  );

  testWidgets('Continue anonymously reaches the app', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.byType(AuthChoiceScreen), findsOneWidget);

    await tester.tap(find.text('Continue anonymously'));
    await tester.pumpAndSettle();

    expect(
      find.byType(HomeShell),
      findsOneWidget,
      reason: 'the button must actually land on the app',
    );
    expect(
      find.byType(AuthChoiceScreen),
      findsNothing,
      reason: 'the sign-in screen must not still be on top of it',
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('the intro is not reachable with the back button afterwards', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue anonymously'));
    await tester.pumpAndSettle();

    // Nothing left to pop: the app is the only route on the stack.
    final popped = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
      popped,
      isFalse,
      reason: 'a back press here should leave the app, not reopen onboarding',
    );
    expect(find.byType(OnboardingScreen), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('walking all three slides also reaches the app', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    // Next, Next, then Get started — the path that does not use Skip.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthChoiceScreen), findsOneWidget);
    await tester.tap(find.text('Continue anonymously'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeShell), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
