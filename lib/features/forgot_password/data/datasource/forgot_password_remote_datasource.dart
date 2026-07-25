import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/i_api_client.dart';
import '../models/request_reset_otp_request_model.dart';
import '../models/reset_password_request_model.dart';
import '../models/verify_reset_otp_request_model.dart';
import '../models/verify_reset_otp_response_model.dart';

/// Contract for the password-reset API.
abstract interface class ForgotPasswordRemoteDataSource {
  Future<void> requestResetOtp(RequestResetOtpRequestModel request);

  Future<VerifyResetOtpResponseModel> verifyResetOtp(
    VerifyResetOtpRequestModel request,
  );

  Future<void> resetPassword(ResetPasswordRequestModel request);
}

/// Talks to the Shikshak backend through [IApiClient].
///
/// The host comes from the active flavor (`AppFlavor.baseUrl`), injected via
/// `apiClientProvider`.
class ForgotPasswordRemoteDataSourceImpl
    implements ForgotPasswordRemoteDataSource {
  const ForgotPasswordRemoteDataSourceImpl(this._client);

  final IApiClient _client;

  @override
  Future<void> requestResetOtp(RequestResetOtpRequestModel request) async {
    final json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.requestPasswordResetOtp,
      data: request.toJson(),
    );
    _ensureSuccess(json);
  }

  @override
  Future<VerifyResetOtpResponseModel> verifyResetOtp(
    VerifyResetOtpRequestModel request,
  ) async {
    final json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.verifyPasswordResetOtp,
      data: request.toJson(),
    );
    return _unwrap(
      json,
      (data) =>
          VerifyResetOtpResponseModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<void> resetPassword(ResetPasswordRequestModel request) async {
    final json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.resetPassword,
      data: request.toJson(),
    );
    _ensureSuccess(json);
  }

  /// Decodes the `{success, message, data}` envelope for endpoints that return
  /// a payload, failing loudly when it is missing or malformed.
  T _unwrap<T>(Map<String, dynamic> json, T Function(Object? data) decode) {
    final response = ApiResponse<T>.fromJson(json, decode);
    final data = response.data;
    if (!response.success || data == null) {
      throw ApiException(
        message: response.message,
        type: ApiExceptionType.server,
      );
    }
    return data;
  }

  /// Envelope check for endpoints that legitimately return a null `data`
  /// (request-OTP and reset both reply `{success, message}` only).
  ///
  /// Reusing [_unwrap] here would treat every successful call as a server
  /// error, because it rejects a null payload.
  void _ensureSuccess(Map<String, dynamic> json) {
    final response = ApiResponse<void>.fromJson(json, (_) {});
    if (!response.success) {
      throw ApiException(
        message: response.message,
        type: ApiExceptionType.server,
      );
    }
  }
}
