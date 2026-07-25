import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';
import '../models/user_model.dart';

extension UserModelMapper on UserModel {
  UserEntity toEntity() => UserEntity(
    id: id,
    fullName: fullName,
    email: email,
    mobileNumber: mobileNumber,
    role: UserRole.tryParse(role) ?? UserRole.student,
  );
}
