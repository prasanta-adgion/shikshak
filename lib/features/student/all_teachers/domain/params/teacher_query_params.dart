import '../entities/teachers_page.dart';

enum TeacherSortOrder { asc, desc }

class TeacherQueryParams {
  const TeacherQueryParams({
    this.page = 1,
    this.limit = TeacherPageInfo.defaultPageSize,
    this.search = '',
    this.classes = const [],
    this.languages = const [],
    this.subjects = const [],
    this.classRegex = '',
    this.languageRegex = '',
    this.subjectRegex = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.gender = '',
    this.hasProfilePhoto,
    this.sortOrder = TeacherSortOrder.desc,
  });

  final int page;
  final int limit;

  final String search;

  final List<String> classes;
  final List<String> languages;
  final List<String> subjects;

  final String classRegex;
  final String languageRegex;
  final String subjectRegex;

  final String city;
  final String state;
  final String country;
  final String gender;

  final bool? hasProfilePhoto;

  final TeacherSortOrder sortOrder;

  Map<String, dynamic> toQueryParameters() => {
    'page': page,
    'limit': limit,
    if (_hasText(search)) 'search': search.trim(),
    if (classes.isNotEmpty) 'classes': classes.join(','),
    if (languages.isNotEmpty) 'languages': languages.join(','),
    if (subjects.isNotEmpty) 'subjects': subjects.join(','),
    if (_hasText(classRegex)) 'classRegex': classRegex.trim(),
    if (_hasText(languageRegex)) 'languageRegex': languageRegex.trim(),
    if (_hasText(subjectRegex)) 'subjectRegex': subjectRegex.trim(),
    if (_hasText(city)) 'city': city.trim(),
    if (_hasText(state)) 'state': state.trim(),
    if (_hasText(country)) 'country': country.trim(),
    if (_hasText(gender)) 'gender': gender.trim(),
    if (hasProfilePhoto != null) 'hasProfilePhoto': hasProfilePhoto,
    'sortOrder': sortOrder.name,
  };

  /// [clearHasProfilePhoto] exists because `hasProfilePhoto ?? this.…` alone
  /// could never put the filter back to "either".
  TeacherQueryParams copyWith({
    int? page,
    int? limit,
    String? search,
    List<String>? classes,
    List<String>? languages,
    List<String>? subjects,
    String? classRegex,
    String? languageRegex,
    String? subjectRegex,
    String? city,
    String? state,
    String? country,
    String? gender,
    bool? hasProfilePhoto,
    bool clearHasProfilePhoto = false,
    TeacherSortOrder? sortOrder,
  }) => TeacherQueryParams(
    page: page ?? this.page,
    limit: limit ?? this.limit,
    search: search ?? this.search,
    classes: classes ?? this.classes,
    languages: languages ?? this.languages,
    subjects: subjects ?? this.subjects,
    classRegex: classRegex ?? this.classRegex,
    languageRegex: languageRegex ?? this.languageRegex,
    subjectRegex: subjectRegex ?? this.subjectRegex,
    city: city ?? this.city,
    state: state ?? this.state,
    country: country ?? this.country,
    gender: gender ?? this.gender,
    hasProfilePhoto: clearHasProfilePhoto
        ? null
        : (hasProfilePhoto ?? this.hasProfilePhoto),
    sortOrder: sortOrder ?? this.sortOrder,
  );

  /// True when anything beyond paging and sorting is narrowing the list —
  /// drives the "no match" copy and the "clear filters" action.
  bool get hasFilters =>
      _hasText(search) ||
      classes.isNotEmpty ||
      languages.isNotEmpty ||
      subjects.isNotEmpty ||
      _hasText(classRegex) ||
      _hasText(languageRegex) ||
      _hasText(subjectRegex) ||
      _hasText(city) ||
      _hasText(state) ||
      _hasText(country) ||
      _hasText(gender) ||
      hasProfilePhoto != null;

  static bool _hasText(String value) => value.trim().isNotEmpty;
}
