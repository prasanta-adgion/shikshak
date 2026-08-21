import 'package:flutter/material.dart';

import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';

/// Small read-only pill for a subject, class or language.
///
/// Matches the chips on the discovery card, so a subject reads the same
/// whether the student is scanning the list or standing on the profile.
class TeacherTag extends StatelessWidget {
  const TeacherTag({super.key, required this.label, this.muted = false});

  final String label;

  /// Secondary values — classes, languages — sit back so the subjects the
  /// teacher leads with stay the loudest thing in the block.
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final tint = muted ? colorScheme.onSurfaceVariant : colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: AppRadius.chip,
        border: Border.all(color: tint.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: tint),
      ),
    );
  }
}
