import '../../../../core/network/api_result.dart';
import '../../domain/repositories/forgot_password_repository.dart';
import '../../domain/usecases/request_reset_otp_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../datasource/i_forgot_password_remote_datasource.dart';
import '../models/request_reset_otp_request_model.dart';
import '../models/reset_password_request_model.dart';

class ForgotPasswordRepositoryImpl implements ForgotPasswordRepository {
  const ForgotPasswordRepositoryImpl({
    required ForgotPasswordRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final ForgotPasswordRemoteDataSource _remote;

  @override
  Future<ApiResult<void>> requestResetOtp(RequestResetOtpParams params) =>
      ApiResult.guard(
        () => _remote.requestResetOtp(
          RequestResetOtpRequestModel(email: params.email.trim()),
        ),
      );

  @override
  Future<ApiResult<void>> resetPasswordWithVerifyOTP(
    ResetPasswordParams params,
  ) => ApiResult.guard(
    () => _remote.resetPassword(
      ResetPasswordRequestModel(
        email: params.email.trim(),
        otp: params.otp.trim(),
        newPassword: params.newPassword,
        confirmPassword: params.confirmPassword,
      ),
    ),
  );
}
