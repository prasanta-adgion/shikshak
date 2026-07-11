import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/initials_avatar.dart';
import '../models/tutor_info.dart';

/// Card in the horizontally scrolling "Featured Teachers" list.
class FeaturedTeacherCard extends StatelessWidget {
  const FeaturedTeacherCard({super.key, required this.tutor});

  final TutorInfo tutor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 200,
      child: AppCard(
        onTap: () {},
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InitialsAvatar(name: tutor.name, size: 48),
                const Spacer(),
                Icon(AppIcons.star, color: theme.colorScheme.secondary, size: 18),
                AppSpacing.hGapXs,
                Text(
                  tutor.rating.toStringAsFixed(1),
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
            AppSpacing.gapMd,
            Text(
              tutor.name,
              style: theme.textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.gapXs,
            Text(
              '${tutor.subject} • ${tutor.experience}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.gapMd,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${tutor.feePerHour}/hr',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  '${tutor.reviews} reviews',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
