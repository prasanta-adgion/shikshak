import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_card.dart';
import '../../../../../shared/widgets/initials_avatar.dart';
import '../../domain/entities/teacher.dart';

/// One teacher in the discovery list.
///
/// Every block below the header is optional — a teacher who has filled in
/// nothing but their name still gets a card that reads as finished, rather
/// than one full of dashes.
class TeacherCard extends StatelessWidget {
  const TeacherCard({super.key, required this.teacher, this.onTap});

  final Teacher teacher;
  final VoidCallback? onTap;

  /// Beyond this, classes are summarised as `+3` — a teacher covering ten
  /// classes would otherwise own half the card.
  static const int _maxClassChips = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final location = teacher.location;
    final subjects = teacher.subjectsLabel;
    final bio = teacher.shortBio;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TeacherAvatar(teacher: teacher),
              AppSpacing.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            teacher.name.isEmpty ? 'Teacher' : teacher.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        if (teacher.isVerified) ...[
                          AppSpacing.hGapXs,
                          Icon(
                            AppIcons.verified,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                    if (subjects != null) ...[
                      AppSpacing.gapXs,
                      Text(
                        subjects,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                    if (location != null) ...[
                      AppSpacing.gapXs,
                      Row(
                        children: [
                          Icon(
                            AppIcons.address,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          AppSpacing.hGapXs,
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (bio != null) ...[
            AppSpacing.gapMd,
            Text(
              bio,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (teacher.classes.isNotEmpty) ...[
            AppSpacing.gapMd,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final className in teacher.classes.take(_maxClassChips))
                  _TeacherChip(label: className),
                if (teacher.classes.length > _maxClassChips)
                  _TeacherChip(
                    label: '+${teacher.classes.length - _maxClassChips}',
                  ),
              ],
            ),
          ],
          if (teacher.languages.isNotEmpty) ...[
            AppSpacing.gapMd,
            Row(
              children: [
                Icon(
                  AppIcons.language,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                AppSpacing.hGapXs,
                Expanded(
                  child: Text(
                    teacher.languages.join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// The signed photo when there is one, initials when there is not — and
/// initials again if the URL has expired, which is the failure this endpoint
/// actually produces.
class _TeacherAvatar extends StatelessWidget {
  const _TeacherAvatar({required this.teacher});

  final Teacher teacher;

  static const double _size = 56;

  @override
  Widget build(BuildContext context) {
    final fallback = InitialsAvatar(
      name: teacher.name.isEmpty ? 'Teacher' : teacher.name,
      size: _size,
    );
    if (!teacher.hasPhoto) return fallback;

    return ClipOval(
      child: Image.network(
        teacher.photoUrl!,
        height: _size,
        width: _size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
        // Initials hold the space while the photo arrives, so the row does
        // not jump when it lands.
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : fallback,
      ),
    );
  }
}

/// Matches the read-only chips on the teacher's own profile, so a class reads
/// the same wherever it is shown.
class _TeacherChip extends StatelessWidget {
  const _TeacherChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: AppRadius.chip,
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.primary),
      ),
    );
  }
}
