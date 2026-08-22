import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// `Override` — the type of a ProviderScope override — lives here in Riverpod 3.
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shiksak/core/media/i_media_picker.dart';
import 'package:shiksak/core/media/picked_media.dart';
import 'package:shiksak/core/network/api_exception.dart';
import 'package:shiksak/core/network/api_result.dart';
import 'package:shiksak/core/providers/core_providers.dart';
import 'package:shiksak/core/theme/app_icons.dart';
import 'package:shiksak/core/theme/app_theme.dart';
import 'package:shiksak/features/teacher/create_profile_account/about_you/domain/repositories/profile_image_repository.dart';
import 'package:shiksak/features/teacher/create_profile_account/about_you/presentation/providers/about_you_providers.dart';
import 'package:shiksak/features/teacher/profile/data/model/teacher_profile_response_model.dart';
import 'package:shiksak/features/teacher/profile/domain/entities/teacher_profile.dart';
import 'package:shiksak/features/teacher/profile/presentation/notifier/teacher_profile_notifier.dart';
import 'package:shiksak/features/teacher/profile/presentation/pages/teacher_profile_page.dart';
import 'package:shiksak/features/teacher/profile/presentation/providers/teacher_profile_providers.dart';
import 'package:shiksak/features/teacher/profile/presentation/state/teacher_profile_state.dart';
import 'package:shiksak/features/teacher/profile/presentation/widgets/profile_tab_bar.dart';

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

/// Answers the avatar's pick with a fixed file instead of opening a camera.
class _FakeMediaPicker implements IMediaPicker {
  ImagePickSource? requestedSource;

  @override
  Future<PickedMedia?> pickImage({
    required ImagePickSource source,
    bool crop = false,
    CropAspectRatio? aspectRatio,
  }) async {
    requestedSource = source;
    return const PickedMedia(
      path: '/tmp/new-avatar.png',
      name: 'new-avatar.png',
      sizeBytes: 1024,
      mimeType: 'image/png',
    );
  }

  @override
  Future<PickedMedia?> pickDocument({List<String>? allowedExtensions}) async =>
      null;
}

/// Stands in for the avatar upload — records the file, answers with a URL or
/// the given failure.
class _FakeImageRepository implements ProfileImageRepository {
  _FakeImageRepository({this.failure});

  final ApiException? failure;
  String? uploadedPath;

  @override
  Future<ApiResult<String>> uploadProfileImage(String filePath) async {
    uploadedPath = filePath;
    final error = failure;
    return error == null
        ? const ApiResult.success('https://example.com/new-avatar.png')
        : ApiResult.failure(error);
  }
}

