import '../../../../../core/network/api_result.dart';
import '../../domain/params/update_document_params.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasource/document_remote_datasource.dart';
import '../model/document_request_model.dart';
import '../model/document_response_model.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDataSource _remote;

  const DocumentRepositoryImpl({
    required DocumentRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  @override
  Future<ApiResult<List<DocumentItem>>> fetchDocuments() =>
      ApiResult.guard(_remote.fetchAll);

  @override
  Future<ApiResult<void>> updateDocument(UpdateDocumentParams params) =>
      ApiResult.guard(
        () => _remote.update(
          id: params.id,
          request: DocumentRequestModel(document: params.document),
        ),
      );
}
