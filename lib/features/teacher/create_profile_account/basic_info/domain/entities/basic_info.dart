import 'gender.dart';

class BasicInfo {
  const BasicInfo({
    this.profilePhotoUrl,
    this.localPhotoPath,
    this.gender,
    this.dateOfBirth,
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.postalCode = '',
  });

  /// Remote URL, set once the picked photo has been uploaded.
  final String? profilePhotoUrl;

  /// Path of the file chosen on device, held until that upload happens.
  final String? localPhotoPath;

  final Gender? gender;
  final DateTime? dateOfBirth;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String country;
  final String postalCode;

  BasicInfo copyWith({
    String? profilePhotoUrl,
    String? localPhotoPath,
    Gender? gender,
    DateTime? dateOfBirth,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    bool clearProfilePhotoUrl = false,
  }) => BasicInfo(
    // A freshly picked photo has to drop the old URL, or the upload is
    // skipped and the previous image is sent again.
    profilePhotoUrl: clearProfilePhotoUrl
        ? null
        : profilePhotoUrl ?? this.profilePhotoUrl,
    localPhotoPath: localPhotoPath ?? this.localPhotoPath,
    gender: gender ?? this.gender,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    addressLine1: addressLine1 ?? this.addressLine1,
    addressLine2: addressLine2 ?? this.addressLine2,
    city: city ?? this.city,
    state: state ?? this.state,
    country: country ?? this.country,
    postalCode: postalCode ?? this.postalCode,
  );
}
