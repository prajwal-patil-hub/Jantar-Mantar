import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/l10n/l10n_labels.dart';
import '../../../../core/theme/depth.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/map_providers.dart';
import 'facility_visuals.dart';

/// Scrollable type-filter chips: All · Water · Food · … (ui-ux-spec §1.4).
///
/// The row rides on its own floating plate. Bare chips over map tiles have no
/// ground: the chip's own surface tone is one rung of a ramp whose steps are
/// ~1.06:1, which separates it from a *page*, not from arbitrary satellite
/// imagery and road labels. The plate is what the chips are legible against.
class FilterChipRow extends ConsumerWidget {
  const FilterChipRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final selected = ref.watch(mapFilterProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DepthSurface(
        elevation: Elevation.floating,
        radius: AppTokens.radiusPill,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(l10n.filterAll),
                  selected: selected == null,
                  onSelected: (_) =>
                      ref.read(mapFilterProvider.notifier).select(null),
                ),
              ),
              for (final type in FacilityType.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Icon(type.icon, size: 18),
                    label: Text(type.label(l10n)),
                    selected: selected == type,
                    onSelected: (_) =>
                        ref.read(mapFilterProvider.notifier).select(type),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
