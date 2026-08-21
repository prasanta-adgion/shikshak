import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/i_api_client.dart';
import '../models/request_reset_otp_request_model.dart';
import '../models/reset_password_request_model.dart';
import 'i_forgot_password_remote_datasource.dart';

class ForgotPasswordRemoteDataSourceImpl
    implements ForgotPasswordRemoteDataSource {
  const ForgotPasswordRemoteDataSourceImpl(this._client);

  final IApiClient _client;

  @override
  Future<void> requestResetOtp(RequestResetOtpRequestModel request) async {
    final json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.sendPasswordResetOtp,
      data: request.toJson(),
    );
    _ensureSuccess(json);
  }

  @override
  Future<void> resetPassword(ResetPasswordRequestModel request) async {
    final json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.verifyPasswordResetOtpAndSetNewPassword,
      data: request.toJson(),
    );
    _ensureSuccess(json);
  }

  /// Neither call returns a payload — only whether the server accepted it.
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
