import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../shared/widgets/app_loading_button.dart';
import '../../../../../shared/widgets/app_outlined_button.dart';
import '../../domain/entities/profile_step.dart';

class WizardActionBar extends StatelessWidget {
  const WizardActionBar({
    super.key,
    required this.step,
    required this.maxWidth,
    required this.isVisible,
    required this.onBack,
    required this.continueButtonOnpressed,
    this.isSubmitting = false,
  });

  final ProfileStep step;
  final double maxWidth;
  final bool isVisible;
  final bool isSubmitting;
  final VoidCallback onBack;
  final VoidCallback continueButtonOnpressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedSlide(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      offset: isVisible ? Offset.zero : const Offset(0, 1),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: isVisible ? 1 : 0,
        // Nothing to tap once it has slid away.
        child: IgnorePointer(
          ignoring: !isVisible,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              boxShadow: AppShadows.soft(theme.brightness),
            ),
            child: Padding(
              padding: context.responsivePagePadding.copyWith(
                top: AppSpacing.md,
                bottom: AppSpacing.md,
              ),
              child: CenteredConstrainedBox(
                maxWidth: maxWidth,
                child: Row(
                  children: [
                    // The first step has nowhere to go back to on screen —
                    // its Back leaves the wizard, which the page confirms.
                    if (!step.isFirst) ...[
                      Expanded(
                        flex: 2,
                        child: AppOutlinedButton(
                          label: 'Back',
                          onPressed: isSubmitting ? null : onBack,
                        ),
                      ),
                      AppSpacing.hGapMd,
                    ],
                    Expanded(
                      flex: 3,
                      child: AppLoadingButton(
                        label: step.primaryLabel,
                        isLoading: isSubmitting,
                        onPressed: continueButtonOnpressed,
                        color: theme.colorScheme.tertiary,
                        trailingIcon: CupertinoIcons.arrow_right,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
