import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The Android manifest carries invariants no Dart test would otherwise see,
/// and one of them shipped broken.
///
/// **INTERNET was declared only in the DEBUG manifest.** Flutter's template
/// puts it there for hot reload, and it is easy to assume it applies
/// everywhere. It does not: a release APK built from that template has no
/// network permission at all.
///
/// On most apps that is obvious within seconds. On this one it is close to
/// invisible — the app is offline-first, so it degrades exactly as designed:
/// the offline banner appears, cached data renders, nothing errors. It looks
/// like it is working. That is the worst possible failure mode for a bug, so
/// it gets a test.
void main() {
  /// Comments stripped: the manifest *explains* why background location is
  /// absent, and a naive substring search matches that explanation and fails.
  /// What matters is the declarations, not the prose around them.
  String manifest(String flavour) => File(
    'android/app/src/$flavour/AndroidManifest.xml',
  ).readAsStringSync().replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');

  test('the release build can reach the network', () {
    expect(
      manifest('main'),
      contains('android.permission.INTERNET'),
      reason:
          'without this the release APK is permanently offline, and this app '
          'makes that look intentional',
    );
  });

  test('cleartext traffic is refused', () {
    // SECURITY.md networking rule: HTTPS or nothing, regardless of what the
    // Android version defaults to.
    expect(manifest('main'), contains('android:usesCleartextTraffic="false"'));
  });

  test('the app can never follow someone in the background', () {
    // Foreground, per-use location only. ACCESS_BACKGROUND_LOCATION is
    // deliberately absent and must stay that way — for this app it is not a
    // feature with a trade-off, it is a capability that must not exist.
    expect(
      manifest('main'),
      isNot(contains('ACCESS_BACKGROUND_LOCATION')),
      reason: 'a protest app that can track you in the background is a weapon',
    );
  });

  test('the launcher name is the product name', () {
    expect(manifest('main'), contains('android:label="CommonGround"'));
  });
}
