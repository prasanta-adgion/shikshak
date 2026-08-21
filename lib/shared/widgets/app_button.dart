import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

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

  final Color? disabledColor;
  final Color? disabledForegroundColor;
  final Color? disabledLabelColor;

  const AppButton({
    super.key,
    required this.label,
    this.labelColor = Colors.white,
    this.onPressed,
    this.icon,
    this.expanded = true,
    this.color,
    this.foregroundColor,
    this.disabledColor,
    this.disabledForegroundColor,
    this.disabledLabelColor,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    final labelStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: isEnabled ? labelColor : (disabledLabelColor ?? labelColor),
    );

    final child = icon == null
        ? Text(label, style: labelStyle)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              AppSpacing.hGapSm,
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle,
                ),
              ),
            ],
          );

    final hasColorOverride =
        color != null ||
        foregroundColor != null ||
        disabledColor != null ||
        disabledForegroundColor != null;

    final button = FilledButton(
      onPressed: onPressed,
      style: hasColorOverride
          ? FilledButton.styleFrom(
              backgroundColor: color,
              foregroundColor: foregroundColor,
              disabledBackgroundColor: disabledColor,
              disabledForegroundColor: disabledForegroundColor,
            )
          : null,
      child: child,
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
