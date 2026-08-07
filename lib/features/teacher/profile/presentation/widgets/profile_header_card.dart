import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../../../core/providers/core_providers.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_card.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../../../../shared/widgets/media_source_sheet.dart';
import '../../../create_profile_account/about_you/presentation/providers/about_you_providers.dart';
import '../../domain/entities/teacher_profile.dart';
import '../providers/teacher_profile_providers.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key, required this.profile});

  final TeacherProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photoUrl = profile.user.avatarUrl;

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

/// The teacher's photo, and the control that replaces it.
///
/// Tapping the disc picks an image, uploads it to the avatar endpoint and
/// re-reads the profile. The camera badge is the affordance; the whole 72pt
/// circle is the target, since the badge alone is well under a thumb.
class _Avatar extends ConsumerStatefulWidget {
  const _Avatar({required this.name, this.photoUrl});

  final String name;
  final String? photoUrl;

  static const double size = 72;
  static const double badgeSize = 26;

  @override
  ConsumerState<_Avatar> createState() => _AvatarState();
}

class _AvatarState extends ConsumerState<_Avatar> {
  /// The file just picked. Shown ahead of [_Avatar.photoUrl] — it is the newer
  /// of the two, and it renders without waiting on a round trip.
  final _localPath = ValueNotifier<String?>(null);

  final _isUploading = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _localPath.dispose();
    _isUploading.dispose();
    super.dispose();
  }

  bool get _hasPhoto =>
      _localPath.value != null || (widget.photoUrl?.isNotEmpty ?? false);

  String get _initials {
    final parts = widget.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _changePhoto() async {
    // A second tap mid-upload would race the first one's result.
    if (_isUploading.value) return;

    final source = await MediaSourceSheet.show(context, title: 'Profile photo');
    if (source == null || !mounted) return;

    final picked = await ref
        .read(mediaPickerProvider)
        .pickImage(
          source: source,
          crop: true,
          // Square, because the avatar is a circle: better the teacher decides
          // what gets cut off than BoxFit.cover.
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        );
    if (picked == null || !mounted) return;

    _isUploading.value = true;
    final result = await ref
        .read(uploadProfileImageUseCaseProvider)
        .call(picked.path);
    if (!mounted) return;

    _isUploading.value = false;

    result.fold(
      onSuccess: (_) {
        _localPath.value = picked.path;
        AppSnackbar.showSuccess(context, 'Profile photo updated.');
        // The upload lands on the user row, so what is on screen is now stale.
        // The picked file keeps showing either way.
        ref.read(teacherProfileNotifierProvider.notifier).refresh();
      },
      onFailure: (exception) =>
          AppSnackbar.showError(context, exception.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: _changePhoto,
      child: SizedBox.square(
        dimension: _Avatar.size,
        child: Stack(
          children: [
            // Two listeners rather than one merged builder: a repaint of the
            // spinner must not decode the photo again.
            ValueListenableBuilder<String?>(
              valueListenable: _localPath,
              builder: (context, localPath, _) => Semantics(
                button: true,
                label: _hasPhoto ? 'Change profile photo' : 'Add profile photo',
                child: Container(
                  height: _Avatar.size,
                  width: _Avatar.size,
                  alignment: Alignment.center,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                  child: _hasPhoto
                      ? _photo(localPath)
                      : _InitialsText(initials: _initials),
                ),
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _isUploading,
              builder: (context, isUploading, _) => !isUploading
                  ? const SizedBox.shrink()
                  : Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            // Inside the 72pt box rather than hanging off it, so the badge
            // does not push the name and role beside it out of place.
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                height: _Avatar.badgeSize,
                width: _Avatar.badgeSize,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.camera,
                  size: 13,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The initials hold the disc while the bytes are in flight and come back if
  /// the URL is dead — an empty circle reads as a broken screen.
  Widget _photo(String? localPath) {
    if (localPath != null) {
      return Image.file(
        File(localPath),
        height: _Avatar.size,
        width: _Avatar.size,
        fit: BoxFit.cover,
        // The picker writes into a cache directory, which can be swept.
        errorBuilder: (context, error, stackTrace) =>
            _InitialsText(initials: _initials),
      );
    }

    return Image.network(
      widget.photoUrl!,
      height: _Avatar.size,
      width: _Avatar.size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          _InitialsText(initials: _initials),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _InitialsText(initials: _initials),
    );
  }
}

class _InitialsText extends StatelessWidget {
  const _InitialsText({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontSize: _Avatar.size * 0.34,
        ),
      ),
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
