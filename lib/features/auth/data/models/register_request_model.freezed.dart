// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegisterRequestModel {

@JsonKey(name: 'full_name') String get fullName; String get email;@JsonKey(name: 'mobile_number') String get mobileNumber; String get password; String get role; String get city;@JsonKey(includeIfNull: false) String? get qualification;@JsonKey(includeIfNull: false) String? get experience;@JsonKey(includeIfNull: false) List<String>? get subjects;@JsonKey(name: 'student_class', includeIfNull: false) String? get studentClass;@JsonKey(name: 'preferred_subjects', includeIfNull: false) List<String>? get preferredSubjects;
/// Create a copy of RegisterRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterRequestModelCopyWith<RegisterRequestModel> get copyWith => _$RegisterRequestModelCopyWithImpl<RegisterRequestModel>(this as RegisterRequestModel, _$identity);

  /// Serializes this RegisterRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterRequestModel&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.password, password) || other.password == password)&&(identical(other.role, role) || other.role == role)&&(identical(other.city, city) || other.city == city)&&(identical(other.qualification, qualification) || other.qualification == qualification)&&(identical(other.experience, experience) || other.experience == experience)&&const DeepCollectionEquality().equals(other.subjects, subjects)&&(identical(other.studentClass, studentClass) || other.studentClass == studentClass)&&const DeepCollectionEquality().equals(other.preferredSubjects, preferredSubjects));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fullName,email,mobileNumber,password,role,city,qualification,experience,const DeepCollectionEquality().hash(subjects),studentClass,const DeepCollectionEquality().hash(preferredSubjects));

@override
String toString() {
  return 'RegisterRequestModel(fullName: $fullName, email: $email, mobileNumber: $mobileNumber, password: $password, role: $role, city: $city, qualification: $qualification, experience: $experience, subjects: $subjects, studentClass: $studentClass, preferredSubjects: $preferredSubjects)';
}


}

/// @nodoc
abstract mixin class $RegisterRequestModelCopyWith<$Res>  {
  factory $RegisterRequestModelCopyWith(RegisterRequestModel value, $Res Function(RegisterRequestModel) _then) = _$RegisterRequestModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'full_name') String fullName, String email,@JsonKey(name: 'mobile_number') String mobileNumber, String password, String role, String city,@JsonKey(includeIfNull: false) String? qualification,@JsonKey(includeIfNull: false) String? experience,@JsonKey(includeIfNull: false) List<String>? subjects,@JsonKey(name: 'student_class', includeIfNull: false) String? studentClass,@JsonKey(name: 'preferred_subjects', includeIfNull: false) List<String>? preferredSubjects
});




}
/// @nodoc
class _$RegisterRequestModelCopyWithImpl<$Res>
    implements $RegisterRequestModelCopyWith<$Res> {
  _$RegisterRequestModelCopyWithImpl(this._self, this._then);

  final RegisterRequestModel _self;
  final $Res Function(RegisterRequestModel) _then;

/// Create a copy of RegisterRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fullName = null,Object? email = null,Object? mobileNumber = null,Object? password = null,Object? role = null,Object? city = null,Object? qualification = freezed,Object? experience = freezed,Object? subjects = freezed,Object? studentClass = freezed,Object? preferredSubjects = freezed,}) {
  return _then(_self.copyWith(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,mobileNumber: null == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,qualification: freezed == qualification ? _self.qualification : qualification // ignore: cast_nullable_to_non_nullable
as String?,experience: freezed == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as String?,subjects: freezed == subjects ? _self.subjects : subjects // ignore: cast_nullable_to_non_nullable
as List<String>?,studentClass: freezed == studentClass ? _self.studentClass : studentClass // ignore: cast_nullable_to_non_nullable
as String?,preferredSubjects: freezed == preferredSubjects ? _self.preferredSubjects : preferredSubjects // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterRequestModel].
extension RegisterRequestModelPatterns on RegisterRequestModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterRequestModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _RegisterRequestModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterRequestModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'full_name')  String fullName,  String email, @JsonKey(name: 'mobile_number')  String mobileNumber,  String password,  String role,  String city, @JsonKey(includeIfNull: false)  String? qualification, @JsonKey(includeIfNull: false)  String? experience, @JsonKey(includeIfNull: false)  List<String>? subjects, @JsonKey(name: 'student_class', includeIfNull: false)  String? studentClass, @JsonKey(name: 'preferred_subjects', includeIfNull: false)  List<String>? preferredSubjects)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterRequestModel() when $default != null:
return $default(_that.fullName,_that.email,_that.mobileNumber,_that.password,_that.role,_that.city,_that.qualification,_that.experience,_that.subjects,_that.studentClass,_that.preferredSubjects);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'full_name')  String fullName,  String email, @JsonKey(name: 'mobile_number')  String mobileNumber,  String password,  String role,  String city, @JsonKey(includeIfNull: false)  String? qualification, @JsonKey(includeIfNull: false)  String? experience, @JsonKey(includeIfNull: false)  List<String>? subjects, @JsonKey(name: 'student_class', includeIfNull: false)  String? studentClass, @JsonKey(name: 'preferred_subjects', includeIfNull: false)  List<String>? preferredSubjects)  $default,) {final _that = this;
switch (_that) {
case _RegisterRequestModel():
return $default(_that.fullName,_that.email,_that.mobileNumber,_that.password,_that.role,_that.city,_that.qualification,_that.experience,_that.subjects,_that.studentClass,_that.preferredSubjects);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'full_name')  String fullName,  String email, @JsonKey(name: 'mobile_number')  String mobileNumber,  String password,  String role,  String city, @JsonKey(includeIfNull: false)  String? qualification, @JsonKey(includeIfNull: false)  String? experience, @JsonKey(includeIfNull: false)  List<String>? subjects, @JsonKey(name: 'student_class', includeIfNull: false)  String? studentClass, @JsonKey(name: 'preferred_subjects', includeIfNull: false)  List<String>? preferredSubjects)?  $default,) {final _that = this;
switch (_that) {
case _RegisterRequestModel() when $default != null:
return $default(_that.fullName,_that.email,_that.mobileNumber,_that.password,_that.role,_that.city,_that.qualification,_that.experience,_that.subjects,_that.studentClass,_that.preferredSubjects);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegisterRequestModel implements RegisterRequestModel {
  const _RegisterRequestModel({@JsonKey(name: 'full_name') required this.fullName, required this.email, @JsonKey(name: 'mobile_number') required this.mobileNumber, required this.password, required this.role, required this.city, @JsonKey(includeIfNull: false) this.qualification, @JsonKey(includeIfNull: false) this.experience, @JsonKey(includeIfNull: false) final  List<String>? subjects, @JsonKey(name: 'student_class', includeIfNull: false) this.studentClass, @JsonKey(name: 'preferred_subjects', includeIfNull: false) final  List<String>? preferredSubjects}): _subjects = subjects,_preferredSubjects = preferredSubjects;
  factory _RegisterRequestModel.fromJson(Map<String, dynamic> json) => _$RegisterRequestModelFromJson(json);

@override@JsonKey(name: 'full_name') final  String fullName;
@override final  String email;
@override@JsonKey(name: 'mobile_number') final  String mobileNumber;
@override final  String password;
@override final  String role;
@override final  String city;
@override@JsonKey(includeIfNull: false) final  String? qualification;
@override@JsonKey(includeIfNull: false) final  String? experience;
 final  List<String>? _subjects;
@override@JsonKey(includeIfNull: false) List<String>? get subjects {
  final value = _subjects;
  if (value == null) return null;
  if (_subjects is EqualUnmodifiableListView) return _subjects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'student_class', includeIfNull: false) final  String? studentClass;
 final  List<String>? _preferredSubjects;
@override@JsonKey(name: 'preferred_subjects', includeIfNull: false) List<String>? get preferredSubjects {
  final value = _preferredSubjects;
  if (value == null) return null;
  if (_preferredSubjects is EqualUnmodifiableListView) return _preferredSubjects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of RegisterRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterRequestModelCopyWith<_RegisterRequestModel> get copyWith => __$RegisterRequestModelCopyWithImpl<_RegisterRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterRequestModel&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.password, password) || other.password == password)&&(identical(other.role, role) || other.role == role)&&(identical(other.city, city) || other.city == city)&&(identical(other.qualification, qualification) || other.qualification == qualification)&&(identical(other.experience, experience) || other.experience == experience)&&const DeepCollectionEquality().equals(other._subjects, _subjects)&&(identical(other.studentClass, studentClass) || other.studentClass == studentClass)&&const DeepCollectionEquality().equals(other._preferredSubjects, _preferredSubjects));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fullName,email,mobileNumber,password,role,city,qualification,experience,const DeepCollectionEquality().hash(_subjects),studentClass,const DeepCollectionEquality().hash(_preferredSubjects));

