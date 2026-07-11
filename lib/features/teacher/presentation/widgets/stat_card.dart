import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';

/// View model for a KPI card. Populated with static data for now; will be
/// built from the analytics API once it exists.
class DashboardStat {
  const DashboardStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.delta,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  /// e.g. "+3 this week"
  final String? delta;
}

/// Compact KPI card in the teacher stats grid.
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.stat});

  final DashboardStat stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.14),
              borderRadius: const BorderRadius.all(
                Radius.circular(AppRadius.xs),
              ),
            ),
            child: Icon(stat.icon, color: stat.color, size: 22),
          ),
          AppSpacing.gapMd,
          Text(stat.value, style: theme.textTheme.headlineMedium),
          AppSpacing.gapXs,
          Text(
            stat.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (stat.delta != null) ...[
            AppSpacing.gapXs,
            Text(
              stat.delta!,
              style: theme.textTheme.labelSmall?.copyWith(color: stat.color),
            ),
          ],
        ],
      ),
    );
  }
}
