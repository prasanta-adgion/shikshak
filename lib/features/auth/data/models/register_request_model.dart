import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_request_model.freezed.dart';
part 'register_request_model.g.dart';

/// Body sent to the register endpoint. Role-specific fields are optional
/// and omitted from JSON when null.
@freezed
abstract class RegisterRequestModel with _$RegisterRequestModel {
  const factory RegisterRequestModel({
    @JsonKey(name: 'full_name') required String fullName,
    required String email,
    @JsonKey(name: 'mobile_number') required String mobileNumber,
    required String password,
    required String role,
    required String city,
    @JsonKey(includeIfNull: false) String? qualification,
    @JsonKey(includeIfNull: false) String? experience,
    @JsonKey(includeIfNull: false) List<String>? subjects,
    @JsonKey(name: 'student_class', includeIfNull: false) String? studentClass,
    @JsonKey(name: 'preferred_subjects', includeIfNull: false)
    List<String>? preferredSubjects,
  }) = _RegisterRequestModel;

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestModelFromJson(json);
}
