import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../dummy/teacher_dummy_data.dart';

/// Monthly earnings summary with a lightweight bar sparkline
/// (plain containers — no chart dependency).
class EarningsCard extends StatelessWidget {
  const EarningsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      gradient: AppColors.teacherGradient,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Earnings this month',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                AppSpacing.gapSm,
                Text(
                  TeacherDummyData.earningsThisMonth,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                AppSpacing.gapSm,
                Row(
                  children: [
                    const Icon(
                      AppIcons.trendingUp,
                      color: Colors.white,
                      size: 18,
                    ),
                    AppSpacing.hGapXs,
                    Flexible(
                      child: Text(
                        TeacherDummyData.earningsGrowth,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.hGapLg,
          // Mini weekly bar chart.
          SizedBox(
            height: 88,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final value in TeacherDummyData.weeklyEarnings) ...[
                  Container(
                    width: 8,
                    height: 88 * value,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppRadius.xs / 2),
                      ),
                    ),
                  ),
                  AppSpacing.hGapXs,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
