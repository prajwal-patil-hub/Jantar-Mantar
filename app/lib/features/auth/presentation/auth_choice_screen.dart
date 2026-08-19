import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/locale_provider.dart';
import '../../../core/theme/depth.dart';
import '../../../core/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import 'phone_verify_screen.dart';

/// Sign-in choice (ui-ux-spec §1.3).
///
/// Anonymous is the primary action and the recommended one, and that ranking
/// is a security position rather than a style: SMS-OTP is the weakest common
/// second factor (SIM swap, interception), and it stops working precisely
/// during the network shutdowns this app is built for. Phone verification is
/// offered because it raises report trust weighting — never because anything
/// requires it (ADR-4).
///
/// Nothing on this screen blocks. Anonymous sign-in already happens in the
/// background, so "Continue anonymously" is a dismissal, not a network call —
/// the offline-first rule means a person with no signal must still get to the
/// map from here.
class AuthChoiceScreen extends ConsumerWidget {
  const AuthChoiceScreen({required this.onContinue, super.key});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.signIn, style: text.headlineSmall),
                  const _LanguageToggle(),
                ],
              ),
              const SizedBox(height: 12),
              Text(l10n.authNoPersonalDetails, style: text.bodyMedium),
              const Spacer(),

              FilledButton.icon(
                onPressed: onContinue,
                icon: const Icon(Icons.arrow_forward),
                label: Text(l10n.continueAnonymously),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final verified = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => const PhoneVerifyScreen(),
                    ),
                  );
                  // Verifying does not change where you land: the phone only
                  // raises trust weighting, so either way the next screen is
                  // the map.
                  if (verified ?? false) onContinue();
                },
                icon: const Icon(Icons.sms_outlined),
                label: Text(l10n.verifyWithPhone),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _showTradeoffs(context),
                child: Text(l10n.whichShouldIChoose),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.authPrivacySummary,
                style: text.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The comparison from the spec, verbatim in substance: it exists so the
  /// person can see that the phone option is worse in exactly the situation
  /// they are most likely to be in.
  void _showTradeoffs(BuildContext context) {
    final l10n = AppL10n.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.whichShouldIChoose,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                // Wide content scrolls inside its own box rather than making
                // the sheet scroll sideways.
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text(l10n.tradeoffAspect)),
                      DataColumn(label: Text(l10n.anonymous)),
                      DataColumn(label: Text(l10n.phoneOtp)),
                    ],
                    rows: [
                      _row(
                        l10n.tradeoffPrivacy,
                        l10n.tradeoffPrivacyAnon,
                        l10n.tradeoffPrivacyOtp,
                      ),
                      _row(
                        l10n.tradeoffTrust,
                        l10n.tradeoffTrustAnon,
                        l10n.tradeoffTrustOtp,
                      ),
                      _row(
                        l10n.tradeoffAbuse,
                        l10n.tradeoffAbuseAnon,
                        l10n.tradeoffAbuseOtp,
                      ),
                      _row(
                        l10n.tradeoffJamming,
                        l10n.tradeoffJammingAnon,
                        l10n.tradeoffJammingOtp,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                DepthSurface(
                  elevation: Elevation.card,
                  radius: AppTokens.radiusCard,
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    l10n.tradeoffRecommendation,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static DataRow _row(String a, String b, String c) =>
      DataRow(cells: [DataCell(Text(a)), DataCell(Text(b)), DataCell(Text(c))]);
}

class _LanguageToggle extends ConsumerWidget {
  const _LanguageToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isHindi = locale?.languageCode == 'hi';
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(value: false, label: Text('EN')),
        ButtonSegment(value: true, label: Text('हिं')),
      ],
      selected: {isHindi},
      showSelectedIcon: false,
      onSelectionChanged: (s) => ref
          .read(localeProvider.notifier)
          .setLocale(s.first ? const Locale('hi') : const Locale('en')),
    );
  }
}
