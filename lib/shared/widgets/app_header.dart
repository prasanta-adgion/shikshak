import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Page header: large title with an optional supporting subtitle.
/// Used at the top of auth screens and section pages.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.alignment = CrossAxisAlignment.start,
  });

  final String title;
  final String? subtitle;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final centered = alignment == CrossAxisAlignment.center;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineMedium,
          textAlign: centered ? TextAlign.center : TextAlign.start,
        ),
        if (subtitle != null) ...[
          AppSpacing.gapSm,
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: centered ? TextAlign.center : TextAlign.start,
          ),
        ],
      ],
    );
  }
}
