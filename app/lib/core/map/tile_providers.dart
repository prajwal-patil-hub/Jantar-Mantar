import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tile source for the map. Defaults to plain network tiles so the widget
/// tree never depends on FMTC being initialised; `main()` overrides this
/// with an FMTC-backed provider (offline cache) once the backend is up, and
/// tests override it with a stub. Falling back to network-only is the
/// correct degradation — tiles already on screen stay usable either way.
final mapTileProviderProvider = Provider<TileProvider>(
  (ref) => NetworkTileProvider(),
);
