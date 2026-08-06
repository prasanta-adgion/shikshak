import 'package:Shikshak/features/auth/domain/entities/user_role.dart';
import 'package:Shikshak/features/teacher/create_profile_account/basic_info/domain/entities/gender.dart';
import 'package:Shikshak/features/teacher/profile/data/model/teacher_profile_response_model.dart';
import 'package:Shikshak/features/teacher/profile/domain/entities/teacher_profile.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures/teacher_profile_response.dart';

void main() {
  group('TeacherProfileResponseModel', () {
    test('parses the envelope', () {
      final model = TeacherProfileResponseModel.fromJson(
        teacherProfileResponseJson(),
      );

      expect(model.success, isTrue);
      expect(model.code, 200);
      expect(model.data, isNotNull);
      expect(model.data!.experience, hasLength(1));
      expect(model.data!.education, hasLength(2));
      expect(model.data!.documents, hasLength(5));
    });

    test('maps the payload onto the entity', () {
      final profile = TeacherProfileResponseModel.fromJson(
        teacherProfileResponseJson(),
      ).data!.toEntity();

      expect(profile.user.fullName, 'Rahul Teacher');
      expect(profile.user.email, 'rahul.adgion@gmail.com');
      expect(profile.user.role, UserRole.teacher);
      expect(profile.phoneNumber, '8617463209');
      expect(profile.isEmailVerified, isTrue);

      expect(profile.status, ProfileReviewStatus.approved);
      expect(profile.isProfileComplete, isTrue);
      expect(profile.reviewedAt, isNotNull);

      expect(profile.basicInfo.gender, Gender.male);
      expect(profile.basicInfo.city, 'Arambagh');
      expect(profile.basicInfo.postalCode, '712602');
      expect(profile.basicInfo.profilePhotoUrl, isNull);

      expect(profile.aboutYou.shortBio, 'short bio');
      expect(profile.aboutYou.subjectsTaught, ['Mathematics', 'Physics']);
      expect(profile.aboutYou.languagesKnown, ['python']);

      expect(profile.experiences.single.currentJobTitle,
          'Computer Teacher with math');
      expect(profile.experiences.single.isCurrent, isTrue);

      expect(profile.educations.first.degree, 'btech');
      expect(profile.educations.first.isHighestQualification, isTrue);
      expect(profile.educations.last.isHighestQualification, isFalse);
    });

    test('keeps document types the DocumentType enum does not cover', () {
      final profile = TeacherProfileResponseModel.fromJson(
        teacherProfileResponseJson(),
      ).data!.toEntity();

      expect(
        profile.documents.map((document) => document.typeLabel),
        [
          'Resume',
          'Aadhaar Card',
          'Pan Card',
          'Highest Qualification Certificate',
          'Experience Certificate',
        ],
      );
      expect(profile.documents.first.readableSize, '95 KB');
      expect(profile.documents.every((document) => !document.isVerified), isTrue);
    });

    test('prefers signedUrl over the stale upload-time fileUrl', () {
      final profile = TeacherProfileResponseModel.fromJson(
        teacherProfileResponseJson(),
      ).data!.toEntity();

      expect(profile.documents.first.fileUrl, contains('20260805T053454Z'));
    });

    test('survives a payload with everything missing', () {
      final model = TeacherProfileResponseModel.fromJson({
        'success': true,
        'data': <String, dynamic>{},
      });
      final profile = model.data!.toEntity();

      expect(profile.user.fullName, isEmpty);
      expect(profile.user.role, UserRole.teacher);
      // No status on the wire is a profile still awaiting review.
      expect(profile.status, ProfileReviewStatus.pending);
      expect(profile.experiences, isEmpty);
      expect(profile.educations, isEmpty);
      expect(profile.documents, isEmpty);
      expect(profile.formattedAddress, isEmpty);
    });

    test('falls back to the profile row when submission is absent', () {
      final json = teacherProfileResponseJson();
      (json['data'] as Map<String, dynamic>).remove('submission');

      final profile = TeacherProfileResponseModel.fromJson(json).data!.toEntity();

      expect(profile.status, ProfileReviewStatus.approved);
      expect(profile.isProfileComplete, isTrue);
    });
  });
}
