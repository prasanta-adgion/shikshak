import '../../../../../core/network/api_exception.dart';
import '../../domain/entities/teacher_class_slot.dart';
import '../../domain/entities/teacher_details.dart';

class SingleTeacherState {
  const SingleTeacherState({
    this.teacherId = '',
    this.teacher,
    this.selectedClassIds = const {},
    this.isLoading = false,
    this.hasLoaded = false,
    this.error,
  });

  /// Who the screen is showing — kept so [refresh] does not need it passed
  /// back in.
  final String teacherId;

  final TeacherDetails? teacher;

  /// The classes the student picked, by id. A set, because the order that
  /// matters is the timetable's — see [selectedClasses] — not the order they
  /// were tapped in.
  final Set<String> selectedClassIds;

  final bool isLoading;

  /// Separates "not asked yet" from "asked, and there is nothing".
  final bool hasLoaded;

  final ApiException? error;

  List<TeacherClassSlot> get availableClasses =>
      teacher?.availableClasses ?? const [];

  /// The picked classes in the order they are listed, so the summary line
  /// reads the same way the cards do.
  List<TeacherClassSlot> get selectedClasses => [
    for (final slot in availableClasses)
      if (selectedClassIds.contains(slot.id)) slot,
  ];

  bool isSelected(String classId) => selectedClassIds.contains(classId);

  bool get canMessage => selectedClasses.isNotEmpty;

  /// True only when there is something to select and all of it is selected —
  /// which is what flips the header action to "Clear all".
  bool get isEverythingSelected =>
      availableClasses.isNotEmpty &&
      selectedClasses.length == availableClasses.length;

  SingleTeacherState copyWith({
    String? teacherId,
    TeacherDetails? teacher,
    Set<String>? selectedClassIds,
    bool? isLoading,
    bool? hasLoaded,
    ApiException? error,
    bool clearError = false,
  }) => SingleTeacherState(
    teacherId: teacherId ?? this.teacherId,
    teacher: teacher ?? this.teacher,
    selectedClassIds: selectedClassIds ?? this.selectedClassIds,
    isLoading: isLoading ?? this.isLoading,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    // `error ?? this.error` alone could never clear it.
    error: clearError ? null : (error ?? this.error),
  );
}
