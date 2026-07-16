import 'package:Shikshak/core/constants/app_images_const.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';

/// Full-bleed banner shown above the auth card: brand mark, an optional
/// two-line headline (second line in the accent color) and a supporting
/// illustration. Screens that put their own heading in the card below (e.g.
/// registration) can omit the headline and show just the logo and image.
class AuthHeroBanner extends StatelessWidget {
  const AuthHeroBanner({
    super.key,
    this.headline,
    this.headlineAccent,
    this.subtitle,
    required this.image,
    this.showBackButton = false,
    this.onBack,
  });

  /// First line of the headline, e.g. "Welcome".
  final String? headline;

  /// Second, accent-colored line of the headline, e.g. "Back!".
  final String? headlineAccent;

  final String? subtitle;
  final String image;

  /// Shows a circular back button above the brand row.
  final bool showBackButton;

  /// Called when the back button is tapped. Defaults to popping the route.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasHeadline = headline != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.sm,
      ),

      decoration: const BoxDecoration(gradient: AppColors.lightPageGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showBackButton) ...[
            _BackButton(
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            ),
            AppSpacing.gapMd,
          ],
          Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: Image.asset(AppImagesConst.onlyLogoWithoutText),
              ),
              AppSpacing.hGapSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName.toUpperCase(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Audiowide',
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Learn. Grow. Success',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          if (hasHeadline)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(headline!, style: theme.textTheme.headlineLarge),
                      Text(
                        headlineAccent!,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      AppSpacing.gapSm,
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hGapMd,
                Expanded(
                  flex: 6,
                  child: Image.asset(image, fit: BoxFit.contain),
                ),
              ],
            )
          else
            Center(child: Image.asset(image, height: 180, fit: BoxFit.contain)),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lightSurface,
      shape: const CircleBorder(),
      elevation: 0,
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(AppIcons.back, size: 18),
        color: AppColors.lightTextPrimary,
      ),
    );
  }
}
