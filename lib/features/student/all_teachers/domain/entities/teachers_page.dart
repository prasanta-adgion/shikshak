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

class TeacherPageInfo {
  static const int defaultPageSize = 10;

  final int page;
  final int limit;

  final int total;

  final int totalPages;

  bool get hasMore => page < totalPages;

  int get nextPage => page + 1;

  const TeacherPageInfo({
    this.page = 1,
    this.limit = defaultPageSize,
    this.total = 0,
    this.totalPages = 0,
  });
}
