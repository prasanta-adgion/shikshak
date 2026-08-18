import 'package:flutter/material.dart';

import 'layout_size.dart';
import 'responsive_builder.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.compact,
    this.medium,
    this.expanded,
    super.key,
  });

  /// Required fallback layout.
  ///
  /// Used for compact widths.
  final Widget compact;

  /// Optional medium layout.
  ///
  /// Falls back to [compact] when not provided.
  final Widget? medium;

  /// Optional expanded layout.
  ///
  /// Falls back to [medium], then [compact].
  final Widget? expanded;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, layoutSize, constraints) {
        return switch (layoutSize) {
          LayoutSize.compact => compact,

          LayoutSize.medium => medium ?? compact,

          LayoutSize.expanded => expanded ?? medium ?? compact,
        };
      },
    );
  }
}
