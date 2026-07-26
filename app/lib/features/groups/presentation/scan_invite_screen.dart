import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../l10n/app_localizations.dart';

/// Scans an invite QR and pops the code back to the caller.
///
/// `mobile_scanner` per project rule (never `qr_code_scanner`, unmaintained).
/// The camera is a hard dependency here, so every failure mode — no camera,
/// permission denied, unsupported platform — falls back to a clear message
/// and the code-paste path, which always works.
class ScanInviteScreen extends StatefulWidget {
  const ScanInviteScreen({super.key});

  @override
  State<ScanInviteScreen> createState() => _ScanInviteScreenState();
}

/// Extracts an invite code from whatever a QR happens to contain.
///
/// A scanned QR is attacker-controlled input, so this is the security
/// boundary: only a well-formed code reaches the join flow. Accepts a bare
/// code or a link carrying one, so a future deep link works unchanged.
String? inviteCodeFrom(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  final fromQuery = Uri.tryParse(trimmed)?.queryParameters['code'];
  final candidate = (fromQuery ?? trimmed).toUpperCase();
  // Codes are 8 chars from an unambiguous alphabet (no O/0, no I/1).
  return RegExp(r'^[A-HJ-NP-Z2-9]{8}$').hasMatch(candidate) ? candidate : null;
}

class _ScanInviteScreenState extends State<ScanInviteScreen> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final code = inviteCodeFrom(barcode.rawValue ?? '');
      if (code != null) {
        _handled = true;
        Navigator.of(context).pop(code);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanInvite)),
      body: kIsWeb
          // The web build has no reliable camera path and this app must stay
          // usable there; say so plainly instead of showing a dead viewfinder.
          ? _Unavailable(message: l10n.scanUnavailable)
          : Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                  errorBuilder: (context, error) => _Unavailable(
                    message: l10n.scanFailed('${error.errorCode}'),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    color: Colors.black.withValues(alpha: 0.6),
                    padding: const EdgeInsets.all(16),
                    child: SafeArea(
                      top: false,
                      child: Text(
                        l10n.scanInviteHint,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_outlined, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.enterCodeInstead),
            ),
          ],
        ),
      ),
    );
  }
}
