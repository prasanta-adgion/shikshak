import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Primary filled button. Inherits shape/size/typography from
/// `FilledButtonThemeData` in the app theme.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// When true (default) the button stretches to the available width.
  final bool expanded;

  final Color? color;

  /// Optional text/icon color override, paired with [color].
  final Color? foregroundColor;
  final Color? labelColor;

  const AppButton({
    super.key,
    required this.label,
    this.labelColor,
    this.onPressed,
    this.icon,
    this.expanded = true,
    this.color,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label, style: TextStyle(color: labelColor))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(icon, size: 20), AppSpacing.hGapSm, Text(label)],
          );

    final button = FilledButton(
      onPressed: onPressed,
      style: (color == null && foregroundColor == null)
          ? null
          : FilledButton.styleFrom(
              backgroundColor: color,
              foregroundColor: foregroundColor,
            ),
      child: child,
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
