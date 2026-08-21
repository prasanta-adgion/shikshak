import '../../../../../core/network/api_exception.dart';
import '../../domain/entities/teacher.dart';
import '../../domain/entities/teachers_page.dart';
import '../../domain/params/teacher_query_params.dart';

class AllTeachersState {
  const AllTeachersState({
    this.teachers = const [],
    this.query = const TeacherQueryParams(),
    this.pagination = const TeacherPageInfo(),
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasLoaded = false,
    this.error,
  });

  /// Every teacher loaded so far — page one plus whatever the scroller has
  /// appended since.
  final List<Teacher> teachers;

  /// The filters the list currently reflects. `page` here is always 1: the
  /// page being appended travels with the request, not with the state.
  final TeacherQueryParams query;

  final TeacherPageInfo pagination;

  /// The first page, or a reload after a filter change — the body shows a
  /// spinner instead of the list.
  final bool isLoading;

  /// A page appended below what is already on screen.
  final bool isLoadingMore;

  /// Separates "not asked yet" from "asked, and there is nothing" — the two
  /// look identical on [teachers] alone but read very differently on screen.
  final bool hasLoaded;

  final ApiException? error;

  bool get hasMore => pagination.hasMore;

  bool get isEmpty => hasLoaded && teachers.isEmpty;

  /// An empty list under active filters is "no match", not "no teachers".
  bool get isFiltered => query.hasFilters;

  AllTeachersState copyWith({
    List<Teacher>? teachers,
    TeacherQueryParams? query,
    TeacherPageInfo? pagination,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasLoaded,
    ApiException? error,
    bool clearError = false,
  }) => AllTeachersState(
    teachers: teachers ?? this.teachers,
    query: query ?? this.query,
    pagination: pagination ?? this.pagination,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    // `error ?? this.error` alone could never clear it.
    error: clearError ? null : (error ?? this.error),
  );
}
