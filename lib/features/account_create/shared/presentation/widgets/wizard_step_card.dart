import 'package:flutter/material.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_card.dart';
import '../../../../../shared/widgets/app_header.dart';

/// The floating card every step renders inside: centered heading, then the
/// step's own fields.
///
/// The Back / Continue pair is deliberately absent — it lives in the page's
/// pinned action bar, so all five steps share one set of buttons in one place
/// on screen.
class WizardStepCard extends StatelessWidget {
  const WizardStepCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppHeader(
            title: title,
            subtitle: subtitle,
            alignment: CrossAxisAlignment.center,
          ),
          AppSpacing.gapXl,
          child,
        ],
      ),
    );
  }
}
