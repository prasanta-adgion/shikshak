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

  /// Stamps every request so a slow one that lands after a newer one is
  /// dropped instead of overwriting it — see [_fetch].
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
    await _fetch(1);
  }

  Future<void> refresh() => _fetch(1);

  /// Appends the next page, per the server's own counters: `page` is only
  /// advanced while it is still short of `totalPages`.
  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    await _fetch(state.pagination.nextPage);
  }

  /// Debounced free-text search. Reloads from page one, because a new term
  /// invalidates every page already held.
  void search(String term) {
    final trimmed = term.trim();
    if (trimmed == state.query.search) return;

    _searchTimer?.cancel();
    _searchTimer = Timer(_searchDebounce, () {
      if (!ref.mounted) return;
      applyQuery(state.query.copyWith(search: trimmed));
    });
  }

  /// Replaces the filters wholesale and reloads from the top — staying on
  /// page 4 of a different result set would show a blank list.
  Future<void> applyQuery(TeacherQueryParams query) {
    _searchTimer?.cancel();
    state = state.copyWith(query: query.copyWith(page: 1));
    return _fetch(1);
  }

  Future<void> clearFilters() =>
      applyQuery(TeacherQueryParams(sortOrder: state.query.sortOrder));

  /// The one request this notifier makes. Page 1 replaces the list; any later
  /// page is appended to it.
  Future<void> _fetch(int page) async {
    final isAppending = page > 1;
    final requestId = ++_requestId;

    state = state.copyWith(
      isLoading: !isAppending,
      isLoadingMore: isAppending,
      clearError: true,
    );

    final result = await ref.read(getAllTeachersUseCaseProvider)(
      state.query.copyWith(page: page),
    );

    // Two ways this response is no longer wanted: the screen was left
    // mid-request, which auto-disposes the notifier and makes writing state
    // throw; or a newer request has since been made and this one lost the
    // race — a fast typist starts a request per debounce window, and they do
    // not necessarily come back in order.
    if (!ref.mounted || requestId != _requestId) return;

    state = switch (result) {
      ApiSuccess(:final data) => state.copyWith(
        teachers: isAppending
            ? [...state.teachers, ...data.teachers]
            : data.teachers,
        pagination: data.pagination,
        isLoading: false,
        isLoadingMore: false,
        hasLoaded: true,
        clearError: true,
      ),
      // Whatever is already on screen stays put: a failed page should not
      // blank a list that was showing good data.
      ApiFailure(:final exception) => state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        hasLoaded: true,
        error: exception,
      ),
    };
  }
}
