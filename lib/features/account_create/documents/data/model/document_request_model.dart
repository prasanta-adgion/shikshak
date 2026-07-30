import '../../domain/entities/teacher_document.dart';

class DocumentRequestModel {
  const DocumentRequestModel({required this.document});

  final TeacherDocument document;

  Map<String, dynamic> toJson() => {
    'documentType': document.documentType?.wireValue ?? '',
    'fileName': document.fileName ?? '',
    'fileUrl': document.fileUrl ?? '',
    'mimeType': document.mimeType ?? '',
    'fileSizeBytes': document.fileSizeBytes ?? 0,
  };
}
