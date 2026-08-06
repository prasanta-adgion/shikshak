import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../flavor/app_flavor.dart';
import '../storage/secure_storage_service.dart';
import 'interceptors/logger_interceptor.dart';

class TokenRefresher {
  TokenRefresher({
    required String baseUrl,
    required SecureStorageService storage,
    bool enableLogging = false,
    Dio? dio,
  }) : _storage = storage,
       _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {'Accept': 'application/json'},
    );
    if (enableLogging) _dio.interceptors.add(LoggerInterceptor());
  }

  final Dio _dio;
  final SecureStorageService _storage;

  Future<String?>? _inFlight;
  Future<String?> refresh() =>
      _inFlight ??= _run().whenComplete(() => _inFlight = null);

  Future<String?> _run() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _endSession('nothing stored to refresh with');
      return null;
    }

    final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.refreshTokenGenerate,
        data: {'refreshToken': refreshToken},
      );
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status != null && status >= 400 && status < 500) {
        await _endSession('server rejected the refresh token ($status)');
      } else {
        _log('could not reach the refresh endpoint (${error.type.name})');
      }
      return null;
    }

    final token = await _persist(response.data);
    if (token == null) {
      await _endSession('the refresh response carried no token');
      return null;
    }

    _log('access token refreshed');
    return token;
  }

  /// Stores the new pair and returns the access token, or null when the
  /// payload was not the shape the endpoint promises.
  Future<String?> _persist(Map<String, dynamic>? body) async {
    final data = body?['data'];
    if (data is! Map) return null;

    final token = data['token'];
    if (token is! String || token.isEmpty) return null;

    // The endpoint reissues both. Guarded anyway so a response that omits the
    // refresh token leaves the working one in place rather than wiping it.
    final next = data['refreshToken'];

    await Future.wait([
      _storage.saveToken(token),
      if (next is String && next.isNotEmpty) _storage.saveRefreshToken(next),
    ]);
    return token;
  }

  /// The session is over: drop the stored keys so the next cold start sends
  /// the user to login instead of retrying a token the server has finished
  /// with.
  Future<void> _endSession(String reason) async {
    _log('session ended — $reason');
    await _storage.clear();
  }

  void _log(String message) {
    if (!AppFlavorConfig.enableNetworkLogging) return;
    developer.log(message, name: 'auth');
  }
}
