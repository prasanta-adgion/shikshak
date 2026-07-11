/// View model for a tutor shown on the student dashboard. Populated with
/// static data for now; will be built from the discovery API once it exists.
class TutorInfo {
  const TutorInfo({
    required this.name,
    required this.subject,
    required this.qualification,
    required this.rating,
    required this.reviews,
    required this.experience,
    required this.feePerHour,
  });

  final String name;
  final String subject;
  final String qualification;
  final double rating;
  final int reviews;
  final String experience;
  final int feePerHour;
}
