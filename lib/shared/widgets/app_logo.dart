import 'package:flutter/material.dart';

/// Shikshak brand mark: a gradient rounded square with the book icon.
///
/// Wrapped in a [Hero] by default so the logo glides between splash, role
/// selection and auth screens.
class AppLogo extends StatelessWidget {
  final double size;
  final bool withHero;
  final bool withGlow;

  static const String _heroTag = 'Shikshak-logo';

  final String image;
  const AppLogo({
    super.key,
    required this.image,
    this.size = 88,
    this.withHero = true,
    this.withGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final mark = SizedBox(
      height: size,
      width: size,
      // decoration: BoxDecoration(
      //   gradient: AppColors.primaryGradient,
      //   borderRadius: BorderRadius.circular(size * 0.28),
      //   boxShadow: withGlow ? AppShadows.primaryGlow : null,
      // ),
      // child: Icon(AppIcons.logo, color: Colors.white, size: size * 0.5),
      child: Image.asset(image),
    );

    return withHero ? Hero(tag: _heroTag, child: mark) : mark;
  }
}
