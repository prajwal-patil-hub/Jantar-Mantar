import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/theme/status_colors.dart';
import 'facility_visuals.dart';

/// Grey "Pending (yours)" pin for the submitter's own queued submissions
/// (optimistic UI, ui-ux-spec §1.8). Visible only on this device until an
/// admin approves it.
class PendingMarker extends StatelessWidget {
  const PendingMarker({required this.submission, super.key});

  final Submission submission;

  FacilityType? get _category {
    final payload = jsonDecode(submission.payload);
    if (payload is! Map<String, Object?>) return null;
    final name = payload['category'];
    for (final type in FacilityType.values) {
      if (type.name == name) return type;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // The "unverified" status colour, not a private grey. This pin used to
    // hardcode #9E9E9E — the exact value StatusColors abandoned for measuring
    // under 3:1 — so the token got fixed twice and the pin never moved.
    final grey = Theme.of(context).extension<StatusColors>()!.unverified;
    return Semantics(
      label: 'Your pending submission, awaiting verification',
      child: Opacity(
        opacity: 0.75,
        child: Stack(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: grey, width: 2),
              ),
              child: Icon(
                _category?.icon ?? Icons.help_outline,
                size: 22,
                color: grey,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.schedule_send, size: 16, color: grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
