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
