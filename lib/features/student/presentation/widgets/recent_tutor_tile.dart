import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/initials_avatar.dart';
import '../models/tutor_info.dart';

/// Row tile in the "Recent Tutors" list.
class RecentTutorTile extends StatelessWidget {
  const RecentTutorTile({super.key, required this.tutor});

  final TutorInfo tutor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: () {},
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          InitialsAvatar(name: tutor.name, size: 52),
          AppSpacing.hGapLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tutor.name,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.gapXs,
                Text(
                  '${tutor.subject} • ${tutor.qualification}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          AppSpacing.hGapMd,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.star,
                    size: 16,
                    color: theme.colorScheme.secondary,
                  ),
                  AppSpacing.hGapXs,
                  Text(
                    tutor.rating.toStringAsFixed(1),
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
              AppSpacing.gapXs,
              Text(
                '₹${tutor.feePerHour}/hr',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
