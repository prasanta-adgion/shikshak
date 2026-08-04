import '../../../../../core/network/api_result.dart';

abstract interface class FileUploadRepository {
  /// Uploads the file at [filePath] and resolves to the URL the profile
  /// payloads carry. [folder] is the bucket the API files it under.
  Future<ApiResult<String>> upload({
    required String filePath,
    required String folder,
  });
}

/// Buckets the upload API files teacher attachments under.
abstract final class UploadFolders {
  static const String documents = 'teacher-documents';
  static const String certificates = 'teacher-certificates';
}
