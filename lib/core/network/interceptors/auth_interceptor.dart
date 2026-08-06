import 'package:dio/dio.dart';

import '../../constants/api_endpoints.dart';
import '../../storage/secure_storage_service.dart';
import '../token_refresher.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(
    this._storage, {
    required Dio dio,
    required TokenRefresher refresher,
  }) : _dio = dio,
       _refresher = refresher;

  final SecureStorageService _storage;
  final Dio _dio;
  final TokenRefresher _refresher;

  static const _publicEndpoints = {
    ApiEndpoints.login,
    ApiEndpoints.register,
    ApiEndpoints.otpVerify,
    ApiEndpoints.resendOtp,
    ApiEndpoints.refreshTokenGenerate,
    ApiEndpoints.requestPasswordResetOtp,
    ApiEndpoints.verifyPasswordResetOtp,
    ApiEndpoints.resetPassword,
  };

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isPublic(options.path)) return handler.next(options);

    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_isRefreshable(err)) return handler.next(err);

    final token = await _refresher.refresh();
    if (token == null || token.isEmpty) return handler.next(err);

    final options = err.requestOptions
      ..headers['Authorization'] = 'Bearer $token';

    try {
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (error) {
      handler.next(error);
    } catch (error, stackTrace) {
      // Anything else escaping here would leave the original request hanging
      // forever, which is worse than the failure itself.
      handler.next(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  bool _isRefreshable(DioException err) => err.response?.statusCode == 401;

  /// Endpoints are written both with and without a leading slash, so compare
  /// on the trimmed path rather than the literal.
  static bool _isPublic(String path) {
    final normalized = _trim(path);
    return _publicEndpoints.any((endpoint) => _trim(endpoint) == normalized);
  }

  static String _trim(String path) =>
      path.startsWith('/') ? path.substring(1) : path;
}
