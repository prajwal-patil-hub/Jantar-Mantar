import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers.dart';
import '../data/phone_verification.dart';

/// Test seam: widget tests override this with a fake rather than reaching a
/// real Supabase project.
final phoneVerificationServiceProvider = Provider<PhoneVerificationService>(
  (ref) => PhoneVerificationService(ref.watch(supabaseClientProvider)),
);

/// Whether this device carries a verified phone on its CURRENT account.
///
/// Read from the live session rather than stored separately: a second copy of
/// "are we verified" is a copy that can disagree with the server, and after a
/// panic wipe the stored flag would outlive the account it described.
final hasVerifiedPhoneProvider = Provider<bool>((ref) {
  final phone = ref.watch(supabaseClientProvider)?.auth.currentUser?.phone;
  return phone != null && phone.isNotEmpty;
});

/// Whether first-run (onboarding + sign-in choice) has been completed.
///
/// Persisted so it is shown once, and deliberately *not* treated as auth
/// state: skipping it leaves the person anonymous and fully able to use the
/// app, which is the point of ADR-4.
final firstRunProvider = AsyncNotifierProvider<FirstRunNotifier, bool>(
  FirstRunNotifier.new,
);

class FirstRunNotifier extends AsyncNotifier<bool> {
  static const _key = 'first_run_done';

  @override
  Future<bool> build() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_key) ?? false;
    } on Object {
      // A preferences failure must not strand anyone on the intro. Treating
      // it as "done" fails towards the map, which is what the app is for.
      return true;
    }
  }

  Future<void> complete() async {
    state = const AsyncValue.data(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
    } on Object {
      // The in-memory value still carries this session.
    }
  }
}
