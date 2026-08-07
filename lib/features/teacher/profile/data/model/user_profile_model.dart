import 'package:Shikshak/features/auth/domain/entities/user_entity.dart';
import 'package:Shikshak/features/auth/domain/entities/user_role.dart';
import 'package:equatable/equatable.dart';

class ProfileUserModel extends Equatable {
  const ProfileUserModel({
    this.id,
    this.name,
    this.email,
    this.role,
    this.verified,
    this.phoneNo,
    this.userProfileImageUrl,
  });

  final String? id;
  final String? name;
  final String? email;
  final String? role;
  final bool? verified;
  final String? phoneNo;
  final String? userProfileImageUrl;

  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserModel(
      id: json['id'] as String?,
      // `fullName` is what the auth endpoints return for the same person.
      name: json['name'] as String? ?? json['fullName'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      verified: json['verified'] as bool?,
      phoneNo: json['phoneNo'] as String? ?? json['mobileNumber'] as String?,
      userProfileImageUrl: json['avatarUrl'] as String?,
    );
  }

  UserEntity toEntity() => UserEntity(
    id: id ?? '',
    fullName: name ?? '',
    email: email ?? '',
    mobileNumber: phoneNo,
    avatarUrl: userProfileImageUrl,
    role: UserRole.tryParse(role) ?? UserRole.teacher,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    verified,
    phoneNo,
    userProfileImageUrl,
  ];
}
