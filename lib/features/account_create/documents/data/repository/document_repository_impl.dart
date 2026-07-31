import '../../../../../core/network/api_exception.dart';
import '../../../../../core/network/api_result.dart';
import '../../domain/params/update_document_params.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasource/document_remote_datasource.dart';
import '../model/document_request_model.dart';
import '../model/document_response_model.dart';
import '../model/document_upload_response_model.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDataSource _remote;

  const DocumentRepositoryImpl({
    required DocumentRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  @override
  Future<ApiResult<DocumentUploadData>> uploadDocument(String filePath) =>
      _guard(() => _remote.upload(filePath));

  @override
  Future<ApiResult<List<DocumentItem>>> fetchDocuments() =>
      _guard(_remote.fetchAll);

  @override
  Future<ApiResult<void>> updateDocument(UpdateDocumentParams params) => _guard(
    () => _remote.update(
      id: params.id,
      request: DocumentRequestModel(document: params.document),
    ),
  );

  Future<ApiResult<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return ApiResult.success(await action());
    } on ApiException catch (exception) {
      return ApiResult.failure(exception);
    } catch (error) {
      return ApiResult.failure(ApiException.unexpected(error));
    }
  }
}
