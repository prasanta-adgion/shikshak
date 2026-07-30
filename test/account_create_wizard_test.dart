import 'package:Shikshak/core/constants/app_images_const.dart';
import 'package:Shikshak/core/theme/app_theme.dart';
import 'package:Shikshak/features/account_create/documents/presentation/notifier/document_list_notifier.dart';
import 'package:Shikshak/features/account_create/documents/presentation/providers/document_providers.dart';
import 'package:Shikshak/features/account_create/education/presentation/notifier/education_list_notifier.dart';
import 'package:Shikshak/features/account_create/education/presentation/providers/education_providers.dart';
import 'package:Shikshak/features/account_create/experience/presentation/notifier/experience_list_notifier.dart';
import 'package:Shikshak/features/account_create/experience/presentation/providers/experience_providers.dart';
import 'package:Shikshak/features/account_create/shared/domain/entities/profile_step.dart';
import 'package:Shikshak/features/account_create/shared/presentation/notifier/account_create_notifier.dart';
import 'package:Shikshak/features/account_create/shared/presentation/pages/create_teacher_account_page.dart';
import 'package:Shikshak/features/account_create/shared/presentation/providers/account_create_providers.dart';
import 'package:Shikshak/features/account_create/shared/presentation/state/account_create_state.dart';
import 'package:Shikshak/features/account_create/shared/presentation/widgets/step_timeline.dart';
import 'package:Shikshak/features/account_create/shared/presentation/widgets/wizard_step_header.dart';
import 'package:Shikshak/features/account_create/shared/presentation/widgets/wizard_step_layout.dart';
import 'package:Shikshak/features/account_create/shared/presentation/widgets/wizard_action_bar.dart';
import 'package:Shikshak/features/auth/domain/entities/user_entity.dart';
import 'package:Shikshak/features/auth/domain/entities/user_role.dart';
import 'package:Shikshak/features/auth/presentation/notifier/auth_notifier.dart';
import 'package:Shikshak/features/auth/presentation/providers_di/auth_providers.dart';
import 'package:Shikshak/features/auth/presentation/state/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timelines_plus/timelines_plus.dart';

/// Windows the wizard must render cleanly in — mirrors the set used by
/// `responsive_screens_test.dart`.
const _windows = <String, Size>{
  'phone portrait': Size(390, 844),
  'phone landscape': Size(844, 390),
  'small phone': Size(320, 640),
  'tablet portrait': Size(800, 1280),
  'tablet landscape': Size(1280, 800),
};

/// Opens the wizard already parked on [step], so every step can be rendered
/// without walking (and validating) the ones before it.
class _NotifierAtStep extends AccountCreateNotifier {
  _NotifierAtStep(this.step);

  final ProfileStep step;

  @override
  AccountCreateState build() => AccountCreateState(step: step);
}

/// Keeps the wizard offline: steps 3 and 4 read their saved rows back from the
/// API as soon as they mount, and these tests only care about what they render.
class _OfflineExperienceList extends ExperienceListNotifier {
  @override
  Future<void> load() async {}
}

class _OfflineEducationList extends EducationListNotifier {
  @override
  Future<void> load() async {}
}

class _OfflineDocumentList extends DocumentListNotifier {
  @override
  Future<void> load() async {}
}

/// The account as it stands after signup — what step 1 shows beside the
/// avatar.
class _SeededAuthNotifier extends AuthNotifier {
  static const UserEntity user = UserEntity(
    id: '1',
    fullName: 'Priya Sharma',
    email: 'priya.sharma@gmail.com',
    mobileNumber: '9876543210',
    role: UserRole.teacher,
  );

  @override
  AuthState build() =>
      const AuthState(status: AuthStatus.authenticated, user: user);
}

