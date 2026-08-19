import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/db/app_database.dart';
import '../../../core/map/map_config.dart';
import '../../map/application/map_providers.dart';

/// What a hit is: a facility, or a named area the map can go to.
///
/// Events are deliberately absent. The events list is still hardcoded sample
/// data with no table behind it, so a search that returned them would be
/// searching five string literals and presenting that as a cache lookup. Add
/// the group once events have a repository.
enum SearchResultKind { facility, area }

class SearchHit {
  const SearchHit({
    required this.kind,
    required this.id,
    required this.title,
    required this.center,
    this.facility,
    this.distanceMeters,
  });

  final SearchResultKind kind;
  final String id;
  final String title;
  final LatLng center;

  /// Present only for [SearchResultKind.facility] — carries status and
  /// freshness so the row can show a pill without a second lookup.
  final Facility? facility;

  /// Null when the hit is outside every mapped box, because a distance from
  /// the current map centre to a place the map cannot draw is a number with
  /// no meaning to the reader.
  final double? distanceMeters;
}

/// The current query. Trimmed but not lowercased — matching lowercases both
/// sides, and keeping the original preserves what the user typed for display.
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value.trim();
  void clear() => state = '';
}

/// Search over the LOCAL cache only (ui-ux-spec §1.11).
///
/// No network call, deliberately: this is one of the screens most likely to be
/// used with no signal, and a search that waits on a server would spin exactly
/// when it must not. The UI says so rather than hiding it — "searching saved
/// data" is a true statement about coverage, not an apology.
final searchResultsProvider = Provider<List<SearchHit>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  if (query.isEmpty) return const [];

  final centre = ref.watch(mapCenterProvider);
  const distance = Distance();

  double? distanceTo(LatLng point) => MapConfig.isMapped(point)
      ? distance.as(LengthUnit.Meter, centre, point)
      : null;

  final hits = <SearchHit>[];

  for (final site in MapConfig.sites) {
    if (site.name.toLowerCase().contains(query)) {
      hits.add(
        SearchHit(
          kind: SearchResultKind.area,
          id: site.id,
          title: site.name,
          center: site.center,
          distanceMeters: distanceTo(site.center),
        ),
      );
    }
  }

  final facilities = ref.watch(facilitiesProvider).asData?.value ?? const [];
  for (final f in facilities) {
    // Name plus the type's enum name, so "water" finds the water points.
    // Known gap: the enum name is English, so a Hindi query matches names
    // only. Fixing that means passing the localized labels in from the
    // widget layer — worth doing, not worth faking here.
    final haystack = '${f.name} ${f.type.name}'.toLowerCase();
    if (!haystack.contains(query)) continue;
    final at = LatLng(f.lat, f.lng);
    hits.add(
      SearchHit(
        kind: SearchResultKind.facility,
        id: f.id,
        title: f.name,
        center: at,
        facility: f,
        distanceMeters: distanceTo(at),
      ),
    );
  }

  // Nearest first, but anything with no usable distance sorts last rather
  // than first — an unknown distance must never outrank a known one.
  hits.sort((a, b) {
    final da = a.distanceMeters, db = b.distanceMeters;
    if (da == null && db == null) return a.title.compareTo(b.title);
    if (da == null) return 1;
    if (db == null) return -1;
    return da.compareTo(db);
  });
  return hits;
});
