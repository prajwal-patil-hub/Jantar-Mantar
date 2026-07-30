import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/db/app_database.dart';
import 'package:jantar_mantar_sahayata/core/domain/sphere_standards.dart';

/// WASH adequacy against Sphere / UNHCR minimums (ADR-30).
///
/// The behaviours that matter are the ones that stop this being a number
/// generator: it must never call missing data "adequate", must not count
/// broken latrines as provision, and must reproduce the real July 2026 Assam
/// figures that motivated it.
void main() {
  Facility facility(
    String id,
    FacilityType type, {
    double lat = 26.1445,
    double lng = 91.7362,
    FacilityStatus status = FacilityStatus.good,
  }) => Facility(
    id: id,
    name: id,
    type: type,
    status: status,
    lat: lat,
    lng: lng,
    canonical: true,
    updatedAt: DateTime(2026, 7, 30),
  );

  /// Offsets roughly [meters] north of the camp, for radius tests.
  double latOffset(double meters) => 26.1445 + meters / 111320.0;

  final camp = facility('camp', FacilityType.shelter);

  group('the Assam floods, July 2026', () {
    test('15,000 people with 6 latrines reads as 2,500 per latrine', () {
      final result = washAdequacy(
        camp: camp,
        people: 15000,
        nearby: [
          for (var i = 0; i < 6; i++)
            facility('latrine-$i', FacilityType.toilet),
          for (var i = 0; i < 3; i++) facility('pump-$i', FacilityType.water),
        ],
      );

      expect(result.latrines.peoplePerPoint, 2500);
      expect(result.latrines.points, 6);
      expect(result.latrines.band, WashBand.belowStandard);
      // 50× the first-phase emergency maximum of 50 people per latrine.
      expect(result.latrines.peoplePerPoint! ~/ latrineEmergencyMax, 50);

      expect(result.water.peoplePerPoint, 5000);
      expect(result.water.band, WashBand.belowStandard);
      expect(result.anyBelowStandard, isTrue);
    });

    test('13,000 people with 3 latrines reads as 4,333 per latrine', () {
      final result = washAdequacy(
        camp: camp,
        people: 13000,
        nearby: [
          for (var i = 0; i < 3; i++)
            facility('latrine-$i', FacilityType.toilet),
        ],
      );
      expect(result.latrines.peoplePerPoint, 4333);
      expect(result.latrines.band, WashBand.belowStandard);
    });
  });

  group('bands', () {
    test('within the target is meetsStandard', () {
      final result = washAdequacy(
        camp: camp,
        people: 100,
        nearby: [
          for (var i = 0; i < 10; i++) facility('l-$i', FacilityType.toilet),
          facility('w-0', FacilityType.water),
        ],
      );
      expect(result.latrines.peoplePerPoint, 10);
      expect(result.latrines.band, WashBand.meetsStandard);
      expect(result.water.peoplePerPoint, 100);
      expect(result.water.band, WashBand.meetsStandard);
    });

    test('between the target and the emergency maximum is emergencyOnly', () {
      final result = washAdequacy(
        camp: camp,
        people: 400,
        nearby: [
          for (var i = 0; i < 10; i++) facility('l-$i', FacilityType.toilet),
        ],
      );
      // 40 people per latrine: inside the emergency max of 50, past the
      // target of 20.
      expect(result.latrines.peoplePerPoint, 40);
      expect(result.latrines.band, WashBand.emergencyOnly);
    });

    test('water between the tap and hand-pump figures is emergencyOnly', () {
      // 300 per point: fine for a hand pump (500), not for a tap (250). The
      // model cannot tell which, so it must not claim either.
      final result = washAdequacy(
        camp: camp,
        people: 300,
        nearby: [facility('w-0', FacilityType.water)],
      );
      expect(result.water.peoplePerPoint, 300);
      expect(result.water.band, WashBand.emergencyOnly);
    });

    test('no latrines at all is belowStandard, with no ratio to print', () {
      final result = washAdequacy(camp: camp, people: 500, nearby: const []);
      expect(result.latrines.band, WashBand.belowStandard);
      expect(result.latrines.peoplePerPoint, isNull);
      expect(result.water.band, WashBand.belowStandard);
    });
  });

  group('refusing to guess', () {
    test('no population figure is unknown, NOT adequate', () {
      final result = washAdequacy(
        camp: camp,
        people: null,
        nearby: [
          for (var i = 0; i < 20; i++) facility('l-$i', FacilityType.toilet),
        ],
      );
      // Twenty latrines and no idea how many people. Silence must not read
      // as a pass.
      expect(result.latrines.band, WashBand.unknown);
      expect(result.hasAnything, isFalse);
      expect(result.anyBelowStandard, isFalse);
    });

    test('a zero or negative population is unknown', () {
      expect(
        washAdequacy(camp: camp, people: 0, nearby: const []).latrines.band,
        WashBand.unknown,
      );
      expect(
        washAdequacy(camp: camp, people: -5, nearby: const []).latrines.band,
        WashBand.unknown,
      );
    });

    test('only shelters are assessed', () {
      final result = washAdequacy(
        camp: facility('water-point', FacilityType.water),
        people: 500,
        nearby: [facility('l-0', FacilityType.toilet)],
      );
      expect(result.latrines.band, WashBand.unknown);
    });
  });

  group('counting only real provision', () {
    test('a latrine that is out or closed provides nothing', () {
      final result = washAdequacy(
        camp: camp,
        people: 100,
        nearby: [
          facility('working', FacilityType.toilet),
          facility('broken', FacilityType.toilet, status: FacilityStatus.out),
          facility(
            'locked',
            FacilityType.toilet,
            status: FacilityStatus.closed,
          ),
        ],
      );
      // Counting the broken ones would turn a failing camp into a compliant
      // one on paper — the exact failure this exists to expose.
      expect(result.latrines.points, 1);
      expect(result.latrines.peoplePerPoint, 100);
    });

    test(
      'a "low" latrine still counts — running short is not being absent',
      () {
        final result = washAdequacy(
          camp: camp,
          people: 100,
          nearby: [
            facility('l-0', FacilityType.toilet, status: FacilityStatus.low),
          ],
        );
        expect(result.latrines.points, 1);
      },
    );

    test('facilities beyond the radius are not this camp\'s', () {
      final result = washAdequacy(
        camp: camp,
        people: 100,
        nearby: [
          facility('near', FacilityType.toilet, lat: latOffset(50)),
          facility('far', FacilityType.toilet, lat: latOffset(900)),
        ],
      );
      expect(result.latrines.points, 1);
    });

    test('the camp does not count itself, and food pins are irrelevant', () {
      final result = washAdequacy(
        camp: camp,
        people: 100,
        nearby: [camp, facility('kitchen', FacilityType.food)],
      );
      expect(result.latrines.points, 0);
      expect(result.water.points, 0);
    });

    test('the evidence count is reported, so partial coverage is visible', () {
      final result = washAdequacy(
        camp: camp,
        people: 1000,
        nearby: [
          for (var i = 0; i < 4; i++) facility('l-$i', FacilityType.toilet),
          for (var i = 0; i < 2; i++) facility('w-$i', FacilityType.water),
        ],
      );
      expect(result.latrines.points, 4);
      expect(result.water.points, 2);
      expect(result.radiusMeters, campRadiusMeters);
      expect(result.latrines.people, 1000);
    });
  });
}
