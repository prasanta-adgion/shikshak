import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/request_reset_otp_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/verify_reset_otp_usecase.dart';
import '../providers/forgot_password_providers.dart';
import '../state/forgot_password_state.dart';

/// Owns the three-step password-reset flow.
///
/// Screens only call methods here and render [ForgotPasswordState]. Navigation
/// stays out of this class entirely: screens watch [ForgotPasswordState.stage]
/// and drive GoRouter themselves — the same rule `AuthNotifier` follows.
///
/// Note the use-case providers are read lazily inside the methods, never in
/// [build]. Reading them eagerly would construct `apiClientProvider` → the Dio
/// client on the very first pump of any reset screen, which throws when the
/// active flavor has no base URL and would break widget tests that merely
/// render these pages.
class ForgotPasswordNotifier extends Notifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  /// Step 1 — email the OTP, then advance to [PasswordResetStage.verifyOtp].
  Future<void> requestOtp(String email) async {
    final trimmed = email.trim();
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      email: trimmed,
    );

    final result = await ref
        .read(requestResetOtpUseCaseProvider)
        .call(RequestResetOtpParams(email: trimmed));

    result.fold(
      onSuccess: (_) => state = state.copyWith(
        isSubmitting: false,
        stage: PasswordResetStage.verifyOtp,
      ),
      onFailure: (exception) => state = state.copyWith(
        isSubmitting: false,
        errorMessage: exception.message,
      ),
    );
  }

  /// Re-sends the code to the address captured in step 1.
  Future<void> resendOtp() async {
    final email = state.email;
    if (email == null || email.isEmpty) return;
    await requestOtp(email);
  }

  /// Step 2 — exchange the OTP for a reset ticket.
  Future<void> verifyOtp(String otp) async {
    final email = state.email;
    if (email == null || email.isEmpty) return;

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final result = await ref
        .read(verifyResetOtpUseCaseProvider)
        .call(VerifyResetOtpParams(email: email, otp: otp));

    result.fold(
      onSuccess: (ticket) => state = state.copyWith(
        isSubmitting: false,
        resetToken: ticket.resetToken,
        stage: PasswordResetStage.setPassword,
      ),
      onFailure: (exception) => state = state.copyWith(
        isSubmitting: false,
        errorMessage: exception.message,
      ),
    );
  }

  /// Step 3 — set the new password and finish the flow.
  Future<void> submitNewPassword(String newPassword) async {
    final email = state.email;
    if (email == null || email.isEmpty) return;

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final result = await ref
        .read(resetPasswordUseCaseProvider)
        .call(
          ResetPasswordParams(
            email: email,
            newPassword: newPassword,
            resetToken: state.resetToken,
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
