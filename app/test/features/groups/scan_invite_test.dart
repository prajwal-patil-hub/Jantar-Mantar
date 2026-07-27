import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/features/groups/presentation/scan_invite_screen.dart';

/// The scanner reads whatever is in front of it, so parsing is the security
/// boundary: only a well-formed invite code may be handed to the join flow.
void main() {
  test('accepts a bare invite code, case-insensitively', () {
    expect(inviteCodeFrom('ABCD2345'), 'ABCD2345');
    expect(inviteCodeFrom(' abcd2345 '), 'ABCD2345');
  });

  test('accepts a link carrying the code', () {
    expect(
      inviteCodeFrom('https://example.org/join?code=ABCD2345'),
      'ABCD2345',
    );
  });

  test('rejects anything that is not an invite code', () {
    // A QR in the wild is attacker-controlled input — none of this reaches
    // joinByCode.
    for (final junk in [
      '',
      '   ',
      'hello world',
      'ABCD234', // too short
      'ABCD23456', // too long
      'ABCD01IO', // excluded ambiguous characters
      'javascript:alert(1)',
      'https://evil.example/?code=<script>',
    ]) {
      expect(inviteCodeFrom(junk), isNull, reason: 'should reject "$junk"');
    }
  });
}
