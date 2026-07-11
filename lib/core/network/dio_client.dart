import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../storage/secure_storage_service.dart';
import 'api_exception.dart';
import 'i_api_client.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logger_interceptor.dart';

/// Production [IApiClient] implementation backed by Dio.
///
/// Owns the base configuration (base URL, timeouts, default headers) and the
/// interceptor chain. Converts every transport failure into [ApiException]
/// so nothing Dio-specific leaks upward.
class DioClient implements IApiClient {
  final Dio _dio;
  DioClient({required SecureStorageService storage, Dio? dio})
    : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 15),
      headers: const {'Accept': 'application/json'},
    );
    _dio.interceptors.addAll([AuthInterceptor(storage), LoggerInterceptor()]);
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
