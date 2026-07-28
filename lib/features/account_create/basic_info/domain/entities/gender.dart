enum Gender {
  male('Male', 'male'),
  female('Female', 'female'),
  other('Other', 'other');

  const Gender(this.label, this.wireValue);

  final String label;
  final String wireValue;
}
