import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/core_providers.dart';
import '../../data/datasource/education_remote_datasource.dart';
import '../../data/repository/education_repository_impl.dart';
import '../../domain/repositories/education_repository.dart';
import '../../domain/usecases/education_usecases.dart';
import '../notifier/education_list_notifier.dart';
import '../state/education_list_state.dart';

final educationRemoteDataSourceProvider = Provider<EducationRemoteDataSource>(
  (ref) => EducationRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);

final educationRepositoryProvider = Provider<EducationRepository>((ref) {
  return EducationRepositoryImpl(
    remoteDataSource: ref.watch(educationRemoteDataSourceProvider),
  );
});

final getEducationsUseCaseProvider = Provider<GetEducationsUseCase>(
  (ref) => GetEducationsUseCase(ref.watch(educationRepositoryProvider)),
);

final updateEducationUseCaseProvider = Provider<UpdateEducationUseCase>(
  (ref) => UpdateEducationUseCase(ref.watch(educationRepositoryProvider)),
);

final educationListNotifierProvider =
    NotifierProvider<EducationListNotifier, EducationListState>(
      EducationListNotifier.new,
    );
