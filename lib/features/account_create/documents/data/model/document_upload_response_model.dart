import 'package:equatable/equatable.dart';

class DocumentUploadResponseModel extends Equatable {
  const DocumentUploadResponseModel({
    required this.success,
    required this.message,
    this.code,
    this.data,
  });

  final bool success;
  final int? code;
  final String message;
  final DocumentUploadData? data;

  factory DocumentUploadResponseModel.fromJson(Map<String, dynamic> json) {
    return DocumentUploadResponseModel(
      success: json['success'] as bool? ?? false,
      code: (json['code'] as num?)?.toInt(),
      message: json['message'] as String? ?? 'Document upload failed.',
      data: json['data'] is Map<String, dynamic>
          ? DocumentUploadData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [success, code, message, data];
}

class DocumentUploadData extends Equatable {
  const DocumentUploadData({required this.signedUrl, this.key, this.expiresIn});

  final String? key;
  final String signedUrl;
  final int? expiresIn;

  factory DocumentUploadData.fromJson(Map<String, dynamic> json) {
    return DocumentUploadData(
      key: json['key'] as String?,
      signedUrl: json['signedUrl'] as String? ?? '',
      expiresIn: (json['expiresIn'] as num?)?.toInt(),
    );
  }

  @override
  List<Object?> get props => [key, signedUrl, expiresIn];
}
