import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../l10n/app_localizations.dart';
import '../data/location_share.dart';

/// "Share my location" (E7). Consent screen first, GPS second.
///
/// The sheet exists so the permission prompt is never the first thing the
/// user sees: it states plainly what a single reading does, who can see it,
/// and that nothing is stored by us — then asks. Every use goes through this
/// screen again; there is no "remember my choice", because a location shared
/// once is not consent to share it later.
class ShareLocationSheet extends ConsumerStatefulWidget {
  const ShareLocationSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const ShareLocationSheet(),
  );

  @override
  ConsumerState<ShareLocationSheet> createState() => _ShareLocationSheetState();
}

class _ShareLocationSheetState extends ConsumerState<ShareLocationSheet> {
  bool _busy = false;

  String _failureText(AppL10n l10n, LocationFailure reason) => switch (reason) {
    LocationFailure.serviceOff => l10n.locationServiceOff,
    LocationFailure.denied => l10n.locationDenied,
    LocationFailure.deniedForever => l10n.locationDeniedForever,
    LocationFailure.timeout => l10n.locationTimeout,
  };

  Future<void> _share() async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);

    final result = await ref.read(locationServiceProvider).currentFix();
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result) {
      case LocationDenied(:final reason):
        // Nothing was captured, so say exactly that — a failed share must
        // never leave the user unsure whether their position went out.
        messenger.showSnackBar(
          SnackBar(content: Text(_failureText(l10n, reason))),
        );
        navigator.pop();
      case final LocationFix fix:
        final text = l10n.shareLocationMessage(
          fix.osmUrl,
          fix.accuracyMeters.round(),
          TimeOfDay.fromDateTime(fix.at.toLocal()).format(context),
        );
        try {
          await SharePlus.instance.share(ShareParams(text: text));
        } on Object {
          // No share sheet (web, locked-down device): the clipboard still
          // lets them paste it into whatever they trust.
          await Clipboard.setData(ClipboardData(text: text));
          messenger.showSnackBar(SnackBar(content: Text(text)));
        }
        if (mounted) navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.share_location),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.shareLocationTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(l10n.shareLocationBody),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    onPressed: _busy ? null : () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    onPressed: _busy ? null : _share,
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: Text(l10n.shareLocationConfirm),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
