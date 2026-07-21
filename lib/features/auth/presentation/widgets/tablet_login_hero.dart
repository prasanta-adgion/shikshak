import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_images_const.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Left-hand hero shown on the tablet login screen. It is overlaid on top of
/// the [AppImagesConst.loginBgOfTablet] background (whose student illustration
/// and bottom wave are baked into the artwork), so this widget only paints the
/// text/brand content that sits in the open areas of that image.
class TabletLoginHero extends StatelessWidget {
  const TabletLoginHero({
    super.key,
    this.headline = 'Welcome',
    this.headlineAccent = 'Back!',
    this.subtitle = 'Continue your journey with ${AppConstants.appName}.',
    this.tagline = 'Education is the key\nto a brighter tomorrow.',
  });

  final String headline;
  final String headlineAccent;
  final String subtitle;
  final String tagline;

  static const _features = <_HeroFeature>[
    _HeroFeature(icon: Icons.menu_book_rounded, label: 'Learn\nAnywhere'),
    _HeroFeature(icon: Icons.school_rounded, label: 'Grow Your\nSkills'),
    _HeroFeature(
      icon: Icons.emoji_events_rounded,
      label: 'Achieve\nYour Goals',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BrandRow(theme: theme),
          AppSpacing.gapXxxl,
          Text(
            headline,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              height: 1.05,
            ),
          ),
          Text(
            headlineAccent,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
              height: 1.05,
            ),
          ),
          AppSpacing.gapSm,
          const _AccentUnderline(),
          AppSpacing.gapLg,
          Text(
            subtitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
          AppSpacing.gapXxxl,
          Row(
            children: [
              for (final feature in _features) ...[
                _FeatureChip(feature: feature),
                if (feature != _features.last) AppSpacing.hGapLg,
              ],
            ],
          ),
          // The baked-in illustration and wave occupy the lower half of the
          // background image; this flexible gap lets the tagline sit above it.
          const Spacer(),
          Text(
            tagline,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          AppSpacing.gapSm,
          const _AccentUnderline(),
        ],
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Image.asset(AppImagesConst.onlyLogoWithoutText),
        ),
        AppSpacing.hGapSm,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppConstants.appName.toUpperCase(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: 'Audiowide',
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            Text(
              'Learn. Grow. Success',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Short amber underline used to accent the headline and tagline.
class _AccentUnderline extends StatelessWidget {
  const _AccentUnderline();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 4,
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        borderRadius: AppRadius.chip,
      ),
    );
  }
}

class _HeroFeature {
  const _HeroFeature({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.feature});

  final _HeroFeature feature;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.lightSurface.withValues(alpha: 0.7),
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
          ),
          child: Icon(feature.icon, color: AppColors.primary, size: 26),
        ),
        AppSpacing.gapSm,
        Text(
          feature.label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            height: 1.15,
          ),
        ),
      ],
    );
  }
}
