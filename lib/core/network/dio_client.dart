import 'package:dio/dio.dart';
import 'package:network_logger/network_logger.dart';

import '../storage/secure_storage_service.dart';
import 'api_exception.dart';
import 'i_api_client.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logger_interceptor.dart';
import 'token_refresher.dart';

class DioClient implements IApiClient {
  final Dio _dio;
  DioClient({
    required String baseUrl,
    required SecureStorageService storage,
    bool enableLogging = true,
    Dio? dio,
    TokenRefresher? refresher,
  }) : _dio = dio ?? Dio() {
    if (baseUrl.isEmpty) {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'DioClient was given an empty baseUrl. The current flavor has no API '
            'host configured — see AppFlavor in lib/core/flavor/app_flavor.dart.',
      );
    }

    final normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';

    _dio.options = BaseOptions(
      baseUrl: normalizedBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 15),
      headers: const {'Accept': 'application/json'},
    );
    _dio.interceptors.add(
      AuthInterceptor(
        storage,
        dio: _dio,
        refresher:
            refresher ??
            TokenRefresher(
              baseUrl: normalizedBaseUrl,
              storage: storage,
              enableLogging: enableLogging,
            ),
      ),
    );
    if (enableLogging) {
      // Two audiences: the console for a terminal, and the in-app inspector
      // (the draggable button) for a device with no console attached.
      _dio.interceptors
        ..add(LoggerInterceptor())
        ..add(DioNetworkLogger());
    }
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
  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => _request(
    () => _dio.patch<T>(
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
