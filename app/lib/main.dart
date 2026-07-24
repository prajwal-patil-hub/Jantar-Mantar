import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/map/map_config.dart';
import 'core/map/tile_providers.dart';

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
      ],
      child: const CommonGroundApp(),
    ),
  );
}
