import 'dart:developer' as developer;

import '../../../../core/flavor/app_flavor.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/params/auth_params.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import '../models/auth_session_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/resend_otp_request_model.dart';
import '../models/verify_signup_otp_request_model.dart';

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
      ),
    );
    developer.log(response.refreshToken);
    await _persistSession(response);
    return response.user.toEntity();
  });

  @override
  Future<ApiResult<void>> register(RegisterParams params) => _guard(() async {
    await _remote.register(
      RegisterRequestModel(
        fullName: params.fullName.trim(),
        email: params.email.trim(),
        mobileNumber: params.mobileNumber.trim(),
        password: params.password,
        role: params.role.name,
      ),
    );
  });

  @override
  Future<ApiResult<UserEntity>> verifySignupOtp(VerifySignupOtpParams params) =>
      _guard(() async {
        final response = await _remote.verifySignupOtp(
          VerifySignupOtpRequestModel(
            email: params.email.trim(),
            otp: params.otp.trim(),
          ),
        );
        await _persistSession(response);
        return response.user.toEntity();
      });

  @override
  Future<ApiResult<void>> resendSignupOtp(ResendOtpParams params) =>
      _guard(() async {
        await _remote.resendSignupOtp(
          ResendOtpRequestModel(inputEmailOrPhone: params.identifier.trim()),
        );
      });

  @override
  Future<UserRole?> sessionRole() async {
    final token = await _storage.getToken();
    _logRestoredToken(token);
    if (token == null || token.isEmpty) return null;
    return UserRole.tryParse(await _storage.getRole());
  }

  /// Prints the token the splash screen just restored from secure storage, so
  /// it can be copied straight into an API client. Dev and staging only.
  void _logRestoredToken(String? token) {
    if (!AppFlavorConfig.logRestoredToken) return;

    developer.log(
      token == null || token.isEmpty
          ? 'No stored session token — heading to login.'
          : 'Restored session token:\n$token',
      name: 'auth',
    );
  }

  @override
  Future<void> logout() => _storage.clear();

  Future<void> _persistSession(AuthSessionModel response) => Future.wait([
    _storage.saveToken(response.token),
    _storage.saveRefreshToken(response.refreshToken),
    _storage.saveRole(response.user.role),
  ]);

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
