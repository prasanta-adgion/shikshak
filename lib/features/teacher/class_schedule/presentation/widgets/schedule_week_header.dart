import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/date_time_picker_func.dart';
import '../../domain/entities/date_range.dart';

/// Week pager: which week is on screen, and the arrows to move between them.
class ScheduleWeekHeader extends StatelessWidget {
  const ScheduleWeekHeader({
    super.key,
    required this.range,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    this.isCurrentWeek = false,
  });

  final DateRange range;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  /// Hides the jump-back action when there is nowhere to jump to.
  final bool isCurrentWeek;

  /// `3 – 9 Aug 2026`, collapsing whatever the two ends share. A range inside
  /// one month names it once; one that straddles a year spells both out.
  static String label(DateRange range) {
    final from = range.from;
    final to = range.to;

    if (from.year != to.year) {
      return '${DateTimeUtils.dayMonthYear(from)} – '
          '${DateTimeUtils.dayMonthYear(to)}';
    }
    if (from.month != to.month) {
      return '${DateTimeUtils.dayMonth(from)} – '
          '${DateTimeUtils.dayMonthYear(to)}';
    }
    return '${from.day} – ${DateTimeUtils.dayMonthYear(to)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        _ArrowButton(
          icon: AppIcons.back,
          tooltip: 'Previous week',
          onPressed: onPrevious,
        ),
        // Expanded + ellipsis: the label sits between two fixed controls and
        // must not push them off a narrow phone.
        Expanded(
          child: Column(
            children: [
              Text(
                label(range),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall,
              ),
              AppSpacing.gapXs,
              if (isCurrentWeek)
                Text(
                  'This week',
                  maxLines: 1,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              else
                // A tap target rather than a label: off the current week, the
                // way back is the thing the teacher most likely wants.
                InkWell(
                  onTap: onToday,
                  borderRadius: AppRadius.chip,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    child: Text(
                      'Back to today',
                      maxLines: 1,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        _ArrowButton(
          icon: AppIcons.forward,
          tooltip: 'Next week',
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 16),
      style: IconButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        backgroundColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.5,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
    );
  }
}
