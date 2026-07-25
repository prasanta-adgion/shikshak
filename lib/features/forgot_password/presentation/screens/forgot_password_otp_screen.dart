import 'package:Shikshak/app/router/route_paths.dart';
import 'package:Shikshak/features/forgot_password/presentation/providers/forgot_password_providers.dart';
import 'package:Shikshak/features/forgot_password/presentation/state/forgot_password_state.dart';
import 'package:Shikshak/features/otp_verification/presentation/pages/otp_verify_screen.dart';
import 'package:Shikshak/shared/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Step 2 of the reset flow.
///
/// A thin adapter, nothing more: it binds the flow-agnostic [OtpVerifyScreen]
/// to this feature's notifier. Keeping the wiring here — in the *consuming*
/// feature — is what lets the OTP screen stay generic enough for signup
/// verification to add its own equivalent adapter later.
class ForgotPasswordOtpScreen extends ConsumerWidget {
  const ForgotPasswordOtpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forgotPasswordNotifierProvider);
    final notifier = ref.read(forgotPasswordNotifierProvider.notifier);

    // Move on once the code is accepted.
    ref.listen(forgotPasswordNotifierProvider.select((s) => s.stage), (
      previous,
      next,
    ) {
      if (next == PasswordResetStage.setPassword && previous != next) {
        context.push(RoutePaths.newPasswordSet);
      }
    });

    ref.listen(forgotPasswordNotifierProvider.select((s) => s.errorMessage), (
      previous,
      next,
    ) {
      if (next != null && next != previous) {
        AppSnackbar.showError(context, next);
      }
    });

    return OtpVerifyScreen(
      destination: state.email ?? 'your email',
      isLoading: state.isSubmitting,
      onVerified: notifier.verifyOtp,
      onResend: notifier.resendOtp,
    );
  }
}
