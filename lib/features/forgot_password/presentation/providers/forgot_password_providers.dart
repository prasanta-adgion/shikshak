import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasource/forgot_password_remote_datasource.dart';
import '../../data/datasource/i_forgot_password_remote_datasource.dart';
import '../../data/repository/forgot_password_repository_impl.dart';
import '../../domain/repositories/forgot_password_repository.dart';
import '../../domain/usecases/request_reset_otp_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../notifier/forgot_password_notifier.dart';
import '../state/forgot_password_state.dart';

/// Composition root for the password-reset feature. Everything depends on
/// abstractions; only this file knows the concrete classes.

final forgotPasswordRemoteDataSourceProvider =
    Provider<ForgotPasswordRemoteDataSource>((ref) {
      return ForgotPasswordRemoteDataSourceImpl(ref.watch(apiClientProvider));
    });

final forgotPasswordRepositoryProvider = Provider<ForgotPasswordRepository>((
  ref,
) {
  return ForgotPasswordRepositoryImpl(
    remoteDataSource: ref.watch(forgotPasswordRemoteDataSourceProvider),
  );
});

final requestResetOtpUseCaseProvider = Provider<RequestResetOtpUseCase>(
  (ref) => RequestResetOtpUseCase(ref.watch(forgotPasswordRepositoryProvider)),
);

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>(
  (ref) => ResetPasswordUseCase(ref.watch(forgotPasswordRepositoryProvider)),
);

final forgotPasswordNotifierProvider =
    NotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>(
      ForgotPasswordNotifier.new,
    );
