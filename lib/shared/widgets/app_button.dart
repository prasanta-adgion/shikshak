import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Primary filled button. Inherits shape/size/typography from
/// `FilledButtonThemeData` in the app theme.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// When true (default) the button stretches to the available width.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              AppSpacing.hGapSm,
              Text(label),
            ],
          );

    final button = FilledButton(onPressed: onPressed, child: child);

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
