import 'package:Shikshak/core/network/api_exception.dart';
import 'package:Shikshak/core/network/api_result.dart';
import 'package:Shikshak/features/account_create/about_you/data/model/about_you_response_model.dart';
import 'package:Shikshak/features/account_create/about_you/domain/entities/about_you.dart';
import 'package:Shikshak/features/account_create/about_you/domain/repositories/about_you_repository.dart';
import 'package:Shikshak/features/account_create/about_you/presentation/providers/about_you_providers.dart';
import 'package:Shikshak/features/account_create/basic_info/data/model/basic_info_response_model.dart';
import 'package:Shikshak/features/account_create/basic_info/domain/entities/basic_info.dart';
import 'package:Shikshak/features/account_create/basic_info/domain/entities/gender.dart';
import 'package:Shikshak/features/account_create/basic_info/domain/repositories/basic_info_repository.dart';
import 'package:Shikshak/features/account_create/basic_info/presentation/providers/basic_info_providers.dart';
import 'package:Shikshak/features/account_create/shared/domain/entities/profile_step.dart';
import 'package:Shikshak/features/account_create/shared/presentation/providers/account_create_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The basic-info payload exactly as the API answers it.
const Map<String, dynamic> _basicInfoJson = {
  'success': true,
  'code': 200,
  'message': 'Teacher profile fetched successfully',
  'data': {
    'profile': {
      'id': '35bc73f8-1204-4043-b3da-760354b02e59',
      'userAuthId': 'e2fc7ef5-8799-4986-924f-6d40b743f114',
      'profilePhotoUrl': null,
      'gender': 'male',
      'dateOfBirth': '2008-08-02T00:00:00.000Z',
      'addressLine1': 'Xn',
      'addressLine2': 'Djdj',
      'city': 'Hh',
      'state': 'Nnx',
      'country': 'Xnnx',
      'postalCode': '989865',
      'isProfileComplete': false,
      'status': 'draft',
      'submittedAt': null,
      'reviewedAt': null,
      'reviewNotes': null,
      'createdAt': '2026-08-02T14:48:03.207Z',
      'updatedAt': '2026-08-02T14:48:03.209Z',
    },
  },
};

const Map<String, dynamic> _aboutYouJson = {
  'success': true,
  'code': 200,
  'message': 'Teacher profile fetched successfully',
  'data': {
    'aboutYou': {
      'id': '14001607-ab9c-4a6f-ad94-8d547c43441d',
      'teacherProfileId': '35bc73f8-1204-4043-b3da-760354b02e59',
      'shortBio': 'Bdb',
      'teachingApproach': 'Xjdj',
      'whatMakesYouUnique': 'Xjxj',
      'subjectsTaught': ['Mathematics'],
      'classesTaught': ['Class 3'],
      'languagesKnown': ['Bengali'],
      'createdAt': '2026-08-02T14:48:39.771Z',
      'updatedAt': '2026-08-02T14:48:39.771Z',
    },
  },
};

class _StubBasicInfoRepository implements BasicInfoRepository {
  _StubBasicInfoRepository(this.result);

  final ApiResult<BasicInfo?> result;

  @override
  Future<ApiResult<BasicInfo?>> fetchBasicInfo() async => result;
}

class _StubAboutYouRepository implements AboutYouRepository {
  _StubAboutYouRepository(this.result);

  final ApiResult<AboutYou?> result;

  @override
  Future<ApiResult<AboutYou?>> fetchAboutYou() async => result;
}

