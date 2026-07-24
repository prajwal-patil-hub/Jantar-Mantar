import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/domain/freshness.dart';

void main() {
  final now = DateTime(2026, 7, 24, 12);

  test('under 5 minutes is fresh', () {
    expect(
      freshnessAt(now.subtract(const Duration(minutes: 4, seconds: 59)), now),
      Freshness.fresh,
    );
    expect(freshnessAt(now, now), Freshness.fresh);
  });

  test('5 to 30 minutes needs judgment', () {
    expect(
      freshnessAt(now.subtract(const Duration(minutes: 5)), now),
      Freshness.judgment,
    );
    expect(
      freshnessAt(now.subtract(const Duration(minutes: 30)), now),
      Freshness.judgment,
    );
  });

  test('over 30 minutes is stale', () {
    expect(
      freshnessAt(now.subtract(const Duration(minutes: 30, seconds: 1)), now),
      Freshness.stale,
    );
    expect(
      freshnessAt(now.subtract(const Duration(hours: 3)), now),
      Freshness.stale,
    );
  });
}
