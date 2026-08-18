import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/core_providers.dart';
import '../../data/datasource/student_profile_remote_datasource.dart';
import '../../data/repository/student_profile_repository_impl.dart';
import '../../domain/repositories/student_profile_repository.dart';
import '../../domain/usecases/get_student_profile_usecase.dart';
import '../notifier/student_profile_notifier.dart';
import '../state/student_profile_state.dart';

final studentProfileRemoteDataSourceProvider =
    Provider<StudentProfileRemoteDataSource>(
      (ref) => StudentProfileRemoteDataSourceImpl(ref.watch(apiClientProvider)),
    );

final studentProfileRepositoryProvider = Provider<StudentProfileRepository>((
  ref,
) {
  return StudentProfileRepositoryImpl(
    remoteDataSource: ref.watch(studentProfileRemoteDataSourceProvider),
  );
});

final getStudentProfileUseCaseProvider = Provider<GetStudentProfileUseCase>(
  (ref) =>
      GetStudentProfileUseCase(ref.watch(studentProfileRepositoryProvider)),
);

/// Dropped with the screen, so reopening the Profile tab re-reads the server
/// rather than showing what the last visit left behind.
final studentProfileNotifierProvider =
    NotifierProvider<StudentProfileNotifier, StudentProfileState>(
      StudentProfileNotifier.new,
      isAutoDispose: true,
    );
