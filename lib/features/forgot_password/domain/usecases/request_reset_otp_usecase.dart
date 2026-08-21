import '../../../../core/network/api_result.dart';
import '../repositories/forgot_password_repository.dart';

/// Input for [RequestResetOtpUseCase].
class RequestResetOtpParams {
  const RequestResetOtpParams({required this.email});

  final String email;
}

/// Step 1 of the reset flow: send a one-time code to the registered email.
class RequestResetOtpUseCase {
  final ForgotPasswordRepository _repository;
  const RequestResetOtpUseCase(this._repository);

  Future<ApiResult<void>> call(RequestResetOtpParams params) =>
      _repository.requestResetOtp(params);
}
