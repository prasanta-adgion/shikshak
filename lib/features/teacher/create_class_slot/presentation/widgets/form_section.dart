import 'package:flutter/material.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_card.dart';

/// One titled block of the create-class form.
///
/// The form is long enough that a single flat column would be hard to scan, so
/// it is broken into three cards — what the class is, when it runs, where it
/// happens — each introduced by an icon, a title and a line of guidance.
class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final IconData icon;
  final String title;

  /// One line under the title saying what the section is for.
  final String subtitle;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              AppSpacing.hGapSm,
              // Expanded + ellipsis: a long title must not overflow the card
              // on a narrow phone.
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ],
          ),
          AppSpacing.gapXs,
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.gapLg,
          Divider(height: 1, color: colorScheme.outlineVariant),
          AppSpacing.gapLg,
          for (final (index, child) in children.indexed) ...[
            if (index > 0) AppSpacing.gapXl,
            child,
          ],
        ],
      ),
    );
  }
}
