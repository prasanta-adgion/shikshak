import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/initials_avatar.dart';

/// View model for an incoming class request. Populated with static data for
/// now; will be built from the bookings API once it exists.
class ClassRequest {
  const ClassRequest({
    required this.studentName,
    required this.subject,
    required this.grade,
    required this.schedule,
    required this.mode,
  });

  final String studentName;
  final String subject;
  final String grade;
  final String schedule;
  final String mode;
}

/// Incoming class request with accept/decline actions (UI only).
class ClassRequestTile extends StatelessWidget {
  const ClassRequestTile({super.key, required this.request});

  final ClassRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsAvatar(name: request.studentName, size: 44),
              AppSpacing.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.studentName,
                      style: theme.textTheme.titleMedium,
                    ),
                    AppSpacing.gapXs,
                    Text(
                      '${request.subject} • ${request.grade}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(request.mode),
                labelStyle: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.10),
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 0,
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          Text(
            request.schedule,
            style: theme.textTheme.bodyMedium,
          ),
          AppSpacing.gapLg,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(
                      color: theme.colorScheme.error.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              AppSpacing.hGapMd,
              Expanded(
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 42)),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
