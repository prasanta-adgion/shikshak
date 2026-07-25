import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/signup_otp_challenge.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../datasource/auth_remote_datasource.dart';
import '../mapper/user_mapper.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final SecureStorageService _storage;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorageService storage,
  }) : _remote = remoteDataSource,
       _storage = storage;

  @override
  Future<ApiResult<UserEntity>> login(LoginParams params) => _guard(() async {
    final response = await _remote.login(
      LoginRequestModel(
        identifier: params.identifier.trim(),
        password: params.password,
        role: params.role.name,
      ),
    );
    await _persistSession(response);
    return response.user.toEntity();
  });

  @override
  Future<ApiResult<SignupOtpChallenge>> register(RegisterParams params) =>
      _guard(() async {
        final response = await _remote.register(
          RegisterRequestModel(
            fullName: params.fullName.trim(),
            email: params.email.trim(),
            mobileNumber: params.mobileNumber.trim(),
            password: params.password,
            role: params.role.name,
          ),
        );
        // No _persistSession here on purpose: this endpoint returns no tokens.
        // The session is established after the OTP is verified.
        return response.toEntity();
      });

  @override
  Future<bool> hasValidSession() async {
    final token = await _storage.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<UserRole?> getPersistedRole() async =>
      UserRole.tryParse(await _storage.getRole());

  @override
  Future<void> logout() => _storage.clear();

  Future<void> _persistSession(AuthResponseModel response) => Future.wait([
    _storage.saveToken(response.accessToken),
    _storage.saveRefreshToken(response.refreshToken),
    _storage.saveRole(response.user.role),
  ]);

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
