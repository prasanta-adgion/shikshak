import 'profile_step.dart';
import 'teacher_profile_draft.dart';

abstract interface class ProfileSection {
  ProfileStep get step;

  String get path;

  Map<String, dynamic> body(TeacherProfileDraft draft);
}

abstract interface class RepeatableSection {
  bool isEntryEmpty(TeacherProfileDraft draft);

  TeacherProfileDraft commitEntry(TeacherProfileDraft draft);
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
  const PendingUpload({
    required this.field,
    required this.localPath,
    this.folder,
  });

  /// Names the payload field this upload fills, e.g. `profilePhotoUrl`.
  final String field;

  final String localPath;

  /// Included for uploads that the server groups into a named folder.
  final String? folder;
}
