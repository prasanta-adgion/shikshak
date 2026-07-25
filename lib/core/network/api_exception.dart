import 'package:dio/dio.dart';

/// Classification of API failures the app cares about.
enum ApiExceptionType {
  network,
  timeout,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  server,
  cancelled,
  unknown,
}

class ApiException implements Exception {
  const ApiException({
    required this.message,
    required this.type,
    this.statusCode,
  });

  final String message;
  final ApiExceptionType type;
  final int? statusCode;

  factory ApiException.fromDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(
          message: 'The request timed out. Please try again.',
          type: ApiExceptionType.timeout,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'No internet connection. Check your network and retry.',
          type: ApiExceptionType.network,
        );
      case DioExceptionType.cancel:
        return const ApiException(
          message: 'The request was cancelled.',
          type: ApiExceptionType.cancelled,
        );
      case DioExceptionType.badResponse:
        return ApiException._fromStatusCode(
          exception.response?.statusCode,
          _serverMessage(exception.response?.data),
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const ApiException(
          message: 'Something went wrong. Please try again.',
          type: ApiExceptionType.unknown,
        );
    }
  }

  factory ApiException._fromStatusCode(int? statusCode, String? serverMessage) {
    final (type, fallback) = switch (statusCode) {
      400 => (ApiExceptionType.badRequest, 'Invalid request.'),
      401 => (ApiExceptionType.unauthorized, 'Invalid credentials.'),
      403 => (ApiExceptionType.forbidden, 'You do not have access.'),
      404 => (ApiExceptionType.notFound, 'Resource not found.'),
      final int code when code >= 500 => (
        ApiExceptionType.server,
        'Server error. Try again later.',
      ),
      _ => (ApiExceptionType.unknown, 'Something went wrong.'),
    };
    return ApiException(
      message: serverMessage ?? fallback,
      type: type,
      statusCode: statusCode,
    );
  }

  factory ApiException.unexpected([Object? error]) => const ApiException(
    message: 'An unexpected error occurred. Please try again.',
    type: ApiExceptionType.unknown,
  );

  /// Attempts to extract a human-readable message from a server payload.
  static String? _serverMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.isNotEmpty) return message;
    }
    return null;
  }

  @override
  String toString() =>
      'ApiException(type: $type, statusCode: $statusCode, message: $message)';
}
