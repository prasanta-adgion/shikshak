import 'package:Shikshak/features/auth/domain/entities/user_role.dart';
import 'package:Shikshak/features/student/profile/data/model/student_profile_response_model.dart';
import 'package:Shikshak/features/student/profile/domain/entities/student_profile.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures/student_profile_response.dart';

StudentProfile parse(Map<String, dynamic> json) =>
    StudentProfileResponseModel.fromJson(json).data!.toEntity();

void main() {
  group('StudentProfileResponseModel', () {
    test('flattens the user and profile rows into one entity', () {
      final profile = parse(studentProfileResponseJson());

      expect(profile.user.id, 'd070abdd-99fe-468b-9431-ce5a91f34818');
      expect(profile.user.fullName, 'Seema');
      expect(profile.user.email, '9991seema@gmail.com');
      expect(profile.user.role, UserRole.student);
      expect(profile.phoneNumber, '9230632745');
      expect(profile.isEmailVerified, isFalse);
      expect(profile.language, 'en');
      expect(profile.isProfileComplete, isFalse);
    });

    test('reads member-since off the user row', () {
      final profile = parse(studentProfileResponseJson());

      expect(profile.joinedAt?.toUtc().year, 2026);
      expect(profile.joinedAt?.toUtc().month, 8);
      expect(profile.joinedAt?.toUtc().day, 17);
    });

    test('leaves the untouched profile columns null', () {
      final profile = parse(studentProfileResponseJson());

      expect(profile.avatarUrl, isNull);
      expect(profile.coverImageUrl, isNull);
      expect(profile.bio, isNull);
      expect(profile.altPhoneNumber, isNull);
      expect(profile.dateOfBirth, isNull);
      expect(profile.gender, isNull);
      expect(profile.genderLabel, isNull);
      expect(profile.age, isNull);
      expect(profile.notificationPrefs, isEmpty);
      expect(profile.socialLinks, isEmpty);
      expect(profile.lastSeenAt, isNull);
    });

    test('survives a payload with no profile row at all', () {
      final profile = parse({
        'success': true,
        'data': {
          'user': {'name': 'Seema', 'email': '9991seema@gmail.com'},
        },
      });

      expect(profile.user.fullName, 'Seema');
      // The role defaults rather than throwing on an absent field.
      expect(profile.user.role, UserRole.student);
      expect(profile.language, 'en');
      expect(profile.isComplete, isFalse);
    });

    test('takes the avatar off the profile row, not the user row', () {
      final profile = parse(completeStudentProfileResponseJson());

      expect(profile.avatarUrl, 'https://example.com/avatar.png');
      expect(profile.user.avatarUrl, 'https://example.com/avatar.png');
      expect(profile.coverImageUrl, 'https://example.com/cover.png');
    });

    test('keeps only the boolean notification preferences', () {
      final profile = parse(completeStudentProfileResponseJson());

      expect(profile.notificationPrefs.map((p) => p.key), [
        'emailUpdates',
        'smsAlerts',
      ]);
      expect(profile.notificationPrefs.first.isEnabled, isTrue);
      expect(profile.notificationPrefs.last.isEnabled, isFalse);
    });

    test('drops social links with no URL behind them', () {
      final profile = parse(completeStudentProfileResponseJson());

      expect(profile.socialLinks.map((link) => link.platform), [
        'linkedin',
        'website',
      ]);
    });
  });

  group('StudentProfile', () {
    test('counts a fresh profile as one detail of six', () {
      final profile = parse(studentProfileResponseJson());

      expect(profile.filledFieldCount, 1);
      expect(profile.totalFieldCount, 6);
      expect(profile.completion, closeTo(1 / 6, 0.001));
      expect(profile.isComplete, isFalse);
      expect(profile.missingFields, [
        StudentProfileField.photo,
        StudentProfileField.bio,
        StudentProfileField.dateOfBirth,
        StudentProfileField.gender,
        StudentProfileField.emailVerified,
      ]);
    });

    test('counts a filled-in profile as complete', () {
      final profile = parse(completeStudentProfileResponseJson());

      expect(profile.missingFields, isEmpty);
      expect(profile.completion, 1);
      expect(profile.isComplete, isTrue);
    });

    test('trusts the server flag even when a tracked field is blank', () {
      final json = completeStudentProfileResponseJson();
      (json['data'] as Map<String, dynamic>)['profile']['bio'] = null;
      final profile = parse(json);

      expect(profile.missingFields, [StudentProfileField.bio]);
      // The backend counts a different set of columns; when it says finished,
      // the card stops nagging.
      expect(profile.isComplete, isTrue);
    });

    test('humanises the wire values it does not translate', () {
      final profile = parse(completeStudentProfileResponseJson());

      expect(profile.genderLabel, 'Female');
      expect(profile.notificationPrefs.first.label, 'Email updates');
      expect(profile.notificationPrefs.last.label, 'Sms alerts');
    });

    test('keeps a gender value the app has never seen', () {
      final json = completeStudentProfileResponseJson();
      (json['data'] as Map<String, dynamic>)['profile']['gender'] =
          'prefer_not_to_say';

      expect(parse(json).genderLabel, 'Prefer not to say');
    });

    test('names the language, and falls back to the raw code', () {
      expect(parse(completeStudentProfileResponseJson()).languageLabel,
          'Bengali');
      expect(parse(studentProfileResponseJson()).languageLabel, 'English');

      final json = studentProfileResponseJson();
      (json['data'] as Map<String, dynamic>)['profile']['language'] = 'sw';
      expect(parse(json).languageLabel, 'SW');
    });

    test('derives the age from the date of birth', () {
      final profile = parse(completeStudentProfileResponseJson());
      final dateOfBirth = profile.dateOfBirth!;
      final now = DateTime.now();

      final expected =
          now.year -
          dateOfBirth.year -
          (now.month < dateOfBirth.month ||
                  (now.month == dateOfBirth.month && now.day < dateOfBirth.day)
              ? 1
              : 0);

      expect(profile.age, expected);
    });

    test('shortens link URLs for display', () {
      final links = parse(completeStudentProfileResponseJson()).socialLinks;

      expect(links.first.label, 'LinkedIn');
      expect(links.first.displayUrl, 'linkedin.com/in/seema');
      expect(links.last.label, 'Website');
      expect(links.last.displayUrl, 'seema.dev');
    });

    test('leaves an unparseable link alone', () {
      const link = SocialLink(platform: 'myspace', url: 'not a url');

      expect(link.label, 'Myspace');
      expect(link.displayUrl, 'not a url');
    });
  });
}
