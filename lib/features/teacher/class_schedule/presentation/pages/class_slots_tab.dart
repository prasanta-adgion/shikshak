import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../../../../shared/widgets/empty_state.dart';
import '../../../../../shared/widgets/error_state.dart';
import '../../domain/entities/schedule_day.dart';
import '../providers/class_schedule_providers.dart';
import '../state/class_slots_state.dart';
import '../widgets/class_slot_card.dart';
import '../widgets/slots_summary_card.dart';

class ClassSlotsTab extends ConsumerStatefulWidget {
  const ClassSlotsTab({super.key});

  @override
  ConsumerState<ClassSlotsTab> createState() => _ClassSlotsTabState();
}

class _ClassSlotsTabState extends ConsumerState<ClassSlotsTab> {
  @override
  void initState() {
    super.initState();
    // Deferred: the notifier writes state, which cannot happen during build.
    Future.microtask(
      () => ref.read(classSlotsNotifierProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(classSlotsNotifierProvider);
    final notifier = ref.read(classSlotsNotifierProvider.notifier);

    ref.listen(classSlotsNotifierProvider, (previous, next) {
      final error = next.error;
      // Only for a refresh that failed over content already on screen — a
      // load with nothing to show gets the full-area error state.
      if (error != null && next.slots.isNotEmpty && previous?.error != error) {
        AppSnackbar.showError(context, error.message);
      }
    });

    return CenteredConstrainedBox(
      child: RefreshIndicator(
        onRefresh: notifier.refresh,
        child: CustomScrollView(
          // Always scrollable, so pull-to-refresh works even when there is too
          // little content to fill the screen.
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            if (state.isEmpty)
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
                    SlotsSummaryCard(
                      slotCount: state.slotCount,
                      activeCount: state.activeCount,
                      durationLabel: state.weeklyDurationLabel,
                    ),
                    AppSpacing.gapXl,
                    for (final MapEntry(key: day, value: daySlots)
                        in state.slotsByDay.entries) ...[
                      _DayGroupHeading(day: day, slotCount: daySlots.length),
                      AppSpacing.gapMd,
                      for (final slot in daySlots) ...[
                        ClassSlotCard(
                          slot: slot,
                          isToggling: state.isToggling(slot.id),
                          onToggleActive: () => notifier.toggleActive(slot),
                        ),
                        AppSpacing.gapMd,
                      ],
                      AppSpacing.gapLg,
                    ],
                    AppSpacing.gapXxl,
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Shown in place of the list while there is nothing to render: the first
/// load, a load that failed outright, or a teacher who has created none.
class _PlaceholderBody extends StatelessWidget {
  const _PlaceholderBody({required this.state, required this.onRetry});

  final ClassSlotsState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading || !state.hasLoaded) {
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
      title: 'No class slots yet',
      message:
          'Create a slot with a day and a time, and it will repeat every week.',
      icon: AppIcons.scheduleOutlined,
      actionLabel: 'Refresh',
      onAction: onRetry,
    );
  }
}

/// `Sunday` with the number of slots on it, and a rule running to the edge so
/// the groups read as bands rather than as a flat list.
class _DayGroupHeading extends StatelessWidget {
  const _DayGroupHeading({required this.day, required this.slotCount});

  final ScheduleDay day;
  final int slotCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isToday = day == ScheduleDay.today;

    return Row(
      children: [
        Text(day.label, maxLines: 1, style: theme.textTheme.titleSmall),
        if (isToday) ...[
          AppSpacing.hGapSm,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: AppRadius.chip,
            ),
            child: Text(
              'Today',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
        AppSpacing.hGapMd,
        // Expanded on the rule, not the label: the day name keeps its natural
        // width and the line simply takes whatever is left.
        Expanded(child: Divider(height: 1, color: colorScheme.outlineVariant)),
        AppSpacing.hGapMd,
        Text(
          slotCount == 1 ? '1 slot' : '$slotCount slots',
          maxLines: 1,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
