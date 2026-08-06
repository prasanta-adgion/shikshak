import '../../../../../core/constants/api_endpoints.dart';
import '../../shared/domain/entities/profile_section.dart';
import '../../shared/domain/entities/profile_step.dart';
import '../../shared/domain/entities/teacher_profile_draft.dart';

class AboutYouSection implements ProfileSection {
  const AboutYouSection();

  @override
  ProfileStep get step => ProfileStep.aboutYou;

  @override
  String get path => ApiEndpoints.aboutYou;

  @override
  Map<String, dynamic> body(TeacherProfileDraft draft) {
    final about = draft.aboutYou;

    return {
      'shortBio': about.shortBio,
      'teachingApproach': about.teachingApproach,
      'whatMakesYouUnique': about.whatMakesYouUnique,
      'subjectsTaught': about.subjectsTaught,
      'classesTaught': about.classesTaught,
      'languagesKnown': about.languagesKnown,
    };
  }
}
