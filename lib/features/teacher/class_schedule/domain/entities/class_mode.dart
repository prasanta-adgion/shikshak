/// How a class is delivered.
enum ClassMode {
  offline(wire: 'offline', label: 'In person'),
  online(wire: 'online', label: 'Online'),
  hybrid(wire: 'hybrid', label: 'Hybrid');

  const ClassMode({required this.wire, required this.label});

  final String wire;
  final String label;

  /// Null for an unrecognised value, so the card omits the badge rather than
  /// claiming a mode the server never sent.
  static ClassMode? tryParse(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    for (final mode in values) {
      if (mode.wire == normalized) return mode;
    }
    return null;
  }

  /// Only these two put the student and teacher in the same room, so only
  /// these two make the venue worth showing.
  bool get hasVenue => this == offline || this == hybrid;
}
