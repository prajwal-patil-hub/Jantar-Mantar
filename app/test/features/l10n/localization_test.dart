import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jantar_mantar_sahayata/core/db/app_database.dart';
import 'package:jantar_mantar_sahayata/core/l10n/locale_provider.dart';
import 'package:jantar_mantar_sahayata/core/map/tile_providers.dart';
import 'package:jantar_mantar_sahayata/core/providers.dart';
import 'package:jantar_mantar_sahayata/l10n/app_localizations.dart';

import '../../support/stub_tile_provider.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  testWidgets('nav bar renders Hindi labels when the locale is hi', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          mapTileProviderProvider.overrideWith((ref) => StubTileProvider()),
          // Pin the locale to Hindi for this test.
          localeProvider.overrideWith(() => _HiLocale()),
        ],
        child: const _Harness(),
      ),
    );
    await tester.pump();

    // Devanagari nav labels from app_hi.arb.
    expect(find.text('नक्शा'), findsOneWidget); // Map
    expect(find.text('चेतावनी'), findsOneWidget); // Alerts
    expect(find.text('प्रोफ़ाइल'), findsOneWidget); // Profile
    expect(find.text('Map'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  test('English and Hindi resolve distinct non-empty strings', () {
    final en = lookupAppL10n(const Locale('en'));
    final hi = lookupAppL10n(const Locale('hi'));
    expect(en.navMap, 'Map');
    expect(hi.navMap, 'नक्शा');
    expect(hi.sos, en.sos); // SOS stays "SOS" in both.
  });
}

class _HiLocale extends LocaleNotifier {
  @override
  Locale? build() => const Locale('hi');
}

class _Harness extends ConsumerWidget {
  const _Harness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp(
      locale: locale,
      supportedLocales: AppL10n.supportedLocales,
      localizationsDelegates: AppL10n.localizationsDelegates,
      home: const _ShellProxy(),
    );
  }
}

// Minimal shell that avoids background sync/prefs during this render.
class _ShellProxy extends StatelessWidget {
  const _ShellProxy();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            label: l10n.navMap,
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_outlined),
            label: l10n.navAlerts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
