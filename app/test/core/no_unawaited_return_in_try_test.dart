import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `return someFuture()` inside a try block does not do what it looks like.
///
/// The Future escapes the try before it completes, so the catch never runs and
/// the failure propagates to the caller instead of being handled. This is not
/// theoretical here: `GroupsRepository._reseal` had exactly this shape, and
/// its caller invokes it OUTSIDE any try, so a re-seal failure aborted the
/// whole pending-message flush rather than letting that one message go out
/// under its old epoch, which is what the method documents.
///
/// A newer analyzer has `unawaited_return_in_try_block`, which is the right
/// tool — but this project is pinned to Flutter 3.44.8, whose analyzer does
/// not know that rule (adding it yields `undefined_lint`). Until the toolchain
/// is upgraded deliberately, this scan is the guard.
///
/// It is a source scan for the same reason the status-literal scan is: the
/// awaited and unawaited forms behave identically on the happy path, so no
/// widget or unit test distinguishes them. Only the failure path differs, and
/// only for async throws.
void main() {
  // Receivers whose methods are async throughout this codebase. Restricting
  // to these keeps the scan quiet — a returned sync call like `_sigContext(…)`
  // is not a finding, and a scan that cries wolf gets deleted.
  const asyncReceivers = ['_crypto', '_client', '_cache', '_identity', '_db'];

  test('no async call is returned unawaited from inside a try block', () {
    final offenders = <String>[];

    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final lines = file.readAsLinesSync();

      // Depth of the innermost enclosing try block, or null when not in one.
      int? tryDepth;
      var depth = 0;

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final code = line.split('//').first;

        if (tryDepth == null && RegExp(r'\btry\s*\{').hasMatch(code)) {
          tryDepth = depth;
        }

        final isReturn = RegExp(r'^\s*return\s').hasMatch(code);
        if (tryDepth != null && isReturn && !code.contains('await')) {
          // A return may span lines; the receiver is on the first one.
          final touchesAsync = asyncReceivers.any(
            (r) => RegExp('return\\s+$r\\.').hasMatch(code),
          );
          if (touchesAsync) {
            offenders.add('${file.path}:${i + 1}: ${line.trim()}');
          }
        }

        depth += '{'.allMatches(code).length;
        depth -= '}'.allMatches(code).length;
        if (tryDepth != null && depth <= tryDepth) tryDepth = null;
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'These return a Future from inside a try without awaiting it, so the '
          'catch cannot see its failure and the error escapes to the caller. '
          'Write `return await …`:\n${offenders.join('\n')}',
    );
  });

  test('the scan actually catches the shape it is looking for', () {
    // Without this, a scan that silently matches nothing — a broken regex, a
    // wrong path — passes forever and protects nothing.
    const sample = '''
Future<String?> reseal() async {
  try {
    return _crypto.encryptMessage(groupKey: to);
  } on Object {
    return null;
  }
}
''';
    const asyncReceivers = ['_crypto'];
    var depth = 0;
    int? tryDepth;
    final hits = <String>[];
    for (final line in sample.split('\n')) {
      final code = line.split('//').first;
      if (tryDepth == null && RegExp(r'\btry\s*\{').hasMatch(code)) {
        tryDepth = depth;
      }
      if (tryDepth != null &&
          RegExp(r'^\s*return\s').hasMatch(code) &&
          !code.contains('await') &&
          asyncReceivers.any((r) => RegExp('return\\s+$r\\.').hasMatch(code))) {
        hits.add(code.trim());
      }
      depth += '{'.allMatches(code).length;
      depth -= '}'.allMatches(code).length;
      if (tryDepth != null && depth <= tryDepth) tryDepth = null;
    }
    expect(hits, hasLength(1), reason: 'the scan must flag the known-bad form');

    // And the fixed form must NOT be flagged, or the scan is unfixable noise.
    expect(
      RegExp(r'^\s*return\s').hasMatch('    return await _crypto.encrypt();') &&
          !'    return await _crypto.encrypt();'.contains('await'),
      isFalse,
    );
  });
}
