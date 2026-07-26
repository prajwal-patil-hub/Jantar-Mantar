import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/groups/application/groups_providers.dart';
import '../providers.dart';
import 'panic_wipe.dart';

final panicWipeProvider = Provider<PanicWipe>(
  (ref) => PanicWipe(
    db: ref.watch(appDatabaseProvider),
    keyStore: ref.watch(keyStoreProvider),
    client: ref.watch(supabaseClientProvider),
  ),
);
