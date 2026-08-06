import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/providers/core_providers.dart';
import '../../data/datasource/about_you_remote_datasource.dart';
import '../../data/repository/about_you_repository_impl.dart';
import '../../data/repository/profile_image_repository_impl.dart';
import '../../domain/repositories/about_you_repository.dart';
import '../../domain/repositories/profile_image_repository.dart';
import '../../domain/usecases/get_about_you_usecase.dart';
import '../../domain/usecases/upload_profile_image_usecase.dart';
import '../notifier/about_you_notifier.dart';
import '../state/about_you_state.dart';

final profileImageRepositoryProvider = Provider<ProfileImageRepository>(
  (ref) => ProfileImageRepositoryImpl(ref.watch(fileUploaderProvider)),
);

final uploadProfileImageUseCaseProvider = Provider<UploadProfileImageUseCase>(
  (ref) => UploadProfileImageUseCase(ref.watch(profileImageRepositoryProvider)),
);

final aboutYouRemoteDataSourceProvider = Provider<AboutYouRemoteDataSource>(
  (ref) => AboutYouRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);

final aboutYouRepositoryProvider = Provider<AboutYouRepository>((ref) {
  return AboutYouRepositoryImpl(
    remoteDataSource: ref.watch(aboutYouRemoteDataSourceProvider),
  );
});

final getAboutYouUseCaseProvider = Provider<GetAboutYouUseCase>(
  (ref) => GetAboutYouUseCase(ref.watch(aboutYouRepositoryProvider)),
);

/// Dropped with the step, so a later visit reads the section fresh instead of
/// showing what the last one left behind.
final aboutYouNotifierProvider =
    NotifierProvider<AboutYouNotifier, AboutYouState>(
      AboutYouNotifier.new,
      isAutoDispose: true,
    );
