import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';

/// A tappable box that mimics `AppTextField` exactly — external label, filled
/// surface, same radius and padding — for inputs that open a picker instead of
/// a keyboard.
///
/// Built by hand rather than with `DropdownButtonFormField` so select and date
/// fields sit flush with the real text fields around them.
class FieldShell extends StatelessWidget {
  const FieldShell({
    super.key,
    required this.onTap,
    required this.child,
    this.label,
    this.trailingIcon = Icons.keyboard_arrow_down_rounded,
    this.errorText,
  });

  /// Omitted inside a [WizardFieldCard], which carries the name itself.
  final String? label;

  final VoidCallback onTap;

  /// Rendered inside the box — usually the selected value or a hint.
  final Widget child;
  final IconData trailingIcon;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          AppSpacing.gapSm,
        ],
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.input,
            child: Ink(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: AppRadius.input,
                border: hasError
                    ? Border.all(color: colorScheme.error, width: 1.2)
                    : null,
              ),
              child: Padding(
                // Matches InputDecorationTheme.contentPadding, minus a little
                // vertically to offset the fixed 24px icon.
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg - 1,
                ),
                child: Row(
                  children: [
                    Expanded(child: child),
                    Icon(
                      trailingIcon,
                      size: 22,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          AppSpacing.gapXs,
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.md),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// The value line inside a [FieldShell] — real value or greyed-out hint.
class FieldShellValue extends StatelessWidget {
  const FieldShellValue({super.key, required this.hint, this.value});

  final String hint;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = value == null || value!.isEmpty;

    return Text(
      isEmpty ? hint : value!,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: isEmpty
            ? theme.colorScheme.onSurfaceVariant
            : theme.colorScheme.onSurface,
      ),
    );
  }
}
