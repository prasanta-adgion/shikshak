import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/core_providers.dart';
import '../../data/datasource/document_remote_datasource.dart';
import '../../data/repository/document_repository_impl.dart';
import '../../domain/repositories/document_repository.dart';
import '../../domain/usecases/document_usecases.dart';
import '../notifier/document_list_notifier.dart';
import '../state/document_list_state.dart';

final documentRemoteDataSourceProvider = Provider<DocumentRemoteDataSource>(
  (ref) => DocumentRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepositoryImpl(
    remoteDataSource: ref.watch(documentRemoteDataSourceProvider),
  );
});

final getDocumentsUseCaseProvider = Provider<GetDocumentsUseCase>(
  (ref) => GetDocumentsUseCase(ref.watch(documentRepositoryProvider)),
);

final updateDocumentUseCaseProvider = Provider<UpdateDocumentUseCase>(
  (ref) => UpdateDocumentUseCase(ref.watch(documentRepositoryProvider)),
);

final documentListNotifierProvider =
    NotifierProvider<DocumentListNotifier, DocumentListState>(
      DocumentListNotifier.new,
    );
