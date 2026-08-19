import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A source scan: `Card(` must not reappear in the app (ADR-39).
///
/// Material's `Card` paints **one** shadow. On the Blush Depth ramp every
/// adjacent surface pair measures ~1.06:1, so tone carries almost nothing and
/// the shadow is doing the entire job of saying "this is above that" — one
/// shadow doing it alone is exactly what made the first pass at this direction
/// read flat. `DepthSurface` paints the compound: a tight contact shadow, a
/// wide cast, and a top lip.
///
/// This is a scan and not a widget test on purpose, for the same reason
/// `no_status_literals_test` is. A `Card` renders perfectly well — it is not
/// broken, it is just one rung shallower than everything around it. Nothing
/// throws, nothing overflows, and no assertion on a rendered tree would notice.
/// The only place to catch it is at the point someone types it.
///
/// If a screen genuinely needs Material's card semantics, add it to
/// [_allowed] with the reason, the way the status scan does.
void main() {
  test('no screen constructs a Material Card', () {
    const allowed = <String>{
      // The component themes still configure CardThemeData: anything that
      // does slip through, or arrives inside a Flutter widget that builds its
      // own Card, still lands on the radii scale rather than stock Material.
      'lib/core/theme/app_theme.dart',
    };

    final offenders = <String>[];
    for (final file
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      final path = file.path.replaceAll(r'\', '/');
      if (allowed.contains(path)) continue;
      if (path.endsWith('.g.dart') || path.contains('/l10n/')) continue;

      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        // Strip comments first: this scan's own explanation used to match
        // itself, which is how the manifest scan wasted an afternoon.
        final code = line.split('//').first;
        // `Card(` but not `_FooCard(`, `StandingCard(`, `CardThemeData(`.
        if (RegExp(r'(?<![\w$])Card\(').hasMatch(code)) {
          offenders.add('$path:${i + 1}: ${line.trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Material Card paints one shadow; this ramp needs the compound one.\n'
          'Use DepthSurface (core/theme/depth.dart) instead:\n'
          '${offenders.join('\n')}',
    );
  });
}
