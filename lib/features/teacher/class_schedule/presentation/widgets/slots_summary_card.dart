import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_card.dart';

/// Hero card for the All Slots tab: how much the teacher has set up, and how
/// much of it is actually running.
class SlotsSummaryCard extends StatelessWidget {
  const SlotsSummaryCard({
    super.key,
    required this.slotCount,
    required this.activeCount,
    required this.durationLabel,
  });

  final int slotCount;

  /// Switched on and inside their date window.
  final int activeCount;

  /// Pre-formatted teaching time for a full week, e.g. `6h`.
  final String durationLabel;

  /// Says something only when part of the list is dormant — otherwise the
  /// counts above already tell the whole story.
  String get _subtitle {
    if (slotCount == 0) return 'Nothing set up yet';
    final dormant = slotCount - activeCount;
    if (dormant <= 0) return 'Every slot is running';
    return dormant == 1
        ? '1 slot is paused or out of date'
        : '$dormant slots are paused or out of date';
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
                  AppIcons.availability,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              AppSpacing.hGapMd,
              // Expanded + ellipsis: neither line may overflow the card on a
              // narrow phone.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your class slots',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    AppSpacing.gapXs,
                    Text(
                      _subtitle,
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
                value: '$slotCount',
                label: slotCount == 1 ? 'Slot' : 'Slots',
              ),
              const _StatDivider(),
              _SummaryStat(value: '$activeCount', label: 'Active'),
              const _StatDivider(),
              _SummaryStat(
                value: durationLabel.isEmpty ? '—' : durationLabel,
                label: 'Per week',
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
