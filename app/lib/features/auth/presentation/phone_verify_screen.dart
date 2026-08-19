import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../application/auth_providers.dart';
import '../data/phone_verification.dart';

/// Optional phone verification (ui-ux-spec §1.3, ADR-4).
///
/// Two things this screen must never do, both of which are the whole reason it
/// is written by hand rather than dropped in from a package:
///
///  * It must never become a dead end. Every failure state keeps a visible
///    "continue without a phone" action, because the failure most likely to
///    happen here is a network shutdown during the protest, and the correct
///    response to that is to carry on anonymously — not to retry.
///  * It must never imply verification is required. The app is fully usable
///    without it; the phone raises report trust weighting and nothing else.
class PhoneVerifyScreen extends ConsumerStatefulWidget {
  const PhoneVerifyScreen({super.key});

  @override
  ConsumerState<PhoneVerifyScreen> createState() => _PhoneVerifyScreenState();
}

class _PhoneVerifyScreenState extends ConsumerState<PhoneVerifyScreen> {
  final _phone = TextEditingController();
  final _code = TextEditingController();

  String? _e164;
  bool _busy = false;
  PhoneVerificationOutcome? _outcome;
  String? _detail;

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppL10n.of(context);
    final e164 = toE164(_phone.text);
    if (e164 == null) {
      setState(() {
        _outcome = null;
        _detail = l10n.phoneInvalid;
      });
      return;
    }
    setState(() {
      _busy = true;
      _detail = null;
    });
    final result = await ref
        .read(phoneVerificationServiceProvider)
        .sendCode(e164);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _outcome = result.outcome;
      _detail = result.detail;
      if (result.ok) _e164 = e164;
    });
  }

  Future<void> _confirm() async {
    final e164 = _e164;
    if (e164 == null) return;
    setState(() {
      _busy = true;
      _detail = null;
    });
    final result = await ref
        .read(phoneVerificationServiceProvider)
        .confirmCode(e164: e164, token: _code.text.trim());
    if (!mounted) return;
    setState(() {
      _busy = false;
      _outcome = result.outcome;
      _detail = result.detail;
    });
    if (result.outcome == PhoneVerificationOutcome.verified && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final awaitingCode = _e164 != null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.verifyWithPhone)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              l10n.phoneWhyBody,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _phone,
              enabled: !awaitingCode && !_busy,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
              decoration: InputDecoration(
                labelText: l10n.phoneNumber,
                hintText: l10n.phoneHint,
                border: const OutlineInputBorder(),
              ),
            ),
            if (awaitingCode) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _code,
                enabled: !_busy,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                decoration: InputDecoration(
                  labelText: l10n.otpCode,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],

            if (_outcome != null || _detail != null) ...[
              const SizedBox(height: 16),
              _Feedback(outcome: _outcome, detail: _detail),
            ],

            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : (awaitingCode ? _confirm : _send),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: _busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(awaitingCode ? l10n.confirmCode : l10n.sendCode),
            ),

            const SizedBox(height: 12),
            // Always present, in every state. This is the escape hatch that
            // makes the screen safe to enter: if SMS is jammed, the person is
            // one tap from the map rather than stuck in a retry loop.
            TextButton(
              onPressed: _busy ? null : () => Navigator.of(context).pop(false),
              child: Text(l10n.continueWithoutPhone),
            ),

            const SizedBox(height: 8),
            Text(
              l10n.phoneNeverShown,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Outcome-specific copy. A generic "something went wrong" here is actively
/// harmful: "wrong code" invites a retry, "SMS could not be delivered" invites
/// the anonymous path, and confusing the two wastes the one thing a person at
/// a protest does not have.
class _Feedback extends StatelessWidget {
  const _Feedback({required this.outcome, required this.detail});

  final PhoneVerificationOutcome? outcome;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;

    final (message, isError) = switch (outcome) {
      PhoneVerificationOutcome.sent => (l10n.otpSent, false),
      PhoneVerificationOutcome.verified => (l10n.otpVerified, false),
      PhoneVerificationOutcome.wrongCode => (l10n.otpWrong, true),
      PhoneVerificationOutcome.expiredCode => (l10n.otpExpired, true),
      PhoneVerificationOutcome.rateLimited => (l10n.otpRateLimited, true),
      PhoneVerificationOutcome.undeliverable => (l10n.otpUndeliverable, true),
      PhoneVerificationOutcome.notConfigured => (l10n.otpNotConfigured, true),
      PhoneVerificationOutcome.failed => (l10n.otpFailed, true),
      null => (detail ?? '', true),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              size: 20,
              color: isError ? scheme.error : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isError ? scheme.error : null,
                ),
              ),
            ),
          ],
        ),
        // Server text goes in the details slot, never the headline.
        if (detail != null && outcome != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(detail!, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ],
    );
  }
}
