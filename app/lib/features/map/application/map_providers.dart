import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/db/app_database.dart';
import '../../../core/map/map_config.dart';
import '../../../core/providers.dart';

/// Active facility-type filter chip; null = All.
final mapFilterProvider = NotifierProvider<MapFilterNotifier, FacilityType?>(
  MapFilterNotifier.new,
);

class MapFilterNotifier extends Notifier<FacilityType?> {
  @override
  FacilityType? build() => null;

  void select(FacilityType? type) => state = type;
}

/// Facilities for the current filter — a Drift stream, so the map re-renders
/// on any local write or sync refresh without touching the network.
final facilitiesProvider = StreamProvider<List<Facility>>((ref) {
  final filter = ref.watch(mapFilterProvider);
  return ref.watch(facilityRepositoryProvider).watchAll(type: filter);
});

/// Map camera center, fed by map events; drives the Nearby list without any
/// GPS involvement (privacy-first: no location permission needed to browse).
final mapCenterProvider = NotifierProvider<MapCenterNotifier, LatLng>(
  MapCenterNotifier.new,
);

class MapCenterNotifier extends Notifier<LatLng> {
  @override
  LatLng build() => MapConfig.jantarMantar;

  void set(LatLng center) => state = center;
}

/// Capacity readings for one facility (detail sheet).
final capacityReadingsProvider =
    StreamProvider.family<List<CapacityReading>, String>(
      (ref, facilityId) =>
          ref.watch(facilityRepositoryProvider).watchCapacity(facilityId),
    );

/// The submitter's own queued/pending submissions — rendered as grey dashed
/// "Pending (yours)" pins on the map (optimistic UI, ui-ux-spec §1.8).
final pendingSubmissionsProvider = StreamProvider<List<Submission>>(
  (ref) => ref.watch(submissionRepositoryProvider).watchMine(),
);

/// Count for the Profile pending-uploads tray.
final pendingCountProvider = StreamProvider<int>(
  (ref) => ref.watch(submissionRepositoryProvider).watchPendingCount(),
);

class NearbyFacility {
  const NearbyFacility(this.facility, this.distanceMeters);

  final Facility facility;
  final double distanceMeters;
}

/// Nearest facilities to the current map center, closest first.
final nearbyFacilitiesProvider = Provider<List<NearbyFacility>>((ref) {
  final facilities = ref.watch(facilitiesProvider).asData?.value ?? const [];
  final center = ref.watch(mapCenterProvider);
  const distance = Distance();

  final nearby = [
    for (final f in facilities)
      NearbyFacility(
        f,
        distance.as(LengthUnit.Meter, center, LatLng(f.lat, f.lng)),
      ),
  ]..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
  return nearby.take(10).toList();
});
