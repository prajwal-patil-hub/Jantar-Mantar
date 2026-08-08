import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_labels.dart';
import '../../../../core/theme/status_colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/map_providers.dart';
import 'facility_visuals.dart';
import 'freshness_badge.dart';

/// Non-modal "Nearby" sheet (ui-ux-spec §1.4): nearest facilities to the map
/// center as cards. Glass hero surface with the standard fallback.
///
/// The header is BOTH draggable and tappable: tapping toggles collapsed ⇄
/// expanded via the controller, so it works even where flutter_map's own pan
/// gestures would otherwise compete with a drag started over the map.
class NearbySheet extends ConsumerStatefulWidget {
  const NearbySheet({required this.onFacilityTap, super.key});

  final void Function(NearbyFacility) onFacilityTap;

  @override
  ConsumerState<NearbySheet> createState() => _NearbySheetState();
}

class _NearbySheetState extends ConsumerState<NearbySheet> {
  final _controller = DraggableScrollableController();

  static const _collapsed = 0.16;
  static const _half = 0.5;
  // Near-full rather than 1.0: leaving a sliver of map visible keeps the
  // sheet obviously dismissible and preserves context.
  static const _full = 0.94;

  /// Grab handle + title. Fixed so the pinned sliver has a stable extent.
  static const _headerHeight = 56.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Tapping the header cycles collapsed -> half -> full -> collapsed, so the
  /// full list is reachable without a drag (flutter_map's pan gestures compete
  /// with a drag that starts over the map).
  void _toggle() {
    if (!_controller.isAttached) return;
    final size = _controller.size;
    final target = switch (size) {
      _ when size < (_collapsed + _half) / 2 => _half,
      _ when size < (_half + _full) / 2 => _full,
      _ => _collapsed,
    };
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final nearby = ref.watch(nearbyFacilitiesProvider);
    final colors = Theme.of(context).extension<StatusColors>()!;
    // Clear the glass nav bar (extendBody) + the device's bottom inset so the
    // list doesn't hide behind it.
    final bottomInset = MediaQuery.of(context).padding.bottom + 72;

    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: _collapsed,
      minChildSize: _collapsed,
      maxChildSize: _full,
      snap: true,
      snapSizes: const [_collapsed, _half, _full],
      builder: (context, scrollController) {
        return GlassSurface(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          // ONE scrollable, header included.
          //
          // The header used to sit outside the scroll view in a
          // GestureDetector. Tapping worked; dragging did nothing at all —
          // measured at exactly 0 px — because DraggableScrollableSheet drags
          // via the scrollable it hands you, and the header was not part of
          // it. So the sheet opened and then could not be pulled back down by
          // the only affordance that looks draggable: the grab handle.
          //
          // As a pinned sliver the header is inside the scrollable, so the
          // framework's own drag, fling and snap handling applies to it. No
          // hand-rolled drag physics.
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _NearbyHeader(
                  height: _headerHeight,
                  onTap: _toggle,
                  label: nearby.isEmpty
                      ? l10n.nearby
                      : '${l10n.nearby} · ${nearby.length}',
                ),
              ),
              if (nearby.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.beFirstToReport,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                SliverList.builder(
                  itemCount: nearby.length,
                  itemBuilder: (context, i) {
                    final item = nearby[i];
                    final f = item.facility;
                    final statusColor = f.status.colorOf(colors);
                    return ListTile(
                      minTileHeight: 56,
                      onTap: () => widget.onFacilityTap(item),
                      leading: Icon(f.type.icon, color: statusColor, size: 28),
                      title: Text(f.name),
                      subtitle: FreshnessBadge(verifiedAt: f.verifiedAt),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(f.status.icon, size: 16, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                f.status.label(l10n),
                                style: TextStyle(color: statusColor),
                              ),
                            ],
                          ),
                          Text(_distanceText(item.distanceMeters)),
                        ],
                      ),
                    );
                  },
                ),
              SliverToBoxAdapter(child: SizedBox(height: bottomInset)),
            ],
          ),
        );
      },
    );
  }

  String _distanceText(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
}

/// Pinned grab handle. Lives inside the scroll view so the sheet's own drag
/// handling covers it; the tap is a convenience for when flutter_map's pan
/// gestures would otherwise compete with a drag started over the map.
class _NearbyHeader extends SliverPersistentHeaderDelegate {
  const _NearbyHeader({
    required this.height,
    required this.onTap,
    required this.label,
  });

  final double height;
  final VoidCallback onTap;
  final String label;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return GestureDetector(
      // Tap only. A drag recognizer here would win the arena against the
      // scroll view and reintroduce exactly the bug this replaced.
      onTap: onTap,
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.01),
        child: Semantics(
          button: true,
          label: label,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                ),
              ),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_NearbyHeader old) =>
      old.label != label || old.height != height;
}
