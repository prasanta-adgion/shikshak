// Field readers shared by the calendar models, so a slot and an occurrence
// interpret the same wire field the same way.

/// Keeps only non-blank strings; anything that is not a list reads as empty.
List<String> readStringList(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<String>()
      .where((item) => item.trim().isNotEmpty)
      .toList(growable: false);
}

/// Accepts both the date-only form the schedule sends (`2026-08-05`) and a
/// full timestamp, in case the endpoint switches later. The time is dropped:
/// these are calendar dates, and a UTC conversion could shift one by a day.
DateTime? readDate(String? value) {
  if (value == null || value.isEmpty) return null;
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return null;
  return DateTime(parsed.year, parsed.month, parsed.day);
}

/// A class with no usable title still has to render as something.
String readTitle(String? value) {
  final title = value?.trim();
  return title == null || title.isEmpty ? 'Class' : title;
}
