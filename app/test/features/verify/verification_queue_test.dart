import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
