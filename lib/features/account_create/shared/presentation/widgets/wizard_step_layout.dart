import 'package:flutter/material.dart';

import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../domain/entities/profile_step.dart';
import 'wizard_step_header.dart';

class WizardStepLayout extends StatelessWidget {
  final ProfileStep step;

  final List<Widget> children;

  /// Corner rounding of the white panel. The clip uses the same value, so the
  /// header's tint always follows the corners it is given.
  final BorderRadius borderRadius;

  const WizardStepLayout({
    super.key,
    required this.step,
    required this.children,
    this.borderRadius = defaultRadius,
  });

  static const BorderRadius defaultRadius = BorderRadius.all(
    Radius.circular(AppRadius.sm),
  );

  /// How far the white panel rides up over the header, and the radius of the
  /// corners it rounds off there.
  static const double _panelLift = AppRadius.md;

  static const BorderRadius _panelRadius = BorderRadius.vertical(
    top: Radius.circular(_panelLift),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: borderRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: AppShadows.soft(theme.brightness),
      ),
      // Clipped so the header's tint runs to the panel's rounded top corners.
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WizardStepHeader(step: step),

            Container(
              transform: Matrix4.translationValues(0, -_panelLift, 0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: _panelRadius,
              ),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0) AppSpacing.gapXl,
                    children[i],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
