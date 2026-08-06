import '../../../../../core/constants/api_endpoints.dart';
import '../../shared/domain/entities/profile_section.dart';
import '../../shared/domain/entities/profile_step.dart';
import '../../shared/domain/entities/teacher_profile_draft.dart';
import '../domain/entities/teacher_document.dart';
import 'model/document_request_model.dart';

/// Maps [TeacherDocument] onto the document payload:
///
/// ```json
/// { "documentType", "fileName", "fileUrl", "mimeType", "fileSizeBytes" }
/// ```
///
/// The document picker uploads the file first and stores its signed URL in
/// [TeacherDocument.fileUrl] before this section submits the document row.
class DocumentSection implements ProfileSection, RepeatableSection {
  const DocumentSection();

  @override
  ProfileStep get step => ProfileStep.documents;

  @override
  String get path => ApiEndpoints.documents;

  @override
  Map<String, dynamic> body(TeacherProfileDraft draft) =>
      DocumentRequestModel(document: draft.document).toJson();

  @override
  bool isEntryEmpty(TeacherProfileDraft draft) => !draft.document.hasFile;

  @override
  TeacherProfileDraft commitEntry(TeacherProfileDraft draft) => draft.copyWith(
    savedDocuments: [...draft.savedDocuments, draft.document],
    document: const TeacherDocument(),
  );
}
