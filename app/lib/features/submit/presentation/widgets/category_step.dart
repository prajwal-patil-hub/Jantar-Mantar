import 'package:flutter/material.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/l10n/l10n_labels.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../map/presentation/widgets/facility_visuals.dart';
import '../../domain/submission_draft.dart';

/// Step 1: big icon grid, two columns, 88dp targets (ui-ux-spec §1.8).
class CategoryStep extends StatelessWidget {
  const CategoryStep({
    required this.draft,
    required this.onSelected,
    super.key,
  });

  final SubmissionDraft draft;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          AppL10n.of(context).stepCategoryQuestion,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: [
            for (final type in FacilityType.values)
              _CategoryCard(
                type: type,
                selected: draft.category == type,
                onTap: () {
                  draft.category = type;
                  onSelected();
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final FacilityType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          height: 88,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(type.icon, size: 32),
              const SizedBox(height: 8),
              Text(
                type.label(AppL10n.of(context)),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
