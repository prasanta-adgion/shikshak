import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_card.dart';
import '../../../../../shared/widgets/initials_avatar.dart';
import '../../domain/entities/teacher_details.dart';
import 'teacher_tag.dart';

/// Who the teacher is: photo, name, where they are, and what they teach.
class TeacherDetailsHeader extends StatelessWidget {
  const TeacherDetailsHeader({super.key, required this.teacher});

  final TeacherDetails teacher;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final location = teacher.location;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TeacherAvatar(teacher: teacher),
              AppSpacing.hGapLg,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            teacher.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        if (teacher.isVerified) ...[
                          AppSpacing.hGapXs,
                          Icon(
                            AppIcons.verified,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                    if (location != null) ...[
                      AppSpacing.gapXs,
                      _MetaLine(icon: AppIcons.address, text: location),
                    ],
                    if (teacher.languages.isNotEmpty) ...[
                      AppSpacing.gapXs,
                      _MetaLine(
                        icon: AppIcons.language,
                        text: teacher.languages.join(', '),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (teacher.subjects.isNotEmpty) ...[
            AppSpacing.gapLg,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final subject in teacher.subjects)
                  TeacherTag(label: subject),
              ],
            ),
          ],
          if (teacher.classes.isNotEmpty) ...[
            AppSpacing.gapSm,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final className in teacher.classes)
                  TeacherTag(label: className, muted: true),
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

  final TeacherDetails teacher;

  static const double _size = 72;

  @override
  Widget build(BuildContext context) {
    final fallback = InitialsAvatar(name: teacher.displayName, size: _size);
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

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        AppSpacing.hGapXs,
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
