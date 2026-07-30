import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/db/app_database.dart';
import 'package:jantar_mantar_sahayata/core/map/tile_providers.dart';
import 'package:jantar_mantar_sahayata/core/providers.dart';
import 'package:jantar_mantar_sahayata/core/theme/app_theme.dart';
import 'package:jantar_mantar_sahayata/features/alerts/presentation/alerts_screen.dart';
import 'package:jantar_mantar_sahayata/features/events/presentation/events_screen.dart';
import 'package:jantar_mantar_sahayata/features/groups/presentation/groups_screen.dart';
import 'package:jantar_mantar_sahayata/features/profile/presentation/profile_screen.dart';
import 'package:jantar_mantar_sahayata/features/routes/presentation/report_route_screen.dart';
import 'package:jantar_mantar_sahayata/features/sos/presentation/sos_screen.dart';
import 'package:jantar_mantar_sahayata/features/verify/presentation/audit_log_screen.dart';
import 'package:jantar_mantar_sahayata/features/verify/presentation/verification_queue_screen.dart';

import '../../support/l10n_harness.dart';
import '../../support/stub_tile_provider.dart';

/// Automates the half of the accessibility audit that a machine can check
/// (ADR-34), the same way ADR-23 automated the colour half.
///
/// Flutter ships three real guideline matchers and this project was not
/// running any of them:
///  · `androidTapTargetGuideline` — every tappable ≥ 48×48
///  · `labeledTapTargetGuideline` — every tappable has a label a screen
///    reader can announce
///  · `textContrastGuideline` — rendered text against what is behind it
///
/// The third is the interesting one: the colour test measures swatches in
/// isolation, this measures what a pixel actually ends up being after theme,
/// opacity and stacking. They catch different bugs.
///
/// Still manual, and still on the board: TalkBack/VoiceOver traversal order
/// on real OEM devices (`docs/accessibility-audit.md`). A label existing is
/// not the same as a sensible reading order.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Future<void> pump(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          mapTileProviderProvider.overrideWith((ref) => StubTileProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: testLocalizationsDelegates,
          supportedLocales: testSupportedLocales,
          // Wrapped in a Scaffold because that is how these render in
          // reality (HomeShell provides one). Without it nothing paints a
          // background and the contrast guideline measures text against
          // whatever is underneath, which is a test artefact, not a bug.
          home: Scaffold(body: screen),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 120));
  }

  final screens = <String, Widget Function()>{
    'alerts': AlertsScreen.new,
    'events': EventsScreen.new,
    'groups': GroupsScreen.new,
    'profile': ProfileScreen.new,
    'sos': SosScreen.new,
    'route report': ReportRouteScreen.new,
    'audit log': AuditLogScreen.new,
    'verification queue': VerificationQueueScreen.new,
  };

  group('tap targets are big enough to hit under stress', () {
    for (final entry in screens.entries) {
      testWidgets(entry.key, (tester) async {
        final handle = tester.ensureSemantics();
        await pump(tester, entry.value());
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        handle.dispose();
        await teardown(tester);
      });
    }
  });

  group('every tappable can be announced', () {
    for (final entry in screens.entries) {
      testWidgets(entry.key, (tester) async {
        final handle = tester.ensureSemantics();
        await pump(tester, entry.value());
        // An unlabelled button is a dead end for a screen-reader user: they
        // can reach it and still not know what it does.
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
        await teardown(tester);
      });
    }
  });

  group('rendered text has enough contrast where it lands', () {
    for (final entry in screens.entries) {
      testWidgets(entry.key, (tester) async {
        final handle = tester.ensureSemantics();
        await pump(tester, entry.value());
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
        await teardown(tester);
      });
    }
  });
}
