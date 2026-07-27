import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/i_api_client.dart';
import '../models/auth_session_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';
import '../models/resend_otp_request_model.dart';
import '../models/verify_signup_otp_request_model.dart';

/// Contract for the auth API.
abstract interface class AuthRemoteDataSource {
  Future<AuthSessionModel> login(LoginRequestModel request);

  Future<RegisterResponseModel> register(RegisterRequestModel request);

  Future<AuthSessionModel> verifySignupOtp(VerifySignupOtpRequestModel request);

  Future<void> resendSignupOtp(ResendOtpRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final IApiClient _client;
  const AuthRemoteDataSourceImpl(this._client);

  @override
  Future<AuthSessionModel> login(LoginRequestModel request) async {
    final json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: request.toJson(),
    );
    return _unwrap(
      json,
      (data) => AuthSessionModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    final json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: request.toJson(),
    );
    return _unwrap(
      json,
      (data) => RegisterResponseModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Verifying the signup OTP completes registration and returns a live
  /// session, so the user never has to log in straight after signing up.
  @override
  Future<AuthSessionModel> verifySignupOtp(
    VerifySignupOtpRequestModel request,
  ) async {
    final json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.otpVerify,
      data: request.toJson(),
    );
    return _unwrap(
      json,
      (data) => AuthSessionModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<void> resendSignupOtp(ResendOtpRequestModel request) async {
    final json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.resendOtp,
      data: request.toJson(),
    );
    _ensureSuccess(json);
  }

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

  /// Envelope check for endpoints whose payload carries nothing the app needs
  /// — resend only has to say whether the code went out. [_unwrap] would
  /// reject those as server errors the moment `data` came back null.
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
