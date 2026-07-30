import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/date_time_picker_func.dart';
import '../../shared/domain/entities/profile_section.dart';
import '../../shared/domain/entities/profile_step.dart';
import '../../shared/domain/entities/teacher_profile_draft.dart';

/// Maps [BasicInfo] onto the basic-info payload:
///
/// ```json
/// { "profilePhotoUrl", "gender", "dateOfBirth", "addressLine1",
///   "addressLine2", "city", "state", "country", "postalCode" }
/// ```
class BasicInfoSection implements ProfileSection, UploadingSection {
  const BasicInfoSection();

  /// Names the payload field the picked avatar fills.
  static const String photoField = 'profilePhotoUrl';

  @override
  ProfileStep get step => ProfileStep.basicInfo;

  @override
  String get path => ApiEndpoints.basicInfo;

  @override
  Map<String, dynamic> body(TeacherProfileDraft draft) {
    final info = draft.basicInfo;

    return {
      'profilePhotoUrl': info.profilePhotoUrl,
      'gender': info.gender?.wireValue,
      'dateOfBirth': info.dateOfBirth == null
          ? null
          : DateTimeUtils.isoDate(info.dateOfBirth!),
      'addressLine1': info.addressLine1,
      'addressLine2': info.addressLine2,
      'city': info.city,
      'state': info.state,
      'country': info.country,
      'postalCode': info.postalCode,
    };
  }

  @override
  List<PendingUpload> pendingUploads(TeacherProfileDraft draft) {
    final localPath = draft.basicInfo.localPhotoPath;
    // Nothing to do once the photo already has a URL, or none was picked.
    if (localPath == null ||
        localPath.isEmpty ||
        draft.basicInfo.profilePhotoUrl != null) {
      return const [];
    }

    return [PendingUpload(field: photoField, localPath: localPath)];
  }

  @override
  TeacherProfileDraft withUploadedUrls(
    TeacherProfileDraft draft,
    Map<String, String> urls,
  ) {
    final url = urls[photoField];
    if (url == null) return draft;

    return draft.copyWith(
      basicInfo: draft.basicInfo.copyWith(profilePhotoUrl: url),
    );
  }
}
