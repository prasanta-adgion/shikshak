import 'package:Shikshak/core/network/api_exception.dart';
import 'package:Shikshak/core/theme/app_theme.dart';
import 'package:Shikshak/features/student/profile/data/model/student_profile_response_model.dart';
import 'package:Shikshak/features/student/profile/domain/entities/student_profile.dart';
import 'package:Shikshak/features/student/profile/presentation/notifier/student_profile_notifier.dart';
import 'package:Shikshak/features/student/profile/presentation/pages/student_profile_page.dart';
import 'package:Shikshak/features/student/profile/presentation/providers/student_profile_providers.dart';
import 'package:Shikshak/features/student/profile/presentation/state/student_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures/student_profile_response.dart';

/// Serves a fixed state instead of hitting the network. `load()` is
/// overridden to a no-op so the page's initState call changes nothing.
class _SeededProfileNotifier extends StudentProfileNotifier {
  _SeededProfileNotifier(this._seed);

  final StudentProfileState _seed;

  @override
  StudentProfileState build() => _seed;

  @override
  Future<void> load() async {}
}

StudentProfile parsedProfile([Map<String, dynamic>? json]) =>
    StudentProfileResponseModel.fromJson(
      json ?? studentProfileResponseJson(),
    ).data!.toEntity();

void main() {
  Future<void> pumpProfile(
    WidgetTester tester, {
    required StudentProfileState state,
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
          studentProfileNotifierProvider.overrideWith(
            () => _SeededProfileNotifier(state),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: StudentProfilePage()),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> pumpLoaded(WidgetTester tester, {StudentProfile? profile}) =>
      pumpProfile(
        tester,
        state: StudentProfileState(
          profile: profile ?? parsedProfile(),
          hasLoaded: true,
        ),
      );

  group('StudentProfilePage', () {
    testWidgets('renders the identity block', (tester) async {
      await pumpLoaded(tester);

      expect(find.text('Seema'), findsOneWidget);
      // Once under the name, once in the Contact section.
      expect(find.text('9991seema@gmail.com'), findsNWidgets(2));
      expect(find.text('Student'), findsOneWidget);
      // The header strip summarises; the sections below give the full value.
      expect(find.text('Aug 2026'), findsOneWidget);
      expect(find.text('17 Aug 2026'), findsOneWidget);
      expect(find.text('English'), findsNWidgets(2));
    });

    testWidgets('falls back to initials when there is no photo', (
      tester,
    ) async {
      await pumpLoaded(tester);

      expect(find.text('S'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('renders the photo and cover when the profile carries them', (
      tester,
    ) async {
      await pumpLoaded(
        tester,
        profile: parsedProfile(completeStudentProfileResponseJson()),
      );

      final urls = tester
          .widgetList<Image>(find.byType(Image))
          .map((image) => (image.image as NetworkImage).url);

      expect(urls, containsAll(<String>[
        'https://example.com/avatar.png',
        'https://example.com/cover.png',
      ]));
    });

    testWidgets('shows how far off a complete profile is', (tester) async {
      await pumpLoaded(tester);

      expect(find.text('Complete your profile'), findsOneWidget);
      expect(find.text('17%'), findsOneWidget);
      expect(
        find.textContaining('1 of 6 details added'),
        findsOneWidget,
      );

      // Every unanswered detail is named, so the nudge is actionable.
      expect(find.text('Profile photo'), findsOneWidget);
      expect(find.text('About you'), findsOneWidget);
      expect(find.text('Verified email'), findsOneWidget);
      // Filled in at signup, so it is not listed as missing.
      expect(find.text('Phone number'), findsOneWidget); // the Contact row
    });

    testWidgets('celebrates a finished profile instead of nagging', (
      tester,
    ) async {
      await pumpLoaded(
        tester,
        profile: parsedProfile(completeStudentProfileResponseJson()),
      );

      expect(find.text('Profile complete'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('Complete your profile'), findsNothing);
    });

    testWidgets('renders every section of a filled-in profile', (tester) async {
      await pumpLoaded(
        tester,
        profile: parsedProfile(completeStudentProfileResponseJson()),
      );

      expect(
        find.text('Class 11 science student, preparing for JEE.'),
        findsOneWidget,
      );
      expect(find.text('Female'), findsOneWidget);
      expect(find.textContaining('12 Apr 2005'), findsOneWidget);
      expect(find.text('Bengali'), findsNWidgets(2));
      expect(find.text('9230632745'), findsOneWidget);
      expect(find.text('9230632746'), findsOneWidget);
      expect(find.text('Email updates'), findsOneWidget);
      expect(find.text('Sms alerts'), findsOneWidget);
      expect(find.text('Social Links (2)'), findsOneWidget);
      expect(find.text('linkedin.com/in/seema'), findsOneWidget);
      expect(find.text('seema.dev'), findsOneWidget);
      expect(find.text('17 Aug 2026'), findsOneWidget);
    });

    testWidgets('flags an unverified email in both places it appears', (
      tester,
    ) async {
      await pumpLoaded(tester);

      // The header stat and the pill on the Contact row.
      expect(find.text('Unverified'), findsNWidgets(2));
      expect(find.text('Verified'), findsNothing);
    });

    testWidgets('empty sections say so instead of collapsing', (tester) async {
      await pumpLoaded(tester);

      expect(
        find.text('No bio yet. A line or two helps teachers place you.'),
        findsOneWidget,
      );
      expect(find.text('No links added yet.'), findsOneWidget);
      expect(
        find.textContaining('Using the default alerts'),
        findsOneWidget,
      );
      // Unanswered fields read as an em dash rather than vanishing.
      expect(find.text('—'), findsWidgets);
    });

    testWidgets('shows a spinner on the first load', (tester) async {
      await pumpProfile(
        tester,
        state: const StudentProfileState(isLoading: true),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Personal Details'), findsNothing);
    });

    testWidgets('shows a retryable error when the load fails', (tester) async {
      await pumpProfile(
        tester,
        state: const StudentProfileState(
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

    testWidgets('offers a retry when the student has no profile row', (
      tester,
    ) async {
      await pumpProfile(
        tester,
        state: const StudentProfileState(hasLoaded: true),
      );

      expect(find.text('No profile yet'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
