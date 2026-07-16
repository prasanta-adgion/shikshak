import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/user_role.dart';

/// Compact, image-led role toggle shown inline on the login screen.
///
/// Unlike the old full [RoleCard] (a whole selection screen), this is just a
/// tappable avatar + label pair — selecting one updates the login form's
/// role in place, no navigation involved.
class SelectRoleCard extends StatelessWidget {
  const SelectRoleCard({
    super.key,
    required this.role,
    required this.image,
    required this.selected,
    required this.onSelected,
  });

  final UserRole role;
  final String image;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;

    return Material(
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.08)
          : theme.colorScheme.surface,
      borderRadius: AppRadius.card,
      child: InkWell(
        onTap: onSelected,
        borderRadius: AppRadius.card,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.card,
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                backgroundImage: AssetImage(image),
              ),
              AppSpacing.gapXs,
              Text(
                "I'm a\n${role.label}",
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
