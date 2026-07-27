import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;

  final UserRole? role;

  const AuthState({this.status = AuthStatus.checking, this.user, this.role});

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
