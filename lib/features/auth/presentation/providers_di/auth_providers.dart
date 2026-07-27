import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../notifier/auth_notifier.dart';
import '../notifier/login_notifier.dart';
import '../notifier/register_notifier.dart';
import '../state/auth_state.dart';

/// Composition root for the auth feature. Everything depends on
/// abstractions; only this file knows the concrete classes.

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final authRepositoryImplementProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    storage: ref.watch(secureStorageServiceProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.watch(authRepositoryImplementProvider)),
);

final registerUseCaseProvider = Provider<RegisterUseCase>(
  (ref) => RegisterUseCase(ref.watch(authRepositoryImplementProvider)),
);

final logoutUseCaseProvider = Provider<LogoutUseCase>(
  (ref) => LogoutUseCase(ref.watch(authRepositoryImplementProvider)),
);

final checkAuthStatusUseCaseProvider = Provider<CheckAuthStatusUseCase>(
  (ref) => CheckAuthStatusUseCase(ref.watch(authRepositoryImplementProvider)),
);

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final loginNotifierProvider =
    NotifierProvider<LoginNotifier, AsyncValue<void>>(LoginNotifier.new);

final registerNotifierProvider =
    NotifierProvider<RegisterNotifier, AsyncValue<void>>(RegisterNotifier.new);
