/// Transport model for a user as returned by the API.
class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String mobileNumber;
  final String role;
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    fullName: json['full_name'] as String,
    email: json['email'] as String,
    mobileNumber: json['mobile_number'] as String,
    role: json['role'] as String,
  );
}
