/// Standard envelope returned by the Shikshak backend:
/// `{ "success": bool, "message": string, "data": {...} }`
class ApiResponse<T> {
  const ApiResponse({required this.success, required this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      ApiResponse(
        success: json['success'] as bool,
        message: json['message'] as String,
        data: json['data'] == null ? null : fromJsonT(json['data']),
      );

  final bool success;
  final String message;
  final T? data;
}
