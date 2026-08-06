import 'package:flutter/material.dart';

import '../../../class_schedule/domain/entities/class_mode.dart';
import '../../../class_schedule/domain/entities/schedule_day.dart';

/// Holds every field of the create-class form.
///
/// A plain controller rather than a Riverpod notifier: none of this outlives
/// the screen, and the form repaints one field at a time through the
/// [ValueNotifier]s below instead of rebuilding whole.
///
/// The enums come from `class_schedule` on purpose — the form collects exactly
/// what a `ClassSlot` is made of, so when the create endpoint lands the mapping
/// is a constructor call rather than a translation.
class ClassSlotFormController {
  ClassSlotFormController();

  final formKey = GlobalKey<FormState>();

  final title = TextEditingController();
  final description = TextEditingController();
  final venueName = TextEditingController();
  final venueAddress = TextEditingController();

  final subjects = ValueNotifier<List<String>>(const []);
  final classes = ValueNotifier<List<String>>(const []);

  final day = ValueNotifier<ScheduleDay?>(null);
  final startTime = ValueNotifier<TimeOfDay?>(null);
  final endTime = ValueNotifier<TimeOfDay?>(null);

  /// `validFrom` — the first date the class runs.
  final validFrom = ValueNotifier<DateTime?>(null);

  /// `validUntil` — optional. Null means it repeats indefinitely.
  final validUntil = ValueNotifier<DateTime?>(null);

  /// Most classes are taught in person, so that is where the form starts.
  final mode = ValueNotifier<ClassMode>(ClassMode.offline);

  /// The picker fields have no validator of their own, so their errors stay
  /// hidden until the first submit rather than shouting at an untouched form.
  final showErrors = ValueNotifier<bool>(false);

  String? get subjectsError =>
      _pickerError(subjects.value.isEmpty, 'Pick at least one subject');

  String? get classesError =>
      _pickerError(classes.value.isEmpty, 'Pick at least one class');

  String? get dayError =>
      _pickerError(day.value == null, 'Choose the day it repeats on');

  String? get startTimeError =>
      _pickerError(startTime.value == null, 'Start time is required');

  String? get endTimeError {
    if (!showErrors.value) return null;
    if (endTime.value == null) return 'End time is required';
    if (!_endsAfterStart) return 'End time must be after the start time';
    return null;
  }

  String? get validFromError =>
      _pickerError(validFrom.value == null, 'Start date is required');

  String? get validUntilError => _pickerError(
    _endsBeforeItStarts,
    'End date cannot be before the start date',
  );

  /// A class that finishes before it begins is a typo far more often than it
  /// is a slot running past midnight, so the form rejects it.
  bool get _endsAfterStart {
    final start = startTime.value;
    final end = endTime.value;
    if (start == null || end == null) return false;
    return end.hour * 60 + end.minute > start.hour * 60 + start.minute;
  }

  bool get _endsBeforeItStarts {
    final from = validFrom.value;
    final until = validUntil.value;
    if (from == null || until == null) return false;
    return until.isBefore(from);
  }

  /// True once anything at all has been entered, which is what makes leaving
  /// the screen worth confirming.
  bool get isDirty =>
      title.text.trim().isNotEmpty ||
      description.text.trim().isNotEmpty ||
      venueName.text.trim().isNotEmpty ||
      venueAddress.text.trim().isNotEmpty ||
      subjects.value.isNotEmpty ||
      classes.value.isNotEmpty ||
      day.value != null ||
      startTime.value != null ||
      endTime.value != null ||
      validFrom.value != null ||
      validUntil.value != null;

  bool validate() {
    showErrors.value = true;

    // The text fields carry their own validators; everything else is a picker
    // whose error is derived above.
    final textValid = formKey.currentState?.validate() ?? false;

    return textValid &&
        subjectsError == null &&
        classesError == null &&
        dayError == null &&
        startTimeError == null &&
        endTimeError == null &&
        validFromError == null &&
        validUntilError == null;
  }

  /// Reads back only once [showErrors] is set, so the message appears on
  /// submit and then live-corrects as the field is filled in.
  String? _pickerError(bool isInvalid, String message) =>
      showErrors.value && isInvalid ? message : null;

  void dispose() {
    title.dispose();
    description.dispose();
    venueName.dispose();
    venueAddress.dispose();
    subjects.dispose();
    classes.dispose();
    day.dispose();
    startTime.dispose();
    endTime.dispose();
    validFrom.dispose();
    validUntil.dispose();
    mode.dispose();
    showErrors.dispose();
  }
}
