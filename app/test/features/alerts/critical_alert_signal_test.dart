import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/db/app_database.dart';
import 'package:jantar_mantar_sahayata/core/providers.dart';
import 'package:jantar_mantar_sahayata/features/alerts/application/alerts_providers.dart';
import 'package:jantar_mantar_sahayata/features/alerts/application/critical_alert_signal.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sound/vibration on a new critical alert (E6). The behaviours that matter:
/// it fires once per alert and not once per rebuild, sound stays off until
/// the user asks for it, and a warning never triggers it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late List<({bool haptics, bool sound})> fired;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase(NativeDatabase.memory());
    fired = [];
  });

  tearDown(() => db.close());

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        alertSignalSinkProvider.overrideWithValue(({
          required bool haptics,
          required bool sound,
        }) async {
          fired.add((haptics: haptics, sound: sound));
        }),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<void> insertAlert(
    String id, {
    AlertSeverity severity = AlertSeverity.critical,
    Duration age = Duration.zero,
  }) async {
    // Drift stores DateTime with second precision, so tests that need a
    // distinguishable ordering have to space the timestamps explicitly.
    final createdAt = DateTime.now().subtract(age);
    await db
        .into(db.alerts)
        .insert(
          AlertsCompanion.insert(
            id: id,
            severity: severity,
            body: 'body $id',
            createdAt: createdAt,
            expiresAt: DateTime.now().add(const Duration(hours: 1)),
          ),
        );
  }

  test('vibrates once for a new critical alert, silently by default', () async {
    final container = makeContainer();
    // The stream must be listened to before it can emit.
    container.listen(activeAlertsProvider, (_, _) {});
    container.listen(criticalAlertSignalProvider, (_, _) {});

    await insertAlert('a1');
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(fired, hasLength(1));
    expect(fired.single.haptics, isTrue);
    // Sound defaults off: an unexpected chime can identify its owner.
    expect(fired.single.sound, isFalse);
  });

  test('does not re-fire when the same alert is edited or re-synced', () async {
    final container = makeContainer();
    container.listen(activeAlertsProvider, (_, _) {});
    container.listen(criticalAlertSignalProvider, (_, _) {});

    await insertAlert('a1');
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(fired, hasLength(1));

    // Same alert, different row value — a pull from the server amending the
    // wording rebuilds the signaller with a genuinely new Alert object. The
    // id is what identifies "already told them", not the object.
    await (db.update(db.alerts)..where((a) => a.id.equals('a1'))).write(
      const AlertsCompanion(body: Value('body a1 (updated)')),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(fired, hasLength(1));
  });

  test('a genuinely new critical alert signals again', () async {
    final container = makeContainer();
    container.listen(activeAlertsProvider, (_, _) {});
    container.listen(criticalAlertSignalProvider, (_, _) {});

    await insertAlert('a1', age: const Duration(minutes: 5));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await insertAlert('a2');
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(fired, hasLength(2));
  });

  test('a warning alone never signals', () async {
    final container = makeContainer();
    container.listen(activeAlertsProvider, (_, _) {});
    container.listen(criticalAlertSignalProvider, (_, _) {});

    await insertAlert('w1', severity: AlertSeverity.warn);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(fired, isEmpty);
  });

  test('nothing fires when both signals are switched off', () async {
    final container = makeContainer();
    await container.read(alertHapticsProvider.notifier).set(false);
    container.listen(activeAlertsProvider, (_, _) {});
    container.listen(criticalAlertSignalProvider, (_, _) {});

    await insertAlert('a1');
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(fired, isEmpty);
  });

  test('sound is included once the user opts in', () async {
    final container = makeContainer();
    await container.read(alertSoundProvider.notifier).set(true);
    container.listen(activeAlertsProvider, (_, _) {});
    container.listen(criticalAlertSignalProvider, (_, _) {});

    await insertAlert('a1');
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(fired.single.sound, isTrue);
  });

  test('the opt-in choices survive a restart', () async {
    final first = makeContainer();
    await first.read(alertSoundProvider.notifier).set(true);
    await first.read(alertHapticsProvider.notifier).set(false);

    final reopened = makeContainer();
    // A fresh container starts at the defaults until load() runs.
    expect(reopened.read(alertSoundProvider), isFalse);
    await reopened.read(alertSoundProvider.notifier).load();
    await reopened.read(alertHapticsProvider.notifier).load();
    expect(reopened.read(alertSoundProvider), isTrue);
    expect(reopened.read(alertHapticsProvider), isFalse);
  });
}
