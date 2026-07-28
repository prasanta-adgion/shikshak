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
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  /// Optional text/border color override (e.g. for a destructive action).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              AppSpacing.hGapSm,
              // Flexible so a long label ellipsizes instead of overflowing on
              // narrow phones or at large text scales — same guard as
              // [AppLoadingButton].
              Flexible(
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          );

    final button = OutlinedButton(
      onPressed: onPressed,
      style: color == null
          ? null
          : OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(color: color!.withValues(alpha: 0.4)),
            ),
      child: child,
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
