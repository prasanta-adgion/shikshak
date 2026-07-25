import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/password_reset_ticket.dart';
import '../../domain/repositories/forgot_password_repository.dart';
import '../../domain/usecases/request_reset_otp_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/verify_reset_otp_usecase.dart';
import '../datasource/forgot_password_remote_datasource.dart';
import '../models/request_reset_otp_request_model.dart';
import '../models/reset_password_request_model.dart';
import '../models/verify_reset_otp_request_model.dart';

/// Concrete [ForgotPasswordRepository]: drives the remote data source and
/// converts thrown [ApiException]s into [ApiResult] failures.
///
/// No secure storage here — a password reset establishes no session.
class ForgotPasswordRepositoryImpl implements ForgotPasswordRepository {
  const ForgotPasswordRepositoryImpl({
    required ForgotPasswordRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final ForgotPasswordRemoteDataSource _remote;

  @override
  Future<ApiResult<void>> requestResetOtp(RequestResetOtpParams params) =>
      _guard(
        () => _remote.requestResetOtp(
          RequestResetOtpRequestModel(email: params.email.trim()),
        ),
      );

  @override
  Future<ApiResult<PasswordResetTicket>> verifyResetOtp(
    VerifyResetOtpParams params,
  ) => _guard(() async {
    final response = await _remote.verifyResetOtp(
      VerifyResetOtpRequestModel(
        email: params.email.trim(),
        otp: params.otp.trim(),
      ),
    );
    return response.toEntity();
  });

  @override
  Future<ApiResult<void>> resetPassword(ResetPasswordParams params) => _guard(
    () => _remote.resetPassword(
      ResetPasswordRequestModel(
        email: params.email.trim(),
        newPassword: params.newPassword,
        resetToken: params.resetToken,
      ),
    ),
  );

  /// Runs [action], normalising every failure into an [ApiResult.failure].
  Future<ApiResult<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return ApiResult.success(await action());
    } on ApiException catch (exception) {
      return ApiResult.failure(exception);
    } catch (error) {
      return ApiResult.failure(ApiException.unexpected(error));
    }
  }
}
