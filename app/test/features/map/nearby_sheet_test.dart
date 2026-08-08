import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/db/app_database.dart';
import 'package:jantar_mantar_sahayata/core/providers.dart';
import 'package:jantar_mantar_sahayata/features/map/presentation/widgets/nearby_sheet.dart';

import '../../support/l10n_harness.dart';

/// The Nearby sheet must be draggable by the thing that looks draggable.
///
/// The bug: the grab handle sat OUTSIDE the scroll view, in a
/// `GestureDetector(behavior: opaque)`. Tapping worked, so the sheet opened —
/// and then dragging the handle back down moved it by **exactly 0 px**,
/// because `DraggableScrollableSheet` drags via the scrollable it hands the
/// builder, and the header was not part of it. The one affordance that
/// signals "drag me" was the one that did nothing.
///
/// Fixed by making the header a pinned sliver inside the same scroll view, so
/// the framework's own drag/fling/snap handling covers it. These tests measure
/// movement in pixels rather than asserting on internal state, because "the
/// controller changed" and "the sheet moved" came apart once already.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    for (var i = 0; i < 4; i++) {
      await db
          .into(db.facilities)
          .insert(
            FacilitiesCompanion.insert(
              id: 'f$i',
              name: 'Water point $i',
              type: FacilityType.water,
              status: FacilityStatus.good,
              lat: 28.6271 + i * 0.001,
              lng: 77.2166,
              updatedAt: DateTime.now(),
            ),
          );
    }
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: testAppTheme(),
          localizationsDelegates: testLocalizationsDelegates,
          supportedLocales: testSupportedLocales,
          home: Scaffold(
            body: Stack(
              children: [
                const ColoredBox(color: Colors.grey, child: SizedBox.expand()),
                NearbySheet(onFacilityTap: (_) {}),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 150));
    await db.close();
  }

  /// Top of the sheet's scroll view. Larger = sheet is further down.
  double top(WidgetTester tester) =>
      tester.getTopLeft(find.byType(CustomScrollView).first).dy;

  testWidgets('the handle can drag the sheet back down after opening', (
    tester,
  ) async {
    await pump(tester);
    final header = find.textContaining('Nearby').first;

    await tester.tap(header);
    await tester.pumpAndSettle(const Duration(milliseconds: 600));
    final opened = top(tester);

    await tester.drag(header, const Offset(0, 300), warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    expect(
      top(tester),
      greaterThan(opened + 50),
      reason:
          'dragging the grab handle down must move the sheet down — this '
          'measured exactly 0 px before the header became a pinned sliver',
    );
    await teardown(tester);
  });

  testWidgets('and drag it back up again', (tester) async {
    await pump(tester);
    final header = find.textContaining('Nearby').first;
    final collapsed = top(tester);

    await tester.drag(header, const Offset(0, -300), warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    expect(top(tester), lessThan(collapsed - 50), reason: 'drag up opens it');
    await teardown(tester);
  });

  testWidgets('tapping the handle still cycles it open', (tester) async {
    // Kept because flutter_map's pan gestures compete with a drag started
    // over the map, so tap is the reliable path on the real map screen.
    await pump(tester);
    final header = find.textContaining('Nearby').first;
    final collapsed = top(tester);

    await tester.tap(header);
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    expect(top(tester), lessThan(collapsed - 50));
    await teardown(tester);
  });

  testWidgets('the handle is reachable by a screen reader', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester);
    expect(
      tester
          .widgetList<Semantics>(find.byType(Semantics))
          .any((s) => s.properties.button ?? false),
      isTrue,
    );
    handle.dispose();
    await teardown(tester);
  });
}
