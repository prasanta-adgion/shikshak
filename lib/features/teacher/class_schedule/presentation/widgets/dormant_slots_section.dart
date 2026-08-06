import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/date_time_picker_func.dart';
import '../../domain/entities/class_slot.dart';
import 'slot_accent.dart';

/// Recurrences that produced no class in the week on screen, each with the
/// reason why.
///
/// Without this, a teacher who set a class up and then sees an empty day has
/// no way to tell whether the app lost it or the class simply is not running
/// yet.
class DormantSlotsSection extends StatelessWidget {
  const DormantSlotsSection({super.key, required this.entries});

  final List<(ClassSlot, SlotDormancy)> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Not running this week',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall,
        ),
        AppSpacing.gapXs,
        Text(
          'These classes are on your schedule but have no session in this week.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        AppSpacing.gapMd,
        for (final (slot, reason) in entries) ...[
          _DormantSlotTile(slot: slot, reason: reason),
          AppSpacing.gapSm,
        ],
      ],
    );
  }
}

class _DormantSlotTile extends StatelessWidget {
  const _DormantSlotTile({required this.slot, required this.reason});

  final ClassSlot slot;
  final SlotDormancy reason;

  /// Turns the reason into something with a date in it wherever there is one
  /// to give — "Starts later" alone leaves the obvious question unanswered.
  String get _explanation => switch (reason) {
    SlotDormancy.notStarted when slot.validFrom != null =>
      'Starts ${DateTimeUtils.dayMonthYear(slot.validFrom!)}',
    SlotDormancy.ended when slot.validUntil != null =>
      'Ended ${DateTimeUtils.dayMonthYear(slot.validUntil!)}',
    SlotDormancy.paused => 'Paused',
    _ => reason.label,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = SlotAccent.of(slot.colorTag, colorScheme);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: AppRadius.card,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 4,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.6),
              borderRadius: AppRadius.chip,
            ),
          ),
          AppSpacing.hGapMd,
          // Expanded + ellipsis: the title and its meta line must not push the
          // reason badge off a narrow phone.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge,
                ),
                AppSpacing.gapXs,
                Text(
                  '${slot.day.label}s · ${slot.timeRangeLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.hGapSm,
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: AppRadius.chip,
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    reason == SlotDormancy.paused
                        ? AppIcons.inactive
                        : AppIcons.schedule,
                    size: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  AppSpacing.hGapXs,
                  Flexible(
                    child: Text(
                      _explanation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
