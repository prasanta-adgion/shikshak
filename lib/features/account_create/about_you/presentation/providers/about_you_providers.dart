import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/core_providers.dart';
import '../../data/repository/profile_image_repository_impl.dart';
import '../../domain/repositories/profile_image_repository.dart';
import '../../domain/usecases/upload_profile_image_usecase.dart';

final profileImageRepositoryProvider = Provider<ProfileImageRepository>(
  (ref) => ProfileImageRepositoryImpl(ref.watch(apiClientProvider)),
);

final uploadProfileImageUseCaseProvider = Provider<UploadProfileImageUseCase>(
  (ref) => UploadProfileImageUseCase(
    ref.watch(profileImageRepositoryProvider),
  ),
);
