import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/core_providers.dart';
import '../../data/datasource/basic_info_remote_datasource.dart';
import '../../data/repository/basic_info_repository_impl.dart';
import '../../domain/repositories/basic_info_repository.dart';
import '../../domain/usecases/get_basic_info_usecase.dart';
import '../notifier/basic_info_notifier.dart';
import '../state/basic_info_state.dart';

final basicInfoRemoteDataSourceProvider = Provider<BasicInfoRemoteDataSource>(
  (ref) => BasicInfoRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);

final basicInfoRepositoryProvider = Provider<BasicInfoRepository>((ref) {
  return BasicInfoRepositoryImpl(
    remoteDataSource: ref.watch(basicInfoRemoteDataSourceProvider),
  );
});

final getBasicInfoUseCaseProvider = Provider<GetBasicInfoUseCase>(
  (ref) => GetBasicInfoUseCase(ref.watch(basicInfoRepositoryProvider)),
);

/// Dropped with the step, so a later visit reads the section fresh instead of
/// showing what the last one left behind.
final basicInfoNotifierProvider =
    NotifierProvider<BasicInfoNotifier, BasicInfoState>(
      BasicInfoNotifier.new,
      isAutoDispose: true,
    );
