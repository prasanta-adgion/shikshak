import 'dart:convert';

import 'package:Shikshak/core/constants/api_endpoints.dart';
import 'package:Shikshak/core/network/api_exception.dart';
import 'package:Shikshak/core/network/api_result.dart';
import 'package:Shikshak/features/account_create/about_you/data/about_you_section.dart';
import 'package:Shikshak/features/account_create/about_you/domain/entities/about_you.dart';
import 'package:Shikshak/features/account_create/basic_info/data/basic_info_section.dart';
import 'package:Shikshak/features/account_create/basic_info/domain/entities/basic_info.dart';
import 'package:Shikshak/features/account_create/education/data/education_section.dart';
import 'package:Shikshak/features/account_create/education/domain/entities/education.dart';
import 'package:Shikshak/features/account_create/experience/data/experience_section.dart';
import 'package:Shikshak/features/account_create/experience/domain/entities/experience_info.dart';
import 'package:Shikshak/features/account_create/shared/domain/entities/profile_step.dart';
import 'package:Shikshak/features/account_create/shared/domain/entities/teacher_profile_draft.dart';
import 'package:Shikshak/features/account_create/shared/domain/repositories/profile_section_repository.dart';
import 'package:Shikshak/features/account_create/shared/domain/usecases/save_profile_section_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _Call = ({String path, Map<String, dynamic> body, bool isUpdate});

class _RecordingRepository implements ProfileSectionRepository {
  final List<_Call> calls = [];
  ApiException? failWith;

  @override
  Future<ApiResult<void>> submit({
    required String path,
    required Map<String, dynamic> body,
    required bool isUpdate,
  }) async {
    calls.add((path: path, body: body, isUpdate: isUpdate));
    final failure = failWith;
    if (failure != null) return ApiResult.failure(failure);
    return const ApiResult.success(null);
  }
}

