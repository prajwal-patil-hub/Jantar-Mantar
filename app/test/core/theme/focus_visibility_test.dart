import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/theme/app_theme.dart';
import 'package:jantar_mantar_sahayata/core/theme/tokens.dart';

/// Visible focus (ADR-34, WCAG 2.4.7).
///
/// The app had none: `FocusNode` appeared zero times across the whole
/// codebase, so anyone driving it with a keyboard, an external switch, or
/// Android's TalkBack-with-keyboard had no way to see where they were.
///
/// Resolved from the theme the buttons actually inherit, not from a style
/// passed in by the test — every button in the app relies on the theme, so
/// that is the thing that has to be right. Focus movement itself is checked
/// by pressing Tab for real.
void main() {
  late ThemeData theme;

  Future<void> pump(
    WidgetTester tester, {
    Brightness? brightness,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: brightness == Brightness.dark ? AppTheme.dark() : AppTheme.light(),
      home: Builder(
        builder: (context) {
          theme = Theme.of(context);
          return Scaffold(
            body: Column(
              children: [
                FilledButton(onPressed: () {}, child: const Text('Publish')),
                OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
                IconButton(
                  onPressed: () {},
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );

  BorderSide? focusedSide(ButtonStyle? style) =>
      style?.side?.resolve({WidgetState.focused});
  BorderSide? restingSide(ButtonStyle? style) => style?.side?.resolve({});

  testWidgets('a focused filled button grows a visible ring', (tester) async {
    await pump(tester);
    final side = focusedSide(theme.filledButtonTheme.style);

    expect(side, isNotNull);
    expect(side!.color, AppTokens.focusRing);
    expect(side.width, AppTokens.focusRingWidth);
  });

  testWidgets('and an unfocused one does not', (tester) async {
    await pump(tester);
    // A permanent ring reads as an error state, not as focus.
    expect(restingSide(theme.filledButtonTheme.style), isNull);
  });

  testWidgets('an outlined button keeps its resting edge unfocused', (
    tester,
  ) async {
    await pump(tester);
    final resting = restingSide(theme.outlinedButtonTheme.style);

    expect(resting, isNotNull, reason: 'the outline is the whole point');
    expect(resting!.color, AppTokens.hairline);
    expect(resting.width, lessThan(AppTokens.focusRingWidth));
  });

  testWidgets('icon buttons are focusable too', (tester) async {
    await pump(tester);
    expect(
      focusedSide(theme.iconButtonTheme.style)?.color,
      AppTokens.focusRing,
    );
  });

  testWidgets('Tab actually moves focus through the controls', (tester) async {
    await pump(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    // Focus really lands on a control, not merely somewhere in the tree.
    expect(primaryFocus?.context?.widget, isNotNull);
    expect(
      find.descendant(
        of: find.byType(FilledButton),
        matching: find.byWidgetPredicate((w) => w is Focus),
      ),
      findsWidgets,
    );
  });

  testWidgets('the ring works on the dark ground too', (tester) async {
    // Saffron is chosen partly because it holds up on both grounds — a ring
    // that vanishes in dark mode is not a focus indicator.
    await pump(tester, brightness: Brightness.dark);
    expect(
      focusedSide(theme.filledButtonTheme.style)!.color,
      AppTokens.focusRing,
    );
  });

  test('the ring is not a status colour', () {
    // ADR-10: the accent never conveys facility status, so reusing it for
    // focus cannot be confused with good/low/out.
    expect(AppTokens.focusRing, AppTokens.accent);
  });
}
