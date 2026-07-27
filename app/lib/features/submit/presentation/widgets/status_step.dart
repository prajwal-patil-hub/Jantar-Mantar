import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/l10n/l10n_labels.dart';
import '../../../../core/media/exif_stripper.dart';
import '../../../../core/media/photo_picker.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../map/presentation/widgets/facility_visuals.dart';
import '../../domain/submission_draft.dart';

/// Step 4: status, optional note, optional photo. Every photo goes through
/// [ExifStripper] before it is stored (SECURITY.md — never upload location
/// metadata), and the original file is never referenced.
class StatusStep extends StatefulWidget {
  const StatusStep({
    required this.draft,
    required this.onChanged,
    this.picker = const PhotoPicker(),
    super.key,
  });

  final SubmissionDraft draft;
  final VoidCallback onChanged;
  final PhotoPicker picker;

  @override
  State<StatusStep> createState() => _StatusStepState();
}

class _StatusStepState extends State<StatusStep> {
  SubmissionDraft get draft => widget.draft;
  VoidCallback get onChanged => widget.onChanged;
  bool _busy = false;

  Future<void> _addPhoto({required bool fromCamera}) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final photo = await widget.picker.pick(fromCamera: fromCamera);
      if (photo == null) return;
      draft.photoPath = photo.path;
      onChanged();
      messenger.showSnackBar(SnackBar(content: Text(l10n.photoStripped)));
    } on UnsupportedImageException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.photoUnsupported)));
    } on Object catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.photoFailed('$e'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

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
        if (draft.photoPath == null) ...[
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l10n.addPhoto),
            // Say what happens to the photo before they choose one, not after.
            subtitle: Text(l10n.photoComingSoon),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    onPressed: _busy ? null : () => _addPhoto(fromCamera: true),
                    icon: const Icon(Icons.photo_camera),
                    label: Text(l10n.photoTakePhoto),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    onPressed: _busy
                        ? null
                        : () => _addPhoto(fromCamera: false),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(l10n.photoChooseFromGallery),
                  ),
                ),
              ],
            ),
          ),
        ] else
          Card(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.file(
                    File(draft.photoPath!),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox(height: 180),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text(l10n.photoStripped),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: l10n.photoRemove,
                    onPressed: () {
                      setState(() => draft.photoPath = null);
                      onChanged();
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
