class ApiResponse<T> {
  final bool success;

  final int? code;

  final String message;
  final T? data;

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
    success: json['success'] as bool? ?? false,
    code: (json['code'] as num?)?.toInt(),
    message: json['message'] as String? ?? 'Something went wrong.',
    data: json['data'] == null ? null : fromJsonT(json['data']),
  );
}
