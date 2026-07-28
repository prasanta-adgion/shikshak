enum ProfileStep {
  basicInfo(
    shortLabel: 'Basic Info',
    title: 'Basic Information',
    subtitle: "Let's start with your basic details",
  ),
  aboutYou(
    shortLabel: 'About You',
    title: 'About You',
    subtitle: 'Tell students who you are and how you teach',
  ),
  experience(
    shortLabel: 'Experience',
    title: 'Teaching Experience',
    subtitle: 'Tell us about your teaching background',
  ),
  education(
    shortLabel: 'Education',
    title: 'Education Details',
    subtitle: 'Add your highest qualification',
  ),
  documents(
    shortLabel: 'Documents',
    title: 'Upload Document',
    subtitle: 'Upload a supporting document',
  );

  const ProfileStep({
    required this.shortLabel,
    required this.title,
    required this.subtitle,
  });

  /// Caption under the timeline dot.
  final String shortLabel;

  /// Heading at the top of the step card.
  final String title;
  final String subtitle;

  bool get isFirst => index == 0;

  bool get isLast => index == values.length - 1;

  /// Human-facing position, i.e. "Step 3 of 5".
  int get number => index + 1;

  /// Label on the wizard's primary action for this step.
  String get primaryLabel => isLast ? 'Finish' : 'Continue';

  static int get count => values.length;
}
