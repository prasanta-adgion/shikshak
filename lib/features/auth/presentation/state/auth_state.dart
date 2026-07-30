import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;

  final UserRole? role;

  /// Mobile number typed on the register form. The signup and login responses
  /// do not carry a phone, so it is remembered here and merged into [user]
  /// when the session opens.
  final String? signupMobileNumber;

  const AuthState({
    this.status = AuthStatus.checking,
    this.user,
    this.role,
    this.signupMobileNumber,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    UserRole? role,
    String? signupMobileNumber,
  }) => AuthState(
    status: status ?? this.status,
    user: user ?? this.user,
    role: role ?? this.role,
    signupMobileNumber: signupMobileNumber ?? this.signupMobileNumber,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          other.status == status &&
          other.user == user &&
          other.role == role &&
          other.signupMobileNumber == signupMobileNumber;

  @override
  int get hashCode => Object.hash(status, user, role, signupMobileNumber);
}
