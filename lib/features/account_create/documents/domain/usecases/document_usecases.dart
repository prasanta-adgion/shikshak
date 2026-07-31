import '../../../../../core/network/api_result.dart';
import '../../data/model/document_response_model.dart';
import '../../data/model/document_upload_response_model.dart';
import '../params/update_document_params.dart';
import '../repositories/document_repository.dart';

class UploadDocumentUseCase {
  final DocumentRepository _repository;
  const UploadDocumentUseCase(this._repository);

  Future<ApiResult<DocumentUploadData>> call(String filePath) =>
      _repository.uploadDocument(filePath);
}

class GetDocumentsUseCase {
  const GetDocumentsUseCase(this._repository);

  final DocumentRepository _repository;

  Future<ApiResult<List<DocumentItem>>> call() => _repository.fetchDocuments();
}

class UpdateDocumentUseCase {
  const UpdateDocumentUseCase(this._repository);

  final DocumentRepository _repository;

  Future<ApiResult<void>> call(UpdateDocumentParams params) =>
      _repository.updateDocument(params);
}
