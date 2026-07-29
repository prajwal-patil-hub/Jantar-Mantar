import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/features/sos/data/location_share.dart';
import 'package:jantar_mantar_sahayata/features/sos/presentation/share_location_sheet.dart';

import '../../support/l10n_harness.dart';

/// Share-my-location (E7). This is the only GPS in the app, so the tests are
/// about consent and about never leaving the user guessing whether their
/// position went out.
class _FakeLocationService implements LocationService {
  _FakeLocationService(this._result);

  final LocationResult _result;
  int calls = 0;

  @override
  Future<LocationResult> currentFix() async {
    calls++;
    return _result;
  }
}

void main() {
  Future<_FakeLocationService> pump(
    WidgetTester tester,
    LocationResult result,
  ) async {
    final service = _FakeLocationService(result);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [locationServiceProvider.overrideWithValue(service)],
        child: MaterialApp(
          localizationsDelegates: testLocalizationsDelegates,
          supportedLocales: testSupportedLocales,
          home: const Scaffold(body: ShareLocationSheet()),
        ),
      ),
    );
    await tester.pump();
    return service;
  }

  final fix = LocationFix(
    lat: 28.62710,
    lng: 77.21660,
    accuracyMeters: 12.4,
    at: DateTime(2026, 7, 28, 14, 30),
  );

  testWidgets('asks before it reads anything', (tester) async {
    final service = await pump(tester, fix);

    // The consent text is on screen and no fix has been taken yet — the
    // permission prompt must never be the first thing the user sees.
    expect(find.textContaining('never reaches our servers'), findsOneWidget);
    expect(find.textContaining('Anyone you send it to'), findsOneWidget);
    expect(service.calls, 0);
  });

  testWidgets('cancelling reads nothing', (tester) async {
    final service = await pump(tester, fix);
    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(service.calls, 0);
  });

  testWidgets('confirming takes exactly one reading', (tester) async {
    final service = await pump(tester, fix);
    await tester.tap(find.text('Get my location'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // One-shot, never a stream.
    expect(service.calls, 1);
  });

  testWidgets('a denial says plainly that nothing was shared', (tester) async {
    await pump(tester, const LocationDenied(LocationFailure.denied));
    await tester.tap(find.text('Get my location'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Nothing was shared'), findsOneWidget);
  });

  testWidgets('location switched off is reported as its own case', (
    tester,
  ) async {
    await pump(tester, const LocationDenied(LocationFailure.serviceOff));
    await tester.tap(find.text('Get my location'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('switched off on this device'), findsOneWidget);
  });

  group('link', () {
    test('points at OpenStreetMap, not a vendor', () {
      // The recipient should not have to tell Google where the sender is in
      // order to read the message (ADR-7).
      expect(fix.osmUrl, startsWith('https://www.openstreetmap.org/'));
      expect(fix.osmUrl, contains('mlat=28.62710'));
      expect(fix.osmUrl, contains('mlon=77.21660'));
      expect(fix.osmUrl.toLowerCase(), isNot(contains('google')));
    });
  });
}
