import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../map/application/map_providers.dart';

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
    // Dialing must never crash the SOS screen; failures leave the user on
    // the numbers list so they can dial manually.
    try {
      await launchUrl(Uri(scheme: 'tel', path: number));
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open dialer — dial $number')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFC62828);
    const surface = Color(0xFF111214);

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        foregroundColor: Colors.white,
        title: const Text('SOS'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(
                _fired
                    ? 'SOS queued — it sends the moment any connection '
                          'returns. Calling directly is fastest.'
                    : 'Hold the button for 2–3 seconds to send an SOS to '
                          'volunteers. Calling directly is always available '
                          'below.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 24),
              Expanded(
                // scaleDown keeps the hero content visible on any screen
                // height instead of overflowing (small devices, landscape).
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _fired
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 96,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'SOS queued',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white),
                                minimumSize: const Size(160, 48),
                              ),
                              onPressed: () {
                                _hold.reset();
                                setState(() => _fired = false);
                              },
                              child: const Text("I'm safe — reset"),
                            ),
                          ],
                        )
                      : GestureDetector(
                          onLongPressStart: (_) => _hold.forward(),
                          onLongPressEnd: (_) {
                            if (!_fired) _hold.reset();
                          },
                          onLongPressCancel: () {
                            if (!_fired) _hold.reset();
                          },
                          child: Semantics(
                            label: 'SOS, hold to send',
                            button: true,
                            child: AnimatedBuilder(
                              animation: _hold,
                              builder: (context, _) => SizedBox(
                                width: 220,
                                height: 220,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CircularProgressIndicator(
                                      value: _hold.value,
                                      strokeWidth: 10,
                                      color: Colors.white,
                                      backgroundColor: Colors.white24,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.all(18),
                                      decoration: const BoxDecoration(
                                        color: red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'SOS\nHold to send',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
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
                        ),
                ),
              ),
              _CallTile(
                icon: Icons.local_police_outlined,
                label:
                    'Call emergency (police) — '
                    '${SosScreen.emergencyNumber}',
                onTap: () => _call(SosScreen.emergencyNumber),
              ),
              _CallTile(
                icon: Icons.medical_services_outlined,
                label: 'Call ambulance — ${SosScreen.ambulanceNumber}',
                onTap: () => _call(SosScreen.ambulanceNumber),
              ),
              _CallTile(
                icon: Icons.gavel_outlined,
                label: 'Legal aid helpline — ${SosScreen.legalAidNumber}',
                onTap: () => _call(SosScreen.legalAidNumber),
              ),
              _CallTile(
                icon: Icons.medical_information_outlined,
                label: 'Nearest medical on map',
                onTap: () {
                  ref
                      .read(mapFilterProvider.notifier)
                      .select(FacilityType.medical);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Sharing location with a trusted contact arrives in a later '
                'build — always explicit, per use.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
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
