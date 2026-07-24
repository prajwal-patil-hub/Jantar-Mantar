import 'package:flutter/material.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/l10n/l10n_labels.dart';
import '../../../../l10n/app_localizations.dart';
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
    final l10n = AppL10n.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.stepStatusQuestion,
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
                label: Text(status.label(l10n)),
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
          decoration: InputDecoration(
            labelText: l10n.noteOptional,
            hintText: l10n.noteHint,
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (text) {
            draft.note = text;
            onChanged();
          },
        ),
        const SizedBox(height: 16),
        ListTile(
          enabled: false,
          leading: const Icon(Icons.photo_camera_outlined),
          title: Text(l10n.addPhoto),
          subtitle: Text(l10n.photoComingSoon),
        ),
      ],
    );
  }
}
