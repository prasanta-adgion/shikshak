import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/core_providers.dart';
import '../../data/datasource/create_class_remote_datasource_impl.dart';
import '../../data/datasource/i_create_class_remote_datasource.dart';
import '../../data/repositories/create_class_repository_impl.dart';
import '../../domain/repositories/create_class_repository.dart';
import '../../domain/usecases/create_class_usecase.dart';
import '../notifier/create_class_notifier.dart';
import '../state/create_class_state.dart';

final createClassRemoteDataSourceProvider =
    Provider<CreateClassRemoteDataSource>(
      (ref) => CreateClassRemoteDataSourceImpl(ref.watch(apiClientProvider)),
    );

final createClassRepositoryProvider = Provider<CreateClassRepository>((ref) {
  return CreateClassRepositoryImpl(
    remoteDataSource: ref.watch(createClassRemoteDataSourceProvider),
  );
});

final createClassUseCaseProvider = Provider<CreateClassUseCase>(
  (ref) => CreateClassUseCase(ref.watch(createClassRepositoryProvider)),
);

/// Dropped with the form, so a second visit starts from a clean slate rather
/// than replaying the last submit's outcome.
final createClassNotifierProvider =
    NotifierProvider<CreateClassNotifier, CreateClassState>(
      CreateClassNotifier.new,
      isAutoDispose: true,
    );
