/// The two account types supported by Shikshak.
enum UserRole {
  teacher,
  student;

  String get label => switch (this) {
    UserRole.teacher => 'Teacher',
    UserRole.student => 'Student',
  };

  /// Parses a persisted/route value; returns `null` when unrecognised so
  /// callers decide the fallback.
  static UserRole? tryParse(String? value) => switch (value?.toLowerCase()) {
    'teacher' => UserRole.teacher,
    'student' => UserRole.student,
    _ => null,
  };
}
