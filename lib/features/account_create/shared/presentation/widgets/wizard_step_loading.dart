import 'package:flutter/material.dart';

import '../../../../../core/theme/app_spacing.dart';

/// Stands in for a step's fields while it reads back what the teacher already
/// saved. Shown instead of the form so an answer typed in the meantime cannot
/// be overwritten when the response lands.
class WizardStepLoading extends StatelessWidget {
  const WizardStepLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Center(
        child: SizedBox.square(
          dimension: 26,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      ),
    );
  }
}
