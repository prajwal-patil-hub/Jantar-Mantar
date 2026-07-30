/// Sphere / UNHCR WASH adequacy for a relief camp (ADR-30).
///
/// Motivation, from July 2026 reporting on the Assam floods: one camp housed
/// **15,000 people with 6 latrines and 3 hand pumps**, another **13,000 with
/// 3 latrines** — 2,500 and 4,333 people per latrine against a first-phase
/// emergency maximum of **50**. Around 20,000 diarrhoea cases followed. The
/// gap was not that the ratio was acceptable; it is that nobody had the
/// number. See `docs/research/disaster-response-adaptation.md`.
///
/// This computes that number from data the app **already** holds — a shelter
/// facility's capacity, and the water/toilet facilities mapped around it. No
/// new collection, no schema change, no personal data of any kind.
///
/// Three things it deliberately does NOT do:
/// - it does not claim to be an audit. Map coverage is partial by definition,
///   so every result carries the count of facilities it actually used;
/// - it does not guess. Too little data returns [WashBand.unknown], never
///   "adequate" — silence must never read as a pass;
/// - it does not collapse the water standard into one number, because the
///   published figure depends on the source type (see [waterPointStandards]),
///   which the facility model cannot distinguish. Reporting a real range
///   beats reporting a confident wrong threshold.
library;

import 'package:latlong2/latlong.dart';

import '../db/app_database.dart';

/// People per latrine. 50 is the first-phase emergency **maximum** (UNHCR);
/// 20 is the standard to aim for once a response stabilises.
const int latrineEmergencyMax = 50;
const int latrineTarget = 20;

/// People per water point, from the Sphere Handbook. The figure depends on
/// flow rate, so it depends on the source: **250** per tap (7.5 L/min),
/// **500** per hand pump (17 L/min), 400 per open well. A facility pin does
/// not record which, so both bounds are surfaced rather than one guess.
const int waterPointTapStandard = 250;
const int waterPointPumpStandard = 500;
const Map<String, int> waterPointStandards = {
  'tap': waterPointTapStandard,
  'well': 400,
  'handpump': waterPointPumpStandard,
};

/// Litres per person per day — context for the UI, not something this module
/// can measure, because flow rate is not in the data model.
const int waterLitresPerPersonPerDay = 15;

/// How far from the camp centre a facility still counts as "in this camp".
/// Sphere puts latrines within 50 m of dwellings; a camp is bigger than a
/// dwelling, so this is generous on purpose — over-counting provision makes
/// the result *less* alarming, which is the safe direction for a number that
/// accuses someone of failing a standard.
const double campRadiusMeters = 150;

enum WashBand {
  /// Meets the standard on any reading of it.
  meetsStandard,

  /// Inside the emergency maximum but not the target — or, for water, only
  /// adequate if the points are hand pumps rather than taps.
  emergencyOnly,

  /// Below the published minimum however you read it.
  belowStandard,

  /// Not enough mapped data to say. Never rendered as a pass.
  unknown,
}

/// One computed ratio, with the evidence it rests on.
class WashRatio {
  const WashRatio({
    required this.band,
    required this.peoplePerPoint,
    required this.points,
    required this.people,
  });

  static const unknown = WashRatio(
    band: WashBand.unknown,
    peoplePerPoint: null,
    points: 0,
    people: 0,
  );

  final WashBand band;

  /// Null when [band] is [WashBand.unknown], or when there are zero usable
  /// points — "infinity people per latrine" is not a number worth printing.
  final int? peoplePerPoint;

  /// How many usable facilities went into this. Shown in the UI so nobody
  /// mistakes partial map coverage for a survey.
  final int points;

  /// The camp population this was measured against.
  final int people;
}

class WashAdequacy {
  const WashAdequacy({
    required this.latrines,
    required this.water,
    required this.radiusMeters,
  });

  static const unknown = WashAdequacy(
    latrines: WashRatio.unknown,
    water: WashRatio.unknown,
    radiusMeters: campRadiusMeters,
  );

  final WashRatio latrines;
  final WashRatio water;
  final double radiusMeters;

  /// True when either ratio is below the published minimum — the case worth
  /// putting in front of someone.
  bool get anyBelowStandard =>
      latrines.band == WashBand.belowStandard ||
      water.band == WashBand.belowStandard;

  bool get hasAnything =>
      latrines.band != WashBand.unknown || water.band != WashBand.unknown;
}

/// A facility only provides service if it is actually usable. A latrine
/// marked `out` or `closed` counts as zero — counting it would turn a broken
/// camp into a compliant one on paper, which is the exact failure this is
/// meant to expose.
bool _usable(Facility f) =>
    f.status == FacilityStatus.good || f.status == FacilityStatus.low;

WashBand _latrineBand(int people, int latrines) {
  if (latrines == 0) return WashBand.belowStandard;
  final ratio = people / latrines;
  if (ratio <= latrineTarget) return WashBand.meetsStandard;
  if (ratio <= latrineEmergencyMax) return WashBand.emergencyOnly;
  return WashBand.belowStandard;
}

WashBand _waterBand(int people, int points) {
  if (points == 0) return WashBand.belowStandard;
  final ratio = people / points;
  if (ratio <= waterPointTapStandard) return WashBand.meetsStandard;
  // Between the two published figures: adequate only if these are hand pumps.
  if (ratio <= waterPointPumpStandard) return WashBand.emergencyOnly;
  return WashBand.belowStandard;
}

/// Compute WASH adequacy for [camp] against the facilities around it.
///
/// [people] is the camp's stated capacity (a shelter capacity reading). With
/// no population figure there is nothing to divide, so the result is
/// [WashAdequacy.unknown] — not a pass.
WashAdequacy washAdequacy({
  required Facility camp,
  required Iterable<Facility> nearby,
  required int? people,
  double radiusMeters = campRadiusMeters,
}) {
  if (camp.type != FacilityType.shelter || people == null || people <= 0) {
    return WashAdequacy.unknown;
  }

  const distance = Distance();
  final campPoint = LatLng(camp.lat, camp.lng);
  var latrines = 0;
  var waterPoints = 0;

  for (final f in nearby) {
    if (f.id == camp.id || !_usable(f)) continue;
    if (f.type != FacilityType.toilet && f.type != FacilityType.water) continue;
    if (distance(campPoint, LatLng(f.lat, f.lng)) > radiusMeters) continue;
    if (f.type == FacilityType.toilet) {
      latrines++;
    } else {
      waterPoints++;
    }
  }

  return WashAdequacy(
    latrines: WashRatio(
      band: _latrineBand(people, latrines),
      peoplePerPoint: latrines == 0 ? null : (people / latrines).round(),
      points: latrines,
      people: people,
    ),
    water: WashRatio(
      band: _waterBand(people, waterPoints),
      peoplePerPoint: waterPoints == 0 ? null : (people / waterPoints).round(),
      points: waterPoints,
      people: people,
    ),
    radiusMeters: radiusMeters,
  );
}
