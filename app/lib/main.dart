import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/supabase_config.dart';
import 'core/map/map_config.dart';
import 'core/map/tile_providers.dart';
import 'core/providers.dart';
import 'core/security/certificate_pinning.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Offline tile cache. If FMTC can't start (e.g. web, storage failure) the
  // app keeps the NetworkTileProvider default — it must boot regardless
  // (offline-first: never block startup on infrastructure).
  var fmtcReady = false;
  try {
    await FMTCObjectBoxBackend().initialise();
    await const FMTCStore(MapConfig.tileStore).manage.create();
    fmtcReady = true;
  } on Object {
    fmtcReady = false;
  }

  // Supabase init is local (no network round-trip); sign-in and sync happen
  // later in the background. Failure here degrades to offline-only.
  SupabaseClient? supabaseClient;
  try {
    // Null unless a pin bundle is shipped — see CertificatePinning. When it is
    // present the handshake fails closed against any CA outside the bundle,
    // including one installed on the device.
    final pinnedClient = await CertificatePinning.client();
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
      httpClient: pinnedClient,
    );
    supabaseClient = Supabase.instance.client;
  } on Object {
    supabaseClient = null;
  }

  runApp(
    ProviderScope(
      overrides: [
        if (fmtcReady)
          mapTileProviderProvider.overrideWith(
            (ref) => FMTCTileProvider(
              stores: const {
                MapConfig.tileStore: BrowseStoreStrategy.readUpdateCreate,
              },
            ),
          ),
        supabaseClientProvider.overrideWithValue(supabaseClient),
      ],
      child: const CommonGroundApp(),
    ),
  );
}
