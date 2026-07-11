/// Transport-agnostic HTTP contract.
///
/// Data sources depend on this abstraction (Dependency Inversion) — the Dio
/// implementation lives in `dio_client.dart` and can be swapped without
/// touching any feature code.
///
/// All methods return the decoded response body and throw [ApiException]
/// on failure.
abstract interface class IApiClient {
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  });

  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  });

  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  });

  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  });
}
