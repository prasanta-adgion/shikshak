import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/route_paths.dart';
import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../../../../shared/widgets/empty_state.dart';
import '../../../../../shared/widgets/error_state.dart';
import '../providers/all_teachers_providers.dart';
import '../state/all_teachers_state.dart';
import '../widgets/teacher_card.dart';
import '../widgets/teacher_filter_sheet.dart';
import '../widgets/teachers_search_field.dart';

/// Every approved teacher, searchable, a page at a time.
class AllTeachersPage extends ConsumerStatefulWidget {
  const AllTeachersPage({super.key});

  @override
  ConsumerState<AllTeachersPage> createState() => _AllTeachersPageState();
}

class _AllTeachersPageState extends ConsumerState<AllTeachersPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  /// How close to the bottom the list gets before the next page is asked
  /// for — roughly one card, so the spinner is rarely seen.
  static const double _loadMoreThreshold = 320;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    // Deferred: the notifier writes state, which cannot happen during build.
    Future.microtask(
      () => ref.read(allTeachersNotifierProvider.notifier).load(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      // The notifier drops the call when a request is already in flight or
      // the last page is showing, so no guard is needed here.
      ref.read(allTeachersNotifierProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged() => ref
      .read(allTeachersNotifierProvider.notifier)
      .search(_searchController.text);

  /// A page shorter than the viewport leaves nothing to scroll, so [_onScroll]
  /// never fires and paging would stall on page one — what a small `limit`
  /// (or a tall tablet) produces. Keeps pulling until the list is long enough
  /// to scroll, or the last page arrives.
  void _loadMoreIfUnscrollable() {
    if (!mounted || !_scrollController.hasClients) return;
    if (_scrollController.position.maxScrollExtent > 0) return;

    ref.read(allTeachersNotifierProvider.notifier).loadMore();
  }

  Future<void> _refresh() =>
      ref.read(allTeachersNotifierProvider.notifier).refresh();

  /// The text only — filters survive, since they are the sheet's to clear.
  /// [AllTeachersNotifier.applyQuery] cancels the debounce `clear()` just
  /// started, so this is one request, not two.
  void _clearSearch() {
    _searchController.clear();

    final notifier = ref.read(allTeachersNotifierProvider.notifier);
    notifier.applyQuery(
      ref.read(allTeachersNotifierProvider).query.copyWith(search: ''),
    );
  }

  /// Back to square one: text and filters both. Reached from the empty state,
  /// where the fastest way out is to drop everything.
  void _clearAll() {
    ref.read(allTeachersNotifierProvider.notifier).clearFilters();
    // Already-empty search: the notifier's own equality check drops the
    // request this fires, so the list is not fetched twice.
    _searchController.clear();
  }

  Future<void> _openFilters() async {
    final query = ref.read(allTeachersNotifierProvider).query;
    final applied = await TeacherFilterSheet.show(context, query: query);

    // Dismissed without applying — leave the list as it was.
    if (applied == null || !mounted) return;

    await ref.read(allTeachersNotifierProvider.notifier).applyQuery(applied);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(allTeachersNotifierProvider);

    // Checked after layout, when the scroll extent this frame produced is
    // known. Terminates: every pass appends a page, and `hasMore` goes false
    // on the last one.
    if (state.hasMore && !state.isLoading && !state.isLoadingMore) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _loadMoreIfUnscrollable(),
      );
    }

    ref.listen(allTeachersNotifierProvider, (previous, next) {
      final error = next.error;
      // Only when there are teachers still on screen — otherwise the body
      // itself carries the error, and a snackbar would say it twice.
      if (error != null &&
          next.teachers.isNotEmpty &&
          previous?.error != error) {
        AppSnackbar.showError(context, error.message);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('All Teachers'), centerTitle: false),
      body: CenteredConstrainedBox(
        // Narrower than the page default: these are single-column cards, and
        // a 1100pt-wide card on a tablet reads as a stretched row.
        maxWidth: 720,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: context.responsivePagePadding.copyWith(
                  top: AppSpacing.lg,
                  bottom: AppSpacing.md,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TeachersSearchField(
                        controller: _searchController,
                        activeFilterCount: state.query.activeFilterCount,
                        onFilterPressed: _openFilters,
                        onClear: _clearSearch,
                      ),
                      if (state.hasLoaded && state.teachers.isNotEmpty) ...[
                        AppSpacing.gapMd,
                        Text(
                          _countLabel(state),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              ..._bodySlivers(state),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _bodySlivers(AllTeachersState state) {
    // First load, or a reload after a new search term: nothing to keep on
    // screen, so the spinner owns the body.
    if (state.isLoading && state.teachers.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (state.teachers.isEmpty && state.error != null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorState(message: state.error!.message, onRetry: _refresh),
        ),
      ];
    }

    if (state.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: state.isFiltered
              ? EmptyState(
                  icon: AppIcons.search,
                  title: 'No teachers found',
                  message: 'Try a different name, or widen the filters.',
                  actionLabel: 'Clear search and filters',
                  onAction: _clearAll,
                )
              : const EmptyState(
                  title: 'No teachers yet',
                  message:
                      'Teachers appear here once their profiles are '
                      'approved.',
                ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: context.responsivePagePadding,
        sliver: SliverList.separated(
          itemCount: state.teachers.length,
          separatorBuilder: (_, _) => AppSpacing.gapMd,
          itemBuilder: (context, index) {
            final teacher = state.teachers[index];

            return TeacherCard(
              teacher: teacher,
              // A row that arrived without an id has nothing to open — the
              // profile route is keyed on it.
              onTap: teacher.id.isEmpty
                  ? null
                  : () => context.push(
                      RoutePaths.studentTeacherDetailsFor(teacher.id),
                    ),
            );
          },
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: Center(
            child: state.isLoadingMore
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : state.hasMore
                ? const SizedBox.shrink()
                : Text(
                    'That’s everyone',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
      ),
    ];
  }

  /// `12 teachers` — or `3 of 12` while more pages are still to come.
  static String _countLabel(AllTeachersState state) {
    final total = state.pagination.total;
    final shown = state.teachers.length;
    final noun = total == 1 ? 'teacher' : 'teachers';

    return shown < total ? '$shown of $total $noun' : '$total $noun';
  }
}
