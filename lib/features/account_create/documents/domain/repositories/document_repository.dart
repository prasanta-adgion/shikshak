import '../../../../../core/network/api_result.dart';
import '../../data/model/document_response_model.dart';
import '../../data/model/document_upload_response_model.dart';
import '../params/update_document_params.dart';

abstract interface class DocumentRepository {
  Future<ApiResult<DocumentUploadData>> uploadDocument(String filePath);

  /// Every document row the server holds for this teacher.
  Future<ApiResult<List<DocumentItem>>> fetchDocuments();

  Future<ApiResult<void>> updateDocument(UpdateDocumentParams params);
}
