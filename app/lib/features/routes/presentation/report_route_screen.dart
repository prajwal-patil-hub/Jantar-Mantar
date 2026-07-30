import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../../../core/map/map_config.dart';
import '../../../core/map/tile_providers.dart';
import '../../../core/providers.dart';
import '../../../core/theme/status_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../map/application/map_providers.dart';
import '../domain/route_visuals.dart';

/// Report a stretch of route as impassable or hard to pass (ADR-31).
///
/// Two drags rather than a drawn polyline: enough to say "do not go along
/// here", and usable one-handed on a phone in the rain, which is the actual
/// context. Start and end are placed by moving the map under a fixed
/// crosshair — no GPS involved, same as every other placement in this app.
///
/// The expiry is mandatory and short by default. A blockage that outlives the
/// water is not a harmless leftover: it routes people away from what may be
/// the only road out.
class ReportRouteScreen extends ConsumerStatefulWidget {
  const ReportRouteScreen({super.key});

  @override
  ConsumerState<ReportRouteScreen> createState() => _ReportRouteScreenState();
}

class _ReportRouteScreenState extends ConsumerState<ReportRouteScreen> {
  static const _ttlChoices = [
    Duration(hours: 2),
    Duration(hours: 6),
    Duration(hours: 24),
    Duration(days: 3),
  ];

  final _name = TextEditingController();
  final _note = TextEditingController();

  LatLng? _start;
  LatLng? _end;
  LatLng _center = MapConfig.jantarMantar;
  RouteCondition _condition = RouteCondition.impassable;
  RouteCause _cause = RouteCause.flood;
  Duration _ttl = _ttlChoices[1];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _center = ref.read(mapCenterProvider);
  }

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  bool get _placed => _start != null && _end != null;

  Future<void> _save() async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);

    final now = DateTime.now().toUtc();
    await ref
        .read(routeRepositoryProvider)
        .insert(
          RouteReportsCompanion.insert(
            id: const Uuid().v4(),
            name: _name.text.trim().isEmpty
                ? l10n.routeUnnamed
                : _name.text.trim(),
            condition: _condition,
            cause: _cause,
            startLat: _start!.latitude,
            startLng: _start!.longitude,
            endLat: _end!.latitude,
            endLng: _end!.longitude,
            note: Value(_note.text.trim().isEmpty ? null : _note.text.trim()),
            expiresAt: now.add(_ttl),
            updatedAt: now,
          ),
        );

    if (!mounted) return;
    setState(() => _saving = false);
    // Local-only for now: there is no server table yet, so saying it was
    // "submitted for verification" would be false. It shows on this device's
    // map and expires on its own.
    messenger.showSnackBar(SnackBar(content: Text(l10n.routeSavedLocally)));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final colors = Theme.of(context).extension<StatusColors>()!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportRoute)),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // FlutterMap's gesture layer is interactive and carries no
                // label, so a screen reader announces an unnamed control in
                // the middle of the screen. Caught by the labelled-tappable
                // guideline (ADR-34).
                Semantics(
                  label: l10n.mapSemanticsPick,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: _center,
                      initialZoom: 16,
                      minZoom: MapConfig.minZoom,
                      maxZoom: MapConfig.maxZoom,
                      onPositionChanged: (camera, _) => _center = camera.center,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: MapConfig.urlTemplate,
                        userAgentPackageName: MapConfig.userAgentPackageName,
                        tileProvider: ref.watch(mapTileProviderProvider),
                        maxZoom: MapConfig.maxZoom,
                      ),
                      if (_placed)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: [_start!, _end!],
                              color: _condition.colorOf(colors),
                              strokeWidth: 6,
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: [
                          for (final point in [_start, _end])
                            if (point != null)
                              Marker(
                                point: point,
                                child: Icon(
                                  Icons.circle,
                                  size: 14,
                                  color: _condition.colorOf(colors),
                                ),
                              ),
                        ],
                      ),
                    ],
                  ),
                ),
                const IgnorePointer(
                  child: Center(child: Icon(Icons.add, size: 32)),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _start == null
                        ? l10n.routePlaceStart
                        : (_end == null
                              ? l10n.routePlaceEnd
                              : l10n.routePlacedBoth),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                          ),
                          onPressed: () => setState(() {
                            if (_start == null || _placed) {
                              _start = _center;
                              _end = null;
                            } else {
                              _end = _center;
                            }
                          }),
                          icon: const Icon(Icons.add_location_alt_outlined),
                          label: Text(
                            _start == null || _placed
                                ? l10n.routeSetStart
                                : l10n.routeSetEnd,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final c in RouteCondition.values)
                        ChoiceChip(
                          avatar: Icon(c.icon, size: 18),
                          label: Text(c.label(l10n)),
                          selected: _condition == c,
                          onSelected: (_) => setState(() => _condition = c),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final c in RouteCause.values)
                        ChoiceChip(
                          avatar: Icon(c.icon, size: 18),
                          label: Text(c.label(l10n)),
                          selected: _cause == c,
                          onSelected: (_) => setState(() => _cause = c),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _name,
                    maxLength: 80,
                    decoration: InputDecoration(
                      labelText: l10n.routeName,
                      border: const OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.routeExpiryWhy,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final ttl in _ttlChoices)
                        ChoiceChip(
                          label: Text(l10n.ttlHours(ttl.inHours)),
                          selected: _ttl == ttl,
                          onSelected: (_) => setState(() => _ttl = ttl),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: _placed && !_saving ? _save : null,
                    icon: const Icon(Icons.check),
                    label: Text(l10n.routeSave),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
