// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

 String get id;@JsonKey(name: 'full_name') String get fullName; String get email;@JsonKey(name: 'mobile_number') String get mobileNumber; String get role; String? get city; String? get qualification; String? get experience; List<String>? get subjects;@JsonKey(name: 'student_class') String? get studentClass;@JsonKey(name: 'preferred_subjects') List<String>? get preferredSubjects;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.role, role) || other.role == role)&&(identical(other.city, city) || other.city == city)&&(identical(other.qualification, qualification) || other.qualification == qualification)&&(identical(other.experience, experience) || other.experience == experience)&&const DeepCollectionEquality().equals(other.subjects, subjects)&&(identical(other.studentClass, studentClass) || other.studentClass == studentClass)&&const DeepCollectionEquality().equals(other.preferredSubjects, preferredSubjects));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,email,mobileNumber,role,city,qualification,experience,const DeepCollectionEquality().hash(subjects),studentClass,const DeepCollectionEquality().hash(preferredSubjects));

@override
String toString() {
  return 'UserModel(id: $id, fullName: $fullName, email: $email, mobileNumber: $mobileNumber, role: $role, city: $city, qualification: $qualification, experience: $experience, subjects: $subjects, studentClass: $studentClass, preferredSubjects: $preferredSubjects)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'full_name') String fullName, String email,@JsonKey(name: 'mobile_number') String mobileNumber, String role, String? city, String? qualification, String? experience, List<String>? subjects,@JsonKey(name: 'student_class') String? studentClass,@JsonKey(name: 'preferred_subjects') List<String>? preferredSubjects
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? email = null,Object? mobileNumber = null,Object? role = null,Object? city = freezed,Object? qualification = freezed,Object? experience = freezed,Object? subjects = freezed,Object? studentClass = freezed,Object? preferredSubjects = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,mobileNumber: null == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,qualification: freezed == qualification ? _self.qualification : qualification // ignore: cast_nullable_to_non_nullable
as String?,experience: freezed == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as String?,subjects: freezed == subjects ? _self.subjects : subjects // ignore: cast_nullable_to_non_nullable
as List<String>?,studentClass: freezed == studentClass ? _self.studentClass : studentClass // ignore: cast_nullable_to_non_nullable
as String?,preferredSubjects: freezed == preferredSubjects ? _self.preferredSubjects : preferredSubjects // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'full_name')  String fullName,  String email, @JsonKey(name: 'mobile_number')  String mobileNumber,  String role,  String? city,  String? qualification,  String? experience,  List<String>? subjects, @JsonKey(name: 'student_class')  String? studentClass, @JsonKey(name: 'preferred_subjects')  List<String>? preferredSubjects)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.mobileNumber,_that.role,_that.city,_that.qualification,_that.experience,_that.subjects,_that.studentClass,_that.preferredSubjects);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'full_name')  String fullName,  String email, @JsonKey(name: 'mobile_number')  String mobileNumber,  String role,  String? city,  String? qualification,  String? experience,  List<String>? subjects, @JsonKey(name: 'student_class')  String? studentClass, @JsonKey(name: 'preferred_subjects')  List<String>? preferredSubjects)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.id,_that.fullName,_that.email,_that.mobileNumber,_that.role,_that.city,_that.qualification,_that.experience,_that.subjects,_that.studentClass,_that.preferredSubjects);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'full_name')  String fullName,  String email, @JsonKey(name: 'mobile_number')  String mobileNumber,  String role,  String? city,  String? qualification,  String? experience,  List<String>? subjects, @JsonKey(name: 'student_class')  String? studentClass, @JsonKey(name: 'preferred_subjects')  List<String>? preferredSubjects)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.mobileNumber,_that.role,_that.city,_that.qualification,_that.experience,_that.subjects,_that.studentClass,_that.preferredSubjects);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel implements UserModel {
  const _UserModel({required this.id, @JsonKey(name: 'full_name') required this.fullName, required this.email, @JsonKey(name: 'mobile_number') required this.mobileNumber, required this.role, this.city, this.qualification, this.experience, final  List<String>? subjects, @JsonKey(name: 'student_class') this.studentClass, @JsonKey(name: 'preferred_subjects') final  List<String>? preferredSubjects}): _subjects = subjects,_preferredSubjects = preferredSubjects;
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'full_name') final  String fullName;
@override final  String email;
@override@JsonKey(name: 'mobile_number') final  String mobileNumber;
@override final  String role;
@override final  String? city;
@override final  String? qualification;
@override final  String? experience;
 final  List<String>? _subjects;
@override List<String>? get subjects {
  final value = _subjects;
  if (value == null) return null;
  if (_subjects is EqualUnmodifiableListView) return _subjects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'student_class') final  String? studentClass;
 final  List<String>? _preferredSubjects;
@override@JsonKey(name: 'preferred_subjects') List<String>? get preferredSubjects {
  final value = _preferredSubjects;
  if (value == null) return null;
  if (_preferredSubjects is EqualUnmodifiableListView) return _preferredSubjects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.role, role) || other.role == role)&&(identical(other.city, city) || other.city == city)&&(identical(other.qualification, qualification) || other.qualification == qualification)&&(identical(other.experience, experience) || other.experience == experience)&&const DeepCollectionEquality().equals(other._subjects, _subjects)&&(identical(other.studentClass, studentClass) || other.studentClass == studentClass)&&const DeepCollectionEquality().equals(other._preferredSubjects, _preferredSubjects));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,email,mobileNumber,role,city,qualification,experience,const DeepCollectionEquality().hash(_subjects),studentClass,const DeepCollectionEquality().hash(_preferredSubjects));

@override
String toString() {
  return 'UserModel(id: $id, fullName: $fullName, email: $email, mobileNumber: $mobileNumber, role: $role, city: $city, qualification: $qualification, experience: $experience, subjects: $subjects, studentClass: $studentClass, preferredSubjects: $preferredSubjects)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'full_name') String fullName, String email,@JsonKey(name: 'mobile_number') String mobileNumber, String role, String? city, String? qualification, String? experience, List<String>? subjects,@JsonKey(name: 'student_class') String? studentClass,@JsonKey(name: 'preferred_subjects') List<String>? preferredSubjects
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? email = null,Object? mobileNumber = null,Object? role = null,Object? city = freezed,Object? qualification = freezed,Object? experience = freezed,Object? subjects = freezed,Object? studentClass = freezed,Object? preferredSubjects = freezed,}) {
  return _then(_UserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,mobileNumber: null == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,qualification: freezed == qualification ? _self.qualification : qualification // ignore: cast_nullable_to_non_nullable
as String?,experience: freezed == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as String?,subjects: freezed == subjects ? _self._subjects : subjects // ignore: cast_nullable_to_non_nullable
as List<String>?,studentClass: freezed == studentClass ? _self.studentClass : studentClass // ignore: cast_nullable_to_non_nullable
as String?,preferredSubjects: freezed == preferredSubjects ? _self._preferredSubjects : preferredSubjects // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
