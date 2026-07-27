import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_snackbar.dart';
import '../../../otp_verification/presentation/pages/otp_verify_screen.dart';

class SignupOtpScreen extends StatelessWidget {
  const SignupOtpScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return OtpVerifyScreen(
      destination: email,
      isLoading: false,
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
