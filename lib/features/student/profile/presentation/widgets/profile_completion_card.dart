import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_card.dart';
import '../../domain/entities/student_profile.dart';

/// How far the profile is from finished, and exactly what is missing.
///
/// A percentage on its own only tells the student they are behind; the chips
/// below it turn that into something they can act on.
class ProfileCompletionCard extends StatelessWidget {
  const ProfileCompletionCard({super.key, required this.profile});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isComplete = profile.isComplete;
    final accent = isComplete ? AppColors.success : colorScheme.primary;
    final missing = profile.missingFields;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ProgressRing(
                // A finished profile reads 100% even if the server counts a
                // different set of fields than [StudentProfileField] does.
                value: isComplete ? 1 : profile.completion,
                accent: accent,
              ),
              AppSpacing.hGapLg,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isComplete
                          ? 'Profile complete'
                          : 'Complete your profile',
                      style: theme.textTheme.titleSmall,
                    ),
                    AppSpacing.gapXs,
                    Text(
                      isComplete
                          ? 'Everything teachers need to know about you is here.'
                          : '${profile.filledFieldCount} of '
                                '${profile.totalFieldCount} details added. '
                                'Finish up so teachers know who they are '
                                'teaching.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (missing.isNotEmpty && !isComplete) ...[
            AppSpacing.gapLg,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final field in missing) _MissingChip(label: field.label),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Circular gauge with the percentage in the middle.
class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.value, required this.accent});

  final double value;
  final Color accent;

  static const double _size = 56;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox.square(
      dimension: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: _size,
            child: CircularProgressIndicator(
              value: value.clamp(0, 1),
              strokeWidth: 5,
              strokeCap: StrokeCap.round,
              backgroundColor: accent.withValues(alpha: 0.14),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          Text(
            '${(value.clamp(0, 1) * 100).round()}%',
            style: theme.textTheme.labelMedium?.copyWith(color: accent),
          ),
        ],
      ),
    );
  }
}

class _MissingChip extends StatelessWidget {
  const _MissingChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.chip,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_rounded,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          AppSpacing.hGapXs,
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
