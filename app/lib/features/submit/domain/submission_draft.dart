import 'package:latlong2/latlong.dart';

import '../../../core/db/app_database.dart';

/// Mutable draft carried through the 5-step submit flow (ui-ux-spec §1.8).
/// Serialized into the Submission payload on the final step; the server
/// re-validates everything on sync (never trust the client).
class SubmissionDraft {
  SubmissionDraft({
    this.category,
    this.location,
    this.existingFacilityId,
    this.existingFacilityName,
  });

  FacilityType? category;
  LatLng? location;

  /// Set when updating an existing facility instead of proposing a new one.
  String? existingFacilityId;
  String? existingFacilityName;

  /// "Water for ~200 people"; null = not specified/skipped.
  int? capacityFor;

  FacilityStatus status = FacilityStatus.good;
  String note = '';

  /// Path to the SANITISED copy written by [PhotoPicker] — never the camera
  /// roll original, which still carries GPS and camera metadata.
  String? photoPath;

  bool get isUpdate => existingFacilityId != null;

  Map<String, Object?> toPayload() {
    return {
      'category': category!.name,
      'status': status.name,
      'mode': isUpdate ? 'update' : 'new',
      if (capacityFor != null) 'forPeople': capacityFor,
      if (note.trim().isNotEmpty) 'note': note.trim(),
    };
  }
}
