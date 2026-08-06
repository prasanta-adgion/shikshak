import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/core_providers.dart';
import '../../data/datasource/teacher_profile_remote_datasource.dart';
import '../../data/repository/teacher_profile_repository_impl.dart';
import '../../domain/repositories/teacher_profile_repository.dart';
import '../../domain/usecases/get_teacher_profile_usecase.dart';
import '../notifier/teacher_profile_notifier.dart';
import '../state/teacher_profile_state.dart';

final teacherProfileRemoteDataSourceProvider =
    Provider<TeacherProfileRemoteDataSource>(
      (ref) => TeacherProfileRemoteDataSourceImpl(ref.watch(apiClientProvider)),
    );

final teacherProfileRepositoryProvider = Provider<TeacherProfileRepository>((
  ref,
) {
  return TeacherProfileRepositoryImpl(
    remoteDataSource: ref.watch(teacherProfileRemoteDataSourceProvider),
  );
});

final getTeacherProfileUseCaseProvider = Provider<GetTeacherProfileUseCase>(
  (ref) =>
      GetTeacherProfileUseCase(ref.watch(teacherProfileRepositoryProvider)),
);

/// Dropped with the screen, so reopening the Profile tab re-reads the server
/// rather than showing what the last visit left behind.
final teacherProfileNotifierProvider =
    NotifierProvider<TeacherProfileNotifier, TeacherProfileState>(
      TeacherProfileNotifier.new,
      isAutoDispose: true,
    );
