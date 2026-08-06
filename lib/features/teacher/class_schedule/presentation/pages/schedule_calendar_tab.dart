import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/date_time_picker_func.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../../../../shared/widgets/empty_state.dart';
import '../../../../../shared/widgets/error_state.dart';
import '../../domain/entities/date_range.dart';
import '../../domain/entities/schedule_day.dart';
import '../providers/class_schedule_providers.dart';
import '../state/class_schedule_state.dart';
import '../widgets/class_occurrence_card.dart';
import '../widgets/dormant_slots_section.dart';
import '../widgets/schedule_date_strip.dart';
import '../widgets/schedule_summary_card.dart';
import '../widgets/schedule_week_header.dart';

/// The teacher's classes for one week at a time, a day at a time.
///
/// The Calendar half of [TeacherSchedulePage]; the shell owns the header, so
/// this contributes a scrollable body only.
class ScheduleCalendarTab extends ConsumerStatefulWidget {
  const ScheduleCalendarTab({super.key});

  @override
  ConsumerState<ScheduleCalendarTab> createState() =>
      _ScheduleCalendarTabState();
}

class _ScheduleCalendarTabState extends ConsumerState<ScheduleCalendarTab> {
  @override
  void initState() {
    super.initState();
    // Deferred: the notifier writes state, which cannot happen during build.
    Future.microtask(
      () => ref.read(classScheduleNotifierProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(classScheduleNotifierProvider);
    final notifier = ref.read(classScheduleNotifierProvider.notifier);

    ref.listen(classScheduleNotifierProvider, (previous, next) {
      final error = next.error;
      // Only for a refresh that failed over content already on screen — a
      // load with nothing to show gets the full-area error state.
      if (error != null && next.calendar != null && previous?.error != error) {
        AppSnackbar.showError(context, error.message);
      }
    });

    return CenteredConstrainedBox(
      child: RefreshIndicator(
        onRefresh: notifier.refresh,
        child: CustomScrollView(
          // Always scrollable, so pull-to-refresh works even when the day has
          // too little content to fill the screen.
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            if (_showsPlaceholder(state))
              SliverFillRemaining(
                hasScrollBody: false,
                child: _PlaceholderBody(
                  state: state,
                  onRetry: notifier.refresh,
                ),
              )
            else
              SliverPadding(
                padding: context.responsivePagePadding,
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    AppSpacing.gapSm,
                    ScheduleWeekHeader(
                      range: state.range,
                      isCurrentWeek: state.isCurrentWeek,
                      onPrevious: notifier.showPreviousWeek,
                      onNext: notifier.showNextWeek,
                      onToday: notifier.goToToday,
                    ),
                    AppSpacing.gapLg,
                    // Held back until the week's classes land: totals of zero
                    // would read as "nothing scheduled" rather than "still
                    // counting".
                    if (!state.isLoadingWeek) ...[
                      ScheduleSummaryCard(
                        classCount: state.weekClassCount,
                        durationLabel: state.weekDurationLabel,
                        teachingDayCount: state.teachingDayCount,
                        nextUp: state.calendar?.nextUp(),
                      ),
                      AppSpacing.gapXl,
                    ],
                    ScheduleDateStrip(
                      days: state.days,
                      selectedDate: state.selectedDate,
                      countsByDate: state.countsByDate,
                      onDateSelected: notifier.selectDate,
                    ),
                    AppSpacing.gapXl,
                    _DayHeading(
                      date: state.selectedDate,
                      classCount: state.selectedDayClasses.length,
                    ),
                    AppSpacing.gapMd,
                    if (state.isLoadingWeek)
                      const _WeekLoading()
                    else if (state.selectedDayClasses.isEmpty)
                      _EmptyDayNote(date: state.selectedDate)
                    else
                      for (final occurrence in state.selectedDayClasses) ...[
                        ClassOccurrenceCard(occurrence: occurrence),
                        AppSpacing.gapMd,
                      ],
                    if (state.calendar?.dormantSlots.isNotEmpty ?? false) ...[
                      AppSpacing.gapXl,
                      DormantSlotsSection(
                        entries: state.calendar!.dormantSlots,
                      ),
                    ],
                    AppSpacing.gapXxxl,
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// The week UI needs its dates and its counts; until one load has landed
  /// there is nothing to hang them on. A teacher with no recurrences at all
  /// never gets the week either — there is no week to page through.
  static bool _showsPlaceholder(ClassScheduleState state) =>
      !state.hasLoaded ||
      state.hasNoSlots ||
      (state.calendar == null && state.error != null);
}

/// Shown in place of the week while there is nothing to render: the first
/// load, a load that failed outright, or a teacher with no slots yet.
class _PlaceholderBody extends StatelessWidget {
  const _PlaceholderBody({required this.state, required this.onRetry});

  final ClassScheduleState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (!state.hasLoaded) {
      return const Center(
        child: SizedBox(
          height: 26,
          width: 26,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      );
    }

    final error = state.error;
    if (error != null) {
      return ErrorState(message: error.message, onRetry: onRetry);
    }

    return EmptyState(
      title: 'No classes scheduled',
      message:
          'Create a class slot and it will show up here, on repeat every week.',
      icon: AppIcons.scheduleOutlined,
      actionLabel: 'Refresh',
      onAction: onRetry,
    );
  }
}

/// Spinner for the list area alone, so the week header and the date strip
/// stay put while another week loads.
class _WeekLoading extends StatelessWidget {
  const _WeekLoading();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
    child: Center(
      child: SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 2.4),
      ),
    ),
  );
}

class _DayHeading extends StatelessWidget {
  const _DayHeading({required this.date, required this.classCount});

  final DateTime date;
  final int classCount;

  /// `Thursday, 6 Aug`, with today and tomorrow named instead of dated —
  /// which is how a teacher thinks about the next two days.
  static String label(DateTime date, {DateTime? now}) {
    final today = DateRange.dateOnly(now ?? DateTime.now());
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final day = ScheduleDay.fromDateTime(date).label;

    if (date == today) return 'Today · $day';
    if (date == tomorrow) return 'Tomorrow · $day';
    return '$day, ${DateTimeUtils.dayMonth(date)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        // Expanded, not bare: the date and the count must not collide on a
        // narrow phone.
        Expanded(
          child: Text(
            label(date),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium,
          ),
        ),
        AppSpacing.hGapSm,
        Text(
          classCount == 1 ? '1 class' : '$classCount classes',
          maxLines: 1,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// A quiet in-place note for a day with no classes — the week itself is not
/// empty, so the full-screen [EmptyState] would overstate it.
class _EmptyDayNote extends StatelessWidget {
  const _EmptyDayNote({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: AppRadius.card,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            AppIcons.availability,
            size: 28,
            color: colorScheme.onSurfaceVariant,
          ),
          AppSpacing.gapMd,
          Text(
            'No classes on ${ScheduleDay.fromDateTime(date).label}',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall,
          ),
          AppSpacing.gapXs,
          Text(
            'Pick another date to see what is scheduled.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