void main() {
  Future<void> pumpProfile(
    WidgetTester tester, {
    required TeacherProfileState state,
    List<Override> overrides = const [],
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
          ...overrides,
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: TeacherProfilePage()),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> pumpLoaded(
    WidgetTester tester, {
    TeacherProfile? profile,
    List<Override> overrides = const [],
  }) => pumpProfile(
    tester,
    state: TeacherProfileState(
      profile: profile ?? parsedProfile(),
      hasLoaded: true,
    ),
    overrides: overrides,
  );

  /// Only one section is on screen at a time, so a test has to open its tab
  /// before it can find anything in it.
  Future<void> openTab(WidgetTester tester, ProfileTab tab) async {
    await tester.tap(
      find.descendant(
        of: find.byType(ProfileTabBar),
        matching: find.text(tab.label),
      ),
    );
    await tester.pumpAndSettle();
  }

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
          user: base.user.copyWith(avatarUrl: 'https://example.com/avatar.png'),
          status: base.status,
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(
        (image.image as NetworkImage).url,
        'https://example.com/avatar.png',
      );
      // The bytes never arrive in a test, so the initials still hold the disc —
      // which is the point: it is never blank.
      expect(find.text('RT'), findsOneWidget);
    });

    testWidgets('tapping the avatar asks where the photo comes from', (
      tester,
    ) async {
      await pumpLoaded(tester);

      await tester.tap(find.byIcon(AppIcons.camera));
      await tester.pumpAndSettle();

      expect(find.text('Profile photo'), findsOneWidget);
      expect(find.text('Take a photo'), findsOneWidget);
      expect(find.text('Choose from gallery'), findsOneWidget);
    });

    testWidgets('a picked photo is uploaded and shown straight away', (
      tester,
    ) async {
      final picker = _FakeMediaPicker();
      final repository = _FakeImageRepository();

      await pumpLoaded(
        tester,
        overrides: [
          mediaPickerProvider.overrideWithValue(picker),
          profileImageRepositoryProvider.overrideWithValue(repository),
        ],
      );

      await tester.tap(find.byIcon(AppIcons.camera));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();

      expect(picker.requestedSource, ImagePickSource.gallery);
      expect(repository.uploadedPath, '/tmp/new-avatar.png');

      // The picked file goes up immediately, ahead of the profile re-read.
      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as FileImage).file.path, '/tmp/new-avatar.png');
      expect(find.text('Profile photo updated.'), findsOneWidget);
    });

    testWidgets('a failed upload says so and keeps the old photo', (
      tester,
    ) async {
      await pumpLoaded(
        tester,
        overrides: [
          mediaPickerProvider.overrideWithValue(_FakeMediaPicker()),
          profileImageRepositoryProvider.overrideWithValue(
            _FakeImageRepository(
              failure: const ApiException(
                message: 'Upload failed. Try again.',
                type: ApiExceptionType.server,
              ),
            ),
          ),
        ],
      );

      await tester.tap(find.byIcon(AppIcons.camera));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();

      expect(find.text('Upload failed. Try again.'), findsOneWidget);
      // Nothing was swapped in, so the initials still hold the disc.
      expect(find.byType(Image), findsNothing);
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
      await openTab(tester, ProfileTab.aboutYou);

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

      await openTab(tester, ProfileTab.experience);
      expect(find.text('Experience (1)'), findsOneWidget);
      expect(find.text('Computer Teacher with math'), findsOneWidget);
      expect(find.text('Arambagh Vivekananda Academy'), findsOneWidget);
      expect(find.text('Current'), findsOneWidget);

      await openTab(tester, ProfileTab.education);
      expect(find.text('Education (2)'), findsOneWidget);
      expect(find.text('btech'), findsOneWidget);
      expect(find.text('cse · Techno'), findsOneWidget);
      expect(find.text('Passed 2025'), findsOneWidget);
      expect(find.text('Highest'), findsOneWidget);

      await openTab(tester, ProfileTab.documents);
      expect(find.text('Documents (5)'), findsOneWidget);
    });

    testWidgets('only the selected section is on screen', (tester) async {
      await pumpLoaded(tester);

      // Basic Info opens first.
      expect(find.text('Basic Information'), findsOneWidget);
      expect(find.text('Short bio'), findsNothing);

      await openTab(tester, ProfileTab.aboutYou);
      expect(find.text('Short bio'), findsOneWidget);
      expect(find.text('Basic Information'), findsNothing);
    });

    testWidgets('the header and status stay put across tabs', (tester) async {
      await pumpLoaded(tester);
      await openTab(tester, ProfileTab.documents);

      // They sit above the strip, so they belong to the profile, not a tab.
      expect(find.text('Rahul Teacher'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
    });

    testWidgets('humanises document types the enum does not cover', (
      tester,
    ) async {
      await pumpLoaded(tester);
      await openTab(tester, ProfileTab.documents);

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

      expect(find.text('Pending review'), findsOneWidget);
      // Unanswered fields read as an em dash rather than vanishing.
      expect(find.text('—'), findsWidgets);

      await openTab(tester, ProfileTab.experience);
      expect(find.text('No experience added yet.'), findsOneWidget);

      await openTab(tester, ProfileTab.education);
      expect(find.text('No qualifications added yet.'), findsOneWidget);

      await openTab(tester, ProfileTab.documents);
      expect(find.text('No documents uploaded yet.'), findsOneWidget);
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
