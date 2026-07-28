import 'package:flutter/material.dart';

import '../../../../../core/theme/app_spacing.dart';

/// One labelled field inside the step container: a small tinted icon, the
/// field name, then the input beneath it.
///
/// No card chrome of its own — the step is a single white surface, and these
/// are just rows within it.
class WizardField extends StatelessWidget {
  const WizardField({
    super.key,
    required this.icon,
    required this.label,
    required this.child,
    this.isOptional = false,
    this.helpText,
  });

  final IconData icon;
  final String label;

  /// Appends a muted "(Optional)" to the label.
  final bool isOptional;

  /// Shown in a tooltip behind a `?` affordance; omitted when null.
  final String? helpText;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: colorScheme.primary),
            AppSpacing.hGapSm,
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
            ),
            if (isOptional) ...[
              AppSpacing.hGapXs,
              Text(
                '(Optional)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (helpText != null) ...[
              const Spacer(),
              Tooltip(
                message: helpText!,
                triggerMode: TooltipTriggerMode.tap,
                showDuration: const Duration(seconds: 4),
                child: Icon(
                  Icons.help_outline_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        AppSpacing.gapSm,
        child,
      ],
    );
  }
}
