import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jantar_mantar_sahayata/core/db/app_database.dart';
import 'package:jantar_mantar_sahayata/core/providers.dart';
import 'package:jantar_mantar_sahayata/core/theme/app_theme.dart';
import 'package:jantar_mantar_sahayata/features/map/presentation/facility_detail_sheet.dart';

void main() {
  late AppDatabase db;
  final now = DateTime.now();

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Future<Facility> insertFacility({DateTime? verifiedAt}) async {
    await db
        .into(db.facilities)
        .insert(
          FacilitiesCompanion.insert(
            id: 'w1',
            name: 'Water point Gate 1',
            type: FacilityType.water,
            status: FacilityStatus.good,
            lat: 28.6278,
            lng: 77.2159,
            verifiedAt: Value(verifiedAt),
            updatedAt: now,
          ),
        );
    return (db.select(
      db.facilities,
    )..where((f) => f.id.equals('w1'))).getSingle();
  }

  Future<void> pumpSheet(WidgetTester tester, Facility facility) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => showFacilityDetailSheet(context, facility),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> flushTimers(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('shows capacity with TTL degrade and stale banner', (
    tester,
  ) async {
    final facility = await insertFacility(
      verifiedAt: now.subtract(const Duration(hours: 2)),
    );
    await db
        .into(db.capacityReadings)
        .insert(
          CapacityReadingsCompanion.insert(
            id: 'r1',
            facilityId: 'w1',
            resource: ResourceType.water,
            forPeople: 200,
            expiresAt: now.add(const Duration(minutes: 30)),
            createdAt: now,
          ),
        );
    await db
        .into(db.capacityReadings)
        .insert(
          CapacityReadingsCompanion.insert(
            id: 'r2',
            facilityId: 'w1',
            resource: ResourceType.food,
            forPeople: 80,
            expiresAt: now.subtract(const Duration(minutes: 5)),
            createdAt: now.subtract(const Duration(hours: 1)),
          ),
        );

    await pumpSheet(tester, facility);

    expect(find.text('Water point Gate 1'), findsOneWidget);
    expect(find.text('for ~200'), findsOneWidget);
    expect(find.text('for ~80'), findsOneWidget);
    expect(find.text('expired — needs re-check'), findsOneWidget);
    expect(find.text('This info may be outdated.'), findsOneWidget);
    expect(find.text('Update this'), findsOneWidget);
    expect(find.text('Report closed'), findsOneWidget);

    await flushTimers(tester);
  });

  testWidgets('report closed queues an update submission', (tester) async {
    final facility = await insertFacility(verifiedAt: now);
    await pumpSheet(tester, facility);

    await tester.tap(find.text('Report closed'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Report closed').last); // dialog confirm
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final submission = (await db.select(db.submissions).get()).single;
    expect(submission.facilityId, 'w1');
    expect(submission.state, SubmissionState.pending);
    expect(submission.payload, contains('closed'));

    await flushTimers(tester);
  });
}
