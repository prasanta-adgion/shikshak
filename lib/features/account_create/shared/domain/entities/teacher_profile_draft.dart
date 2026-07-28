import '../../../about_you/domain/entities/about_you.dart';
import '../../../basic_info/domain/entities/basic_info.dart';
import '../../../documents/domain/entities/teacher_document.dart';
import '../../../education/domain/entities/education.dart';
import '../../../experience/domain/entities/experience_info.dart';

class TeacherProfileDraft {
  const TeacherProfileDraft({
    this.basicInfo = const BasicInfo(),
    this.aboutYou = const AboutYou(),
    this.experience = const ExperienceInfo(),
    this.education = const Education(),
    this.document = const TeacherDocument(),
  });

  final BasicInfo basicInfo;
  final AboutYou aboutYou;
  final ExperienceInfo experience;
  final Education education;
  final TeacherDocument document;

  List<String> get teachingSubjects => aboutYou.subjectsTaught;

  /// Classes shared by the about-you and experience payloads.
  List<String> get classesTaught => aboutYou.classesTaught;

  TeacherProfileDraft copyWith({
    BasicInfo? basicInfo,
    AboutYou? aboutYou,
    ExperienceInfo? experience,
    Education? education,
    TeacherDocument? document,
  }) => TeacherProfileDraft(
    basicInfo: basicInfo ?? this.basicInfo,
    aboutYou: aboutYou ?? this.aboutYou,
    experience: experience ?? this.experience,
    education: education ?? this.education,
    document: document ?? this.document,
  );
}