void main() {
  group('basic info response', () {
    final profile = BasicInfoResponseModel.fromJson(_basicInfoJson).data!
        .profile!;

    test('maps every field onto the form entity', () {
      final info = profile.toBasicInfo();

      expect(info.gender, Gender.male);
      expect(info.addressLine1, 'Xn');
      expect(info.addressLine2, 'Djdj');
      expect(info.city, 'Hh');
      expect(info.state, 'Nnx');
      expect(info.country, 'Xnnx');
      expect(info.postalCode, '989865');
    });

    test('reads the date of birth as a plain calendar date', () {
      final dateOfBirth = profile.toBasicInfo().dateOfBirth!;

      // Whatever the device's zone, the day must not slide.
      expect(dateOfBirth.year, 2008);
      expect(dateOfBirth.month, 8);
      expect(dateOfBirth.day, 2);
    });

    test('a null photo stays null rather than becoming an empty URL', () {
      expect(profile.toBasicInfo().profilePhotoUrl, isNull);
    });

    test('an unknown gender reads as unanswered', () {
      expect(Gender.fromWire(null), isNull);
      expect(Gender.fromWire(''), isNull);
      expect(Gender.fromWire('unknown'), isNull);
      expect(Gender.fromWire('FEMALE'), Gender.female);
    });

    test('a profile the API omits does not throw', () {
      final empty = BasicInfoResponseModel.fromJson(const {
        'success': true,
        'data': null,
      });

      expect(empty.data, isNull);
    });
  });

  group('about you response', () {
    final about = AboutYouResponseModel.fromJson(_aboutYouJson).data!.aboutYou!;

    test('maps every field onto the form entity', () {
      final entity = about.toAboutYou();

      expect(entity.shortBio, 'Bdb');
      expect(entity.teachingApproach, 'Xjdj');
      expect(entity.whatMakesYouUnique, 'Xjxj');
      expect(entity.subjectsTaught, ['Mathematics']);
      expect(entity.classesTaught, ['Class 3']);
      expect(entity.languagesKnown, ['Bengali']);
    });

    test('missing lists read as empty, never null', () {
      final sparse = AboutYouModel.fromJson(const {'shortBio': 'Bio only'});
      final entity = sparse.toAboutYou();

      expect(entity.subjectsTaught, isEmpty);
      expect(entity.classesTaught, isEmpty);
      expect(entity.languagesKnown, isEmpty);
      expect(entity.teachingApproach, isEmpty);
    });
  });

  group('loading a saved section', () {
    ProviderContainer basicInfoContainer(ApiResult<BasicInfo?> result) {
      final container = ProviderContainer(
        overrides: [
          basicInfoRepositoryProvider.overrideWithValue(
            _StubBasicInfoRepository(result),
          ),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('holds what the server answered', () async {
      final info = BasicInfoResponseModel.fromJson(
        _basicInfoJson,
      ).data!.profile!.toBasicInfo();

      final container = basicInfoContainer(ApiResult.success(info));
      // Keeps the auto-disposing notifier alive for the duration of the test.
      container.listen(basicInfoNotifierProvider, (_, _) {});

      await container.read(basicInfoNotifierProvider.notifier).load();

      final state = container.read(basicInfoNotifierProvider);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.info?.city, 'Hh');
    });

    test('a teacher with nothing saved is not an error', () async {
      final container = ProviderContainer(
        overrides: [
          aboutYouRepositoryProvider.overrideWithValue(
            _StubAboutYouRepository(const ApiResult.success(null)),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(aboutYouNotifierProvider, (_, _) {});

      await container.read(aboutYouNotifierProvider.notifier).load();

      final state = container.read(aboutYouNotifierProvider);
      expect(state.about, isNull);
      expect(state.error, isNull);
    });

    test('surfaces a failure and keeps nothing', () async {
      const exception = ApiException(
        message: 'Server error. Try again later.',
        type: ApiExceptionType.server,
      );
      final container = basicInfoContainer(const ApiResult.failure(exception));
      container.listen(basicInfoNotifierProvider, (_, _) {});

      await container.read(basicInfoNotifierProvider.notifier).load();

      final state = container.read(basicInfoNotifierProvider);
      expect(state.info, isNull);
      expect(state.isLoading, isFalse);
      expect(state.error, same(exception));
    });
  });

  group('hydrating the draft', () {
    ProviderContainer wizardContainer() {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(accountCreateNotifierProvider, (_, _) {});
      return container;
    }

    test('fills the draft and marks the section as already saved', () {
      final container = wizardContainer();
      final info = BasicInfoResponseModel.fromJson(
        _basicInfoJson,
      ).data!.profile!.toBasicInfo();

      container.read(accountCreateNotifierProvider.notifier).hydrateBasicInfo(
        info,
      );

      final state = container.read(accountCreateNotifierProvider);
      expect(state.draft.basicInfo.city, 'Hh');
      // A recorded body is what makes the next save a PATCH instead of a
      // second POST of a section that already exists.
      expect(state.savedBodies[ProfileStep.basicInfo], isNotNull);
      expect(state.savedBodies[ProfileStep.basicInfo], contains('"city":"Hh"'));
    });

    test('records the about-you body too', () {
      final container = wizardContainer();
      final about = AboutYouResponseModel.fromJson(
        _aboutYouJson,
      ).data!.aboutYou!.toAboutYou();

      container.read(accountCreateNotifierProvider.notifier).hydrateAboutYou(
        about,
      );

      final state = container.read(accountCreateNotifierProvider);
      expect(state.draft.aboutYou.subjectsTaught, ['Mathematics']);
      expect(state.savedBodies[ProfileStep.aboutYou], contains('"shortBio"'));
    });

    test('leaves the other sections untouched', () {
      final container = wizardContainer();
      final info = BasicInfoResponseModel.fromJson(
        _basicInfoJson,
      ).data!.profile!.toBasicInfo();

      container.read(accountCreateNotifierProvider.notifier).hydrateBasicInfo(
        info,
      );

      final state = container.read(accountCreateNotifierProvider);
      expect(state.savedBodies.containsKey(ProfileStep.aboutYou), isFalse);
      expect(state.draft.aboutYou.shortBio, isEmpty);
    });
  });
}
