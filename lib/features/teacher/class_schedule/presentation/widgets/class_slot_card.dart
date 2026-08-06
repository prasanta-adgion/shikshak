import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/date_time_picker_func.dart';
import '../../../../../shared/widgets/app_card.dart';
import '../../domain/entities/class_slot.dart';
import 'schedule_chips.dart';
import 'slot_accent.dart';

/// One recurring slot as the teacher created it.
///
/// The sibling of [ClassOccurrenceCard]: that one shows a class on a date,
/// this one shows the rule behind it — so it carries the validity window and
/// the on/off state instead of a "done" marker.
class ClassSlotCard extends StatelessWidget {
  const ClassSlotCard({super.key, required this.slot, this.onTap});

  final ClassSlot slot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = SlotAccent.of(slot.colorTag, colorScheme);
    final dormancy = slot.dormancy();

    return Opacity(
      // A slot that is switched off or out of its window is dimmed, never
      // hidden — the teacher still has to be able to find and fix it.
      opacity: dormancy == null ? 1 : 0.7,
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
                        slot: slot,
                        accent: accent,
                        dormancy: dormancy,
                      ),
                      AppSpacing.gapMd,
                      Text(
                        slot.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      if (slot.description?.trim().isNotEmpty ?? false) ...[
                        AppSpacing.gapXs,
                        Text(
                          slot.description!.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (slot.subjects.isNotEmpty ||
                          slot.classes.isNotEmpty) ...[
                        AppSpacing.gapMd,
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            for (final subject in slot.subjects)
                              SlotTag(label: subject, color: accent),
                            for (final className in slot.classes)
                              SlotTag(
                                label: className,
                                color: colorScheme.onSurfaceVariant,
                              ),
                          ],
                        ),
                      ],
                      AppSpacing.gapMd,
                      _FooterRows(slot: slot),
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

/// Time range, duration, and why the slot is quiet when it is.
class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.slot,
    required this.accent,
    required this.dormancy,
  });

  final ClassSlot slot;
  final Color accent;
  final SlotDormancy? dormancy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final duration = slot.durationLabel;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TimeRangePill(
          label: slot.timeRangeLabel,
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
        // Only the exceptions are badged. Running is the normal case, and
        // marking it too would put a badge on every card for no information.
        if (dormancy case final reason?)
          StatusBadge(
            label: reason.label,
            icon: reason == SlotDormancy.paused
                ? AppIcons.inactive
                : AppIcons.schedule,
            color: reason == SlotDormancy.ended
                ? colorScheme.error
                : colorScheme.onSurfaceVariant,
          ),
      ],
    );
  }
}

/// Delivery mode, venue, and the window the recurrence runs for.
class _FooterRows extends StatelessWidget {
  const _FooterRows({required this.slot});

  final ClassSlot slot;

  /// `From 5 Aug 2026`, `Until 30 Sep 2026`, or both ends when both are set.
  /// Empty when the slot repeats with no bounds at all.
  static String validityLabel(ClassSlot slot) {
    final from = slot.validFrom;
    final until = slot.validUntil;

    if (from != null && until != null) {
      return '${DateTimeUtils.dayMonthYear(from)} – '
          '${DateTimeUtils.dayMonthYear(until)}';
    }
    if (from != null) return 'From ${DateTimeUtils.dayMonthYear(from)}';
    if (until != null) return 'Until ${DateTimeUtils.dayMonthYear(until)}';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mode = slot.mode;
    final venue = slot.venueLabel;
    final validity = validityLabel(slot);

    final rows = <Widget>[
      if (mode != null)
        _MetaLine(
          icon: mode.icon,
          text: venue.isEmpty ? mode.label : '${mode.label} · $venue',
        ),
      if (validity.isNotEmpty)
        _MetaLine(icon: AppIcons.schedule, text: validity),
    ];

    // Nothing to add beyond the times and tags above; the divider alone would
    // just be a dangling line.
    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, color: colorScheme.outlineVariant),
        AppSpacing.gapMd,
        for (final (index, row) in rows.indexed) ...[
          if (index > 0) AppSpacing.gapXs,
          row,
        ],
      ],
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: colorScheme.onSurfaceVariant),
        AppSpacing.hGapSm,
        // Expanded: a long venue address wraps instead of overflowing.
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
