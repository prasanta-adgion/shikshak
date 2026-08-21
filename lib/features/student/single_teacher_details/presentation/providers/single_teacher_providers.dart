import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/core_providers.dart';
import '../../data/datasource/single_teacher_remote_datasource.dart';
import '../../data/repository/single_teacher_repository_impl.dart';
import '../../domain/repositories/single_teacher_repository.dart';
import '../../domain/usecases/get_single_teacher_usecase.dart';
import '../notifier/single_teacher_notifier.dart';
import '../state/single_teacher_state.dart';

final singleTeacherRemoteDataSourceProvider =
    Provider<SingleTeacherRemoteDataSource>(
      (ref) => SingleTeacherRemoteDataSourceImpl(ref.watch(apiClientProvider)),
    );

final singleTeacherRepositoryProvider = Provider<SingleTeacherRepository>((
  ref,
) {
  return SingleTeacherRepositoryImpl(
    remoteDataSource: ref.watch(singleTeacherRemoteDataSourceProvider),
  );
});

final getSingleTeacherUseCaseProvider = Provider<GetSingleTeacherUseCase>(
  (ref) => GetSingleTeacherUseCase(ref.watch(singleTeacherRepositoryProvider)),
);

/// Auto-disposed, so opening a second teacher starts from an empty state
/// rather than showing the first one's classes for a frame.
final singleTeacherNotifierProvider =
    NotifierProvider<SingleTeacherNotifier, SingleTeacherState>(
      SingleTeacherNotifier.new,
      isAutoDispose: true,
    );
