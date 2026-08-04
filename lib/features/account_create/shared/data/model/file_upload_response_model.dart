import 'package:equatable/equatable.dart';

/// Reply from the upload endpoint:
///
/// ```json
/// { "success": true, "data": { "key": "...", "signedUrl": "...",
///   "expiresIn": 3600 } }
/// ```
class FileUploadResponseModel extends Equatable {
  const FileUploadResponseModel({
    required this.success,
    required this.message,
    this.code,
    this.data,
  });

  final bool success;
  final int? code;
  final String message;
  final FileUploadData? data;

  factory FileUploadResponseModel.fromJson(Map<String, dynamic> json) {
    return FileUploadResponseModel(
      success: json['success'] as bool? ?? false,
      code: (json['code'] as num?)?.toInt(),
      message: json['message'] as String? ?? 'File upload failed.',
      data: json['data'] is Map<String, dynamic>
          ? FileUploadData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [success, code, message, data];
}

class FileUploadData extends Equatable {
  const FileUploadData({required this.signedUrl, this.key, this.expiresIn});

  final String? key;

  /// The URL the profile payloads carry.
  final String signedUrl;

  final int? expiresIn;

  factory FileUploadData.fromJson(Map<String, dynamic> json) {
    return FileUploadData(
      key: json['key'] as String?,
      signedUrl: json['signedUrl'] as String? ?? '',
      expiresIn: (json['expiresIn'] as num?)?.toInt(),
    );
  }

  @override
  List<Object?> get props => [key, signedUrl, expiresIn];
}
