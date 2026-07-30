import 'profile_step.dart';
import 'teacher_profile_draft.dart';

/// One saveable section of the teacher profile.
///
/// The five endpoints differ only in path and body, so this is all a slice has
/// to supply — the transport, the create-vs-update decision and the error
/// handling are shared. Adding a sixth section means writing one of these and
/// registering it; nothing else in the wizard changes.
abstract interface class ProfileSection {
  /// The wizard step this section is saved from.
  ProfileStep get step;

  /// An `ApiEndpoints` constant. POST creates, PATCH updates the same path.
  String get path;

  /// The exact request body for this section, read off [draft].
  Map<String, dynamic> body(TeacherProfileDraft draft);
}

/// Companion contract for the sections that carry a file.
///
/// Kept separate from [ProfileSection] so the sections without one never
/// depend on uploading.
abstract interface class UploadingSection {
  /// Files picked on the device that still need a URL. Empty when there is
  /// nothing to upload, which is the common case.
  List<PendingUpload> pendingUploads(TeacherProfileDraft draft);

  /// Writes the uploaded URLs back into the draft, keyed by
  /// [PendingUpload.field].
  TeacherProfileDraft withUploadedUrls(
    TeacherProfileDraft draft,
    Map<String, String> urls,
  );
}

/// A local file waiting to become a URL.
class PendingUpload {
  const PendingUpload({required this.field, required this.localPath});

  /// Names the payload field this upload fills, e.g. `profilePhotoUrl`.
  final String field;

  final String localPath;
}
