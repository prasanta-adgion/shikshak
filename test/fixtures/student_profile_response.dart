/// A real `GET /api/v1/user/student/profile` payload for a freshly signed-up
/// student: the auth row is filled in, the profile row is almost entirely
/// empty. This is the state the screen has to look good in.
Map<String, dynamic> studentProfileResponseJson() => {
  'success': true,
  'code': 200,
  'message': 'Profile fetched successfully',
  'data': <String, dynamic>{
    'user': <String, dynamic>{
      'id': 'd070abdd-99fe-468b-9431-ce5a91f34818',
      'name': 'Seema',
      'email': '9991seema@gmail.com',
      'role': 'student',
      'verified': false,
      'phoneNo': '9230632745',
      'isLocked': false,
      'isDeleted': false,
      'createdAt': '2026-08-17T08:24:49.680Z',
      'updatedAt': null,
    },
    'profile': <String, dynamic>{
      'id': '2b4dd40a-c2e3-46ca-8be0-f311df91ed7c',
      'userAuthId': 'd070abdd-99fe-468b-9431-ce5a91f34818',
      'avatarUrl': null,
      'coverImageUrl': null,
      'bio': null,
      'altPhoneNo': null,
      'dateOfBirth': null,
      'gender': null,
      'language': 'en',
      'notificationPrefs': <String, dynamic>{},
      'socialLinks': <String, dynamic>{},
      'isProfileComplete': false,
      'lastSeenAt': null,
      'createdAt': '2026-08-17T08:26:50.151Z',
      'updatedAt': '2026-08-17T08:26:50.151Z',
    },
  },
};

/// The same student once every optional column has been filled in — the other
/// end of the range the screen has to cover.
Map<String, dynamic> completeStudentProfileResponseJson() => {
  'success': true,
  'code': 200,
  'message': 'Profile fetched successfully',
  'data': <String, dynamic>{
    'user': <String, dynamic>{
      'id': 'd070abdd-99fe-468b-9431-ce5a91f34818',
      'name': 'Seema Chatterjee',
      'email': '9991seema@gmail.com',
      'role': 'student',
      'verified': true,
      'phoneNo': '9230632745',
      'createdAt': '2026-08-17T08:24:49.680Z',
      'updatedAt': '2026-08-18T09:00:00.000Z',
    },
    'profile': <String, dynamic>{
      'id': '2b4dd40a-c2e3-46ca-8be0-f311df91ed7c',
      'avatarUrl': 'https://example.com/avatar.png',
      'coverImageUrl': 'https://example.com/cover.png',
      'bio': 'Class 11 science student, preparing for JEE.',
      'altPhoneNo': '9230632746',
      'dateOfBirth': '2005-04-12T00:00:00.000Z',
      'gender': 'female',
      'language': 'bn',
      'notificationPrefs': <String, dynamic>{
        'emailUpdates': true,
        'smsAlerts': false,
        // Not a switch, so the screen has nothing to draw for it.
        'digest': 'weekly',
      },
      'socialLinks': <String, dynamic>{
        'linkedin': 'https://www.linkedin.com/in/seema',
        'website': 'https://seema.dev/',
        // No URL behind it — dropped rather than shown as an empty row.
        'twitter': '',
      },
      'isProfileComplete': true,
      'lastSeenAt': '2026-08-18T09:00:00.000Z',
      'createdAt': '2026-08-17T08:26:50.151Z',
      'updatedAt': '2026-08-18T09:00:00.000Z',
    },
  },
};
