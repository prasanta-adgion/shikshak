import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';

class AppPopoverMenuItem<T> {
  const AppPopoverMenuItem({
    required this.value,
    required this.icon,
    required this.label,
    this.color,
  });

  final T value;
  final IconData icon;
  final String label;
  final Color? color;
}

Future<T?> showAppPopoverMenu<T>({
  required BuildContext context,
  required List<AppPopoverMenuItem<T>> items,
  PopoverDirection direction = PopoverDirection.bottom,
  double width = 200,
  Color? borderColor,
}) {
  final theme = Theme.of(context);

  return showPopover<T>(
    context: context,
    direction: direction,
    backgroundColor: borderColor ?? theme.colorScheme.primary,
    barrierColor: Colors.transparent,
    radius: AppRadius.s,
    arrowWidth: 18,
    arrowHeight: 9,
    width: width,
    shadow: AppShadows.medium(theme.brightness),
    bodyBuilder: (_) => _AppPopoverMenuBody<T>(items: items),
  );
}

class _AppPopoverMenuBody<T> extends StatelessWidget {
  const _AppPopoverMenuBody({required this.items});

  final List<AppPopoverMenuItem<T>> items;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      // Leaves the popover background showing as a hairline border.
      padding: const EdgeInsets.all(2),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.s),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in items) _AppPopoverMenuTile<T>(item: item),
          ],
        ),
      ),
    );
  }
}

class _AppPopoverMenuTile<T> extends StatelessWidget {
  const _AppPopoverMenuTile({required this.item});

  final AppPopoverMenuItem<T> item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = item.color ?? theme.colorScheme.onSurface;

    return InkWell(
      onTap: () => Navigator.of(context).pop(item.value),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(item.icon, size: 18, color: tint),

            AppSpacing.hGapSm,

            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(color: tint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
