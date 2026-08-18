import 'package:flutter/material.dart';

import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_card.dart';

/// A titled block of the profile: a tinted icon, the title, then the
/// section's own rows.
///
/// The card owns the spacing between [children] rather than each row padding
/// itself, so no section ends with a stray gap above its bottom edge.
class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.count,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  /// Appended to the title as `Social links (3)` for repeatable sections.
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
              Container(
                height: 30,
                width: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Icon(icon, size: 16, color: colorScheme.primary),
              ),
              AppSpacing.hGapMd,
              Expanded(
                child: Text(
                  count == null ? title : '$title ($count)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          Divider(height: 1, color: colorScheme.outlineVariant),
          AppSpacing.gapLg,
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0) AppSpacing.gapLg,
            children[index],
          ],
        ],
      ),
    );
  }
}
