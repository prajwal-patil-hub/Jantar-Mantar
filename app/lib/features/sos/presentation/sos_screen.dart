import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../map/application/map_providers.dart';
import 'share_location_sheet.dart';

/// SOS screen (ui-ux-spec §1.9): full-screen, high contrast, NO glass.
/// Huge hold-to-send button with a radial countdown; direct-call tiles that
/// work regardless of app connectivity; "I'm safe" reset after firing.
/// India emergency numbers; make these site-configurable before new regions.
class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  static const emergencyNumber = '112'; // national emergency (all services)
  static const ambulanceNumber = '108';
  static const legalAidNumber = '15100'; // NALSA legal aid helpline

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen>
    with SingleTickerProviderStateMixin {
  static const _holdDuration = Duration(milliseconds: 2500);

  late final AnimationController _hold = AnimationController(
    vsync: this,
    duration: _holdDuration,
  );
  bool _fired = false;

  @override
  void initState() {
    super.initState();
    _hold.addStatusListener((status) {
      if (status == AnimationStatus.completed) _fire();
    });
  }

  @override
  void dispose() {
    _hold.dispose();
    super.dispose();
  }

  Future<void> _fire() async {
    setState(() => _fired = true);
    await ref.read(sosRepositoryProvider).fireSos();
  }

  Future<void> _call(String number) async {
    final l10n = AppL10n.of(context);
    // Dialing must never crash the SOS screen; failures leave the user on
    // the numbers list so they can dial manually.
    try {
      await launchUrl(Uri(scheme: 'tel', path: number));
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.couldNotDial(number))));
    }
  }

  /// Ideal and minimum diameter for the hold disc. The floor is double the
  /// 48 dp guideline on purpose: this is a control someone operates while
  /// running, in the rain, possibly one-handed.
  static const double _idealDiscSize = 220;
  static const double _minDiscSize = 96;

  /// Share of the body height reserved for the hero, and the bounds it may
  /// not leave. 42% keeps the disc dominant without crowding out the call
  /// tiles on a tall screen.
  static const double _heroShare = 0.42;
  static const double _minHeroHeight = 112;
  static const double _maxHeroHeight = 260;

  double _discSize(double heroHeight, double maxWidth) {
    final available = heroHeight < maxWidth ? heroHeight : maxWidth;
    return available.clamp(_minDiscSize, _idealDiscSize);
  }

  Widget _hero(AppL10n l10n, Color red, double size) {
    if (_fired) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 72),
          const SizedBox(height: 16),
          Text(
            l10n.sosQueued,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              minimumSize: const Size(160, AppTokens.minTouchTarget),
            ),
            onPressed: () {
              _hold.reset();
              setState(() => _fired = false);
            },
            child: Text(l10n.imSafeReset),
          ),
        ],
      );
    }

    final big = size > 150;
    return GestureDetector(
      onLongPressStart: (_) => _hold.forward(),
      onLongPressEnd: (_) {
        if (!_fired) _hold.reset();
      },
      onLongPressCancel: () {
        if (!_fired) _hold.reset();
      },
      child: Semantics(
        label: l10n.sosSemanticsHold,
        button: true,
        child: AnimatedBuilder(
          animation: _hold,
          builder: (context, _) => SizedBox(
            width: size,
            height: size,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: _hold.value,
                  strokeWidth: big ? 10 : 7,
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                ),
                Container(
                  margin: EdgeInsets.all(big ? 18 : 12),
                  decoration: BoxDecoration(color: red, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      l10n.sosHoldToSend,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: big ? 24 : 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    // Read straight off the constant, not off the theme: this screen renders
    // identically in light and dark on purpose, and StatusColors is
    // theme-invariant by design — so the token can be honoured without the
    // screen becoming theme-dependent. What it must NOT be is a copied hex.
    final red = StatusColors.standard.out;
    const surface = Color(0xFF111214); // deliberate near-black, not a token

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        foregroundColor: Colors.white,
        title: Text(l10n.sos),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          // The hero gets a guaranteed share of the height and the secondary
          // tiles give way, not the other way round (ADR-34).
          //
          // Before this, the whole column was fixed and the hero took
          // whatever was left over. Measured disc diameter, before → after:
          // 360×640 overflowed outright → 220; 390×844 165 → 220;
          // 800×600 41 → 212. FittedBox(scaleDown) is what hid it — scaling
          // a control away is not the same as fitting it, and a control
          // someone reaches for in an emergency does not get to be the thing
          // that shrinks.
          child: LayoutBuilder(
            builder: (context, constraints) {
              final heroHeight = (constraints.maxHeight * _heroShare).clamp(
                _minHeroHeight,
                _maxHeroHeight,
              );
              return Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    _fired
                        ? l10n.sosQueuedInstruction
                        : l10n.sosHoldInstruction,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: heroHeight,
                    child: Center(
                      child: _hero(
                        l10n,
                        red,
                        _discSize(heroHeight, constraints.maxWidth),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Secondary actions. These scroll when the screen is short;
                  // the hero above never does, because a scrollable ancestor
                  // would also join the gesture arena and swallow the hold.
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _CallTile(
                          icon: Icons.local_police_outlined,
                          label: l10n.callPolice(SosScreen.emergencyNumber),
                          onTap: () => _call(SosScreen.emergencyNumber),
                        ),
                        _CallTile(
                          icon: Icons.medical_services_outlined,
                          label: l10n.callAmbulance(SosScreen.ambulanceNumber),
                          onTap: () => _call(SosScreen.ambulanceNumber),
                        ),
                        _CallTile(
                          icon: Icons.gavel_outlined,
                          label: l10n.callLegalAid(SosScreen.legalAidNumber),
                          onTap: () => _call(SosScreen.legalAidNumber),
                        ),
                        _CallTile(
                          icon: Icons.share_location,
                          label: l10n.shareMyLocation,
                          onTap: () => ShareLocationSheet.show(context),
                        ),
                        _CallTile(
                          icon: Icons.medical_information_outlined,
                          label: l10n.nearestMedical,
                          onTap: () {
                            ref
                                .read(mapFilterProvider.notifier)
                                .select(FacilityType.medical);
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.shareLocationLater,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CallTile extends StatelessWidget {
  const _CallTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
