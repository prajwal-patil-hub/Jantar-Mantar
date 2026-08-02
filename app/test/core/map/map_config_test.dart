import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/map/map_config.dart';

/// The tile User-Agent must identify this app.
///
/// OSM's tile usage policy requires a User-Agent that identifies the
/// application well enough to contact whoever runs it, and explicitly blocks
/// generic or default ones. `MapConfig.userAgentPackageName` sat at Flutter's
/// `com.example.jantar_mantar_sahayata` long after the real applicationId was
/// set, so the map was one enforcement sweep away from silently serving no
/// tiles — and "no tiles" on this app looks identical to "offline".
///
/// Checked against the Android manifest rather than a second copy of the
/// string, so the two cannot drift apart again.
void main() {
  test('the tile User-Agent is not a placeholder', () {
    expect(
      MapConfig.userAgentPackageName,
      isNot(startsWith('com.example')),
      reason: 'OSM blocks default User-Agents',
    );
    expect(MapConfig.userAgentPackageName, contains('.'));
  });

  test('and it matches the Android applicationId', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final match = RegExp(
      r'applicationId\s*=\s*"([^"]+)"',
    ).firstMatch(gradle);

    expect(match, isNotNull, reason: 'could not read the applicationId');
    expect(
      MapConfig.userAgentPackageName,
      match!.group(1),
      reason:
          'the User-Agent is meant to identify this app — if the '
          'applicationId changes, this must follow',
    );
  });

  test('tiles are fetched over TLS', () {
    // Plain HTTP would be both a downgrade and a mixed-content failure on the
    // hosted web build.
    expect(MapConfig.urlTemplate, startsWith('https://'));
  });
}
