import 'teacher.dart';

/// One page of teachers plus the counters needed to ask for the next one.
class TeachersPage {
  const TeachersPage({
    this.teachers = const [],
    this.pagination = const TeacherPageInfo(),
  });

  final List<Teacher> teachers;
  final TeacherPageInfo pagination;
}

/// The server's `pagination` block, as the list scroller needs it.
class TeacherPageInfo {
  const TeacherPageInfo({
    this.page = 1,
    this.limit = defaultPageSize,
    this.total = 0,
    this.totalPages = 0,
  });

  /// Matches the API default and is what the first request asks for.
  static const int defaultPageSize = 10;

  final int page;
  final int limit;

  /// Teachers matching the current filters, across every page.
  final int total;

  final int totalPages;

  bool get hasMore => page < totalPages;

  int get nextPage => page + 1;
}
