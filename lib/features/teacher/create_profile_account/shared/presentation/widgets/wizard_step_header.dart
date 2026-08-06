import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_images_const.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../domain/entities/profile_step.dart';

/// Tinted top section of the step panel: the step's own title and subtitle
/// beside the shared account-setup illustration.
///
/// The artwork is identical on all five steps, so it stays warm in the image
/// cache and only the text changes as the wizard advances.
class WizardStepHeader extends StatelessWidget {
  const WizardStepHeader({super.key, required this.step});

  final ProfileStep step;

  /// Decode width for the illustration — roughly 2x its layout size, which is
  /// enough for any DPR without decoding the full-resolution asset.
  static const int _decodeWidth = 320;
  static const double _artHeight = 100;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ColoredBox(
      color: colorScheme.primary.withValues(alpha: 0.09),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.xs,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    step.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  AppSpacing.gapSm,
                  Text(
                    step.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.hGapSm,
            const Expanded(flex: 4, child: _HeaderArt()),
          ],
        ),
      ),
    );
  }
}

/// Const so it is never rebuilt when the surrounding step changes.
class _HeaderArt extends StatelessWidget {
  const _HeaderArt();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppImagesConst.accountCreateForm,
      height: WizardStepHeader._artHeight,
      cacheWidth: WizardStepHeader._decodeWidth,
      filterQuality: FilterQuality.medium,
      fit: BoxFit.contain,
      // Decorative: the heading beside it already says where the teacher is.
      excludeFromSemantics: true,
    );
  }
}
