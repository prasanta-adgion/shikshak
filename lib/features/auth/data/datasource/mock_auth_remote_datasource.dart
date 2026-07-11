import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
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
  MockAuthRemoteDataSource(this._storage);

  /// Needed only to reconstruct a dummy profile for a persisted session
  /// (a real backend derives the user from the bearer token instead).
  final SecureStorageService _storage;

  static const _mockAccessToken = 'mock-access-token-shiksha';
  static const _mockRefreshToken = 'mock-refresh-token-shiksha';

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    await Future<void>.delayed(AppConstants.mockNetworkDelay);

    final role = UserRole.tryParse(request.role) ?? UserRole.student;
    final isEmail = request.identifier.contains('@');

    return AuthResponseModel(
      accessToken: _mockAccessToken,
      refreshToken: _mockRefreshToken,
      user: _dummyUser(
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

  @override
  Future<UserModel> fetchProfile() async {
    await Future<void>.delayed(AppConstants.mockNetworkDelay);

    final storedRole = UserRole.tryParse(await _storage.getRole());
    if (storedRole == null) {
      throw const ApiException(
        message: 'Session expired. Please log in again.',
        type: ApiExceptionType.unauthorized,
        statusCode: 401,
      );
    }
    return _dummyUser(role: storedRole);
  }

  UserModel _dummyUser({
    required UserRole role,
    String? email,
    String? mobileNumber,
  }) {
    final isTeacher = role == UserRole.teacher;
    return UserModel(
      id: isTeacher ? 'usr_teacher_001' : 'usr_student_001',
      fullName: isTeacher ? 'Priya Sharma' : 'Aarav Mehta',
      email: email ??
          (isTeacher ? 'priya.sharma@shiksha.app' : 'aarav.mehta@shiksha.app'),
      mobileNumber: mobileNumber ?? (isTeacher ? '9876543210' : '9812345670'),
      role: role.name,
      city: isTeacher ? 'Kolkata' : 'Bengaluru',
      qualification: isTeacher ? 'M.Sc. Mathematics, B.Ed.' : null,
      experience: isTeacher ? '8+ years' : null,
      subjects: isTeacher ? const ['Mathematics', 'Physics'] : null,
      studentClass: isTeacher ? null : 'Class 10',
      preferredSubjects: isTeacher ? null : const ['Mathematics', 'Science'],
    );
  }
}
