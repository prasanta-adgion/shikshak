import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_snackbar.dart';
import '../../../otp_verification/presentation/pages/otp_verify_screen.dart';

/// Step 2 of signup: enter the code emailed by the request-OTP endpoint.
///
/// A thin adapter binding the flow-agnostic [OtpVerifyScreen] to the auth
/// notifier — the same shape `ForgotPasswordOtpScreen` uses for password
/// reset. Each flow owns its own wiring so the OTP widget stays reusable.
class SignupOtpScreen extends StatelessWidget {
  const SignupOtpScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return OtpVerifyScreen(
      destination: email,
      isLoading: false,
      // TODO(api): wire to AuthNotifier.verifySignupOtp once the
      // signup verify-OTP endpoint's request/response contract is known.
      // It should return the access/refresh tokens + user, at which point the
      // notifier calls _setAuthenticated and this screen routes to the
      // role dashboard.
      onVerified: (_) => AppSnackbar.show(
        context,
        'Signup OTP verification is not connected yet.',
      ),
      // TODO(api): needs the resend endpoint. Re-posting the full signup body
      // is not assumed here — the password is deliberately not retained.
      onResend: () =>
          AppSnackbar.show(context, 'Resending the code is not connected yet.'),
    );
  }
}
