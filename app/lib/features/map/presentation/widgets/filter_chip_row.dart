import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database.dart';
import '../../application/map_providers.dart';
import 'facility_visuals.dart';

/// Scrollable type-filter chips: All · Water · Food · … (ui-ux-spec §1.4).
class FilterChipRow extends ConsumerWidget {
  const FilterChipRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(mapFilterProvider);

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('All'),
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
                label: Text(type.label),
                selected: selected == type,
                onSelected: (_) =>
                    ref.read(mapFilterProvider.notifier).select(type),
              ),
            ),
        ],
      ),
    );
  }
}
