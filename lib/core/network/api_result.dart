import 'api_exception.dart';

sealed class ApiResult<T> {
  const ApiResult();

  const factory ApiResult.success(T data) = ApiSuccess<T>;

  const factory ApiResult.failure(ApiException exception) = ApiFailure<T>;

  /// Runs [action] and turns whatever it throws into an [ApiFailure]. This is
  /// the one place repositories need to catch: they call the datasource
  /// through it and never write a try/catch of their own.
  static Future<ApiResult<T>> guard<T>(Future<T> Function() action) async {
    try {
      return ApiResult.success(await action());
    } on ApiException catch (exception) {
      return ApiResult.failure(exception);
    } catch (error) {
      return ApiResult.failure(ApiException.unexpected(error));
    }
  }

  bool get isSuccess => this is ApiSuccess<T>;

  T? get dataOrNull => switch (this) {
    ApiSuccess<T>(:final data) => data,
    ApiFailure<T>() => null,
  };

  /// Exhaustively handles both cases.
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(ApiException exception) onFailure,
  }) => switch (this) {
    ApiSuccess<T>(:final data) => onSuccess(data),
    ApiFailure<T>(:final exception) => onFailure(exception),
  };

  /// Transforms the success value while preserving failures.
  ApiResult<R> map<R>(R Function(T data) transform) => switch (this) {
    ApiSuccess<T>(:final data) => ApiResult.success(transform(data)),
    ApiFailure<T>(:final exception) => ApiResult.failure(exception),
  };
}

final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);

  final T data;
}

final class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.exception);

  final ApiException exception;
}
