import 'package:equatable/equatable.dart';

import '../../domain/entities/teacher_document.dart';

class DocumentResponseModel extends Equatable {
  final bool? success;
  final int? code;
  final String? message;
  final DocumentData? data;

  const DocumentResponseModel({
    this.success,
    this.code,
    this.message,
    this.data,
  });

  factory DocumentResponseModel.fromJson(Map<String, dynamic> json) {
    return DocumentResponseModel(
      success: json['success'] as bool?,
      code: json['code'] as int?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? DocumentData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [success, code, message, data];
}

class DocumentData extends Equatable {
  final List<DocumentItem>? items;

  const DocumentData({this.items});

  factory DocumentData.fromJson(Map<String, dynamic> json) {
    return DocumentData(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => DocumentItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [items];
}

class DocumentItem extends Equatable {
  final String? id;
  final String? teacherProfileId;
  final String? documentType;
  final String? fileName;
  final String? fileUrl;
  final String? mimeType;
  final int? fileSizeBytes;
  final String? createdAt;
  final String? updatedAt;

  const DocumentItem({
    this.id,
    this.teacherProfileId,
    this.documentType,
    this.fileName,
    this.fileUrl,
    this.mimeType,
    this.fileSizeBytes,
    this.createdAt,
    this.updatedAt,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: json['id'] as String?,
      teacherProfileId: json['teacherProfileId'] as String?,
      documentType: json['documentType'] as String?,
      fileName: json['fileName'] as String?,
      fileUrl: json['fileUrl'] as String?,
      mimeType: json['mimeType'] as String?,
      // Tolerates the size arriving as a JSON number or a string.
      fileSizeBytes:
          (json['fileSizeBytes'] as num?)?.toInt() ??
          int.tryParse('${json['fileSizeBytes']}'),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  /// The row as the edit form takes it.
  TeacherDocument toDocument() => TeacherDocument(
    documentType: DocumentTypeX.tryParse(documentType),
    fileName: fileName,
    fileUrl: fileUrl,
    mimeType: mimeType,
    fileSizeBytes: fileSizeBytes,
  );

  @override
  List<Object?> get props => [
    id,
    teacherProfileId,
    documentType,
    fileName,
    fileUrl,
    mimeType,
    fileSizeBytes,
    createdAt,
    updatedAt,
  ];
}
