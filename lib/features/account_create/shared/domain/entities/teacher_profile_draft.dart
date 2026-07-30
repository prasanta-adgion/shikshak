import '../../../about_you/domain/entities/about_you.dart';
import '../../../basic_info/domain/entities/basic_info.dart';
import '../../../documents/domain/entities/teacher_document.dart';
import '../../../education/domain/entities/education.dart';
import '../../../experience/domain/entities/experience_info.dart';

class TeacherProfileDraft {
  final BasicInfo basicInfo;
  final AboutYou aboutYou;

  final ExperienceInfo experience;
  final List<ExperienceInfo> savedExperiences;

  final Education education;
  final List<Education> savedEducations;

  final TeacherDocument document;

  List<String> get teachingSubjects => aboutYou.subjectsTaught;

  /// Classes shared by the about-you and experience payloads.
  List<String> get classesTaught => aboutYou.classesTaught;

  const TeacherProfileDraft({
    this.basicInfo = const BasicInfo(),
    this.aboutYou = const AboutYou(),
    this.experience = const ExperienceInfo(),
    this.savedExperiences = const [],
    this.education = const Education(),
    this.savedEducations = const [],
    this.document = const TeacherDocument(),
  });

  TeacherProfileDraft copyWith({
    BasicInfo? basicInfo,
    AboutYou? aboutYou,
    ExperienceInfo? experience,
    List<ExperienceInfo>? savedExperiences,
    Education? education,
    List<Education>? savedEducations,
    TeacherDocument? document,
  }) => TeacherProfileDraft(
    basicInfo: basicInfo ?? this.basicInfo,
    aboutYou: aboutYou ?? this.aboutYou,
    experience: experience ?? this.experience,
    savedExperiences: savedExperiences ?? this.savedExperiences,
    education: education ?? this.education,
    savedEducations: savedEducations ?? this.savedEducations,
    document: document ?? this.document,
  );
}
