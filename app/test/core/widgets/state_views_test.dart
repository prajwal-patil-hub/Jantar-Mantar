import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/theme/app_theme.dart';
import 'package:jantar_mantar_sahayata/core/widgets/state_views.dart';

/// Shared empty / loading / error views (ADR-33).
///
/// The one that matters is the error view: screens used to render `'$e'`
/// straight from a Postgres or socket failure. That tells a volunteer in a
/// field nothing and shows backend internals to anyone reading over their
/// shoulder.
void main() {
  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    bool stillness = false,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: stillness),
        child: Scaffold(body: child),
      ),
    ),
  );

  group('error', () {
    const raw =
        'PostgrestException(message: permission denied for table user_trust, '
        'code: 42501, details: , hint: null)';

    testWidgets('the raw exception is never the headline', (tester) async {
      await pump(
        tester,
        const ErrorStateView(
          message: 'Could not load this. You may be offline.',
          details: raw,
        ),
      );

      expect(find.text('Could not load this. You may be offline.'), findsOne);
      // Folded away behind a disclosure, not shouted at the user.
      expect(find.textContaining('permission denied'), findsNothing);
      expect(find.textContaining('42501'), findsNothing);
    });

    testWidgets('but a developer can still get at it', (tester) async {
      await pump(
        tester,
        const ErrorStateView(message: 'Could not load this.', details: raw),
      );
      await tester.tap(find.text('Technical details'));
      await tester.pumpAndSettle();

      expect(find.textContaining('permission denied'), findsOne);
    });

    testWidgets('offers a way out, not just an apology', (tester) async {
      var retried = 0;
      await pump(
        tester,
        ErrorStateView(
          message: 'Could not load this.',
          onRetry: () => retried++,
          retryLabel: 'Refresh',
        ),
      );
      await tester.tap(find.text('Refresh'));
      expect(retried, 1);
    });

    testWidgets('with no details there is nothing to expand', (tester) async {
      await pump(tester, const ErrorStateView(message: 'Could not load this.'));
      expect(find.text('Technical details'), findsNothing);
    });
  });

  group('empty', () {
    testWidgets('says what is empty and what to do', (tester) async {
      await pump(
        tester,
        EmptyStateView(
          icon: Icons.inbox_outlined,
          title: 'Queue is clear',
          body: 'Nothing is waiting for review right now.',
          action: FilledButton(onPressed: () {}, child: const Text('Refresh')),
        ),
      );

      expect(find.text('Queue is clear'), findsOne);
      expect(find.textContaining('Nothing is waiting'), findsOne);
      // Icon as well as text — a bare sentence in the middle of a screen
      // reads as a failure, not as a normal state.
      expect(find.byIcon(Icons.inbox_outlined), findsOne);
      expect(find.text('Refresh'), findsOne);
    });

    testWidgets('body and action are optional', (tester) async {
      await pump(
        tester,
        const EmptyStateView(icon: Icons.inbox_outlined, title: 'Nothing yet'),
      );
      expect(find.text('Nothing yet'), findsOne);
    });
  });

  group('loading', () {
    testWidgets('keeps the shape of what is coming', (tester) async {
      await pump(tester, const LoadingStateView(rows: 3));
      await tester.pump(const Duration(milliseconds: 400));

      // Three placeholder cards, not one spinner on a blank screen.
      expect(find.byType(Card), findsNWidgets(3));
      // No pumpAndSettle: the pulse repeats forever by design.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('announces itself to a screen reader', (tester) async {
      await pump(tester, const LoadingStateView(semanticLabel: 'Audit log'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(
        tester.getSemantics(find.byType(LoadingStateView)),
        matchesSemantics(label: 'Audit log', isLiveRegion: true),
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('holds still when animations are disabled', (tester) async {
      // Battery saver and reduced-motion both land here. A pulsing skeleton
      // is decoration; it must not override that choice.
      await pump(tester, const LoadingStateView(rows: 2), stillness: true);
      await tester.pump(const Duration(milliseconds: 300));
      final first = tester.widgetList<Opacity>(find.byType(Opacity)).first;
      await tester.pump(const Duration(milliseconds: 550));
      final later = tester.widgetList<Opacity>(find.byType(Opacity)).first;

      expect(later.opacity, first.opacity);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('cancels its stagger timer on dispose', (tester) async {
      // Regression: a bare Future.delayed here leaked a pending timer past
      // dispose and failed teardown in every test that mounted a loader.
      await pump(tester, const LoadingStateView(rows: 4));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
      // Reaching here without a "pending timers" failure is the assertion.
      expect(find.byType(LoadingStateView), findsNothing);
    });
  });
}
