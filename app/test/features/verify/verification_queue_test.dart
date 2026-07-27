import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/demo/demo_mode.dart';
import 'package:jantar_mantar_sahayata/features/verify/application/verify_providers.dart';
import 'package:jantar_mantar_sahayata/features/verify/presentation/audit_log_screen.dart';
import 'package:jantar_mantar_sahayata/features/verify/presentation/verification_queue_screen.dart';

import '../../support/l10n_harness.dart';

/// Admin queue (E5). Approving publishes to the public map, so the behaviours
/// worth pinning are the ones that stop the wrong thing being published:
/// batch mode is opt-in, it confirms with a count, and it hides the one-tap
/// per-card approve while it is on.
///
/// Runs in Demo Mode (the default), which serves the sample queue locally.
void main() {
  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: testLocalizationsDelegates,
          supportedLocales: testSupportedLocales,
          home: const VerificationQueueScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('per-card approve and reject are the default affordance', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('Approve'), findsWidgets);
    expect(find.text('Reject'), findsWidgets);
    expect(find.byType(Checkbox), findsNothing);
  });

  testWidgets('select mode hides per-card decisions and shows checkboxes', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.byIcon(Icons.checklist));
    await tester.pump();

    expect(find.byType(Checkbox), findsWidgets);
    // A single tap must not be able to publish while multi-select is on.
    expect(find.text('Reject'), findsNothing);
    expect(find.text('0 selected'), findsOneWidget);
  });

  testWidgets('batch approve confirms with a count before publishing', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.byIcon(Icons.checklist));
    await tester.pump();

    await tester.tap(find.byType(Checkbox).at(0));
    await tester.pump();
    await tester.tap(find.byType(Checkbox).at(1));
    await tester.pump();
    expect(find.text('2 selected'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.done_all));
    await tester.pump();
    expect(find.textContaining('Approve 2 submissions?'), findsOneWidget);

    // Dismissing the dialog must leave the queue untouched.
    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(find.text('2 selected'), findsOneWidget);
  });

  testWidgets('approving the selection clears them and reports the count', (
    tester,
  ) async {
    await pump(tester);
    // The first two sample submissions, identified by their notes — the card
    // count is unreliable because the list only builds what fits.
    expect(find.textContaining('New tanker'), findsOneWidget);
    expect(find.textContaining('Langar running low'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.checklist));
    await tester.pump();
    await tester.tap(find.byType(Checkbox).at(0));
    await tester.pump();
    await tester.tap(find.byType(Checkbox).at(1));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.done_all));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Approve'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('2 approved.'), findsOneWidget);
    expect(find.textContaining('New tanker'), findsNothing);
    expect(find.textContaining('Langar running low'), findsNothing);
    // Empty selection drops back out of select mode.
    expect(find.byType(Checkbox), findsNothing);
  });

  testWidgets('the approve-selected action is disabled with nothing picked', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.byIcon(Icons.checklist));
    await tester.pump();

    final button = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.done_all),
        matching: find.byType(IconButton),
      ),
    );
    expect(button.onPressed, isNull);
  });

  group('promoted verifier (ADR-25)', () {
    // Demo Mode simulates a full admin, so these run with it off and no
    // Supabase session: what is left is exactly the verifier's subset.
    Future<void> pumpAsVerifier(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            demoModeProvider.overrideWith(_DemoOff.new),
            pendingServerSubmissionsProvider(0).overrideWith(
              (ref) async => [
                {
                  'id': 'srv-update',
                  'facility_ref': '22222222-2222-2222-2222-222222222222',
                  'created_at': DateTime.now().toIso8601String(),
                  'payload': {
                    'category': 'water',
                    'status': 'low',
                    'mode': 'update',
                  },
                },
                {
                  'id': 'srv-new',
                  'facility_ref': null,
                  'created_at': DateTime.now().toIso8601String(),
                  'payload': {
                    'category': 'food',
                    'status': 'good',
                    'mode': 'new',
                  },
                },
              ],
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: testLocalizationsDelegates,
            supportedLocales: testSupportedLocales,
            home: const VerificationQueueScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
    }

    testWidgets('cannot reject, and is told why', (tester) async {
      await pumpAsVerifier(tester);
      final reject = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Reject').first,
      );
      expect(reject.onPressed, isNull);
      expect(find.textContaining('Rejecting is admin-only'), findsWidgets);
    });

    testWidgets('cannot approve a submission that would create a facility', (
      tester,
    ) async {
      await pumpAsVerifier(tester);
      final buttons = tester
          .widgetList<FilledButton>(
            find.widgetWithText(FilledButton, 'Approve'),
          )
          .toList();
      // First card updates a known facility; second would mint a new pin.
      expect(buttons[0].onPressed, isNotNull);
      expect(buttons[1].onPressed, isNull);
      expect(
        find.textContaining('new facility needs an admin'),
        findsOneWidget,
      );
    });

    testWidgets('gets neither the alert composer nor the audit log', (
      tester,
    ) async {
      await pumpAsVerifier(tester);
      expect(find.byIcon(Icons.campaign_outlined), findsNothing);
      expect(find.byIcon(Icons.history), findsNothing);
      // Batch mode is still available — it only ever approves.
      expect(find.byIcon(Icons.checklist), findsOneWidget);
    });

    testWidgets('cannot batch-select what it cannot approve', (tester) async {
      await pumpAsVerifier(tester);
      await tester.tap(find.byIcon(Icons.checklist));
      await tester.pump();

      final boxes = tester.widgetList<Checkbox>(find.byType(Checkbox)).toList();
      expect(boxes[0].onChanged, isNotNull);
      expect(boxes[1].onChanged, isNull);
    });
  });

  testWidgets('the audit log is reachable from the queue', (tester) async {
    await pump(tester);
    await tester.tap(find.byIcon(Icons.history));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(AuditLogScreen), findsOneWidget);
    expect(find.text('Approved a submission'), findsWidgets);
    expect(find.text('Rejected a submission'), findsOneWidget);
    // The append-only promise is stated in the UI, not just in the schema.
    expect(find.textContaining('cannot be edited or deleted'), findsOneWidget);
  });
}

/// Demo Mode grants a simulated admin view, so turning it off is how a test
/// reaches the ordinary (here: promoted verifier) path.
class _DemoOff extends DemoModeNotifier {
  @override
  bool build() => false;
}
