import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

/// The authenticated session, shared by splash, logout, and the dashboards.
/// Form state (submitting/error) belongs to the login and register notifiers.
class AuthState {
  const AuthState({
    this.status = AuthStatus.checking,
    this.user,
    this.role,
  });

  final AuthStatus status;

  /// Only available after a login in this session.
  final UserEntity? user;

  /// Role of the active session: from the login response, or restored from
  /// storage on startup when [user] has not been fetched.
  final UserRole? role;

  AuthState copyWith({AuthStatus? status, UserEntity? user, UserRole? role}) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        role: role ?? this.role,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          other.status == status &&
          other.user == user &&
          other.role == role;

  @override
  int get hashCode => Object.hash(status, user, role);
}
