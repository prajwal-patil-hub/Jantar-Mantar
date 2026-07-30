import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jantar_mantar_sahayata/core/db/app_database.dart';
import 'package:jantar_mantar_sahayata/core/map/map_config.dart';
import 'package:jantar_mantar_sahayata/core/map/tile_providers.dart';
import 'package:jantar_mantar_sahayata/core/providers.dart';
import 'package:jantar_mantar_sahayata/features/submit/presentation/submit_flow_screen.dart';

import '../../support/l10n_harness.dart';
import '../../support/stub_tile_provider.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Widget flow({Facility? prefill}) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        mapTileProviderProvider.overrideWith((ref) => StubTileProvider()),
      ],
      child: MaterialApp(
        theme: testAppTheme(),
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: testSupportedLocales,
        home: SubmitFlowScreen(
          initialLocation: MapConfig.jantarMantar,
          prefill: prefill,
        ),
      ),
    );
  }

  Future<void> flushTimers(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('full walkthrough stores pending submission with payload', (
    tester,
  ) async {
    await tester.pumpWidget(flow());
    await tester.pump();

    // Step 1: category auto-advances on tap.
    await tester.tap(find.text('Water'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Step 2: location defaults to the provided map center.
    expect(find.text('Where is it?'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Step 3: capacity preset.
    await tester.tap(find.text('~200'));
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Step 4: status Low + note.
    await tester.tap(find.text('Low'));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), 'long queue');
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Step 5: review shows the choices, then submit.
    expect(find.text('Status: Low'), findsOneWidget);
    expect(find.text('Capacity: ~200 people'), findsOneWidget);
    await tester.tap(find.text('Submit for verification'));
    await tester.pump();
    await tester.pump();

    final submission = (await db.select(db.submissions).get()).single;
    expect(submission.state, SubmissionState.pending);
    expect(submission.facilityId, isNull);
    expect(submission.lat, closeTo(MapConfig.jantarMantar.latitude, 1e-6));

    final payload = jsonDecode(submission.payload) as Map<String, Object?>;
    expect(payload['category'], 'water');
    expect(payload['status'], 'low');
    expect(payload['forPeople'], 200);
    expect(payload['note'], 'long queue');
    expect(payload['mode'], 'new');

    final queue = (await db.select(db.syncQueueEntries).get()).single;
    expect(queue.state, SyncState.pending);

    await flushTimers(tester);
  });

  testWidgets('prefilled update flow skips pin placement and tags facility', (
    tester,
  ) async {
    final facility = Facility(
      id: 'w9',
      name: 'Water point Gate 4',
      type: FacilityType.water,
      status: FacilityStatus.good,
      lat: 28.6280,
      lng: 77.2150,
      canonical: true,
      verifiedAt: null,
      updatedAt: DateTime(2026, 7, 24),
    );
    await db
        .into(db.facilities)
        .insert(
          FacilitiesCompanion.insert(
            id: facility.id,
            name: facility.name,
            type: facility.type,
            status: facility.status,
            lat: facility.lat,
            lng: facility.lng,
            verifiedAt: const Value(null),
            updatedAt: facility.updatedAt,
          ),
        );

    await tester.pumpWidget(flow(prefill: facility));
    await tester.pump();

    expect(find.text('Update facility'), findsOneWidget);

    // Category is prefilled; advance through all steps.
    await tester.tap(find.text('Water'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Updating an existing facility'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Submit for verification'));
    await tester.pump();
    await tester.pump();

    final submission = (await db.select(db.submissions).get()).single;
    expect(submission.facilityId, 'w9');
    final payload = jsonDecode(submission.payload) as Map<String, Object?>;
    expect(payload['mode'], 'update');

    await flushTimers(tester);
  });
}
