import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/i_api_client.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/user_model.dart';

/// Contract for the auth API.
abstract interface class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);

  Future<AuthResponseModel> register(RegisterRequestModel request);

  Future<UserModel> fetchProfile();
}

/// Real implementation that talks to the Shikshak backend through
/// [IApiClient].
///
/// The endpoints are placeholders — this class is fully wired and becomes
/// live the moment [ApiEndpoints.baseUrl] points at a real server. Until
/// then the app runs on [MockAuthRemoteDataSource] (see
/// `mock_auth_remote_datasource.dart` and the provider wiring).
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._client);

  final IApiClient _client;

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    final json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: request.toJson(),
    );
    return _unwrap(
      json,
      (data) => AuthResponseModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    final json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: request.toJson(),
    );
    return _unwrap(
      json,
      (data) => AuthResponseModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<UserModel> fetchProfile() async {
    final json = await _client.get<Map<String, dynamic>>(ApiEndpoints.profile);
    return _unwrap(
      json,
      (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Decodes the standard `{success, message, data}` envelope and fails
  /// loudly when the payload is malformed.
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
}
