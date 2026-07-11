import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Theme-aware soft gradient backdrop used behind auth flow screens.
///
/// Pass a custom [gradient] (e.g. [AppColors.splashGradient]) to override
/// the default subtle wash.
class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
    this.gradient,
  });

  final Widget child;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient ??
            (isDark
                ? AppColors.darkPageGradient
                : AppColors.lightPageGradient),
      ),
      child: child,
    );
  }
}
