import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/features/auth/data/phone_verification.dart';

/// Optional phone verification (ui-ux-spec §1.3, ADR-4).
void main() {
  group('E.164 normalisation', () {
    test('accepts a bare 10-digit Indian mobile', () {
      expect(toE164('9876543210'), '+919876543210');
    });

    test('accepts the common prefixes people actually type', () {
      for (final input in [
        '09876543210',
        '919876543210',
        '+919876543210',
        '0091 98765 43210',
        '+91 98765-43210',
        '(98765) 43210',
      ]) {
        expect(toE164(input), '+919876543210', reason: 'failed on "$input"');
      }
    });

    test('keeps a full international number as given', () {
      expect(toE164('+442071838750'), '+442071838750');
    });

    group('refuses rather than guessing', () {
      // Every case here would, if coerced, send someone's verification code
      // to a number they did not enter. Returning null puts the correction in
      // front of the person instead.
      const bad = {
        'empty': '',
        'too short': '98765',
        'too long for India': '98765432101',
        'letters': '98765abcde',
        'landline-style leading digit': '1234567890',
        'starts with 5, not an Indian mobile': '5876543210',
        'plus with nothing after it': '+',
        'plus with letters': '+91987654abc',
      };
      bad.forEach((why, input) {
        test(why, () => expect(toE164(input), isNull, reason: input));
      });
    });

    test('an 11-digit number not starting 0 is not silently trimmed', () {
      // The 0-stripping branch must not become "drop any leading digit".
      expect(toE164('19876543210'), isNull);
    });
  });

  group('with no backend configured', () {
    const service = PhoneVerificationService(null);

    test('reports notConfigured rather than failing silently', () async {
      final sent = await service.sendCode('+919876543210');
      expect(sent.outcome, PhoneVerificationOutcome.notConfigured);
      expect(sent.ok, isFalse);

      final confirmed = await service.confirmCode(
        e164: '+919876543210',
        token: '123456',
      );
      expect(confirmed.outcome, PhoneVerificationOutcome.notConfigured);
    });

    test('isAvailable is false', () {
      expect(service.isAvailable, isFalse);
    });
  });

  group('outcomes that must stay distinct', () {
    // "Wrong code" invites a retry; "could not be delivered" invites the
    // anonymous path. Collapsing them into one generic failure sends someone
    // into a retry loop during exactly the network shutdown the anonymous
    // path exists for.
    test('sent and verified are the only ok outcomes', () {
      for (final o in PhoneVerificationOutcome.values) {
        final ok = PhoneVerificationResult(o).ok;
        expect(
          ok,
          o == PhoneVerificationOutcome.sent ||
              o == PhoneVerificationOutcome.verified,
          reason: '$o classified as ok=$ok',
        );
      }
    });

    test('undeliverable is its own outcome, not folded into failed', () {
      expect(
        PhoneVerificationOutcome.values,
        containsAll([
          PhoneVerificationOutcome.undeliverable,
          PhoneVerificationOutcome.failed,
          PhoneVerificationOutcome.wrongCode,
          PhoneVerificationOutcome.expiredCode,
          PhoneVerificationOutcome.rateLimited,
        ]),
      );
    });
  });
}
