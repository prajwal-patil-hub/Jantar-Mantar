import 'package:flutter/material.dart';

import '../../../map/presentation/widgets/facility_visuals.dart';
import '../../domain/submission_draft.dart';

/// Step 5: review before "Submit for verification" (ui-ux-spec §1.8).
class ReviewStep extends StatelessWidget {
  const ReviewStep({required this.draft, super.key});

  final SubmissionDraft draft;

  @override
  Widget build(BuildContext context) {
    final category = draft.category;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Review', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          draft.isUpdate
              ? 'This update goes to the verification queue before it '
                    'changes the public map.'
              : 'New facilities appear publicly only after verification. '
                    'You’ll see it as "Pending (yours)" meanwhile.',
        ),
        const SizedBox(height: 16),
        if (category != null)
          ListTile(
            leading: Icon(category.icon),
            title: Text(category.label),
            subtitle: draft.isUpdate
                ? Text('Updating: ${draft.existingFacilityName}')
                : const Text('New facility'),
          ),
        ListTile(
          leading: Icon(draft.status.icon),
          title: Text('Status: ${draft.status.label}'),
        ),
        ListTile(
          leading: const Icon(Icons.groups),
          title: Text(
            draft.capacityFor == null
                ? 'Capacity: not specified'
                : 'Capacity: ~${draft.capacityFor} people',
          ),
        ),
        if (draft.location != null)
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(
              'Location: ${draft.location!.latitude.toStringAsFixed(5)}, '
              '${draft.location!.longitude.toStringAsFixed(5)}',
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
