import 'package:Shikshak/app/router/route_paths.dart';
import 'package:Shikshak/core/constants/api_endpoints.dart';
import 'package:Shikshak/core/network/i_api_client.dart';
import 'package:Shikshak/core/providers/core_providers.dart';
import 'package:Shikshak/core/theme/app_theme.dart';
import 'package:Shikshak/features/teacher/create_profile_account/documents/presentation/widgets/document_form_fields.dart';
import 'package:Shikshak/features/teacher/create_profile_account/education/presentation/widgets/education_form_fields.dart';
import 'package:Shikshak/features/teacher/create_profile_account/experience/presentation/widgets/experience_display_screen.dart';
import 'package:Shikshak/features/teacher/create_profile_account/experience/presentation/widgets/experience_form_fields.dart';
import 'package:Shikshak/features/teacher/create_profile_account/shared/domain/entities/profile_step.dart';
import 'package:Shikshak/features/teacher/create_profile_account/shared/domain/entities/wizard_mode.dart';
import 'package:Shikshak/features/teacher/create_profile_account/shared/presentation/notifier/account_create_notifier.dart';
import 'package:Shikshak/features/teacher/create_profile_account/shared/presentation/pages/create_teacher_account_page.dart';
import 'package:Shikshak/features/teacher/create_profile_account/shared/presentation/providers/account_create_providers.dart';
import 'package:Shikshak/features/teacher/create_profile_account/shared/presentation/widgets/step_timeline.dart';
import 'package:Shikshak/features/teacher/create_profile_account/shared/presentation/widgets/wizard_add_another_button.dart';
import 'package:Shikshak/features/teacher/profile/data/model/teacher_profile_response_model.dart';
import 'package:Shikshak/features/teacher/profile/presentation/notifier/teacher_profile_notifier.dart';
import 'package:Shikshak/features/teacher/profile/presentation/pages/teacher_profile_page.dart';
import 'package:Shikshak/features/teacher/profile/presentation/providers/teacher_profile_providers.dart';
import 'package:Shikshak/features/teacher/profile/presentation/state/teacher_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'fixtures/teacher_profile_response.dart';

/// Answers every GET with an empty-but-well-formed envelope, so the wizard
/// steps can hydrate without touching the network.
class _EmptyApiClient implements IApiClient {
  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async =>
      {
            'success': true,
            'code': 200,
            'data': {'items': <dynamic>[]},
          }
          as T;

  @override
  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => throw UnimplementedError('No write should happen in these tests.');

  @override
  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => throw UnimplementedError();

  @override
  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => throw UnimplementedError('No write should happen in these tests.');

  @override
  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => throw UnimplementedError();
}

/// Records every call so a test can assert which verbs actually fired.
class _RecordingApiClient extends _EmptyApiClient {
  final calls = <String>[];

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) {
    calls.add('GET $path');
    return super.get<T>(
      path,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  @override
  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    calls.add('POST $path');
    return {'success': true, 'code': 200, 'data': <String, dynamic>{}} as T;
  }
}

class _SeededProfileNotifier extends TeacherProfileNotifier {
  @override
  TeacherProfileState build() => TeacherProfileState(
    profile: TeacherProfileResponseModel.fromJson(
      teacherProfileResponseJson(),
    ).data!.toEntity(),
    hasLoaded: true,
  );

  @override
  Future<void> load() async {}
}

