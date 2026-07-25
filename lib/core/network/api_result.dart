import 'api_exception.dart';

sealed class ApiResult<T> {
  const ApiResult();

  const factory ApiResult.success(T data) = ApiSuccess<T>;

  const factory ApiResult.failure(ApiException exception) = ApiFailure<T>;

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