void main() {
  Future<void> setWindow(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpWizard(
    WidgetTester tester,
    ProfileStep step, {
    ThemeData? theme,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountCreateNotifierProvider.overrideWith(
            () => _NotifierAtStep(step),
          ),
          authStateNotifierProvider.overrideWith(_SeededAuthNotifier.new),
          experienceListNotifierProvider.overrideWith(
            _OfflineExperienceList.new,
          ),
          educationListNotifierProvider.overrideWith(_OfflineEducationList.new),
          documentListNotifierProvider.overrideWith(_OfflineDocumentList.new),
        ],
        child: MaterialApp(
          theme: theme ?? AppTheme.light,
          home: const CreateTeacherAccountPage(),
        ),
      ),
    );
    await tester.pump();
  }

  group('renders without overflow', () {
    for (final step in ProfileStep.values) {
      for (final MapEntry(key: windowName, value: size) in _windows.entries) {
        testWidgets('${step.name} on $windowName', (tester) async {
          await setWindow(tester, size);
          await pumpWizard(tester, step);

          // A RenderFlex overflow (or any layout assertion) surfaces here.
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('dark theme', () {
    for (final step in ProfileStep.values) {
      testWidgets('${step.name} renders in dark mode', (tester) async {
        await setWindow(tester, const Size(390, 844));
        await pumpWizard(tester, step, theme: AppTheme.dark);

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('step chrome', () {
    testWidgets('timeline labels every step and heads the current one', (
      tester,
    ) async {
      await setWindow(tester, const Size(390, 844));
      await pumpWizard(tester, ProfileStep.experience);

      for (final step in ProfileStep.values) {
        expect(find.text(step.shortLabel), findsOneWidget);
      }
      expect(find.text('Teaching Experience'), findsOneWidget);
    });

    testWidgets('renders no app bar', (tester) async {
      await setWindow(tester, const Size(390, 844));
      await pumpWizard(tester, ProfileStep.basicInfo);

      expect(find.byType(AppBar), findsNothing);
    });

    // One pump per test: pumping twice reuses the overridden notifier, so the
    // second step would never actually mount.
    testWidgets('first step hides the Back button', (tester) async {
      await setWindow(tester, const Size(390, 844));
      await pumpWizard(tester, ProfileStep.basicInfo);

      expect(find.widgetWithText(OutlinedButton, 'Back'), findsNothing);
    });

    testWidgets('later steps show the Back button', (tester) async {
      await setWindow(tester, const Size(390, 844));
      await pumpWizard(tester, ProfileStep.aboutYou);

      expect(find.widgetWithText(OutlinedButton, 'Back'), findsOneWidget);
    });

    testWidgets('the last step finishes rather than continuing', (
      tester,
    ) async {
      await setWindow(tester, const Size(390, 844));
      await pumpWizard(tester, ProfileStep.documents);

      expect(find.widgetWithText(FilledButton, 'Finish'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Continue'), findsNothing);
    });
  });

  group('step header', () {
    for (final step in ProfileStep.values) {
      testWidgets('${step.name} pairs its own copy with the shared art', (
        tester,
      ) async {
        await setWindow(tester, const Size(390, 844));
        await pumpWizard(tester, step);

        // Scoped to the header: a step's title can legitimately repeat as a
        // timeline label ("About You") or a field name ("Upload Document").
        final inHeader = find.descendant(
          of: find.byType(WizardStepHeader),
          matching: find.text(step.title),
        );
        expect(inHeader, findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(WizardStepHeader),
            matching: find.text(step.subtitle),
          ),
          findsOneWidget,
        );

        final image = tester.widget<Image>(
          find.descendant(
            of: find.byType(WizardStepHeader),
            matching: find.byType(Image),
          ),
        );
        // cacheWidth wraps the AssetImage in a ResizeImage.
        final resized = image.image as ResizeImage;
        expect(
          (resized.imageProvider as AssetImage).assetName,
          AppImagesConst.accountCreateForm,
        );
      });
    }
  });

  group('profile identity', () {
    testWidgets('shows the account details left of the avatar', (tester) async {
      await setWindow(tester, const Size(390, 844));
      await pumpWizard(tester, ProfileStep.basicInfo);

      // Comes from the signed-in account, not from constants in the step.
      expect(find.text(_SeededAuthNotifier.user.fullName), findsOneWidget);
      expect(find.text(_SeededAuthNotifier.user.email), findsOneWidget);
      expect(find.text(_SeededAuthNotifier.user.mobileNumber!), findsOneWidget);

      // The camera badge stands in for the avatar's position.
      final nameX = tester.getCenter(find.text('Priya Sharma')).dx;
      final avatarX = tester
          .getCenter(find.byIcon(Icons.photo_camera_rounded))
          .dx;
      expect(avatarX, greaterThan(nameX));
    });
  });

  group('step container', () {
    testWidgets('holds the header and every field in one surface', (
      tester,
    ) async {
      await setWindow(tester, const Size(390, 844));
      await pumpWizard(tester, ProfileStep.basicInfo);

      final container = find.byType(WizardStepLayout);
      expect(container, findsOneWidget);

      // Header and fields are all inside that single panel — not separate
      // cards stacked down the page.
      expect(
        find.descendant(of: container, matching: find.byType(WizardStepHeader)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: container,
          matching: find.text('Select your gender'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: container, matching: find.text('Postal Code')),
        findsOneWidget,
      );
    });
  });

  group('timeline', () {
    testWidgets('centres the step number inside its dot', (tester) async {
      await setWindow(tester, const Size(390, 844));
      await pumpWizard(tester, ProfileStep.experience);

      // Step 3 is current, so its dot carries the number.
      final number = find.text('3');
      final dot = find.ancestor(
        of: number,
        matching: find.byType(DotIndicator),
      );

      expect(dot, findsOneWidget);

      // DotIndicator hands its child the circle's tight constraints and no
      // alignment. Stretched to 26x26 the glyph paints at the top edge, and
      // the box centre still matches the dot's — so size is what proves a
      // Center is doing the work.
      final numberSize = tester.getSize(number);
      final dotSize = tester.getSize(dot);
      expect(numberSize.height, lessThan(dotSize.height));
      expect(numberSize.width, lessThan(dotSize.width));
      expect(
        tester.getCenter(number),
        offsetMoreOrLessEquals(tester.getCenter(dot), epsilon: 0.5),
      );
    });

    testWidgets('stays pinned while the form scrolls', (tester) async {
      await setWindow(tester, const Size(390, 700));
      await pumpWizard(tester, ProfileStep.basicInfo);

      final before = tester.getTopLeft(find.byType(StepTimeline));
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -260),
      );
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(find.byType(StepTimeline)), equals(before));
    });
  });

  group('action bar', () {
    bool isVisible(WidgetTester tester) =>
        tester.widget<WizardActionBar>(find.byType(WizardActionBar)).isVisible;

    testWidgets('hides on scroll down and returns on scroll up', (
      tester,
    ) async {
      await setWindow(tester, const Size(390, 700));
      await pumpWizard(tester, ProfileStep.basicInfo);

      expect(isVisible(tester), isTrue);

      final scrollable = find.byType(SingleChildScrollView).first;
      await tester.drag(scrollable, const Offset(0, -260));
      await tester.pumpAndSettle();
      expect(isVisible(tester), isFalse);

      await tester.drag(scrollable, const Offset(0, 160));
      await tester.pumpAndSettle();
      expect(isVisible(tester), isTrue);
    });
  });

  group('date entry', () {
    testWidgets('opens the shared app date picker', (tester) async {
      await setWindow(tester, const Size(390, 844));
      await pumpWizard(tester, ProfileStep.basicInfo);

      await tester.tap(find.text('Select your date of birth'));
      await tester.pumpAndSettle();

      // Proves DateTimeUtils.showAppDatePicker builds: its blurred, scaled
      // frame and themed overrides all run before the dialog appears.
      expect(find.byType(DatePickerDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('about you', () {
    testWidgets('tapping a subject marks it selected', (tester) async {
      await setWindow(tester, const Size(390, 844));
      await pumpWizard(tester, ProfileStep.aboutYou);

      expect(find.text('You can select multiple subjects'), findsOneWidget);

      // The grid sits below the three prose cards, so it has to be scrolled
      // into reach before it can be tapped.
      await tester.ensureVisible(find.text('Mathematics'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mathematics'));
      await tester.pump();

      expect(find.text('1 selected'), findsOneWidget);
    });

    testWidgets('prose fields carry a character counter', (tester) async {
      await setWindow(tester, const Size(390, 844));
      await pumpWizard(tester, ProfileStep.aboutYou);

      // Short Bio, Teaching Approach and What Makes You Unique.
      expect(find.text('0/500'), findsNWidgets(3));
    });
  });

  group('experience', () {
    testWidgets('asks for the position, not the subjects again', (
      tester,
    ) async {
      await setWindow(tester, const Size(390, 844));
      await pumpWizard(tester, ProfileStep.experience);

      expect(find.text('Job Title'), findsOneWidget);
      expect(find.text('Institution'), findsOneWidget);

      // About You already captured these; they ride along with the payload.
      expect(find.text('Subjects Taught'), findsNothing);
      expect(find.text('Classes Taught'), findsNothing);
    });
  });
}
