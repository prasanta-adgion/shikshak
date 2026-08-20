import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_card.dart';
import '../../domain/entities/class_occurrence.dart';
import 'schedule_chips.dart';
import 'slot_accent.dart';

class ClassOccurrenceCard extends StatelessWidget {
  const ClassOccurrenceCard({
    super.key,
    required this.occurrence,
    this.now,
    this.onTap,
  });

  final ClassOccurrence occurrence;

  /// Injectable so a widget test can pin "now" rather than depending on the
  /// moment it runs.
  final DateTime? now;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = SlotAccent.of(occurrence.colorTag, colorScheme);
    final isPast = occurrence.isPast(now: now);

    return Opacity(
      // Finished classes stay on the day but recede, so the next one to teach
      // is the one that stands out.
      opacity: isPast ? 0.6 : 1,
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Full-height accent rail. AppCard clips to its radius, so the
              // rail picks up the rounded corners for free.
              Container(width: 4, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeaderRow(
                        occurrence: occurrence,
                        accent: accent,
                        isPast: isPast,
                      ),
                      AppSpacing.gapMd,
                      Text(
                        occurrence.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      if (occurrence.description?.trim().isNotEmpty ??
                          false) ...[
                        AppSpacing.gapXs,
                        Text(
                          occurrence.description!.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (occurrence.subjects.isNotEmpty ||
                          occurrence.classes.isNotEmpty) ...[
                        AppSpacing.gapMd,
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            for (final subject in occurrence.subjects)
                              SlotTag(label: subject, color: accent),
                            for (final className in occurrence.classes)
                              SlotTag(
                                label: className,
                                color: colorScheme.onSurfaceVariant,
                              ),
                          ],
                        ),
                      ],
                      AppSpacing.gapMd,
                      _VenueRow(occurrence: occurrence),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Time range, duration, and any status the teacher needs to notice.
class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.occurrence,
    required this.accent,
    required this.isPast,
  });

  final ClassOccurrence occurrence;
  final Color accent;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final duration = occurrence.durationLabel;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TimeRangePill(
          label: occurrence.timeRangeLabel,
          accent: accent,
          icon: AppIcons.hours,
        ),
        if (duration.isNotEmpty)
          Text(
            duration,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        if (occurrence.isException)
          StatusBadge(
            label: 'Changed',
            icon: AppIcons.classHybrid,
            color: colorScheme.primary,
          ),
        if (isPast)
          StatusBadge(
            label: 'Done',
            icon: AppIcons.success,
            color: colorScheme.onSurfaceVariant,
          ),
      ],
    );
  }
}

/// Delivery mode and venue, under a divider.
class _VenueRow extends StatelessWidget {
  const _VenueRow({required this.occurrence});

  final ClassOccurrence occurrence;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mode = occurrence.mode;

    // Nothing to add beyond the times and tags above; the divider alone would
    // just be a dangling line.
    if (mode == null) return const SizedBox.shrink();

    final venue = occurrence.venueLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, color: colorScheme.outlineVariant),
        AppSpacing.gapMd,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(mode.icon, size: 15, color: colorScheme.onSurfaceVariant),
            AppSpacing.hGapSm,
            // Expanded: a long venue address wraps instead of overflowing.
            Expanded(
              child: Text(
                venue.isEmpty ? mode.label : '${mode.label} · $venue',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
