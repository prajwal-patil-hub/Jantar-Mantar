import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/submission_draft.dart';

/// Step 3: big +/− steppers and presets, no keyboard (ui-ux-spec §1.8).
class CapacityStep extends StatelessWidget {
  const CapacityStep({required this.draft, required this.onChanged, super.key});

  final SubmissionDraft draft;
  final VoidCallback onChanged;

  static const _presets = [50, 100, 200, 500];

  void _set(int? value) {
    draft.capacityFor = value;
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final value = draft.capacityFor;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.stepCapacityQuestion,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(l10n.skipIfNotApplicable),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              iconSize: 28,
              style: IconButton.styleFrom(minimumSize: const Size(56, 56)),
              onPressed: value == null || value <= 0
                  ? null
                  : () => _set(value - 10 <= 0 ? null : value - 10),
              icon: const Icon(Icons.remove),
              tooltip: 'Less',
            ),
            SizedBox(
              width: 140,
              child: Text(
                value == null ? '—' : '~$value',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            IconButton.filledTonal(
              iconSize: 28,
              style: IconButton.styleFrom(minimumSize: const Size(56, 56)),
              onPressed: () => _set((value ?? 0) + 10),
              icon: const Icon(Icons.add),
              tooltip: 'More',
            ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            for (final preset in _presets)
              ChoiceChip(
                label: Text('~$preset'),
                selected: value == preset,
                onSelected: (_) => _set(preset),
              ),
            ChoiceChip(
              label: Text(l10n.skip),
              selected: value == null,
              onSelected: (_) => _set(null),
            ),
          ],
        ),
      ],
    );
  }
}
