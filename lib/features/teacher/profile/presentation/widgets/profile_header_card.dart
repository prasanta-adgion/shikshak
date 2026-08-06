import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_card.dart';
import '../../domain/entities/teacher_profile.dart';

/// Identity block at the top of the profile: photo, name, contact, role.
///
/// Sits on the brand gradient, so every colour here is a fixed white tint
/// rather than a scheme lookup — the card looks the same in both themes.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key, required this.profile});

  final TeacherProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photoUrl = profile.basicInfo.profilePhotoUrl;

    return AppCard(
      gradient: AppColors.primaryGradient,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(name: profile.user.fullName, photoUrl: photoUrl),
              AppSpacing.hGapLg,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.user.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (profile.isEmailVerified) ...[
                          AppSpacing.hGapXs,
                          const Icon(
                            Icons.verified_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ],
                    ),
                    AppSpacing.gapSm,
                    _RolePill(label: profile.user.role.label),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapLg,
          _ContactLine(icon: AppIcons.email, value: profile.user.email),
          if (profile.phoneNumber != null) ...[
            AppSpacing.gapSm,
            _ContactLine(icon: AppIcons.phone, value: profile.phoneNumber!),
          ],
        ],
      ),
    );
  }
}

/// The remote photo when there is one, initials on a translucent disc
/// otherwise. `InitialsAvatar` is not reused here: it tints itself from the
/// colour scheme, which disappears against the gradient.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.photoUrl});

  final String name;
  final String? photoUrl;

  static const double size = 72;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
        image: photoUrl == null || photoUrl!.isEmpty
            ? null
            : DecorationImage(
                image: NetworkImage(photoUrl!),
                fit: BoxFit.cover,
              ),
      ),
      child: photoUrl == null || photoUrl!.isEmpty
          ? Text(
              _initials,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontSize: size * 0.34,
              ),
            )
          : null,
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: AppRadius.chip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(AppIcons.teacher, size: 13, color: Colors.white),
          AppSpacing.hGapXs,
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.white.withValues(alpha: 0.85)),
        AppSpacing.hGapSm,
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }
}
