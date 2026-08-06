import '../entities/teacher_document.dart';

/// One document row's payload, plus the id of the row it belongs to.
class UpdateDocumentParams {
  const UpdateDocumentParams({required this.id, required this.document});

  final String id;

  final TeacherDocument document;
}
