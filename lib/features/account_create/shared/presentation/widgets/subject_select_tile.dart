import 'package:flutter/material.dart';

import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';

/// One tappable subject in the selection grid.
///
/// Works on the raw payload string (`"Mathematics"`) rather than an enum, so
/// the value selected is the value sent.
class SubjectSelectTile extends StatelessWidget {
  const SubjectSelectTile({
    super.key,
    required this.subject,
    required this.isSelected,
    required this.onTap,
  });

  final String subject;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.08)
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                width: isSelected ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  subjectIcon(subject),
                  size: 20,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                AppSpacing.hGapSm,
                Expanded(
                  child: Text(
                    subject,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
                // Reserves the checkmark's slot at all times, so labels don't
                // reflow when a tile is selected.
                SizedBox(
                  width: 18,
                  child: isSelected
                      ? Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: colorScheme.primary,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Glyph for a subject name, falling back to a neutral book for anything not
/// listed in `ReferenceData.subjects`.
IconData subjectIcon(String subject) => switch (subject) {
  'Mathematics' || 'Algebra' => Icons.functions_rounded,
  'Geometry' => Icons.change_history_rounded,
  'Science' => Icons.science_outlined,
  'Physics' => Icons.rocket_launch_outlined,
  'Chemistry' => Icons.biotech_outlined,
  'Biology' => Icons.eco_outlined,
  'English' || 'Hindi' => Icons.translate_rounded,
  'Social Science' => Icons.groups_outlined,
  'History' => Icons.history_edu_outlined,
  'Geography' => Icons.public_rounded,
  'Economics' => Icons.trending_up_rounded,
  'Accountancy' => Icons.calculate_outlined,
  'Business Studies' => Icons.storefront_outlined,
  'Computer Science' => Icons.computer_rounded,
  _ => Icons.menu_book_outlined,
};
