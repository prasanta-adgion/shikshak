import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/core_providers.dart';
import '../../data/datasource/experience_remote_datasource.dart';
import '../../data/repository/experience_repository_impl.dart';
import '../../domain/repositories/experience_repository.dart';
import '../../domain/usecases/experience_usecases.dart';
import '../notifier/experience_list_notifier.dart';
import '../state/experience_list_state.dart';

final experienceRemoteDataSourceProvider = Provider<ExperienceRemoteDataSource>(
  (ref) => ExperienceRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);

final experienceRepositoryProvider = Provider<ExperienceRepository>((ref) {
  return ExperienceRepositoryImpl(
    remoteDataSource: ref.watch(experienceRemoteDataSourceProvider),
  );
});

final getExperiencesUseCaseProvider = Provider<GetExperiencesUseCase>(
  (ref) => GetExperiencesUseCase(ref.watch(experienceRepositoryProvider)),
);

final updateExperienceUseCaseProvider = Provider<UpdateExperienceUseCase>(
  (ref) => UpdateExperienceUseCase(ref.watch(experienceRepositoryProvider)),
);

/// Dropped with the step, so a later visit reads the rows fresh instead of
/// showing what the last one left behind.
final experienceListNotifierProvider =
    NotifierProvider<ExperienceListNotifier, ExperienceListState>(
      ExperienceListNotifier.new,
      isAutoDispose: true,
    );
