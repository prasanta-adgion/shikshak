import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/request_reset_otp_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../providers/forgot_password_providers.dart';
import '../state/forgot_password_state.dart';

class ForgotPasswordNotifier extends Notifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  Future<bool> requestOtp(String email) async {
    final trimmed = email.trim();
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      email: trimmed,
    );

    final result = await ref
        .read(requestResetOtpUseCaseProvider)
        .call(RequestResetOtpParams(email: trimmed));

    return result.fold(
      onSuccess: (_) {
        state = state.copyWith(
          isSubmitting: false,
          stage: PasswordResetStage.resetPassword,
        );
        return true;
      },
      onFailure: (exception) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: exception.message,
        );
        return false;
      },
    );
  }

  /// Re-sends the code to the address captured in step 1.
  Future<bool> resendOtp() async {
    final email = state.email;
    if (email == null || email.isEmpty) return false;
    return requestOtp(email);
  }

  /// Step 2 — verify the OTP and set the new password in a single request.
  Future<void> resetPassword({
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final email = state.email;
    if (email == null || email.isEmpty) return;

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final result = await ref
        .read(resetPasswordUseCaseProvider)
        .call(
          ResetPasswordParams(
            email: email,
            otp: otp,
            newPassword: newPassword,
            confirmPassword: confirmPassword,
          ),
        );

    result.fold(
      onSuccess: (_) => state = state.copyWith(
        isSubmitting: false,
        stage: PasswordResetStage.completed,
      ),
      onFailure: (exception) => state = state.copyWith(
        isSubmitting: false,
        errorMessage: exception.message,
      ),
    );
  }

  /// Clears the flow, e.g. when the user backs out and starts again.
  void reset() => state = const ForgotPasswordState();
}
