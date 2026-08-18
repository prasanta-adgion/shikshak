/// What kind of device the app is running on, derived from the window's
/// shortest side so it stays put across rotation and split-screen.
///
/// This is a different question from `LayoutSize`, and the two must not be
/// used interchangeably:
///
/// - [DeviceFormFactor] — "what hardware is this?" Use it for structural
///   choices that should not flip when the user rotates the device: nav rail
///   vs bottom bar, two-pane vs stacked auth, base component sizing.
/// - `LayoutSize` — "how much width do I have right now?" Use it for choices
///   that *should* react to the space available: column counts, page gutters,
///   whether a pair of fields fits on one row.
enum DeviceFormFactor {
  handset,
  tablet;

  bool get isHandset => this == DeviceFormFactor.handset;

  bool get isTablet => this == DeviceFormFactor.tablet;
}
