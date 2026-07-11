import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';

/// Rounded surface card with the app's soft shadow.
///
/// Supports an optional [onTap] (renders ink ripple) and an optional
/// [gradient] for hero cards.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = AppSpacing.cardPadding,
    this.gradient,
    this.color,
    this.borderRadius = AppRadius.card,
    this.showBorder = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final Color? color;
  final BorderRadius borderRadius;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Padding(padding: padding, child: child);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? theme.colorScheme.surface) : null,
        gradient: gradient,
        borderRadius: borderRadius,
        border: showBorder && gradient == null
            ? Border.all(color: theme.colorScheme.outlineVariant)
            : null,
        boxShadow: AppShadows.soft(theme.brightness),
      ),
      child: onTap == null
          ? ClipRRect(borderRadius: borderRadius, child: content)
          : Material(
              color: Colors.transparent,
              borderRadius: borderRadius,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                borderRadius: borderRadius,
                child: content,
              ),
            ),
    );
  }
}
