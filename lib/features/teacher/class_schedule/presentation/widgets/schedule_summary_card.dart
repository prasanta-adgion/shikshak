import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_card.dart';
import '../../domain/entities/class_occurrence.dart';
import '../../domain/entities/schedule_day.dart';

/// Hero card at the top of the schedule: what the week on screen adds up to,
/// and which class is due next.
class ScheduleSummaryCard extends StatelessWidget {
  const ScheduleSummaryCard({
    super.key,
    required this.classCount,
    required this.durationLabel,
    required this.teachingDayCount,
    this.nextUp,
  });

  final int classCount;

  /// Pre-formatted total teaching time, e.g. `4h 30m`.
  final String durationLabel;

  final int teachingDayCount;

  /// The next class still to come in this week, if any.
  final ClassOccurrence? nextUp;

  /// `Next: Logarithm · Thu 9:00 AM`
  static String subtitleFor(ClassOccurrence? nextUp, int classCount) {
    if (nextUp == null) {
      return classCount == 0
          ? 'No classes in this week'
          : 'Every class in this week is done';
    }
    final day = ScheduleDay.fromDateTime(nextUp.date).shortLabel;
    return 'Next: ${nextUp.title} · $day ${nextUp.startTime.label}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      gradient: AppColors.teacherGradient,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadius.xs),
                  ),
                ),
                child: const Icon(
                  AppIcons.schedule,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              AppSpacing.hGapMd,
              // Expanded + ellipsis: the subtitle carries a class title, so it
              // must not overflow the card on a narrow phone.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // Which week this is belongs to the header directly
                      // above; repeating it here just says it twice.
                      'At a glance',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    AppSpacing.gapXs,
                    Text(
                      subtitleFor(nextUp, classCount),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapXl,
          Row(
            children: [
              _SummaryStat(
                value: '$classCount',
                label: classCount == 1 ? 'Class' : 'Classes',
              ),
              const _StatDivider(),
              _SummaryStat(
                value: durationLabel.isEmpty ? '—' : durationLabel,
                label: 'Teaching time',
              ),
              const _StatDivider(),
              _SummaryStat(
                value: '$teachingDayCount',
                label: teachingDayCount == 1 ? 'Day' : 'Days',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Expanded so the three stats share the width evenly however long their
    // values are.
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          AppSpacing.gapXs,
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) => Container(
    height: 32,
    width: 1,
    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    color: Colors.white.withValues(alpha: 0.25),
  );
}
