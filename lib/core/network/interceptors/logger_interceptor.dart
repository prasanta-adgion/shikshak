import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

class LoggerInterceptor extends Interceptor {
  static const _name = 'network';
  static const _encoder = JsonEncoder.withIndent('  ');
  static const _sensitiveKeys = {
    'authorization',
    'password',
    'confirmpassword',
    'currentpassword',
    'newpassword',
    'token',
    'accesstoken',
    'refreshtoken',
    'otp',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      '→ ${options.method} ${options.uri}\n'
      'Request body:\n${_formatBody(options.data)}',
      name: _name,
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri}',
      name: _name,
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '✕ ${err.response?.statusCode ?? '---'} '
      '${err.requestOptions.method} ${err.requestOptions.uri} '
      '(${err.type.name})',
      name: _name,
      error: err.message,
    );
    handler.next(err);
  }

  static String _formatBody(Object? body) {
    if (body == null) return '<empty>';

    final Object? printable;
    if (body is FormData) {
      printable = {
        'fields': {
          for (final field in body.fields)
            field.key: _redact(field.key, field.value),
        },
        'files': [
          for (final file in body.files)
            {
              'field': file.key,
              'filename': file.value.filename,
              'contentType': file.value.contentType?.toString(),
            },
        ],
      };
    } else {
      printable = _sanitize(body);
    }

    try {
      return _encoder.convert(printable);
    } catch (_) {
      return printable.toString();
    }
  }

  static Object? _sanitize(Object? value) {
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _redact(
            entry.key.toString(),
            _sanitize(entry.value),
          ),
      };
    }
    if (value is Iterable) return value.map(_sanitize).toList();
    return value;
  }

  static Object? _redact(String key, Object? value) {
    final normalized = key.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    return _sensitiveKeys.contains(normalized) ? '<redacted>' : value;
  }
}
