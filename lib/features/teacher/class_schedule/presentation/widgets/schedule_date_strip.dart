import 'package:flutter/material.dart';

import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/responsive.dart';
import '../../domain/entities/date_range.dart';
import '../../domain/entities/schedule_day.dart';

/// The week's dates as a selector, each showing how many classes fall on it
/// and today marked.
class ScheduleDateStrip extends StatelessWidget {
  const ScheduleDateStrip({
    super.key,
    required this.days,
    required this.selectedDate,
    required this.countsByDate,
    required this.onDateSelected,
    this.today,
  });

  final List<DateTime> days;
  final DateTime selectedDate;

  /// Class count per date. Dates with no classes are absent from the map.
  final Map<DateTime, int> countsByDate;

  final ValueChanged<DateTime> onDateSelected;

  /// Injectable so a widget test can pin "today" instead of depending on the
  /// day it happens to run.
  final DateTime? today;

  /// Below this, seven pills stop being tappable-and-readable, so the strip
  /// scrolls horizontally instead of squeezing further.
  static const double _minPillWidth = 46;

  @override
  Widget build(BuildContext context) {
    final today = DateRange.dateOnly(this.today ?? DateTime.now());

    return ResponsiveBuilder(
      builder: (context, constraints) {
        final pills = [
          for (final day in days)
            _DatePill(
              date: day,
              count: countsByDate[day] ?? 0,
              isSelected: day == selectedDate,
              isToday: day == today,
              onTap: () => onDateSelected(day),
            ),
        ];

        final fits = constraints.maxWidth >= _minPillWidth * days.length;
        if (fits) {
          return Row(
            children: [for (final pill in pills) Expanded(child: pill)],
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              for (final pill in pills)
                SizedBox(width: _minPillWidth, child: pill),
            ],
          ),
        );
      },
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({
    required this.date,
    required this.count,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final int count;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasClasses = count > 0;

    // Green marks a date that has classes — the one thing the strip exists to
    // show at a glance. Selection still wins, because the pill is filled and
    // only [ColorScheme.onPrimary] stays legible on it.
    final foreground = isSelected
        ? colorScheme.onPrimary
        : hasClasses
        ? colorScheme.tertiary
        : isToday
        ? colorScheme.primary
        : colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      child: Material(
        color: isSelected ? colorScheme.primary : Colors.transparent,
        borderRadius: AppRadius.card,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: AppRadius.card,
              border: Border.all(
                color: isSelected
                    ? colorScheme.outlineVariant
                    : hasClasses
                    // Matches the green on the date itself, so a busy day
                    // reads as one marked pill rather than a tinted numeral.
                    ? colorScheme.tertiary.withValues(alpha: 0.55)
                    : isToday
                    ? colorScheme.primary.withValues(alpha: 0.45)
                    : colorScheme.outlineVariant,
                // Today keeps a heavier ring rather than a colour of its own,
                // so it stays findable even on a date the green has claimed.
                width: isToday ? 1.6 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ScheduleDay.fromDateTime(date).shortLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimary.withValues(alpha: 0.85)
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                AppSpacing.gapXs,
                Text(
                  '${date.day}',
                  maxLines: 1,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: foreground,
                  ),
                ),
                AppSpacing.gapXs,
                // A dot rather than a number: at this size the count is a
                // density cue, and the exact figure is on the day heading.
                // Shares [foreground], so the dots are green whenever the
                // date is.
                _CountDots(count: count, color: foreground),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Up to three dots for the classes on a date; a quiet dash for none.
class _CountDots extends StatelessWidget {
  const _CountDots({required this.count, required this.color});

  final int count;
  final Color color;

  static const int _maxDots = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (count == 0) {
      return SizedBox(
        height: 6,
        child: Center(
          child: Container(
            height: 2,
            width: 6,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    // Beyond three the dots stop being countable, so the number takes over.
    if (count > _maxDots) {
      return SizedBox(
        height: 6,
        child: Center(
          child: Text(
            '$count',
            maxLines: 1,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              height: 1,
              fontSize: 9,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < count; index++)
            Container(
              height: 5,
              width: 5,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
