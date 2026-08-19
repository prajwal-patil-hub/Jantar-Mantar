import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/domain/enums.dart';
import '../../../core/l10n/l10n_labels.dart';
import '../../../core/theme/depth.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../../../l10n/app_localizations.dart';
import '../../map/presentation/widgets/facility_visuals.dart';
import '../application/search_providers.dart';

/// Full-screen search (ui-ux-spec §1.11).
///
/// Local cache only, and the screen says so in the results footer rather than
/// leaving it to be inferred. That line is the whole reason this screen can be
/// trusted offline: without it, "no results" is ambiguous between "there is no
/// water point called that" and "we could not reach the server", and those
/// call for opposite reactions from someone standing in a crowd.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({required this.onGoTo, super.key});

  /// Moves the map to a hit and closes search.
  final void Function(LatLng) onGoTo;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Opening search that does not focus the field costs a tap for the one
    // thing this screen exists to do.
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final query = ref.watch(searchQueryProvider);
    final hits = ref.watch(searchResultsProvider);

    final facilities = hits.where((h) => h.kind == SearchResultKind.facility);
    final areas = hits.where((h) => h.kind == SearchResultKind.area);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          focusNode: _focus,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
          ),
          onChanged: (v) => ref.read(searchQueryProvider.notifier).set(v),
        ),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: l10n.clear,
              onPressed: () {
                _controller.clear();
                ref.read(searchQueryProvider.notifier).clear();
                _focus.requestFocus();
              },
            ),
        ],
      ),
      body: query.isEmpty
          ? _Suggestions(
              onPick: (term) {
                _controller.text = term;
                ref.read(searchQueryProvider.notifier).set(term);
              },
            )
          : hits.isEmpty
          ? EmptyStateView(
              icon: Icons.search_off,
              title: l10n.searchNoResults,
              body: l10n.searchLocalOnly,
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (facilities.isNotEmpty) ...[
                  _GroupHeader(label: l10n.searchGroupFacilities),
                  for (final h in facilities) _HitTile(hit: h, onTap: _go),
                  const SizedBox(height: 12),
                ],
                if (areas.isNotEmpty) ...[
                  _GroupHeader(label: l10n.searchGroupAreas),
                  for (final h in areas) _HitTile(hit: h, onTap: _go),
                  const SizedBox(height: 12),
                ],
                // Footer, not a banner: it qualifies the results below it, and
                // a reader who found what they wanted does not need stopping.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    l10n.searchLocalOnly,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
    );
  }

  void _go(SearchHit hit) {
    widget.onGoTo(hit.center);
    Navigator.of(context).pop();
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
    child: Text(label, style: Theme.of(context).textTheme.titleSmall),
  );
}

class _HitTile extends StatelessWidget {
  const _HitTile({required this.hit, required this.onTap});

  final SearchHit hit;
  final void Function(SearchHit) onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final facility = hit.facility;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DepthSurface(
        elevation: Elevation.card,
        radius: AppTokens.radiusCard,
        child: ListTile(
          leading: Icon(
            facility == null ? Icons.place_outlined : facility.type.icon,
          ),
          title: Text(hit.title),
          subtitle: facility == null
              ? null
              // Status as text as well as colour, per the accessibility rule
              // that nothing is carried by colour alone.
              : Text(facility.status.label(l10n)),
          // Distance is never status-tinted: a status colour here would be
          // read as a claim about the place, and "1.2 km" is not a status.
          trailing: Text(
            // No distance means the hit is outside every mapped box. Saying
            // so beats printing a number the map cannot take you to.
            hit.distanceMeters == null
                ? l10n.searchOffMap
                : _formatDistance(hit.distanceMeters!),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          onTap: () => onTap(hit),
        ),
      ),
    );
  }

  static String _formatDistance(double metres) => metres < 1000
      ? '${metres.round()} m'
      : '${(metres / 1000).toStringAsFixed(1)} km';
}

/// Type chips shown before anything is typed (ui-ux-spec §1.11 "suggested").
///
/// Deliberately not "recent searches": recents would persist what someone
/// looked for, and on a device that may be taken from them at a protest a
/// stored trail of "medical", "legal aid" is exactly the metadata this project
/// avoids keeping.
class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.onPick});

  final void Function(String) onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.searchSuggested,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in FacilityType.values)
                ActionChip(
                  avatar: Icon(type.icon, size: 18),
                  label: Text(type.label(l10n)),
                  onPressed: () => onPick(type.name),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            l10n.searchLocalOnly,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