void main() {
  void setWindow(WidgetTester tester, [Size size = const Size(390, 4000)]) {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('Profile Edit entry point', () {
    testWidgets('each section opens its own wizard step', (tester) async {
      setWindow(tester);
      Object? capturedExtra;

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Scaffold(body: TeacherProfilePage()),
          ),
          GoRoute(
            path: RoutePaths.editProfileSection,
            builder: (context, state) {
              capturedExtra = state.extra;
              return const Scaffold(body: Text('EDIT SCREEN'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            teacherProfileNotifierProvider.overrideWith(
              _SeededProfileNotifier.new,
            ),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // One Edit per section, in the order the page lists them. The saved-row
      // cards on this screen carry no Edit of their own, so the count is exact.
      expect(find.text('Edit'), findsNWidgets(5));

      const expected = [
        ProfileStep.basicInfo,
        ProfileStep.aboutYou,
        ProfileStep.experience,
        ProfileStep.education,
        ProfileStep.documents,
      ];

      for (var index = 0; index < expected.length; index++) {
        await tester.tap(find.text('Edit').at(index));
        await tester.pumpAndSettle();

        expect(
          capturedExtra,
          expected[index],
          reason: 'Edit #$index should open ${expected[index].name}',
        );

        router.go('/');
        await tester.pumpAndSettle();
        capturedExtra = null;
      }
    });
  });

  group('Wizard in edit mode', () {
    Future<void> pumpWizard(WidgetTester tester, ProfileStep step) async {
      setWindow(tester);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(_EmptyApiClient()),
            // Exactly how the edit route scopes it.
            accountCreateNotifierProvider.overrideWith(
              () => AccountCreateNotifier(
                initialStep: step,
                initialMode: WizardMode.edit,
              ),
            ),
          ],
          child: const MaterialApp(home: CreateTeacherAccountPage()),
        ),
      );
      // The page seeds the notifier in a microtask, then the step loads.
      await tester.pumpAndSettle();
    }

    testWidgets('a singleton section offers Update and hides the timeline', (
      tester,
    ) async {
      await pumpWizard(tester, ProfileStep.basicInfo);

      expect(find.text('Update'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
      expect(find.byType(StepTimeline), findsNothing);
      // 'Back' would mean the previous step, of which there is none. Cancel
      // is also the only way off a screen that has no app bar.
      expect(find.text('Back'), findsNothing);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('About You also offers Update', (tester) async {
      await pumpWizard(tester, ProfileStep.aboutYou);

      expect(find.text('Update'), findsOneWidget);
      expect(find.byType(StepTimeline), findsNothing);
    });

    testWidgets('a repeatable section can edit rows and add another', (
      tester,
    ) async {
      await pumpWizard(tester, ProfileStep.experience);

      expect(find.text('Update'), findsOneWidget);
      // The saved rows are edited one by one through their own sheets...
      expect(find.byType(SavedExperienceList), findsOneWidget);
      // ...and the form stays, so a new position can be added while editing.
      expect(find.byType(ExperienceFormFields), findsOneWidget);
      expect(find.byType(WizardAddAnotherButton), findsOneWidget);
    });

    testWidgets('Education keeps its create form', (tester) async {
      await pumpWizard(tester, ProfileStep.education);

      expect(find.text('Update'), findsOneWidget);
      expect(find.byType(EducationFormFields), findsOneWidget);
      expect(find.byType(WizardAddAnotherButton), findsOneWidget);
    });

    testWidgets('Documents keeps its create form', (tester) async {
      await pumpWizard(tester, ProfileStep.documents);

      expect(find.text('Update'), findsOneWidget);
      // 'Finish' is the create-mode label for this last step.
      expect(find.text('Finish'), findsNothing);
      expect(find.byType(DocumentFormFields), findsOneWidget);
      expect(find.byType(WizardAddAnotherButton), findsOneWidget);
    });
  });

  group('Adding while editing', () {
    Future<_RecordingApiClient> pumpRecorded(
      WidgetTester tester,
      ProfileStep step,
    ) async {
      setWindow(tester);
      final client = _RecordingApiClient();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(client),
            accountCreateNotifierProvider.overrideWith(
              () => AccountCreateNotifier(
                initialStep: step,
                initialMode: WizardMode.edit,
              ),
            ),
          ],
          child: const MaterialApp(home: CreateTeacherAccountPage()),
        ),
      );
      await tester.pumpAndSettle();
      return client;
    }

    testWidgets('Update on a blank form adds nothing', (tester) async {
      final client = await pumpRecorded(tester, ProfileStep.experience);

      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      // The empty entry is skipped, so leaving without typing cannot create a
      // stray row — the whole reason the create form is safe to show here.
      expect(client.calls.where((call) => call.startsWith('POST')), isEmpty);
    });

    testWidgets('Experience reads About You so a new row carries its lists', (
      tester,
    ) async {
      final client = await pumpRecorded(tester, ProfileStep.experience);

      // Every experience row repeats teachingSubjects and classesTaught, and
      // editing opens without the draft onboarding would have filled.
      expect(client.calls, contains('GET ${ApiEndpoints.aboutYou}'));
    });

    testWidgets('Education does not need About You', (tester) async {
      final client = await pumpRecorded(tester, ProfileStep.education);

      expect(client.calls, isNot(contains('GET ${ApiEndpoints.aboutYou}')));
    });
  });

  group('Wizard in create mode is unchanged', () {
    testWidgets('starts at step one with the timeline and Continue', (
      tester,
    ) async {
      setWindow(tester);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [apiClientProvider.overrideWithValue(_EmptyApiClient())],
          child: const MaterialApp(home: CreateTeacherAccountPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StepTimeline), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Update'), findsNothing);
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('a repeatable step still shows its create form', (
      tester,
    ) async {
      setWindow(tester);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [apiClientProvider.overrideWithValue(_EmptyApiClient())],
          child: const MaterialApp(home: CreateTeacherAccountPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Jump forward the way a completed save would.
      final context = tester.element(find.byType(CreateTeacherAccountPage));
      ProviderScope.containerOf(context)
          .read(accountCreateNotifierProvider.notifier)
          .goTo(ProfileStep.experience);
      await tester.pumpAndSettle();

      expect(find.byType(ExperienceFormFields), findsOneWidget);
      expect(find.byType(WizardAddAnotherButton), findsOneWidget);
    });
  });
}
