import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/utils/date_time_picker_func.dart';
import '../../shared/domain/entities/profile_section.dart';
import '../../shared/domain/entities/profile_step.dart';
import '../../shared/domain/entities/teacher_profile_draft.dart';

/// Maps [BasicInfo] onto the basic-info payload:
///
/// ```json
/// { "profilePhotoUrl", "gender", "dateOfBirth", "addressLine1",
///   "addressLine2", "city", "state", "country", "postalCode" }
/// ```
class BasicInfoSection implements ProfileSection {
  const BasicInfoSection();

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
}
