import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shell/home_shell.dart';
import '../application/auth_providers.dart';
import 'onboarding_screen.dart';

/// Decides between the intro flow and the app (ui-ux-spec §1.1).
///
/// The "splash" here is deliberately not a branded hold. The spec asks for a
/// logo and a loader, but it also says an offline cold start must skip
/// straight to the cached map — and the performance target is under three
/// seconds to a usable map on a sub-2GB phone. A timed splash spends that
/// budget on nothing. All this waits for is one SharedPreferences read of a
/// single bool, which resolves in a frame or two; the brief blank is the
/// scaffold background rather than a spinner, so it does not read as loading.
///
/// If that read fails, [FirstRunNotifier] reports "done" and this falls
/// through to the map. Failing towards the map is the only correct direction:
/// nobody should be stuck on an intro carousel because a preferences file is
/// unreadable.
class FirstRunGate extends ConsumerWidget {
  const FirstRunGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstRunDone = ref.watch(firstRunProvider);

    return firstRunDone.when(
      loading: () => const Scaffold(body: SizedBox.shrink()),
      // An error is already handled inside the notifier, so this branch only
      // fires on something unexpected — and it still lands on the map.
      error: (_, _) => const HomeShell(),
      data: (done) => done
          ? const HomeShell()
          : OnboardingScreen(
              onDone: () async {
                await ref.read(firstRunProvider.notifier).complete();
                if (!context.mounted) return;
                // pushAndRemoveUntil, not push: the intro must not be
                // reachable with the back button once it is finished.
                await Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(builder: (_) => const HomeShell()),
                  (route) => false,
                );
              },
            ),
    );
  }
}
