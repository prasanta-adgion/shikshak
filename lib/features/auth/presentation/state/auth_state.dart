import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

/// Session state shared by login, splash, logout, and authenticated screens.
class AuthState {
  const AuthState({
    this.status = AuthStatus.checking,
    this.isSubmitting = false,
    this.user,
    this.selectedRole,
    this.errorMessage,
  });

  final AuthStatus status;
  final bool isSubmitting;
  final UserEntity? user;
  final UserRole? selectedRole;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  static const _unset = Object();

  AuthState copyWith({
    AuthStatus? status,
    bool? isSubmitting,
    Object? user = _unset,
    Object? selectedRole = _unset,
    Object? errorMessage = _unset,
  }) => AuthState(
    status: status ?? this.status,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    user: identical(user, _unset) ? this.user : user as UserEntity?,
    selectedRole: identical(selectedRole, _unset)
        ? this.selectedRole
        : selectedRole as UserRole?,
    errorMessage: identical(errorMessage, _unset)
        ? this.errorMessage
        : errorMessage as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          other.status == status &&
          other.isSubmitting == isSubmitting &&
          other.user == user &&
          other.selectedRole == selectedRole &&
          other.errorMessage == errorMessage;

  @override
  int get hashCode =>
      Object.hash(status, isSubmitting, user, selectedRole, errorMessage);
}
