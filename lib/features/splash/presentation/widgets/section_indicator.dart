import 'package:flutter/material.dart';

class SectionIndicator extends StatelessWidget {
  const SectionIndicator({
    super.key,
    this.width = 25,
    this.height = 1,
    this.color = const Color(0xFF5B6EF5),
    this.reversed = false,
  });

  final double width;
  final double height;
  final Color color;
  final bool reversed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: reversed ? Alignment.centerRight : Alignment.centerLeft,
          end: reversed ? Alignment.centerLeft : Alignment.centerRight,
          colors: [color, color.withValues(alpha: 0)],
        ),
        borderRadius: BorderRadius.circular(height),
      ),
    );
  }
}
