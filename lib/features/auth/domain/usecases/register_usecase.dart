import '../../../../core/network/api_result.dart';
import '../entities/user_entity.dart';
import '../entities/user_role.dart';
import '../repositories/auth_repository.dart';

/// Input for [RegisterUseCase]. Role-specific fields are nullable and only
/// populated for the matching [role].
class RegisterParams {
  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.password,
    required this.role,
    required this.city,
    this.qualification,
    this.experience,
    this.subjects = const [],
    this.studentClass,
    this.preferredSubjects = const [],
  });

  final String fullName;
  final String email;
  final String mobileNumber;
  final String password;
  final UserRole role;
  final String city;

  // Teacher-specific
  final String? qualification;
  final String? experience;
  final List<String> subjects;

  // Student-specific
  final String? studentClass;
  final List<String> preferredSubjects;
}

/// Creates a new teacher or student account.
class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<UserEntity>> call(RegisterParams params) =>
      _repository.register(params);
}
