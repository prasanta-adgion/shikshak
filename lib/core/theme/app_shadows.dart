import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Elevation system — soft, diffuse shadows that read as "premium" rather
/// than harsh Material elevation.
abstract final class AppShadows {
  /// Subtle lift for resting cards.
  static List<BoxShadow> soft(Brightness brightness) => [
    BoxShadow(
      color:
          (brightness == Brightness.dark
                  ? Colors.black
                  : AppColors.lightTextPrimary)
              .withValues(alpha: brightness == Brightness.dark ? 0.45 : 0.06),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  /// Stronger lift for hero cards and floating elements.
  static List<BoxShadow> medium(Brightness brightness) => [
    BoxShadow(
      color:
          (brightness == Brightness.dark
                  ? Colors.black
                  : AppColors.lightTextPrimary)
              .withValues(alpha: brightness == Brightness.dark ? 0.55 : 0.10),
      blurRadius: 30,
      offset: const Offset(0, 12),
    ),
  ];

  /// Colored glow used behind the logo and primary CTAs.
  static List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.35),
      blurRadius: 28,
      offset: const Offset(0, 10),
    ),
  ];
}
