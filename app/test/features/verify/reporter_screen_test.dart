import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/features/verify/application/verify_providers.dart';
import 'package:jantar_mantar_sahayata/features/verify/presentation/reporter_screen.dart';
import 'package:jantar_mantar_sahayata/features/verify/presentation/verification_queue_screen.dart';

import '../../support/l10n_harness.dart';

/// Moderator view of one reporter (ADR-27). Revoking a verifier is the
/// manual brake on automatic promotion, so the UI behaviours worth pinning
/// are that it demands a reason and that a held account offers restore
/// instead of a second revoke.
void main() {
  Future<void> pump(
    WidgetTester tester, {
    required Map<String, Object?> record,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reporterHistoryProvider((
            userId: 'u1',
            tick: 0,
          )).overrideWith((ref) async => record),
        ],
        child: MaterialApp(
          localizationsDelegates: testLocalizationsDelegates,
          supportedLocales: testSupportedLocales,
          home: const ReporterScreen(userId: 'u1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  const active = <String, Object?>{
    'tier': 'verifier',
    'held': false,
    'approved': 24,
    'rejected': 2,
    'recent': [
      {
        'id': 's1',
        'state': 'approved',
        'category': 'water',
        'status': 'good',
        'created_at': '2026-07-28T10:00:00Z',
      },
      {
        'id': 's2',
        'state': 'rejected',
        'reason': 'Duplicate',
        'category': 'food',
        'status': 'low',
        'created_at': '2026-07-28T09:00:00Z',
      },
    ],
  };

  testWidgets('shows the standing, the counts and the recent record', (
    tester,
  ) async {
    await pump(tester, record: active);
    expect(find.text('Verifier'), findsOneWidget);
    expect(find.textContaining('24 approved · 2 rejected'), findsOneWidget);
    // Outcomes are icon + text, never colour alone.
    expect(find.text('Approved a submission'), findsOneWidget);
    expect(find.textContaining('Duplicate'), findsOneWidget);
  });

  testWidgets('revoking demands a reason before it will submit', (
    tester,
  ) async {
    await pump(tester, record: active);
    await tester.tap(find.widgetWithText(FilledButton, 'Revoke verifier'));
    await tester.pump();

    // The dialog explains that the hold outlasts further approvals.
    expect(find.textContaining('will not promote it again'), findsOneWidget);

    // Confirming with an empty reason must do nothing — the server requires
    // one too, so this only avoids a round trip that fails.
    await tester.tap(find.widgetWithText(FilledButton, 'Revoke verifier').last);
    await tester.pump();
    expect(find.text('Standing revoked and held.'), findsNothing);
  });

  testWidgets('a held account offers restore, not another revoke', (
    tester,
  ) async {
    await pump(
      tester,
      record: const {
        'tier': 'new',
        'held': true,
        'hold_reason': 'infiltration report',
        'approved': 24,
        'rejected': 2,
        'recent': <Map<String, Object?>>[],
      },
    );

    expect(find.text('Standing held by an admin'), findsOneWidget);
    // The reason is shown, not just the fact — a hold without a stated
    // reason is unreviewable.
    expect(find.text('infiltration report'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Restore standing'), findsWidgets);
    expect(find.widgetWithText(FilledButton, 'Revoke verifier'), findsNothing);
    expect(find.text('No reports yet.'), findsOneWidget);
  });

  testWidgets(
    'restoring says it recomputes rather than handing the badge back',
    (tester) async {
      await pump(
        tester,
        record: const {
          'tier': 'new',
          'held': true,
          'approved': 24,
          'rejected': 2,
          'recent': <Map<String, Object?>>[],
        },
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Restore standing'));
      await tester.pump();
      expect(
        find.textContaining('does not hand back the old level'),
        findsOneWidget,
      );
    },
  );

  testWidgets('the queue links to the submitter for an admin', (tester) async {
    // Demo Mode (the default) simulates a full admin.
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

    await tester.tap(find.byIcon(Icons.person_search_outlined).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ReporterScreen), findsOneWidget);
  });
}
