import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/submission_draft.dart';
import 'widgets/capacity_step.dart';
import 'widgets/category_step.dart';
import 'widgets/location_step.dart';
import 'widgets/review_step.dart';
import 'widgets/status_step.dart';

/// 5-step submit flow (ui-ux-spec §1.8): Category → Location → Capacity →
/// Status/note → Review. Fully offline: the final submit commits the pending
/// submission + outbox entry locally and returns immediately.
class SubmitFlowScreen extends ConsumerStatefulWidget {
  const SubmitFlowScreen({
    required this.initialLocation,
    this.prefill,
    super.key,
  });

  /// Starting point for the location step (map center — no GPS required).
  final LatLng initialLocation;

  /// Set when launched from "Update this" on a facility detail sheet.
  final Facility? prefill;

  @override
  ConsumerState<SubmitFlowScreen> createState() => _SubmitFlowScreenState();
}

class _SubmitFlowScreenState extends ConsumerState<SubmitFlowScreen> {
  late final SubmissionDraft _draft;
  final _pageController = PageController();
  int _step = 0;
  bool _submitting = false;

  static const _stepCount = 5;

  @override
  void initState() {
    super.initState();
    final prefill = widget.prefill;
    _draft = SubmissionDraft(
      category: prefill?.type,
      location: prefill == null
          ? widget.initialLocation
          : LatLng(prefill.lat, prefill.lng),
      existingFacilityId: prefill?.id,
      existingFacilityName: prefill?.name,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _canAdvance => switch (_step) {
    0 => _draft.category != null,
    1 => _draft.location != null,
    _ => true,
  };

  void _goTo(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _next() {
    if (_step < _stepCount - 1) _goTo(_step + 1);
  }

  void _back() {
    if (_step > 0) {
      _goTo(_step - 1);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final location = _draft.location!;
    await ref
        .read(submissionRepositoryProvider)
        .submit(
          payload: _draft.toPayload(),
          facilityId: _draft.existingFacilityId,
          lat: location.latitude,
          lng: location.longitude,
          // Always the sanitised copy — PhotoPicker never hands back the
          // camera-roll original.
          photoPath: _draft.photoPath,
        );
    if (!mounted) return;
    final l10n = AppL10n.of(context);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.savedWillSend)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _back,
          tooltip: l10n.back,
        ),
        title: Text(
          _draft.isUpdate ? l10n.updateFacilityTitle : l10n.reportFacilityTitle,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_step + 1) / _stepCount),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                // Steps advance only via the buttons so validation holds.
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  CategoryStep(
                    draft: _draft,
                    onSelected: () {
                      setState(() {});
                      _next();
                    },
                  ),
                  LocationStep(draft: _draft, onChanged: () => setState(() {})),
                  CapacityStep(draft: _draft, onChanged: () => setState(() {})),
                  StatusStep(draft: _draft, onChanged: () => setState(() {})),
                  ReviewStep(draft: _draft),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_step > 0)
                    OutlinedButton(
                      onPressed: _back,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(96, 48),
                      ),
                      child: Text(l10n.back),
                    ),
                  const Spacer(),
                  if (_step < _stepCount - 1)
                    FilledButton(
                      onPressed: _canAdvance ? _next : null,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(120, 48),
                      ),
                      child: Text(l10n.next),
                    )
                  else
                    FilledButton.icon(
                      onPressed: _submitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(200, 56),
                      ),
                      icon: const Icon(Icons.send),
                      label: Text(l10n.submitForVerification),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
