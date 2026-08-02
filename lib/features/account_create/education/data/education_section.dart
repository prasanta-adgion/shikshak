import '../../../../core/constants/api_endpoints.dart';
import '../../shared/domain/entities/profile_section.dart';
import '../../shared/domain/entities/profile_step.dart';
import '../../shared/domain/entities/teacher_profile_draft.dart';
import '../domain/entities/education.dart';

/// Maps [Education] onto the education payload.
class EducationSection implements ProfileSection, RepeatableSection {
  const EducationSection();

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
  bool isEntryEmpty(TeacherProfileDraft draft) {
    final education = draft.education;
    return education.degree == null &&
        education.specialization.isEmpty &&
        education.universityCollege.isEmpty &&
        education.yearOfPassing == null &&
        education.marksOrGrade.isEmpty;
  }

  @override
  TeacherProfileDraft commitEntry(TeacherProfileDraft draft) => draft.copyWith(
    savedEducations: [...draft.savedEducations, draft.education],
    education: const Education(),
  );
}
