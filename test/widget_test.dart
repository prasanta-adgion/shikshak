import 'package:Shikshak/core/theme/app_theme.dart';
import 'package:Shikshak/core/utils/validators.dart';
import 'package:Shikshak/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:Shikshak/shared/widgets/adaptive_navigation_scaffold.dart';
import 'package:Shikshak/shared/widgets/app_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    test('email accepts valid and rejects invalid addresses', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });

    test('mobileNumber requires a valid 10-digit Indian number', () {
      expect(Validators.mobileNumber('9876543210'), isNull);
      expect(Validators.mobileNumber('1234567890'), isNotNull);
      expect(Validators.mobileNumber('98765'), isNotNull);
    });

    test('emailOrMobile accepts either format', () {
      expect(Validators.emailOrMobile('user@example.com'), isNull);
      expect(Validators.emailOrMobile('9876543210'), isNull);
      expect(Validators.emailOrMobile('nope'), isNotNull);
    });

    test('password enforces length and composition', () {
      expect(Validators.password('secure1x'), isNull);
      expect(Validators.password('short1'), isNotNull);
      expect(Validators.password('onlyletters'), isNotNull);
      expect(Validators.password('12345678'), isNotNull);
    });

    test('confirmPassword must match the original', () {
      expect(Validators.confirmPassword('abc12345', 'abc12345'), isNull);
      expect(Validators.confirmPassword('abc12345', 'different'), isNotNull);
    });
  });

  group('AppLoadingButton', () {
    testWidgets('shows label when idle and spinner when loading', (
      tester,
    ) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppLoadingButton(
              label: 'Login',
              isLoading: false,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Login'), findsOneWidget);
      await tester.tap(find.byType(FilledButton));
      expect(pressed, isTrue);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppLoadingButton(label: 'Login', isLoading: true),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('Responsive layouts', () {
    const destinations = [
      AdaptiveNavigationDestination(icon: Icons.home, label: 'Home'),
      AdaptiveNavigationDestination(icon: Icons.person, label: 'Profile'),
    ];

    // Drive `tester.view` (not `setSurfaceSize`) so `MediaQuery.sizeOf` — which
    // `context.isTabletDevice` reads — reflects the intended window. Device
    // class keys off the shortest side, so height matters: a wide-but-short
    // window (landscape phone) must stay a phone.
    Future<void> setSize(
      WidgetTester tester,
      double width, {
      double height = 900,
    }) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = Size(width, height);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    // (width, height) windows that should resolve to phone chrome — including a
    // landscape phone (wide but short), which must NOT flip to tablet.
    const phoneWindows = [
      (390.0, 844.0),
      (719.0, 900.0),
      (900.0, 400.0),
    ];

    for (final (width, height) in phoneWindows) {
      testWidgets(
        'uses phone navigation at ${width.toInt()}x${height.toInt()}',
        (tester) async {
          await setSize(tester, width, height: height);
          await tester.pumpWidget(
            MaterialApp(
              home: AdaptiveNavigationScaffold(
                selectedIndex: 0,
                onDestinationSelected: (_) {},
                destinations: destinations,
                body: const Text('Content'),
              ),
            ),
          );

          expect(
            find.byKey(const Key('phone-bottom-navigation')),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('tablet-navigation-rail')),
            findsNothing,
          );
        },
      );
    }

    for (final width in [720.0, 800.0, 1100.0]) {
      testWidgets('uses tablet navigation at ${width.toInt()}px', (
        tester,
      ) async {
        await setSize(tester, width);
        await tester.pumpWidget(
          MaterialApp(
            home: AdaptiveNavigationScaffold(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              destinations: destinations,
              body: const Text('Content'),
            ),
          ),
        );

        expect(find.byKey(const Key('tablet-navigation-rail')), findsOneWidget);
        expect(find.byKey(const Key('phone-bottom-navigation')), findsNothing);
      });
    }

    testWidgets('auth switches from stacked to split by device class', (
      tester,
    ) async {
      Widget authApp() => const MaterialApp(
        home: AuthScaffold(
          title: 'Sign in',
          subtitle: 'Continue learning',
          banner: ColoredBox(color: Colors.blue, child: Text('Hero')),
          form: Text('Form'),
        ),
      );

      await setSize(tester, 719);
      await tester.pumpWidget(authApp());
      expect(find.byKey(const Key('auth-phone-layout')), findsOneWidget);
      expect(find.byKey(const Key('auth-tablet-layout')), findsNothing);

      await setSize(tester, 720);
      await tester.pumpWidget(authApp());
      await tester.pump();
      expect(find.byKey(const Key('auth-tablet-layout')), findsOneWidget);
      expect(find.byKey(const Key('auth-phone-layout')), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tablet auth lays out a form containing a LayoutBuilder', (
      tester,
    ) async {
      // Regression: the OTP screen (and pinput) put a LayoutBuilder inside the
      // form. The tablet two-pane must not wrap it in IntrinsicHeight, which
      // throws "LayoutBuilder does not support returning intrinsic dimensions".
      await setSize(tester, 900);
      await tester.pumpWidget(
        MaterialApp(
          home: AuthScaffold(
            title: 'Verify',
            subtitle: 'Enter the code',
            banner: const ColoredBox(color: Colors.blue, child: Text('Hero')),
            form: LayoutBuilder(
              builder: (context, constraints) =>
                  SizedBox(width: constraints.maxWidth, child: const Text('OTP')),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('auth-tablet-layout')), findsOneWidget);
      expect(find.text('OTP'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
