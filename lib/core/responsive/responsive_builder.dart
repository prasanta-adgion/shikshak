import 'package:flutter/material.dart';

import 'app_breakpoints.dart';
import 'layout_size.dart';

typedef ResponsiveWidgetBuilder =
    Widget Function(
      BuildContext context,
      LayoutSize layoutSize,
      BoxConstraints constraints,
    );

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({required this.builder, super.key});

  final ResponsiveWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = _resolveWidth(context, constraints);

        final layoutSize = AppBreakpoints.layoutSizeOf(width);

        return builder(context, layoutSize, constraints);
      },
    );
  }

  double _resolveWidth(BuildContext context, BoxConstraints constraints) {
    if (constraints.maxWidth.isFinite) {
      return constraints.maxWidth;
    }

    return MediaQuery.sizeOf(context).width;
  }
}
