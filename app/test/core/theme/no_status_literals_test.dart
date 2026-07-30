import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/theme/status_colors.dart';

/// Status colour must reach the screen through the token, never as a copied
/// hex (ADR-35).
///
/// This is a source scan rather than a widget test, because the bug it exists
/// to prevent is invisible to every other kind of test. A literal that happens
/// to equal the token renders identically today, so nothing fails — and then
/// the token gets corrected and the literal does not follow.
///
/// That is not hypothetical. `PendingMarker` painted `#9E9E9E`, the exact grey
/// `StatusColors` abandoned for measuring 2.43:1 against the light card. The
/// token had been fixed twice; the pin had moved neither time, and the contrast
/// suite could not see it because the suite measures tokens and the pin was
/// not using one.
///
/// The allowlist is deliberately tiny. Adding to it should feel like a
/// decision, and each entry says why it is there.
void main() {
  /// Files permitted to name a status hex directly.
  const allowed = <String>{
    // The definition itself.
    'lib/core/theme/status_colors.dart',
    // Info blue lives next to the severity mapping that owns it.
    'lib/features/alerts/presentation/widgets/alert_visuals.dart',
  };

  const statusHexes = <String, String>{
    '0xFF2E7D32': 'StatusColors.good',
    '0xFFC62828': 'StatusColors.out',
    '0xFFF9A825': 'StatusColors.low',
    '0xFF767472': 'StatusColors.unverified',
    '0xFF1976D2': 'AlertSeverityVisuals.infoBlue',
    // Retired values. These must never reappear at all — they are the
    // failures the palette was corrected away from.
    '0xFF9E9E9E': 'a retired grey (2.43:1 on the light card)',
    '0xFF616161': 'a retired grey (2.75:1 on the dark card)',
  };

  test('no screen hardcodes a status colour', () {
    final offences = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final path = entity.path.replaceAll(r'\', '/');
      if (allowed.contains(path)) continue;

      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final entry in statusHexes.entries) {
          // Case-insensitive: 0xffc62828 is the same colour.
          if (lines[i].toLowerCase().contains(entry.key.toLowerCase())) {
            offences.add(
              '$path:${i + 1} uses ${entry.key} — use ${entry.value}',
            );
          }
        }
      }
    }

    expect(
      offences,
      isEmpty,
      reason:
          'Status colour must come from StatusColors so that correcting the '
          'token corrects every screen, and so the contrast suite can see it:'
          '\n  ${offences.join('\n  ')}',
    );
  });

  test('the scan is looking for the values actually in use', () {
    // Guards the guard: if a token changes and this map is not updated, the
    // scan quietly starts checking for a colour nobody paints any more.
    const colors = StatusColors.standard;
    for (final entry in <String, int>{
      '0xFF2E7D32': 0xFF2E7D32,
      '0xFFC62828': 0xFFC62828,
      '0xFFF9A825': 0xFFF9A825,
      '0xFF767472': 0xFF767472,
    }.entries) {
      expect(
        statusHexes.containsKey(entry.key),
        isTrue,
        reason: '${entry.key} must be in the scan list',
      );
    }
    expect(colors.good.toARGB32(), 0xFF2E7D32);
    expect(colors.out.toARGB32(), 0xFFC62828);
    expect(colors.low.toARGB32(), 0xFFF9A825);
    expect(colors.unverified.toARGB32(), 0xFF767472);
  });
}
