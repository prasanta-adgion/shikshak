import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';

/// View model for a subject category tile. Populated with static data for
/// now; will be built from the discovery API once it exists.
class SubjectCategory {
  const SubjectCategory({
    required this.name,
    required this.icon,
    required this.color,
  });

  final String name;
  final IconData icon;
  final Color color;
}

/// Single tile in the categories grid.
class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.category, this.onTap});

  final SubjectCategory category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap ?? () {},
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.14),
              borderRadius: const BorderRadius.all(
                Radius.circular(AppRadius.sm),
              ),
            ),
            child: Icon(category.icon, color: category.color, size: 26),
          ),
          AppSpacing.gapSm,
          Text(
            category.name,
            style: theme.textTheme.labelMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
