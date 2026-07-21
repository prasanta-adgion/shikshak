import 'package:flutter/widgets.dart';

/// Layout breakpoints (logical pixels).
abstract final class Breakpoints {
  static const double tablet = 720;
  static const double desktop = 1100;

  /// Max width for centered page content on large screens.
  static const double contentMaxWidth = 1100;

  /// Max width for focused forms (auth screens).
  static const double formMaxWidth = 480;

  /// Horizontal page gutters by window size.
  static const double phonePadding = 16;
  static const double tabletPadding = 24;
  static const double desktopPadding = 32;
}

extension ResponsiveContext on BuildContext {
  Size get _windowSize => MediaQuery.sizeOf(this);

  double get screenWidth => _windowSize.width;

  /// Shorter of the two window edges. Unlike [screenWidth] this is stable
  /// across rotation, so it's the right signal for "what kind of device is
  /// this" (see [isTabletDevice]).
  double get shortestSide => _windowSize.shortestSide;

  Orientation get orientation => _windowSize.width >= _windowSize.height
      ? Orientation.landscape
      : Orientation.portrait;

  /// True when the physical device is tablet-class. Rotation-stable, so a
  /// large phone in landscape stays a phone. Prefer this over [isTabletOrLarger]
  /// for structural decisions (nav rail vs bottom bar, two-pane forms, base
  /// component sizing). Use available width (`constraints.maxWidth`) instead for
  /// "how much room do I have right now" decisions like column counts.
  bool get isTabletDevice => shortestSide >= Breakpoints.tablet;

  bool get isPhone => screenWidth < Breakpoints.tablet;

  bool get isTablet =>
      screenWidth >= Breakpoints.tablet && screenWidth < Breakpoints.desktop;

  bool get isDesktop => screenWidth >= Breakpoints.desktop;

  bool get isTabletOrLarger => screenWidth >= Breakpoints.tablet;

  EdgeInsets get responsivePagePadding => EdgeInsets.symmetric(
    horizontal: isDesktop
        ? Breakpoints.desktopPadding
        : isTablet
        ? Breakpoints.tabletPadding
        : Breakpoints.phonePadding,
  );

  /// Grid column count that scales with available width.
  int gridColumns({int compact = 3, int medium = 4, int expanded = 6}) {
    if (isDesktop) return expanded;
    if (isTablet) return medium;
    return compact;
  }
}

/// Builds from the width actually offered by the parent. This makes layouts
/// react correctly to rotation and split-screen windows.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, BoxConstraints constraints)
  builder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);
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
