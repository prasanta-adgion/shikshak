import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_result.dart';
import '../../domain/params/teacher_query_params.dart';
import '../providers/all_teachers_providers.dart';
import '../state/all_teachers_state.dart';

class AllTeachersNotifier extends Notifier<AllTeachersState> {
  /// Long enough that typing a word is one request, short enough that the
  /// list still feels like it is keeping up.
  static const _searchDebounce = Duration(milliseconds: 350);

  Timer? _searchTimer;

  /// Stamps every request so a slow one that lands after a newer one cannot
  /// overwrite it — the case a fast typist hits on every keystroke.
  int _requestId = 0;

  @override
  AllTeachersState build() {
    ref.onDispose(() => _searchTimer?.cancel());
    return const AllTeachersState();
  }

  /// First page. A no-op once the list is on screen, so returning to the tab
  /// does not re-fetch what is already there — [refresh] is for that.
  Future<void> load() async {
    if (state.isLoading || state.hasLoaded) return;
    await _loadFirstPage();
  }

  Future<void> refresh() => _loadFirstPage();

  /// Appends the next page. Ignored while a request is in flight or when the
  /// last page is already showing.
  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    final requestId = ++_requestId;
    final nextPage = state.pagination.nextPage;
    state = state.copyWith(isLoadingMore: true, clearError: true);

    final result = await ref.read(getAllTeachersUseCaseProvider)(
      state.query.copyWith(page: nextPage),
    );

    if (!ref.mounted || requestId != _requestId) return;

    switch (result) {
      case ApiSuccess(:final data):
        state = state.copyWith(
          teachers: [...state.teachers, ...data.teachers],
          pagination: data.pagination,
          isLoadingMore: false,
        );
      case ApiFailure(:final exception):
        // The pages already loaded stay put; the screen shows a snackbar and
        // the scroller can try the same page again.
        state = state.copyWith(isLoadingMore: false, error: exception);
    }
  }

  /// Debounced free-text search. Reloads from page one, because a new term
  /// invalidates every page already held.
  void search(String term) {
    final trimmed = term.trim();
    if (trimmed == state.query.search) return;

    _searchTimer?.cancel();
    _searchTimer = Timer(_searchDebounce, () {
      if (!ref.mounted) return;
      state = state.copyWith(query: state.query.copyWith(search: trimmed));
      _loadFirstPage();
    });
  }

  /// Replaces the filters wholesale and reloads. `page` is forced back to 1:
  /// staying on page 4 of a different result set would show a blank list.
  Future<void> applyQuery(TeacherQueryParams query) {
    _searchTimer?.cancel();
    state = state.copyWith(query: query.copyWith(page: 1));
    return _loadFirstPage();
  }

  Future<void> clearFilters() =>
      applyQuery(TeacherQueryParams(sortOrder: state.query.sortOrder));

  Future<void> _loadFirstPage() async {
    final requestId = ++_requestId;
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(getAllTeachersUseCaseProvider)(
      state.query.copyWith(page: 1),
    );

    // The screen can be left mid-request, which auto-disposes this notifier —
    // touching state after that throws.
    if (!ref.mounted || requestId != _requestId) return;

    switch (result) {
      case ApiSuccess(:final data):
        state = state.copyWith(
          teachers: data.teachers,
          pagination: data.pagination,
          isLoading: false,
          isLoadingMore: false,
          hasLoaded: true,
          clearError: true,
        );
      case ApiFailure(:final exception):
        // The previous list is kept: a failed refresh should not blank a
        // screen that was already showing good data.
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          hasLoaded: true,
          error: exception,
        );
    }
  }
}
