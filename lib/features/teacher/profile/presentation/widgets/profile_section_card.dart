import 'package:flutter/material.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_card.dart';

/// A titled block of the profile: icon + title, an optional edit action, then
/// the section's own content.
///
/// [onEdit] is nullable so a section can opt out of the affordance entirely
/// rather than showing a button that does nothing.
class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.onEdit,
    this.count,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final VoidCallback? onEdit;

  /// Appended to the title as `Documents (5)` for repeatable sections.
  final int? count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              AppSpacing.hGapSm,
              Expanded(
                child: Text(
                  count == null ? title : '$title ($count)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              if (onEdit != null)
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: theme.textTheme.labelMedium,
                  ),
                ),
            ],
          ),
          AppSpacing.gapMd,
          Divider(height: 1, color: colorScheme.outlineVariant),
          AppSpacing.gapLg,
          ...children,
        ],
      ),
    );
  }
}
