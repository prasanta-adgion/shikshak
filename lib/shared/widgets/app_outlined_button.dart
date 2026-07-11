import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Secondary (outlined) button. Inherits styling from
/// `OutlinedButtonThemeData` in the app theme.
class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
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

    final button = OutlinedButton(onPressed: onPressed, child: child);

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
