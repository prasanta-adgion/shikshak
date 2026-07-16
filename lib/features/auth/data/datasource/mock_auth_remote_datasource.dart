import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/user_role.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

/// In-memory stand-in for the real API, used until the backend exists.
///
/// * Accepts any well-formed credentials.
/// * Simulates realistic network latency.
/// * Persists nothing itself — the repository stores tokens exactly as it
///   would with the real data source, so swapping to
///   [AuthRemoteDataSourceImpl] requires zero changes elsewhere.
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  MockAuthRemoteDataSource();

  static const _mockAccessToken = 'mock-access-token-Shikshak';
  static const _mockRefreshToken = 'mock-refresh-token-Shikshak';

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    await Future<void>.delayed(AppConstants.mockNetworkDelay);

    final role = UserRole.tryParse(request.role) ?? UserRole.student;
    final isEmail = request.identifier.contains('@');

    return AuthResponseModel(
      accessToken: _mockAccessToken,
      refreshToken: _mockRefreshToken,
      user: _placeholderUser(
        role: role,
        email: isEmail ? request.identifier : null,
        mobileNumber: isEmail ? null : request.identifier,
      ),
    );
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    await Future<void>.delayed(AppConstants.mockNetworkDelay);

    return AuthResponseModel(
      accessToken: _mockAccessToken,
      refreshToken: _mockRefreshToken,
      user: UserModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        fullName: request.fullName,
        email: request.email,
        mobileNumber: request.mobileNumber,
        role: request.role,
        city: request.city,
        qualification: request.qualification,
        experience: request.experience,
        subjects: request.subjects,
        studentClass: request.studentClass,
        preferredSubjects: request.preferredSubjects,
      ),
    );
  }

  /// Minimal placeholder profile; the real API returns the actual user.
  UserModel _placeholderUser({
    required UserRole role,
    String? email,
    String? mobileNumber,
  }) {
    final isTeacher = role == UserRole.teacher;
    return UserModel(
      id: isTeacher ? 'usr_teacher' : 'usr_student',
      fullName: isTeacher ? 'Teacher' : 'Student',
      email: email ?? 'user@example.com',
      mobileNumber: mobileNumber ?? '0000000000',
      role: role.name,
    );
  }
}
