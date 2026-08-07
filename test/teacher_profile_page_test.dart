import 'package:Shikshak/core/network/api_exception.dart';
import 'package:Shikshak/core/theme/app_theme.dart';
import 'package:Shikshak/features/teacher/profile/data/model/teacher_profile_response_model.dart';
import 'package:Shikshak/features/teacher/profile/domain/entities/teacher_profile.dart';
import 'package:Shikshak/features/teacher/profile/presentation/notifier/teacher_profile_notifier.dart';
import 'package:Shikshak/features/teacher/profile/presentation/pages/teacher_profile_page.dart';
import 'package:Shikshak/features/teacher/profile/presentation/providers/teacher_profile_providers.dart';
import 'package:Shikshak/features/teacher/profile/presentation/state/teacher_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures/teacher_profile_response.dart';

/// Serves a fixed state instead of hitting the network. `load()` is
/// overridden to a no-op so the page's initState call changes nothing.
class _SeededProfileNotifier extends TeacherProfileNotifier {
  _SeededProfileNotifier(this._seed);

  final TeacherProfileState _seed;

  @override
  TeacherProfileState build() => _seed;

  @override
  Future<void> load() async {}
}

TeacherProfile parsedProfile() => TeacherProfileResponseModel.fromJson(
  teacherProfileResponseJson(),
).data!.toEntity();

void main() {
  Future<void> pumpProfile(
    WidgetTester tester, {
    required TeacherProfileState state,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    // Tall enough for the whole page: the sliver list builds lazily, so
    // anything below the viewport would never be laid out for the finders.
    tester.view.physicalSize = const Size(390, 4000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          teacherProfileNotifierProvider.overrideWith(
            () => _SeededProfileNotifier(state),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: TeacherProfilePage()),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> pumpLoaded(WidgetTester tester, {TeacherProfile? profile}) =>
      pumpProfile(
        tester,
        state: TeacherProfileState(
          profile: profile ?? parsedProfile(),
          hasLoaded: true,
        ),
      );

  group('TeacherProfilePage', () {
    testWidgets('renders the identity block', (tester) async {
      await pumpLoaded(tester);

      expect(find.text('Rahul Teacher'), findsOneWidget);
      expect(find.text('rahul.adgion@gmail.com'), findsOneWidget);
      expect(find.text('8617463209'), findsOneWidget);
      expect(find.text('Teacher'), findsOneWidget);
    });

    testWidgets('falls back to initials when there is no photo', (
      tester,
    ) async {
      await pumpLoaded(tester);

      expect(find.text('RT'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('renders the profile photo when the user row carries one', (
      tester,
    ) async {
      final base = parsedProfile();

      await pumpLoaded(
        tester,
        profile: TeacherProfile(
          user: base.user.copyWith(
            avatarUrl: 'https://example.com/avatar.png',
          ),
          status: base.status,
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as NetworkImage).url, 'https://example.com/avatar.png');
      // The bytes never arrive in a test, so the initials still hold the disc —
      // which is the point: it is never blank.
      expect(find.text('RT'), findsOneWidget);
    });

    testWidgets('renders the review status', (tester) async {
      await pumpLoaded(tester);

      expect(find.text('Approved'), findsOneWidget);
      expect(find.text('Reviewed on 3 Aug 2026'), findsOneWidget);
    });

    testWidgets('renders basic information', (tester) async {
      await pumpLoaded(tester);

      expect(find.text('Male'), findsOneWidget);
      expect(find.text('9 Dec 2002'), findsOneWidget);
      expect(find.text('Arambagh, West Bengal'), findsOneWidget);
      expect(find.text('712602'), findsOneWidget);
      expect(
        find.text(
          'Chandur Daulatpur Arambagh 712602, Arambagh, West Bengal, India',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders about-you text and chips', (tester) async {
      await pumpLoaded(tester);

      expect(find.text('short bio'), findsOneWidget);
      expect(find.text('Discussion Based'), findsOneWidget);
      expect(find.text('i am unique'), findsOneWidget);
      expect(find.text('Mathematics'), findsOneWidget);
      expect(find.text('Class 11'), findsOneWidget);
      expect(find.text('python'), findsOneWidget);
    });

    testWidgets('renders repeatable sections with their counts', (
      tester,
    ) async {
      await pumpLoaded(tester);

      expect(find.text('Experience (1)'), findsOneWidget);
      expect(find.text('Education (2)'), findsOneWidget);
      expect(find.text('Documents (5)'), findsOneWidget);

      expect(find.text('Computer Teacher with math'), findsOneWidget);
      expect(find.text('Arambagh Vivekananda Academy'), findsOneWidget);
      expect(find.text('Current'), findsOneWidget);

      expect(find.text('btech'), findsOneWidget);
      expect(find.text('cse · Techno'), findsOneWidget);
      expect(find.text('Passed 2025'), findsOneWidget);
      expect(find.text('Highest'), findsOneWidget);
    });

    testWidgets('humanises document types the enum does not cover', (
      tester,
    ) async {
      await pumpLoaded(tester);

      expect(find.text('Resume'), findsOneWidget);
      expect(find.text('Aadhaar Card'), findsOneWidget);
      expect(find.text('Pan Card'), findsOneWidget);
      expect(find.text('Highest Qualification Certificate'), findsOneWidget);
      expect(find.text('Experience Certificate'), findsOneWidget);
      expect(find.text('Pending verification'), findsNWidgets(5));
      expect(find.text('95 KB'), findsNWidgets(5));
    });

    testWidgets('empty sections say so instead of collapsing', (tester) async {
      final empty = TeacherProfileResponseModel.fromJson({
        'success': true,
        'data': <String, dynamic>{
          'user': {'name': 'Rahul Teacher', 'email': 'rahul.adgion@gmail.com'},
        },
      }).data!.toEntity();

      await pumpLoaded(tester, profile: empty);

      expect(find.text('No experience added yet.'), findsOneWidget);
      expect(find.text('No qualifications added yet.'), findsOneWidget);
      expect(find.text('No documents uploaded yet.'), findsOneWidget);
      expect(find.text('Pending review'), findsOneWidget);
      // Unanswered fields read as an em dash rather than vanishing.
      expect(find.text('—'), findsWidgets);
    });

    testWidgets('shows a spinner on the first load', (tester) async {
      await pumpProfile(
        tester,
        state: const TeacherProfileState(isLoading: true),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Basic Information'), findsNothing);
    });

    testWidgets('shows a retryable error when the load fails', (tester) async {
      await pumpProfile(
        tester,
        state: const TeacherProfileState(
          hasLoaded: true,
          error: ApiException(
            message: 'No internet connection. Check your network and retry.',
            type: ApiExceptionType.network,
          ),
        ),
      );

      expect(
        find.text('No internet connection. Check your network and retry.'),
        findsOneWidget,
      );
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('offers to start a profile when the teacher has none', (
      tester,
    ) async {
      await pumpProfile(
        tester,
        state: const TeacherProfileState(hasLoaded: true),
      );

      expect(find.text('No profile yet'), findsOneWidget);
    });
  });
}
