import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';

/// Gradient hero card at the top of the student dashboard.
class StudentWelcomeCard extends StatelessWidget {
  const StudentWelcomeCard({super.key, required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      gradient: AppColors.primaryGradient,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi $firstName 👋',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                AppSpacing.gapSm,
                Text(
                  'Unlock your potential — find the perfect tutor for your next goal.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                AppSpacing.gapLg,
                AppButton(
                  label: 'Explore Teachers',
                  onPressed: () {},
                  expanded: false,
                  color: Colors.white,
                  foregroundColor: AppColors.primary,
                ),
              ],
            ),
          ),
          AppSpacing.hGapLg,
          Container(
            height: 84,
            width: 84,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: const BorderRadius.all(
                Radius.circular(AppRadius.lg),
              ),
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}
