import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/core_providers.dart';
import '../../data/datasource/all_teachers_remote_datasource.dart';
import '../../data/repository/all_teachers_repository_impl.dart';
import '../../domain/repositories/all_teachers_repository.dart';
import '../../domain/usecases/get_all_teachers_usecase.dart';
import '../notifier/all_teachers_notifier.dart';
import '../state/all_teachers_state.dart';

final allTeachersRemoteDataSourceProvider =
    Provider<AllTeachersRemoteDataSource>(
      (ref) => AllTeachersRemoteDataSourceImpl(ref.watch(apiClientProvider)),
    );

final allTeachersRepositoryProvider = Provider<AllTeachersRepository>((ref) {
  return AllTeachersRepositoryImpl(
    remoteDataSource: ref.watch(allTeachersRemoteDataSourceProvider),
  );
});

final getAllTeachersUseCaseProvider = Provider<GetAllTeachersUseCase>(
  (ref) => GetAllTeachersUseCase(ref.watch(allTeachersRepositoryProvider)),
);

/// Dropped with the screen: the pages appended by scrolling are a lot of
/// state to carry around, and reopening the list should start at the top.
final allTeachersNotifierProvider =
    NotifierProvider<AllTeachersNotifier, AllTeachersState>(
      AllTeachersNotifier.new,
      isAutoDispose: true,
    );
