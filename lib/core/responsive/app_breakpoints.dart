import 'device_form_factor.dart';
import 'layout_size.dart';

abstract final class AppBreakpoints {
  const AppBreakpoints._();

  /// Compact layout:
  ///
  /// Width: 0 - 599 logical pixels.
  ///
  /// Commonly suitable for:
  /// - Phones
  /// - Small app windows
  static const double compact = 600;

  /// Medium layout:
  ///
  /// Width: 600 - 839 logical pixels.
  ///
  /// Commonly suitable for:
  /// - Tablet portrait
  /// - Large phone landscape
  /// - Medium app windows
  static const double medium = 840;

  /// Shortest-side threshold at which a device counts as tablet-class.
  ///
  /// Deliberately *not* one of the layout breakpoints above. [compact] and
  /// [medium] answer "how much width is on offer right now", which changes on
  /// rotation and in split-screen. This answers "what kind of device is this",
  /// which does not — a large phone turned landscape is still a phone.
  static const double tabletDevice = 720;

  /// Max width for centered page content on large windows.
  static const double contentMaxWidth = 1100;

  /// Max width for focused forms (auth screens).
  static const double formMaxWidth = 480;

  /// Max width for focused forms in a tablet's two-pane layout, wider than
  /// [formMaxWidth] since the pane has more room to give the card.
  static const double tabletFormMaxWidth = 600;

  /// Horizontal page gutters by layout size.
  static const double compactPadding = 16;
  static const double mediumPadding = 14;
  static const double expandedPadding = 32;

  /// Returns the responsive layout category for [width].
  static LayoutSize layoutSizeOf(double width) {
    if (width < compact) {
      return LayoutSize.compact;
    }

    if (width < medium) {
      return LayoutSize.medium;
    }

    return LayoutSize.expanded;
  }

  /// Returns the device class for [shortestSide] — the shorter of the two
  /// window edges, so the result survives rotation.
  static DeviceFormFactor deviceFormFactorOf(double shortestSide) {
    return shortestSide >= tabletDevice
        ? DeviceFormFactor.tablet
        : DeviceFormFactor.handset;
  }

  /// Horizontal page gutter for [layoutSize].
  static double pagePaddingOf(LayoutSize layoutSize) {
    return switch (layoutSize) {
      LayoutSize.compact => compactPadding,
      LayoutSize.medium => mediumPadding,
      LayoutSize.expanded => expandedPadding,
    };
  }

  static bool isCompact(double width) {
    return width < compact;
  }

  static bool isMedium(double width) {
    return width >= compact && width < medium;
  }

  static bool isExpanded(double width) {
    return width >= medium;
  }
}
