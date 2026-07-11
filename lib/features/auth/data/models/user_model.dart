import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Transport model for a user as returned by the API.
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    required String email,
    @JsonKey(name: 'mobile_number') required String mobileNumber,
    required String role,
    String? city,
    String? qualification,
    String? experience,
    List<String>? subjects,
    @JsonKey(name: 'student_class') String? studentClass,
    @JsonKey(name: 'preferred_subjects') List<String>? preferredSubjects,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
