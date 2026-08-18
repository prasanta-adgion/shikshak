enum LayoutSize {
  compact,
  medium,
  expanded;

  bool get isCompact => this == LayoutSize.compact;

  bool get isMedium => this == LayoutSize.medium;

  bool get isExpanded => this == LayoutSize.expanded;
}
