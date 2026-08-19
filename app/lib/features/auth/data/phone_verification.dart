import 'package:supabase_flutter/supabase_flutter.dart';

/// Why a verification attempt ended, so the UI can say something true.
///
/// `undeliverable` is not a generic failure. SMS is the one factor that stops
/// working exactly when this app matters most — during a network shutdown or
/// SMS jamming at a protest — so it gets its own outcome and its own copy
/// pointing back at the anonymous path, per ui-ux-spec §1.3.
enum PhoneVerificationOutcome {
  sent,
  verified,
  wrongCode,
  expiredCode,
  rateLimited,
  undeliverable,
  notConfigured,
  failed,
}

class PhoneVerificationResult {
  const PhoneVerificationResult(this.outcome, {this.detail});

  final PhoneVerificationOutcome outcome;

  /// Server text, for the `details` slot of an error view — never the
  /// headline, per the shared-state rule.
  final String? detail;

  bool get ok =>
      outcome == PhoneVerificationOutcome.sent ||
      outcome == PhoneVerificationOutcome.verified;
}

/// Optional phone verification (ui-ux-spec §1.3, ADR-4).
///
/// **This upgrades the existing anonymous account; it never signs in as a new
/// one.** `signInWithOtp` would mint or switch to a different user id, and the
/// anonymous id is what every submission, trust counter and group membership
/// is attached to — verifying a phone that way would silently orphan
/// everything the person had already contributed and drop them back to the
/// `new` tier. So the flow is `updateUser(phone:)` followed by a
/// `phoneChange` OTP, which keeps `auth.uid()` stable.
///
/// Nothing here is ever required. Verification only raises trust weighting;
/// every screen stays usable anonymously, and the server never exposes the
/// number to other users.
class PhoneVerificationService {
  const PhoneVerificationService(this._client);

  final SupabaseClient? _client;

  bool get isAvailable => _client != null;

  /// Ask Supabase to send a code to [e164]. Number must already be in E.164.
  Future<PhoneVerificationResult> sendCode(String e164) async {
    final client = _client;
    if (client == null) {
      return const PhoneVerificationResult(
        PhoneVerificationOutcome.notConfigured,
      );
    }
    try {
      await client.auth.updateUser(UserAttributes(phone: e164));
      return const PhoneVerificationResult(PhoneVerificationOutcome.sent);
    } on AuthException catch (e) {
      return PhoneVerificationResult(_classify(e), detail: e.message);
    } on Object catch (e) {
      // No connection at all is the SMS-jamming case from the app's point of
      // view: the code is not coming, and the honest next step is the same.
      return PhoneVerificationResult(
        PhoneVerificationOutcome.undeliverable,
        detail: e.toString(),
      );
    }
  }

  /// Confirm the code. On success the SAME user now carries a phone.
  Future<PhoneVerificationResult> confirmCode({
    required String e164,
    required String token,
  }) async {
    final client = _client;
    if (client == null) {
      return const PhoneVerificationResult(
        PhoneVerificationOutcome.notConfigured,
      );
    }
    try {
      await client.auth.verifyOTP(
        phone: e164,
        token: token,
        // phoneChange, not sms: `sms` is the sign-in verification and would
        // resolve to a different session. This one confirms a change on the
        // account already signed in, which is the whole point.
        type: OtpType.phoneChange,
      );
      return const PhoneVerificationResult(PhoneVerificationOutcome.verified);
    } on AuthException catch (e) {
      return PhoneVerificationResult(_classify(e), detail: e.message);
    } on Object catch (e) {
      return PhoneVerificationResult(
        PhoneVerificationOutcome.failed,
        detail: e.toString(),
      );
    }
  }

  /// Supabase reports these as text, so matching is on substrings. Anything
  /// unrecognised stays `failed` rather than being guessed into a friendlier
  /// bucket — telling someone their code was wrong when the service is down
  /// sends them into a retry loop that cannot succeed.
  static PhoneVerificationOutcome _classify(AuthException e) {
    final m = e.message.toLowerCase();
    if (m.contains('expired')) return PhoneVerificationOutcome.expiredCode;
    if (m.contains('invalid') || m.contains('incorrect')) {
      return PhoneVerificationOutcome.wrongCode;
    }
    if (m.contains('rate limit') || m.contains('too many')) {
      return PhoneVerificationOutcome.rateLimited;
    }
    if (m.contains('sms') ||
        m.contains('provider') ||
        m.contains('not enabled') ||
        m.contains('unsupported')) {
      return PhoneVerificationOutcome.undeliverable;
    }
    return PhoneVerificationOutcome.failed;
  }
}

/// E.164 normalisation for Indian numbers, which is what the sites are.
///
/// Deliberately narrow: it accepts a bare 10-digit Indian mobile, the same
/// with 0, 91 or +91 in front, and otherwise requires the user to type a full
/// international number. Guessing a country code for an arbitrary string is
/// how people end up sending an OTP to a stranger.
String? toE164(String input, {String defaultCountry = '+91'}) {
  final cleaned = input.replaceAll(RegExp(r'[\s()\-.]'), '');
  if (cleaned.isEmpty) return null;

  if (cleaned.startsWith('+')) {
    final digits = cleaned.substring(1);
    if (!RegExp(r'^\d{8,15}$').hasMatch(digits)) return null;
    return '+$digits';
  }

  var digits = cleaned;
  if (digits.startsWith('00')) digits = digits.substring(2);
  if (digits.startsWith('91') && digits.length == 12) return '+$digits';
  if (digits.startsWith('0') && digits.length == 11) {
    digits = digits.substring(1);
  }

  // Indian mobile numbers are 10 digits and start 6-9.
  if (RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) return '$defaultCountry$digits';
  return null;
}
