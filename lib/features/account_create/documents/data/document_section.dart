import '../../../../core/constants/api_endpoints.dart';
import '../../shared/domain/entities/profile_section.dart';
import '../../shared/domain/entities/profile_step.dart';
import '../../shared/domain/entities/teacher_profile_draft.dart';

/// Maps [TeacherDocument] onto the document payload:
///
/// ```json
/// { "documentType", "fileName", "fileUrl", "mimeType", "fileSizeBytes" }
/// ```
///
/// Everything but `fileUrl` is derived from the picked file; the URL comes
/// from the shared upload endpoint.
class DocumentSection implements ProfileSection, UploadingSection {
  const DocumentSection();

  /// Names the payload field the picked document fills.
  static const String fileField = 'fileUrl';

  @override
  ProfileStep get step => ProfileStep.documents;

  @override
  String get path => ApiEndpoints.documents;

  @override
  Map<String, dynamic> body(TeacherProfileDraft draft) {
    final document = draft.document;

    return {
      'documentType': document.documentType?.wireValue,
      'fileName': document.fileName,
      'fileUrl': document.fileUrl,
      'mimeType': document.mimeType,
      'fileSizeBytes': document.fileSizeBytes,
    };
  }

  @override
  List<PendingUpload> pendingUploads(TeacherProfileDraft draft) {
    // The device path, never the display name — only a real path can be
    // uploaded. Stays empty until file picking is connected.
    final localPath = draft.document.localFilePath;
    if (localPath == null ||
        localPath.isEmpty ||
        draft.document.fileUrl != null) {
      return const [];
    }

    return [PendingUpload(field: fileField, localPath: localPath)];
  }

  @override
  TeacherProfileDraft withUploadedUrls(
    TeacherProfileDraft draft,
    Map<String, String> urls,
  ) {
    final url = urls[fileField];
    if (url == null) return draft;

    return draft.copyWith(document: draft.document.copyWith(fileUrl: url));
  }
}
