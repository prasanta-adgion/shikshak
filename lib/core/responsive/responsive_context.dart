import 'package:flutter/material.dart';

import 'app_breakpoints.dart';
import 'device_form_factor.dart';
import 'layout_size.dart';

/// Window-level responsive signals.
///
/// These read the whole app window, which makes them the right input for
/// page-level decisions. For a decision *inside* a page — where the widget
/// only gets part of the window — use `ResponsiveBuilder` and the
/// [LayoutSize] it resolves from the constraints actually on offer.
extension ResponsiveContext on BuildContext {
  /// Current app window size.
  Size get screenSize {
    return MediaQuery.sizeOf(this);
  }

  /// Current app window width.
  double get screenWidth {
    return screenSize.width;
  }

  /// Current app window height.
  double get screenHeight {
    return screenSize.height;
  }

  /// Shorter of the two window edges. Unlike [screenWidth] this is stable
  /// across rotation, so it is the signal behind [deviceFormFactor].
  double get shortestSide {
    return screenSize.shortestSide;
  }

  /// Current responsive layout category.
  LayoutSize get layoutSize {
    return AppBreakpoints.layoutSizeOf(screenWidth);
  }

  bool get isCompact {
    return layoutSize.isCompact;
  }

  bool get isMedium {
    return layoutSize.isMedium;
  }

  bool get isExpanded {
    return layoutSize.isExpanded;
  }

  /// Device class, rotation-stable. See [DeviceFormFactor] for when to reach
  /// for this instead of [layoutSize].
  DeviceFormFactor get deviceFormFactor {
    return AppBreakpoints.deviceFormFactorOf(shortestSide);
  }

  /// True when the physical device is tablet-class. Prefer this over
  /// [isExpanded] for structural decisions (nav rail vs bottom bar, two-pane
  /// forms, base component sizing) — a phone in landscape is wide, but it is
  /// still a phone.
  bool get isTabletDevice {
    return deviceFormFactor.isTablet;
  }

  bool get isHandsetDevice {
    return deviceFormFactor.isHandset;
  }

  bool get isPortrait {
    return screenHeight >= screenWidth;
  }

  bool get isLandscape {
    return screenWidth > screenHeight;
  }

  /// Horizontal page gutters, widening with the layout size.
  EdgeInsets get responsivePagePadding {
    return EdgeInsets.symmetric(
      horizontal: AppBreakpoints.pagePaddingOf(layoutSize),
    );
  }

  /// Max width for a focused form card. Keyed to the device rather than the
  /// window: the wider card belongs to a tablet's two-pane layout, and should
  /// not appear just because a phone was turned sideways.
  double get responsiveFormMaxWidth {
    return isTabletDevice
        ? AppBreakpoints.tabletFormMaxWidth
        : AppBreakpoints.formMaxWidth;
  }

  /// Grid column count that scales with the window's layout size.
  int gridColumns({int compact = 3, int medium = 4, int expanded = 6}) {
    return switch (layoutSize) {
      LayoutSize.compact => compact,
      LayoutSize.medium => medium,
      LayoutSize.expanded => expanded,
    };
  }
}
