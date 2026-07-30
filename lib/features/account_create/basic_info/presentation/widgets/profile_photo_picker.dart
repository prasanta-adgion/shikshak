import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';

/// Identity row at the top of step 1: the teacher's name, email and phone on
/// the left, the tappable avatar on the right.
///
/// The details are read-only here — signup already captured and verified them.
class ProfilePhotoPicker extends StatelessWidget {
  const ProfilePhotoPicker({
    super.key,
    required this.onTap,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.photoPath,
    this.size = 76,
  });

  /// Local file path of the picked image; `null` shows the placeholder.
  final String? photoPath;
  final VoidCallback onTap;

  final String name;
  final String email;
  final String phoneNumber;

  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPhoto = photoPath != null && photoPath!.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Each line is dropped when empty rather than rendering a blank
              // row — the account may not carry every detail.
              if (name.isNotEmpty) ...[
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                AppSpacing.gapSm,
              ],
              if (email.isNotEmpty) _DetailLine(icon: AppIcons.email, value: email),
              if (phoneNumber.isNotEmpty) ...[
                AppSpacing.gapXs,
                _DetailLine(icon: AppIcons.phone, value: phoneNumber),
              ],
            ],
          ),
        ),
        AppSpacing.hGapMd,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAvatar(context, hasPhoto: hasPhoto),
            AppSpacing.gapSm,
            Text(
              hasPhoto ? 'Change photo' : 'Add photo',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, {required bool hasPhoto}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: hasPhoto ? 'Change profile photo' : 'Add profile photo',
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: size,
          width: size,
          child: Stack(
            children: [
              Container(
                height: size,
                width: size,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: hasPhoto
                    ? Image.file(
                        File(photoPath!),
                        fit: BoxFit.cover,
                        // A path can go stale between sessions; fall back
                        // rather than throwing inside the build.
                        errorBuilder: (context, error, stackTrace) =>
                            _Placeholder(size: size),
                      )
                    : _Placeholder(size: size),
              ),
              Positioned(
                right: 0,
                bottom: AppSpacing.xs,
                child: Container(
                  height: 26,
                  width: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.surface, width: 2),
                  ),
                  child: Icon(
                    Icons.photo_camera_rounded,
                    size: 13,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One muted icon + value line under the teacher's name.
class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        AppSpacing.hGapXs,
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.person_rounded,
      size: size * 0.5,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
    );
  }
}
