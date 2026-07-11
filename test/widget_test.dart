import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiksha/core/theme/app_theme.dart';
import 'package:shiksha/core/utils/validators.dart';
import 'package:shiksha/shared/widgets/app_loading_button.dart';

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
    testWidgets('shows label when idle and spinner when loading',
        (tester) async {
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
}
