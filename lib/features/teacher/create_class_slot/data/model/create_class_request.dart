/// The `POST /api/v1/user/teacher/class-slot` body.
///
/// Every key is sent on every request. The fields the form leaves out are held
/// as null here and flattened to `''` by [toJson] — the same shape the profile
/// sections send, via `RequestBody.nullsAsEmptyStrings`.
class CreateClassRequest {
  final String title;
  final String? description;
  final List<String> subjects;
  final List<String> classes;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String validFrom;
  final String? validUntil;
  final String mode;
  final String? venueName;
  final String? venueAddress;

  const CreateClassRequest({
    required this.title,
    required this.subjects,
    required this.classes,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.validFrom,
    required this.mode,
    this.description,
    this.validUntil,
    this.venueName,
    this.venueAddress,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description ?? '',
    'subjects': subjects,
    'classes': classes,
    'dayOfWeek': dayOfWeek,
    'startTime': startTime,
    'endTime': endTime,
    'validFrom': validFrom,
    'validUntil': validUntil ?? '',
    'mode': mode,
    'venueName': venueName ?? '',
    'venueAddress': venueAddress ?? '',
  };
}
