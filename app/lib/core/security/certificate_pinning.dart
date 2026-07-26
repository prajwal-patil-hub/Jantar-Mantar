import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// TLS pinning for the API host (SECURITY.md networking rule).
///
/// **Threat this addresses:** a certificate authority the *device* trusts but
/// we do not — a state- or employer-installed root, or an interception proxy.
/// Ordinary TLS accepts those silently; pinning does not.
///
/// **Mechanism.** We build a [SecurityContext] with `withTrustedRoots: false`
/// and load only the root CAs in `assets/certs/api_roots.pem`. Anything whose
/// chain does not terminate in that bundle fails the handshake — there is no
/// override callback, so it fails closed. Roots (not leaves) are pinned
/// deliberately: leaf certificates rotate every few weeks and would brick the
/// app between releases, while roots last years.
///
/// **Not enabled until the bundle exists.** With no PEM asset the app uses the
/// platform trust store, exactly as before. That is the honest default: a
/// guessed pin is worse than no pin, because it either breaks every request or
/// pins the wrong authority. Generate the real bundle with
/// `tool/fetch_api_roots.sh` **from a trusted network** — running it behind a
/// corporate or sandbox proxy captures the proxy's CA, which would defeat the
/// entire point. See `SECURITY.md` → "Certificate pinning".
///
/// Web is exempt: the browser owns TLS and Dart cannot influence it there.
abstract final class CertificatePinning {
  static const assetPath = 'assets/certs/api_roots.pem';

  /// The pinned client, or null to use the default (unpinned) one.
  ///
  /// Returns null when the bundle is absent or empty, when running on web, or
  /// in debug builds — a developer pointing at a local Supabase stack must not
  /// have to defeat pinning to do it.
  static Future<http.Client?> client() async {
    if (kIsWeb || kDebugMode) return null;

    final pem = await _loadBundle();
    if (pem == null || pem.trim().isEmpty) return null;

    final context = SecurityContext(withTrustedRoots: false)
      ..setTrustedCertificatesBytes(utf8Encode(pem));

    // No badCertificateCallback on purpose: supplying one is how pinning gets
    // accidentally disabled. Absent, a rejected chain throws and stays thrown.
    return IOClient(HttpClient(context: context));
  }

  static Future<String?> _loadBundle() async {
    try {
      return await rootBundle.loadString(assetPath);
    } on Object {
      return null; // Asset not bundled yet.
    }
  }

  @visibleForTesting
  static Uint8List utf8Encode(String pem) => Uint8List.fromList(pem.codeUnits);

  /// Whether a pin bundle is actually in effect, for the diagnostics screen
  /// and the release checklist. Never assume pinning is on — ask.
  static Future<bool> isActive() async => await client() != null;
}
