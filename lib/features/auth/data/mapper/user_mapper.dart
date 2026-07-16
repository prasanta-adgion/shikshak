import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';
import '../models/user_model.dart';

/// Maps transport models to domain entities.
///
/// Keeps JSON quirks (nullable lists, string roles) out of the domain.
extension UserModelMapper on UserModel {
  UserEntity toEntity() => UserEntity(
    id: id,
    fullName: fullName,
    email: email,
    mobileNumber: mobileNumber,
    role: UserRole.tryParse(role) ?? UserRole.student,
    city: city,
    qualification: qualification,
    experience: experience,
    subjects: subjects ?? const [],
    studentClass: studentClass,
    preferredSubjects: preferredSubjects ?? const [],
  );
}
