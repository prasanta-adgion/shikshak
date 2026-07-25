import 'package:dio/dio.dart';

import '../storage/secure_storage_service.dart';
import 'api_exception.dart';
import 'i_api_client.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logger_interceptor.dart';

/// Production [IApiClient] implementation backed by Dio.
///
/// Owns the base configuration (timeouts, default headers) and the
/// interceptor chain. Converts every transport failure into [ApiException]
/// so nothing Dio-specific leaks upward.
///
/// [baseUrl] is injected rather than read from a global, so the flavor
/// decides the environment and tests can point this at a fake server.
class DioClient implements IApiClient {
  final Dio _dio;
  DioClient({
    required String baseUrl,
    required SecureStorageService storage,
    bool enableLogging = true,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    // A throw, not an assert: asserts are stripped from release builds, and a
    // release build silently issuing relative requests is far worse than one
    // that refuses to start talking to a host it does not have.
    if (baseUrl.isEmpty) {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'DioClient was given an empty baseUrl. The current flavor has no API '
            'host configured — see AppFlavor in lib/core/flavor/app_flavor.dart.',
      );
    }

    // Dio joins baseUrl and path by plain concatenation. Without a separator
    // between them the result is malformed — "http://host:5001" + "api/v1/x"
    // becomes "http://host:5001api/v1/x", which throws FormatException
    // ("Invalid port") on every request. Normalising the base to end with "/"
    // keeps both relative ("api/v1/x") and rooted ("/api/v1/x") endpoint
    // styles working, so ApiEndpoints can be written either way.
    final normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';

    _dio.options = BaseOptions(
      baseUrl: normalizedBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 15),
      headers: const {'Accept': 'application/json'},
    );
    _dio.interceptors.add(AuthInterceptor(storage));
    if (enableLogging) _dio.interceptors.add(LoggerInterceptor());
  }

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => _request(
    () => _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    ),
  );

  @override
  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => _request(
    () => _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    ),
  );

  @override
  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => _request(
    () => _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    ),
  );

  @override
  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => _request(
    () => _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    ),
  );

  Future<T> _request<T>(Future<Response<T>> Function() send) async {
    try {
      final response = await send();
      return response.data as T;
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    } catch (error) {
      throw ApiException.unexpected(error);
    }
  }
}
