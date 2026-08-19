import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import 'auth_choice_screen.dart';

/// Three skippable slides, then the sign-in choice (ui-ux-spec §1.2 → §1.3).
///
/// Skip is on every slide, not only the last. Someone opening this app for the
/// first time may be doing it because they need water in the next ten minutes,
/// and an intro carousel they cannot leave is the worst possible thing to put
/// between them and the map.
///
/// The spec's third slide offers a map download. That button is deliberately
/// absent for now: FMTC can prefetch a region, but the tile source itself is
/// unsettled (ADR-40), and offering "download ≈8 MB" against a source we are
/// about to move off would either fail or fill the cache with tiles from an
/// endpoint being retired. The slide still states the offline promise, which
/// is true — the cache fills as you use it.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({required this.onDone, super.key});

  final VoidCallback onDone;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _toAuth() => Navigator.of(context).pushReplacement(
    MaterialPageRoute<void>(
      builder: (_) => AuthChoiceScreen(onContinue: widget.onDone),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    final slides = [
      (Icons.map_outlined, l10n.onboardFindTitle, l10n.onboardFindBody),
      (
        Icons.verified_outlined,
        l10n.onboardVerifiedTitle,
        l10n.onboardVerifiedBody,
      ),
      (
        Icons.cloud_off_outlined,
        l10n.onboardOfflineTitle,
        l10n.onboardOfflineBody,
      ),
    ];
    final isLast = _index == slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(onPressed: _toAuth, child: Text(l10n.skip)),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final (icon, title, body) = slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 72),
                        const SizedBox(height: 28),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          body,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < slides.length; i++)
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      i == _index ? Icons.circle : Icons.circle_outlined,
                      size: 10,
                      // Position is also announced by the button label
                      // changing on the last slide, so the dots are not the
                      // only signal.
                      semanticLabel: null,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: () => isLast
                    ? _toAuth()
                    : _pages.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: Text(isLast ? l10n.getStarted : l10n.next),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
