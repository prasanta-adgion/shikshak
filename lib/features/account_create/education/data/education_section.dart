import '../../../../core/constants/api_endpoints.dart';
import '../../shared/domain/entities/profile_section.dart';
import '../../shared/domain/entities/profile_step.dart';
import '../../shared/domain/entities/teacher_profile_draft.dart';

/// Maps [Education] onto the education payload:
///
/// ```json
/// { "degree", "specialization", "universityCollege", "yearOfPassing",
///   "marksOrGrade", "certificateUrl", "isHighestQualification" }
/// ```
class EducationSection implements ProfileSection, UploadingSection {
  const EducationSection();

  /// Names the payload field the picked certificate fills.
  static const String certificateField = 'certificateUrl';

  @override
  ProfileStep get step => ProfileStep.education;

  @override
  String get path => ApiEndpoints.education;

  @override
  Map<String, dynamic> body(TeacherProfileDraft draft) {
    final education = draft.education;

    return {
      'degree': education.degree,
      'specialization': education.specialization,
      'universityCollege': education.universityCollege,
      'yearOfPassing': education.yearOfPassing,
      'marksOrGrade': education.marksOrGrade,
      'certificateUrl': education.certificateUrl,
      'isHighestQualification': education.isHighestQualification,
    };
  }

  @override
  List<PendingUpload> pendingUploads(TeacherProfileDraft draft) {
    // The device path, never the display name — only a real path can be
    // uploaded. Stays empty until file picking is connected.
    final localPath = draft.education.certificateLocalPath;
    if (localPath == null ||
        localPath.isEmpty ||
        draft.education.certificateUrl != null) {
      return const [];
    }

    return [PendingUpload(field: certificateField, localPath: localPath)];
  }

  @override
  TeacherProfileDraft withUploadedUrls(
    TeacherProfileDraft draft,
    Map<String, String> urls,
  ) {
    final url = urls[certificateField];
    if (url == null) return draft;

    return draft.copyWith(
      education: draft.education.copyWith(certificateUrl: url),
    );
  }
}
