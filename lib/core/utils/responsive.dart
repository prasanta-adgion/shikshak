import 'package:flutter/widgets.dart';

/// Layout breakpoints (logical pixels).
abstract final class Breakpoints {
  static const double tablet = 720;
  static const double desktop = 1100;

  /// Max width for centered page content on large screens.
  static const double contentMaxWidth = 1100;

  /// Max width for focused forms (auth screens).
  static const double formMaxWidth = 480;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  bool get isTablet => screenWidth >= Breakpoints.tablet;

  bool get isDesktop => screenWidth >= Breakpoints.desktop;

  /// Grid column count that scales with available width.
  int gridColumns({int compact = 3, int medium = 4, int expanded = 6}) {
    if (isDesktop) return expanded;
    if (isTablet) return medium;
    return compact;
  }
}

/// Constrains [child] to [maxWidth] and centers it — used to keep content
/// readable on tablets and desktop.
class CenteredConstrainedBox extends StatelessWidget {
  const CenteredConstrainedBox({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.contentMaxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
