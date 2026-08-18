import 'package:flutter/material.dart';

import 'app_breakpoints.dart';

/// Constrains [child] to [maxWidth] and centers it — used to keep content
/// readable on tablets and desktop.
class CenteredConstrainedBox extends StatelessWidget {
  const CenteredConstrainedBox({
    required this.child,
    this.maxWidth = AppBreakpoints.contentMaxWidth,
    super.key,
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
