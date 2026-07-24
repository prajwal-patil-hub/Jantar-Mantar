import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jantar_mantar_sahayata/app.dart';

void main() {
  testWidgets('app boots to the shell with all four destinations', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: SahayataApp()));

    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Events'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('navigation switches screens', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SahayataApp()));

    await tester.tap(find.text('Alerts'));
    await tester.pumpAndSettle();

    expect(find.text('Alerts — E6'), findsOneWidget);
  });
}
