import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/features/verify/application/verify_providers.dart';
import 'package:jantar_mantar_sahayata/features/verify/domain/trust_standing.dart';
import 'package:jantar_mantar_sahayata/features/verify/presentation/widgets/standing_card.dart';

import '../../support/l10n_harness.dart';

/// Trust standing (Phase 4, ADR-25). The parsing tests matter because the
/// thresholds arrive FROM the server — a client that quietly substituted its
/// own numbers would show a progress bar that does not match the rules the
/// user is actually judged by.
void main() {
  group('parsing', () {
    test('reads tier, counts and server thresholds', () {
      final standing = TrustStanding.fromJson(const {
        'tier': 'trusted',
        'approved': 12,
        'rejected': 1,
        'thresholds': {'trusted_approved': 5, 'verifier_approved': 20},
      });

      expect(standing.tier, TrustTier.trusted);
      expect(standing.approved, 12);
      expect(standing.verifierAt, 20);
      expect(standing.remaining, 8);
      expect(standing.progress, closeTo(0.6, 0.001));
    });

    test('an unknown tier reads as newcomer, never as a privileged one', () {
      // Postgres could gain a tier this build has never heard of; the safe
      // reading of an unrecognised value is the least privileged one.
      expect(
        TrustStanding.fromJson(const {'tier': 'superadmin'}).tier,
        TrustTier.newcomer,
      );
      expect(TrustStanding.fromJson(const {}).tier, TrustTier.newcomer);
    });

    test('numeric thresholds survive being sent as strings', () {
      final standing = TrustStanding.fromJson(const {
        'tier': 'new',
        'approved': '3',
        'thresholds': {'trusted_approved': '5'},
      });
      expect(standing.approved, 3);
      expect(standing.trustedAt, 5);
      expect(standing.remaining, 2);
    });

    test('a verifier is at the top and has nothing remaining', () {
      final standing = TrustStanding.fromJson(const {
        'tier': 'verifier',
        'approved': 40,
      });
      expect(standing.remaining, isNull);
      expect(standing.progress, 1);
    });

    test('progress never exceeds 1 when counts overshoot', () {
      const standing = TrustStanding(
        tier: TrustTier.trusted,
        approved: 99,
        rejected: 0,
        trustedAt: 5,
        verifierAt: 20,
      );
      expect(standing.progress, 1);
      expect(standing.remaining, 0);
    });
  });

  group('card', () {
    Future<void> pump(WidgetTester tester, TrustStanding standing) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            trustStandingProvider.overrideWith((ref) async => standing),
          ],
          child: MaterialApp(
            theme: testAppTheme(),
            localizationsDelegates: testLocalizationsDelegates,
            supportedLocales: testSupportedLocales,
            home: const Scaffold(body: StandingCard()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
    }

    testWidgets('names the tier in text, not by colour alone', (tester) async {
      await pump(tester, TrustStanding.unknown);
      expect(find.text('New reporter'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('a verifier is told what the role does NOT grant', (
      tester,
    ) async {
      await pump(
        tester,
        const TrustStanding(
          tier: TrustTier.verifier,
          approved: 25,
          rejected: 0,
          trustedAt: 5,
          verifierAt: 20,
        ),
      );
      expect(find.text('Verifier'), findsOneWidget);
      expect(
        find.textContaining('rejections and alerts stay with admins'),
        findsOneWidget,
      );
      expect(find.textContaining('Highest level reached'), findsOneWidget);
    });

    testWidgets('shows how many more approvals the next tier needs', (
      tester,
    ) async {
      await pump(
        tester,
        const TrustStanding(
          tier: TrustTier.trusted,
          approved: 12,
          rejected: 1,
          trustedAt: 5,
          verifierAt: 20,
        ),
      );
      expect(find.textContaining('12 approved · 1 rejected'), findsOneWidget);
      expect(find.textContaining('8 more approved reports'), findsOneWidget);
    });
  });
}
