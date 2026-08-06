import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/date_time_picker_func.dart';
import '../../domain/entities/teacher_profile.dart';

/// Review state of the profile, tinted by outcome.
///
/// Kept local to the profile feature rather than reusing the wizard's
/// `WizardInfoNote`: that widget is tied to the wizard's single accent colour,
/// and this one has to change colour per status.
class ProfileStatusBanner extends StatelessWidget {
  const ProfileStatusBanner({
    super.key,
    required this.status,
    this.reviewedAt,
    this.reviewNotes,
  });

  final ProfileReviewStatus status;
  final DateTime? reviewedAt;
  final String? reviewNotes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = switch (status) {
      ProfileReviewStatus.approved => AppColors.success,
      ProfileReviewStatus.pending => AppColors.warning,
      ProfileReviewStatus.rejected => theme.colorScheme.error,
    };
    final icon = switch (status) {
      ProfileReviewStatus.approved => Icons.verified_rounded,
      ProfileReviewStatus.pending => Icons.hourglass_top_rounded,
      ProfileReviewStatus.rejected => Icons.report_gmailerrorred_rounded,
    };

    // Rejections explain themselves through the reviewer's note when there is
    // one; otherwise fall back to the generic copy.
    final detail =
        status == ProfileReviewStatus.rejected &&
            (reviewNotes?.trim().isNotEmpty ?? false)
        ? reviewNotes!
        : status.message;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 34,
            width: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.label,
                  style: theme.textTheme.titleSmall?.copyWith(color: accent),
                ),
                AppSpacing.gapXs,
                Text(
                  detail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (reviewedAt != null) ...[
                  AppSpacing.gapXs,
                  Text(
                    'Reviewed on ${DateTimeUtils.dayMonthYear(reviewedAt!)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
