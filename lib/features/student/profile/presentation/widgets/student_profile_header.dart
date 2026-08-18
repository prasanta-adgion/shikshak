import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/date_time_picker_func.dart';
import '../../../../../shared/widgets/app_card.dart';
import '../../../../../shared/widgets/initials_avatar.dart';
import '../../domain/entities/student_profile.dart';
import 'profile_stat_strip.dart';

/// Cover banner, overlapping avatar, name, role, and the three facts that
/// answer "who is this" before any section is read.
class StudentProfileHeader extends StatelessWidget {
  const StudentProfileHeader({super.key, required this.profile});

  final StudentProfile profile;

  static const double _coverHeight = 104;
  static const double _avatarSize = 92;

  /// The ring that lifts the avatar off the cover behind it.
  static const double _avatarRing = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          SizedBox(
            // The avatar hangs half-way below the cover, and the box has to
            // be tall enough to hold that half — a Stack does not grow for an
            // overflowing child.
            height: _coverHeight + _avatarSize / 2,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _Cover(imageUrl: profile.coverImageUrl),
                ),
                Positioned(
                  top: _coverHeight - _avatarSize / 2,
                  child: _Avatar(
                    name: profile.user.fullName,
                    photoUrl: profile.avatarUrl,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Flexible + ellipsis: a long name must not push the
                    // verification tick off the card.
                    Flexible(
                      child: Text(
                        profile.user.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    if (profile.isEmailVerified) ...[
                      AppSpacing.hGapXs,
                      Icon(
                        AppIcons.verified,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                    ],
                  ],
                ),
                AppSpacing.gapSm,
                const _RolePill(),
                AppSpacing.gapSm,
                Text(
                  profile.user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                AppSpacing.gapLg,
                Divider(height: 1, color: colorScheme.outlineVariant),
                AppSpacing.gapLg,
                ProfileStatStrip(
                  stats: [
                    ProfileStat(
                      label: 'Member since',
                      value: profile.joinedAt == null
                          ? '—'
                          : DateTimeUtils.monthYear(profile.joinedAt!),
                    ),
                    ProfileStat(
                      label: 'Language',
                      value: profile.languageLabel,
                    ),
                    ProfileStat(
                      label: 'Verification',
                      value: profile.isEmailVerified
                          ? 'Verified'
                          : 'Unverified',
                      color: profile.isEmailVerified
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The banner behind the avatar: the student's own image when there is one,
/// the student brand gradient otherwise.
class _Cover extends StatelessWidget {
  const _Cover({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;

    return Container(
      height: StudentProfileHeader._coverHeight,
      decoration: const BoxDecoration(gradient: AppColors.studentGradient),
      // The gradient shows through whenever the image is missing, still
      // loading, or dead — the banner is never a blank rectangle.
      child: url == null || url.isEmpty
          ? null
          : Image.network(
              url,
              height: StudentProfileHeader._coverHeight,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const SizedBox.shrink(),
            ),
    );
  }
}

/// The photo, ringed in the card's own surface colour so it reads as sitting
/// on top of the cover rather than punched out of it.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.photoUrl});

  final String name;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const size = StudentProfileHeader._avatarSize;
    const inner = size - StudentProfileHeader._avatarRing * 2;

    return Container(
      height: size,
      width: size,
      padding: const EdgeInsets.all(StudentProfileHeader._avatarRing),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: AppShadows.soft(Theme.of(context).brightness),
      ),
      child: ClipOval(child: _photo(inner)),
    );
  }

  /// The initials hold the disc while the bytes are in flight and come back
  /// if the URL is dead — an empty circle reads as a broken screen.
  Widget _photo(double size) {
    final url = photoUrl;
    final fallback = InitialsAvatar(name: name, size: size);
    if (url == null || url.isEmpty) return fallback;

    return Image.network(
      url,
      height: size,
      width: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : fallback,
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: AppRadius.chip,
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.student, size: 13, color: colorScheme.primary),
          AppSpacing.hGapXs,
          Text(
            'Student',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
