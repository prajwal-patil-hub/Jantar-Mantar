import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/db/app_database.dart';
import 'package:jantar_mantar_sahayata/core/providers.dart';
import 'package:jantar_mantar_sahayata/core/theme/app_theme.dart';
import 'package:jantar_mantar_sahayata/features/map/presentation/facility_detail_sheet.dart';

import '../../support/l10n_harness.dart';

/// The WASH adequacy card in the facility sheet (ADR-30).
///
/// What must hold on screen: the ratio is stated in words, the standard it is
/// measured against is stated next to it, the card says how partial the
/// evidence is, and it never appears when there is nothing to say.
void main() {
  late AppDatabase db;
  final now = DateTime.now();

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Future<void> addFacility(
    String id,
    FacilityType type, {
    double lat = 26.14450,
    double lng = 91.73620,
    FacilityStatus status = FacilityStatus.good,
  }) => db
      .into(db.facilities)
      .insert(
        FacilitiesCompanion.insert(
          id: id,
          name: id,
          type: type,
          status: status,
          lat: lat,
          lng: lng,
          updatedAt: now,
        ),
      );

  Future<void> addShelterCapacity(String facilityId, int people) => db
      .into(db.capacityReadings)
      .insert(
        CapacityReadingsCompanion.insert(
          id: 'cap-$facilityId',
          facilityId: facilityId,
          resource: ResourceType.shelter,
          forPeople: people,
          expiresAt: now.add(const Duration(minutes: 45)),
          createdAt: now,
        ),
      );

  Future<Facility> camp() =>
      (db.select(db.facilities)..where((f) => f.id.equals('camp'))).getSingle();

  Future<void> pumpSheet(WidgetTester tester, Facility facility) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: testLocalizationsDelegates,
          supportedLocales: testSupportedLocales,
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

  testWidgets('a camp below the standard states the ratio and the standard', (
    tester,
  ) async {
    await addFacility('camp', FacilityType.shelter);
    await addShelterCapacity('camp', 8000);
    await addFacility('t1', FacilityType.toilet, lat: 26.14472);
    await addFacility('t2', FacilityType.toilet, lat: 26.14418);
    await addFacility('w1', FacilityType.water, lng: 91.73580);
    await pumpSheet(tester, await camp());

    // 8,000 people over two usable latrines.
    expect(find.textContaining('4000 people per toilet'), findsOneWidget);
    // The standard is named on screen, so the number can be judged.
    expect(find.textContaining('maximum is 50 people'), findsOneWidget);
    expect(find.textContaining('8000 people per water point'), findsOneWidget);
    // And the card admits how partial its evidence is.
    expect(
      find.textContaining('treat this as an indicator, not a survey'),
      findsOneWidget,
    );

    await flushTimers(tester);
  });

  testWidgets('a broken latrine is not counted as provision', (tester) async {
    await addFacility('camp', FacilityType.shelter);
    await addShelterCapacity('camp', 200);
    await addFacility('t1', FacilityType.toilet, lat: 26.14472);
    await addFacility(
      't2',
      FacilityType.toilet,
      lat: 26.14418,
      status: FacilityStatus.out,
    );
    await pumpSheet(tester, await camp());

    // Two toilets mapped, one working: 200 per toilet, not 100.
    expect(find.textContaining('200 people per toilet'), findsOneWidget);

    await flushTimers(tester);
  });

  testWidgets('no headcount means no card — silence is not a pass', (
    tester,
  ) async {
    await addFacility('camp', FacilityType.shelter);
    await addFacility('t1', FacilityType.toilet, lat: 26.14472);
    // Plenty of toilets, no idea how many people. The card must stay away
    // rather than imply the camp is fine.
    await pumpSheet(tester, await camp());

    expect(find.textContaining('Against humanitarian minimums'), findsNothing);
    expect(find.textContaining('people per toilet'), findsNothing);

    await flushTimers(tester);
  });

  testWidgets('the card does not appear on a non-shelter facility', (
    tester,
  ) async {
    await addFacility('camp', FacilityType.water);
    await pumpSheet(tester, await camp());

    expect(find.textContaining('Against humanitarian minimums'), findsNothing);

    await flushTimers(tester);
  });
}
