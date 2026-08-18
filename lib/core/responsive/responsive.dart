/// The app's single responsive system.
///
/// Two independent axes, deliberately kept apart:
///
/// - `DeviceFormFactor` (`context.isTabletDevice`) — rotation-stable device
///   class, for structural decisions.
/// - `LayoutSize` (`context.isCompact` / `isMedium` / `isExpanded`, or the
///   value `ResponsiveBuilder` hands you) — available width, for layout
///   decisions.
///
/// Page-level layout reads `context`; a widget inside a page reads the
/// constraints it was actually given via `ResponsiveBuilder`.
library;

export 'app_breakpoints.dart';
export 'centered_constrained_box.dart';
export 'device_form_factor.dart';
export 'layout_size.dart';
export 'responsive_builder.dart';
export 'responsive_context.dart';
export 'responsive_layout.dart';
