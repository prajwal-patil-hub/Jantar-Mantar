import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/config/supabase_config.dart';
import 'package:jantar_mantar_sahayata/core/map/map_config.dart';

/// `web/index.html` carries security and layout invariants that nothing else
/// in the Dart codebase can enforce (ADR-37).
///
/// Both of the bugs below actually shipped:
///
///  · **No viewport tag.** Mobile Safari then uses a 980 px layout viewport
///    and scales the page down, so every responsive breakpoint in the app was
///    measured against a viewport the device does not have — and a pinch
///    became a browser page-zoom instead of a map gesture, which is what
///    "the map disappears when I zoom" turned out to be.
///  · **No CSP.** GitHub Pages cannot set response headers, so the meta tag
///    is the only egress control the deployment has.
///
/// The CSP is checked against the real endpoint constants rather than a copy,
/// because the failure mode of a stale allowlist is silent: the app simply
/// stops being able to reach its own backend, in the field, offline-first
/// masking it as "sync is just slow".
void main() {
  final html = File('web/index.html').readAsStringSync();

  String? metaContent(String name) {
    final m = RegExp(
      '<meta\\s+name="$name"\\s+content="([^"]*)"',
      caseSensitive: false,
    ).firstMatch(html);
    return m?.group(1);
  }

  group('viewport', () {
    test('the tag exists at all', () {
      expect(
        metaContent('viewport'),
        isNotNull,
        reason: 'without it iOS Safari lays the app out at 980 px',
      );
    });

    test('it pins the layout viewport to the device', () {
      expect(metaContent('viewport'), contains('width=device-width'));
      expect(metaContent('viewport'), contains('initial-scale=1.0'));
    });

    test('and browser pinch-zoom is off, so pinch reaches the map', () {
      // A pinch that the browser swallows never reaches flutter_map. This is
      // the actual fix for the reported bug, not a cosmetic addition.
      expect(metaContent('viewport'), contains('user-scalable=no'));
    });
  });

  group('content security policy', () {
    late String csp;

    setUp(() {
      final m = RegExp(
        r'http-equiv="Content-Security-Policy"\s+content="([^"]*)"',
        caseSensitive: false,
        dotAll: true,
      ).firstMatch(html);
      csp = m?.group(1) ?? '';
    });

    test('is present', () => expect(csp, isNotEmpty));

    test('default-src is self, so anything unlisted is denied', () {
      expect(csp, contains("default-src 'self'"));
    });

    test('script-src allows no remote origin', () {
      final scriptSrc = RegExp(
        r'script-src([^;]*)',
      ).firstMatch(csp)?.group(1)?.trim();
      expect(scriptSrc, isNotNull);
      expect(
        scriptSrc,
        isNot(contains('http')),
        reason: 'a remote script origin defeats the whole policy',
      );
      // Flutter compiles CanvasKit and the drift worker to WebAssembly.
      expect(scriptSrc, contains("'wasm-unsafe-eval'"));
      expect(
        scriptSrc,
        isNot(contains("'unsafe-eval'")),
        reason: 'wasm-unsafe-eval is the narrow form; plain unsafe-eval is not',
      );
    });

    test('connect-src still covers the backend this app actually calls', () {
      // Read from the constants, never from a second copy of the URL.
      expect(
        csp,
        contains(SupabaseConfig.url),
        reason:
            'connect-src must list ${SupabaseConfig.url} or sync silently '
            'fails in the browser',
      );
    });

    test('and the tile host the map actually fetches from', () {
      final tileHost = Uri.parse(
        MapConfig.urlTemplate.replaceAll(RegExp(r'\{[a-z]\}'), '0'),
      ).origin;
      expect(csp, contains(tileHost), reason: 'the map would show no tiles');
    });

    test('framing and form posts are denied outright', () {
      // Clickjacking an SOS button is a real consequence, not a theoretical
      // one. frame-ancestors is ignored in a meta tag by design, but keeping
      // it here means it is already correct behind a real header later.
      expect(csp, contains("frame-ancestors 'none'"));
      expect(csp, contains("form-action 'none'"));
      expect(csp, contains("object-src 'none'"));
    });
  });

  test('no referrer is sent to the tile server or anywhere else', () {
    expect(metaContent('referrer'), 'no-referrer');
  });

  test('the description is not still the Flutter template placeholder', () {
    expect(metaContent('description'), isNotNull);
    expect(metaContent('description'), isNot(contains('A new Flutter project')));
  });
}
