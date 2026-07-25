import 'package:flutter/material.dart';

/// Primary CTA with a built-in loading state.
///
/// While [isLoading] is true the button is disabled and shows a spinner,
/// cross-faded with the label via [AnimatedSwitcher].
class AppLoadingButton extends StatelessWidget {
  const AppLoadingButton({
    super.key,
    required this.label,
    required this.isLoading,
    this.onPressed,
    this.icon,
    this.trailingIcon,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('loading'),
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: colorScheme.primary,
                  ),
                )
              : Row(
                  key: const ValueKey('label'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    // Flexible so a long label ellipsizes instead of
                    // overflowing on narrow phones or at large text scales.
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(trailingIcon, size: 20),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
