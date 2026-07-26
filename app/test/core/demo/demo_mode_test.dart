import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/demo/demo_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('defaults to on so the app is explorable out of the box', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(demoModeProvider), isTrue);
  });

  test('set() persists the choice and load() restores it', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(demoModeProvider.notifier).set(false);
    expect(container.read(demoModeProvider), isFalse);

    // A fresh container starts at the default, then load() restores "off".
    final reopened = ProviderContainer();
    addTearDown(reopened.dispose);
    expect(reopened.read(demoModeProvider), isTrue);
    await reopened.read(demoModeProvider.notifier).load();
    expect(reopened.read(demoModeProvider), isFalse);
  });

  test('load() keeps the default when nothing is saved', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(demoModeProvider.notifier).load();
    expect(container.read(demoModeProvider), isTrue);
  });
}
