import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../domain/entities/student_profile.dart';

/// Which alerts are switched on, as tinted chips.
///
/// Both states are shown rather than only the enabled ones: "SMS alerts is
/// off" is the fact the student came here to check.
class NotificationPrefsWrap extends StatelessWidget {
  const NotificationPrefsWrap({super.key, required this.preferences});

  final List<NotificationPreference> preferences;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final preference in preferences) _PreferenceChip(preference),
      ],
    );
  }
}

class _PreferenceChip extends StatelessWidget {
  const _PreferenceChip(this.preference);

  final NotificationPreference preference;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOn = preference.isEnabled;
    final accent = isOn ? AppColors.success : colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: AppRadius.chip,
        border: Border.all(color: accent.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOn ? AppIcons.preferenceOn : AppIcons.preferenceOff,
            size: 14,
            color: accent,
          ),
          AppSpacing.hGapXs,
          Text(
            preference.label,
            style: theme.textTheme.labelSmall?.copyWith(color: accent),
          ),
        ],
      ),
    );
  }
}
