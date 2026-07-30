import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../otp_verification/presentation/pages/otp_verify_screen.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/params/auth_params.dart';
import '../providers_di/auth_providers.dart';

/// Signup OTP entry. Verification completes registration and opens a session.
///
/// Students land on their dashboard; teachers first walk the profile wizard,
/// which is what their account is judged on.
class SignupOtpScreen extends ConsumerWidget {
  const SignupOtpScreen({super.key, required this.email});

  final String email;

  Future<void> _verify(BuildContext context, WidgetRef ref, String otp) async {
    final user = await ref
        .read(signupOtpNotifierProvider.notifier)
        .verify(VerifySignupOtpParams(email: email, otp: otp));

    if (user == null || !context.mounted) return;

    context.go(
      user.role == UserRole.teacher
          ? RoutePaths.createAccountScreenPath
          : RoutePaths.dashboardFor(user.role),
    );
  }

  Future<void> _resend(BuildContext context, WidgetRef ref) async {
    final sent = await ref
        .read(signupOtpNotifierProvider.notifier)
        .resend(ResendOtpParams(identifier: email));

    if (sent && context.mounted) {
      AppSnackbar.show(context, 'A new code has been sent to $email.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Verify and resend share one flag: whichever is in flight, the screen is
    // busy and neither action should be tappable.
    final isBusy = ref.watch(
      signupOtpNotifierProvider.select((state) => state.isLoading),
    );

    // The repository funnels every failure through ApiException, so the
    // message is always presentable.
    ref.listen(signupOtpNotifierProvider, (previous, next) {
      if (next case AsyncError(error: final ApiException error)) {
        AppSnackbar.showError(context, error.message);
      }
    });

    return OtpVerifyScreen(
      destination: email,
      isLoading: isBusy,
      onVerified: (otp) => _verify(context, ref, otp),
      onResend: () => _resend(context, ref),
    );
  }
}
