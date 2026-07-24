import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jantar_mantar_sahayata/core/db/app_database.dart';
import 'package:jantar_mantar_sahayata/core/providers.dart';
import 'package:jantar_mantar_sahayata/features/sos/presentation/sos_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Widget app() {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: SosScreen()),
    );
  }

  Future<void> flushTimers(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('shows hold button and direct-call tiles', (tester) async {
    await tester.pumpWidget(app());

    expect(find.text('SOS\nHold to send'), findsOneWidget);
    expect(find.textContaining('112'), findsOneWidget);
    expect(find.textContaining('108'), findsOneWidget);
    expect(find.textContaining('15100'), findsOneWidget);
    expect(find.text('Nearest medical on map'), findsOneWidget);

    await flushTimers(tester);
  });

  testWidgets('holding through the countdown queues an SOS', (tester) async {
    await tester.pumpWidget(app());

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('SOS\nHold to send')),
    );
    // Long-press recognizer kicks in ~500ms, countdown is 2.5s.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 2600));
    await gesture.up();
    await tester.pump();

    expect(find.text('SOS queued'), findsOneWidget);
    expect(find.text("I'm safe — reset"), findsOneWidget);

    final entry = (await db.select(db.syncQueueEntries).get()).single;
    expect(entry.entity, 'sos');
    expect(entry.state, SyncState.pending);
    final payload = jsonDecode(entry.payload) as Map<String, Object?>;
    expect(payload['firedAt'], isNotNull);

    await flushTimers(tester);
  });

  testWidgets('releasing early cancels the countdown', (tester) async {
    await tester.pumpWidget(app());

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('SOS\nHold to send')),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 800)); // released early
    await gesture.up();
    await tester.pump();

    expect(find.text('SOS queued'), findsNothing);
    expect(await db.select(db.syncQueueEntries).get(), isEmpty);

    await flushTimers(tester);
  });
}