@override
String toString() {
  return 'RegisterRequestModel(fullName: $fullName, email: $email, mobileNumber: $mobileNumber, password: $password, role: $role, city: $city, qualification: $qualification, experience: $experience, subjects: $subjects, studentClass: $studentClass, preferredSubjects: $preferredSubjects)';
}


}

/// @nodoc
abstract mixin class _$RegisterRequestModelCopyWith<$Res> implements $RegisterRequestModelCopyWith<$Res> {
  factory _$RegisterRequestModelCopyWith(_RegisterRequestModel value, $Res Function(_RegisterRequestModel) _then) = __$RegisterRequestModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'full_name') String fullName, String email,@JsonKey(name: 'mobile_number') String mobileNumber, String password, String role, String city,@JsonKey(includeIfNull: false) String? qualification,@JsonKey(includeIfNull: false) String? experience,@JsonKey(includeIfNull: false) List<String>? subjects,@JsonKey(name: 'student_class', includeIfNull: false) String? studentClass,@JsonKey(name: 'preferred_subjects', includeIfNull: false) List<String>? preferredSubjects
});




}
/// @nodoc
class __$RegisterRequestModelCopyWithImpl<$Res>
    implements _$RegisterRequestModelCopyWith<$Res> {
  __$RegisterRequestModelCopyWithImpl(this._self, this._then);

  final _RegisterRequestModel _self;
  final $Res Function(_RegisterRequestModel) _then;

/// Create a copy of RegisterRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fullName = null,Object? email = null,Object? mobileNumber = null,Object? password = null,Object? role = null,Object? city = null,Object? qualification = freezed,Object? experience = freezed,Object? subjects = freezed,Object? studentClass = freezed,Object? preferredSubjects = freezed,}) {
  return _then(_RegisterRequestModel(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,mobileNumber: null == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,qualification: freezed == qualification ? _self.qualification : qualification // ignore: cast_nullable_to_non_nullable
as String?,experience: freezed == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as String?,subjects: freezed == subjects ? _self._subjects : subjects // ignore: cast_nullable_to_non_nullable
as List<String>?,studentClass: freezed == studentClass ? _self.studentClass : studentClass // ignore: cast_nullable_to_non_nullable
as String?,preferredSubjects: freezed == preferredSubjects ? _self._preferredSubjects : preferredSubjects // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
