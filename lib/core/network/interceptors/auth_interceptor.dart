import 'package:dio/dio.dart';

import '../../storage/secure_storage_service.dart';

/// Attaches the bearer token (when present) to every outgoing request.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  final SecureStorageService _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Hook for token refresh: on a 401, exchange the refresh token and retry
    // the request once. Left unimplemented until the real API exists.
    handler.next(err);
  }
}
