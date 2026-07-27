import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggerInterceptor extends Interceptor {
  static const _name = 'network';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      developer.log('→ ${options.method} ${options.uri}', name: _name);
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      developer.log(
        '← ${response.statusCode} ${response.requestOptions.method} '
        '${response.requestOptions.uri}',
        name: _name,
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      developer.log(
        '✕ ${err.response?.statusCode ?? '---'} '
        '${err.requestOptions.method} ${err.requestOptions.uri} '
        '(${err.type.name})',
        name: _name,
        error: err.message,
      );
    }
    handler.next(err);
  }
}
