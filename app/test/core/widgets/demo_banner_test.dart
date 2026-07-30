import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/demo/demo_mode.dart';
import 'package:jantar_mantar_sahayata/core/widgets/demo_banner.dart';

import '../../support/l10n_harness.dart';

/// Demo Mode must announce itself on screen, not only in Profile (ADR-38).
///
/// Demo Mode defaults ON, and the hosted web build is public. Without this the
/// site shows fabricated relief camps, capacity counts and an admin queue that
/// look exactly like real reporting — and a screenshot of it carries no
/// warning at all.
void main() {
  Future<void> pump(WidgetTester tester, {required bool demo}) =>
      tester.pumpWidget(
        ProviderScope(
          overrides: [
            if (!demo) demoModeProvider.overrideWith(_DemoOff.new),
          ],
          child: MaterialApp(
            theme: testAppTheme(),
            localizationsDelegates: testLocalizationsDelegates,
            supportedLocales: testSupportedLocales,
            home: const Scaffold(body: DemoBanner()),
          ),
        ),
      );

  testWidgets('it says the data is not real while demo mode is on', (
    tester,
  ) async {
    await pump(tester, demo: true);
    expect(find.byType(DemoBanner), findsOneWidget);

    final text = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .join(' ')
        .toLowerCase();
    expect(
      text,
      contains('sample data'),
      reason: 'a banner that does not say the data is fake is decoration',
    );
    expect(
      text,
      contains('not real'),
      reason: 'state it plainly — this is a safety message, not a hint',
    );
  });

  testWidgets('never colour alone — it carries an icon and text', (
    tester,
  ) async {
    await pump(tester, demo: true);
    expect(find.byType(Icon), findsOneWidget);
    expect(find.byType(Text), findsWidgets);
  });

  testWidgets('a screen reader is told about it', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, demo: true);
    // liveRegion so it is announced rather than only found by exploration.
    expect(
      tester
          .widgetList<Semantics>(find.byType(Semantics))
          .any((s) => s.properties.liveRegion ?? false),
      isTrue,
    );
    handle.dispose();
  });

  testWidgets('and it disappears entirely once demo mode is off', (
    tester,
  ) async {
    await pump(tester, demo: false);
    // Real data must not carry a "this is fake" warning — crying wolf here
    // would train people to ignore the banner that matters.
    expect(find.byType(Text), findsNothing);
    expect(find.byType(Icon), findsNothing);
  });

  test('demo mode is still the default, so the banner is the safety net', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(
      container.read(demoModeProvider),
      isTrue,
      reason:
          'if this ever flips to false, revisit ADR-38 — the banner exists '
          'because the default is on',
    );
  });
}

class _DemoOff extends DemoModeNotifier {
  @override
  bool build() => false;
}