void main() {
  late _RecordingRepository repository;

  SaveProfileSectionUseCase buildUseCase() => SaveProfileSectionUseCase(
    sections: const {
      ProfileStep.aboutYou: AboutYouSection(),
      ProfileStep.basicInfo: BasicInfoSection(),
      ProfileStep.experience: ExperienceSection(),
      ProfileStep.education: EducationSection(),
    },
    repository: repository,
  );

  TeacherProfileDraft draftWithBio(String bio) =>
      TeacherProfileDraft(aboutYou: AboutYou(shortBio: bio));

  setUp(() {
    repository = _RecordingRepository();
  });

  group('save decision', () {
    test('creates with POST when the section has never been saved', () async {
      final result = await buildUseCase().call(
        step: ProfileStep.aboutYou,
        draft: draftWithBio('Maths teacher'),
        lastSavedBody: null,
      );

      expect(repository.calls, hasLength(1));
      expect(repository.calls.single.isUpdate, isFalse);
      expect(repository.calls.single.path, ApiEndpoints.aboutYou);

      final outcome = (result as ApiSuccess<SectionSaveOutcome>).data;
      expect(outcome.wasSkipped, isFalse);
      expect(outcome.savedBody, isNotEmpty);
    });

    test('sends nothing when the body is unchanged', () async {
      final useCase = buildUseCase();
      final draft = draftWithBio('Maths teacher');

      final first = await useCase.call(
        step: ProfileStep.aboutYou,
        draft: draft,
        lastSavedBody: null,
      );
      final savedBody =
          (first as ApiSuccess<SectionSaveOutcome>).data.savedBody;

      final second = await useCase.call(
        step: ProfileStep.aboutYou,
        draft: draft,
        lastSavedBody: savedBody,
      );

      // Still just the first call.
      expect(repository.calls, hasLength(1));
      expect(
        (second as ApiSuccess<SectionSaveOutcome>).data.wasSkipped,
        isTrue,
      );
    });

    test('updates with PATCH when the body has changed', () async {
      final useCase = buildUseCase();

      final first = await useCase.call(
        step: ProfileStep.aboutYou,
        draft: draftWithBio('Maths teacher'),
        lastSavedBody: null,
      );
      final savedBody =
          (first as ApiSuccess<SectionSaveOutcome>).data.savedBody;

      await useCase.call(
        step: ProfileStep.aboutYou,
        draft: draftWithBio('Physics teacher'),
        lastSavedBody: savedBody,
      );

      expect(repository.calls, hasLength(2));
      expect(repository.calls.last.isUpdate, isTrue);
      expect(repository.calls.last.body['shortBio'], 'Physics teacher');
    });

    test('each section is judged on its own history', () async {
      final useCase = buildUseCase();

      // Basic info creates itself.
      final created = await useCase.call(
        step: ProfileStep.basicInfo,
        draft: const TeacherProfileDraft(),
        lastSavedBody: null,
      );

      // About you has never been saved, so it creates itself too — a sibling
      // section having been saved does not make this an update.
      await useCase.call(
        step: ProfileStep.aboutYou,
        draft: draftWithBio('Maths teacher'),
        lastSavedBody: null,
      );

      // Back on basic info with an edit: that section now exists, so PATCH.
      await useCase.call(
        step: ProfileStep.basicInfo,
        draft: const TeacherProfileDraft(
          basicInfo: BasicInfo(city: 'New Delhi'),
        ),
        lastSavedBody:
            (created as ApiSuccess<SectionSaveOutcome>).data.savedBody,
      );

      expect(repository.calls, hasLength(3));
      expect(repository.calls.map((call) => call.isUpdate), [
        false,
        false,
        true,
      ]);
    });

    test('surfaces the failure and records nothing as saved', () async {
      repository.failWith = const ApiException(
        message: 'Server error. Try again later.',
        type: ApiExceptionType.server,
      );

      final result = await buildUseCase().call(
        step: ProfileStep.aboutYou,
        draft: draftWithBio('Maths teacher'),
        lastSavedBody: null,
      );

      expect(result, isA<ApiFailure<SectionSaveOutcome>>());
      expect(
        (result as ApiFailure<SectionSaveOutcome>).exception.message,
        'Server error. Try again later.',
      );
    });
  });

  group('repeatable sections', () {
    ExperienceInfo position(String jobTitle) => ExperienceInfo(
      totalTeachingExperience: '5-7 years',
      currentJobTitle: jobTitle,
      currentInstitution: 'Delhi Public School',
      experienceDetails: 'Taught senior classes.',
      startDate: DateTime(2019, 4),
    );

    test('files each experience with its own POST', () async {
      final useCase = buildUseCase();

      final first = await useCase.call(
        step: ProfileStep.experience,
        draft: TeacherProfileDraft(experience: position('Mathematics Teacher')),
        lastSavedBody: null,
      );
      final afterFirst = (first as ApiSuccess<SectionSaveOutcome>).data;

      expect(repository.calls.single.isUpdate, isFalse);
      expect(afterFirst.draft.savedExperiences, hasLength(1));
      // The form is cleared for the next position...
      expect(afterFirst.draft.experience.currentJobTitle, isEmpty);
      // ...but the profile-level answer rides along.
      expect(afterFirst.draft.experience.totalTeachingExperience, '5-7 years');

      // A second entry creates another row — never a PATCH of the first.
      final second = await useCase.call(
        step: ProfileStep.experience,
        draft: afterFirst.draft.copyWith(
          experience: position('Head of Department'),
        ),
        lastSavedBody: afterFirst.savedBody,
      );

      expect(repository.calls, hasLength(2));
      expect(repository.calls.last.isUpdate, isFalse);
      expect(
        (second as ApiSuccess<SectionSaveOutcome>).data.draft.savedExperiences,
        hasLength(2),
      );
    });

    test('sends nothing when the form is left blank', () async {
      final result = await buildUseCase().call(
        step: ProfileStep.experience,
        draft: TeacherProfileDraft(
          savedExperiences: [position('Mathematics Teacher')],
          // Only the profile-level answer remains after filing an entry.
          experience: const ExperienceInfo(
            totalTeachingExperience: '5-7 years',
          ),
        ),
        lastSavedBody: 'whatever was sent last time',
      );

      expect(repository.calls, isEmpty);
      expect(
        (result as ApiSuccess<SectionSaveOutcome>).data.wasSkipped,
        isTrue,
      );
    });

    test('files each qualification with its own POST', () async {
      final useCase = buildUseCase();

      final first = await useCase.call(
        step: ProfileStep.education,
        draft: const TeacherProfileDraft(
          education: Education(
            degree: 'Bachelor of Science',
            specialization: 'Mathematics',
            universityCollege: 'University of Delhi',
            yearOfPassing: 2014,
            marksOrGrade: 'A',
          ),
        ),
        lastSavedBody: null,
      );
      final afterFirst = (first as ApiSuccess<SectionSaveOutcome>).data;

      expect(repository.calls.single.isUpdate, isFalse);
      expect(repository.calls.single.path, ApiEndpoints.education);
      expect(afterFirst.draft.savedEducations, hasLength(1));
      expect(afterFirst.draft.education.degree, isNull);

      await useCase.call(
        step: ProfileStep.education,
        draft: afterFirst.draft.copyWith(
          education: const Education(
            degree: 'Master of Science',
            specialization: 'Mathematics',
            universityCollege: 'University of Delhi',
            yearOfPassing: 2016,
            marksOrGrade: 'A+',
          ),
        ),
        lastSavedBody: afterFirst.savedBody,
      );

      expect(repository.calls, hasLength(2));
      expect(repository.calls.last.isUpdate, isFalse);
      expect(repository.calls.last.body['degree'], 'Master of Science');
    });
  });

  group('null handling', () {
    test('sends empty strings in place of nulls', () async {
      await buildUseCase().call(
        step: ProfileStep.basicInfo,
        // Nothing optional filled in: no photo, no gender, no date of birth.
        draft: const TeacherProfileDraft(),
        lastSavedBody: null,
      );

      final body = repository.calls.single.body;
      expect(body['profilePhotoUrl'], '');
      expect(body['gender'], '');
      expect(body['dateOfBirth'], '');
      expect(body.values, isNot(contains(null)));
    });

    test('leaves values that are present untouched', () async {
      await buildUseCase().call(
        step: ProfileStep.basicInfo,
        draft: const TeacherProfileDraft(
          basicInfo: BasicInfo(city: 'New Delhi', postalCode: '110016'),
        ),
        lastSavedBody: null,
      );

      final body = repository.calls.single.body;
      expect(body['city'], 'New Delhi');
      expect(body['postalCode'], '110016');
    });
  });

  group('body', () {
    test('matches the about-you payload keys', () async {
      const section = AboutYouSection();

      final body = section.body(
        const TeacherProfileDraft(
          aboutYou: AboutYou(
            shortBio: 'Experienced mathematics teacher',
            teachingApproach: 'Conceptual learning with practice',
            whatMakesYouUnique: 'Focus on clarity and problem solving',
            subjectsTaught: ['Mathematics', 'Algebra'],
            classesTaught: ['Class 8', 'Class 9'],
            languagesKnown: ['English', 'Hindi'],
          ),
        ),
      );

      expect(jsonDecode(jsonEncode(body)), {
        'shortBio': 'Experienced mathematics teacher',
        'teachingApproach': 'Conceptual learning with practice',
        'whatMakesYouUnique': 'Focus on clarity and problem solving',
        'subjectsTaught': ['Mathematics', 'Algebra'],
        'classesTaught': ['Class 8', 'Class 9'],
        'languagesKnown': ['English', 'Hindi'],
      });
    });

    test('experience reuses the subjects captured in about you', () {
      const draft = TeacherProfileDraft(
        aboutYou: AboutYou(
          subjectsTaught: ['Mathematics'],
          classesTaught: ['Class 8'],
        ),
      );

      expect(draft.teachingSubjects, ['Mathematics']);
      expect(draft.classesTaught, ['Class 8']);
    });
  });
}
