/// Helpers for shaping a request body before it goes on the wire.
abstract final class RequestBody {
  static Map<String, dynamic> nullsAsEmptyStrings(Map<String, dynamic> body) {
    return {
      for (final MapEntry(:key, :value) in body.entries) key: value ?? '',
    };
  }
}
