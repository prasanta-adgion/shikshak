import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_shadows.dart';

/// Shiksha brand mark: a gradient rounded square with the book icon.
///
/// Wrapped in a [Hero] by default so the logo glides between splash, role
/// selection and auth screens.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 88,
    this.withHero = true,
    this.withGlow = true,
  });

  final double size;
  final bool withHero;
  final bool withGlow;

  static const String _heroTag = 'shiksha-logo';

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: withGlow ? AppShadows.primaryGlow : null,
      ),
      child: Icon(
        AppIcons.logo,
        color: Colors.white,
        size: size * 0.5,
      ),
    );

    return withHero ? Hero(tag: _heroTag, child: mark) : mark;
  }
}
