import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_labels.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../map/presentation/widgets/facility_visuals.dart';
import '../../domain/submission_draft.dart';

/// Step 5: review before "Submit for verification" (ui-ux-spec §1.8).
class ReviewStep extends StatelessWidget {
  const ReviewStep({required this.draft, super.key});

  final SubmissionDraft draft;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final category = draft.category;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.review, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(draft.isUpdate ? l10n.reviewUpdateNotice : l10n.reviewNewNotice),
        const SizedBox(height: 16),
        if (category != null)
          ListTile(
            leading: Icon(category.icon),
            title: Text(category.label(l10n)),
            subtitle: draft.isUpdate
                ? Text(l10n.reviewUpdating(draft.existingFacilityName ?? ''))
                : Text(l10n.reviewNewFacility),
          ),
        ListTile(
          leading: Icon(draft.status.icon),
          title: Text(l10n.reviewStatus(draft.status.label(l10n))),
        ),
        ListTile(
          leading: const Icon(Icons.groups),
          title: Text(
            draft.capacityFor == null
                ? l10n.reviewCapacityNone
                : l10n.reviewCapacityPeople(draft.capacityFor!),
          ),
        ),
        if (draft.location != null)
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(
              l10n.reviewLocation(
                draft.location!.latitude.toStringAsFixed(5),
                draft.location!.longitude.toStringAsFixed(5),
              ),
            ),
          ),
        if (draft.note.trim().isNotEmpty)
          ListTile(
            leading: const Icon(Icons.notes),
            title: Text(draft.note.trim()),
          ),
      ],
    );
  }
}
