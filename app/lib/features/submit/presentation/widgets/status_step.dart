import 'package:flutter/material.dart';

import '../../../../core/db/app_database.dart';
import '../../../map/presentation/widgets/facility_visuals.dart';
import '../../domain/submission_draft.dart';

/// Step 4: status + optional note. Photo capture lands later with the
/// EXIF-stripping pipeline (SECURITY.md — never upload location metadata).
class StatusStep extends StatelessWidget {
  const StatusStep({required this.draft, required this.onChanged, super.key});

  final SubmissionDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'How is it right now?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        SegmentedButton<FacilityStatus>(
          segments: [
            for (final status in const [
              FacilityStatus.good,
              FacilityStatus.low,
              FacilityStatus.out,
            ])
              ButtonSegment(
                value: status,
                icon: Icon(status.icon),
                label: Text(status.label),
              ),
          ],
          selected: {draft.status},
          onSelectionChanged: (selection) {
            draft.status = selection.single;
            onChanged();
          },
        ),
        const SizedBox(height: 24),
        TextFormField(
          initialValue: draft.note,
          decoration: const InputDecoration(
            labelText: 'Note (optional)',
            hintText: 'e.g. queue is long, tanker refills at 5 PM',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (text) {
            draft.note = text;
            onChanged();
          },
        ),
        const SizedBox(height: 16),
        const ListTile(
          enabled: false,
          leading: Icon(Icons.photo_camera_outlined),
          title: Text('Add photo'),
          subtitle: Text(
            'Coming soon — photos are stripped of location data before '
            'upload.',
          ),
        ),
      ],
    );
  }
}
