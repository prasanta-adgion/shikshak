/// Standard envelope returned by the Shikshak backend:
/// `{ "success": bool, "code": int, "message": string, "data": {...} }`
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    this.code,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => ApiResponse(
    // Defensive reads: a gateway or proxy error can return a body that is
    // shaped differently, and a hard cast there would surface as an opaque
    // TypeError instead of the server's actual message.
    success: json['success'] as bool? ?? false,
    code: (json['code'] as num?)?.toInt(),
    message: json['message'] as String? ?? 'Something went wrong.',
    data: json['data'] == null ? null : fromJsonT(json['data']),
  );

  final bool success;

  /// HTTP-style status echoed in the body (e.g. 200). Null when omitted.
  final int? code;

  final String message;
  final T? data;
}
