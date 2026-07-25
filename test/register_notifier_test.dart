import 'dart:async';

import 'package:Shikshak/core/network/api_exception.dart';
import 'package:Shikshak/core/network/api_result.dart';
import 'package:Shikshak/features/auth/domain/entities/user_entity.dart';
import 'package:Shikshak/features/auth/domain/entities/user_role.dart';
import 'package:Shikshak/features/auth/domain/repositories/auth_repository.dart';
import 'package:Shikshak/features/auth/domain/usecases/login_usecase.dart';
import 'package:Shikshak/features/auth/domain/usecases/register_usecase.dart';
import 'package:Shikshak/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const params = RegisterParams(
    fullName: 'Prasanta',
    email: 'prasanta@example.com',
    mobileNumber: '9876543218',
    password: 'Password123',
    role: UserRole.teacher,
  );

  test('register notifier exposes loading and then success', () async {
    final completer = Completer<ApiResult<void>>();
    final repository = _FakeAuthRepository(() => completer.future);
    final container = ProviderContainer(
      overrides: [
        registerUseCaseProvider.overrideWithValue(RegisterUseCase(repository)),
      ],
    );
    addTearDown(container.dispose);

    final future = container
        .read(registerNotifierProvider.notifier)
        .register(params);

    expect(container.read(registerNotifierProvider), isA<AsyncLoading<void>>());

    completer.complete(const ApiResult.success(null));
    expect(await future, isTrue);
    expect(container.read(registerNotifierProvider), isA<AsyncData<void>>());
  });

  test('register notifier exposes the repository failure', () async {
    const exception = ApiException(
      message: 'Email already registered',
      type: ApiExceptionType.badRequest,
    );
    final repository = _FakeAuthRepository(
      () async => const ApiResult.failure(exception),
    );
    final container = ProviderContainer(
      overrides: [
        registerUseCaseProvider.overrideWithValue(RegisterUseCase(repository)),
      ],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(registerNotifierProvider.notifier)
        .register(params);

    expect(succeeded, isFalse);
    final state = container.read(registerNotifierProvider);
    expect(state, isA<AsyncError<void>>());
    expect(state.error, same(exception));
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this.onRegister);

  final Future<ApiResult<void>> Function() onRegister;

  @override
  Future<ApiResult<void>> register({
    required String fullName,
    required String email,
    required String mobileNumber,
    required String password,
    required UserRole role,
  }) => onRegister();

  @override
  Future<UserRole?> getPersistedRole() async => null;

  @override
  Future<bool> hasValidSession() async => false;

  @override
  Future<ApiResult<UserEntity>> login(LoginParams params) =>
      throw UnimplementedError();

  @override
  Future<void> logout() async {}
}
