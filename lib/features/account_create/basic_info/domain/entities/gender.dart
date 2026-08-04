enum Gender {
  male('Male', 'male'),
  female('Female', 'female'),
  other('Other', 'other');

  const Gender(this.label, this.wireValue);

  final String label;
  final String wireValue;

  /// Reads back what [wireValue] wrote. Anything unrecognised — including the
  /// empty string a never-filled profile carries — means "not answered".
  static Gender? fromWire(String? value) {
    if (value == null || value.isEmpty) return null;

    final wire = value.toLowerCase();
    for (final gender in values) {
      if (gender.wireValue == wire) return gender;
    }
    return null;
  }
}
