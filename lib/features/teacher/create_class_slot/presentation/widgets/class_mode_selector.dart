import 'package:flutter/material.dart';

import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../class_schedule/domain/entities/class_mode.dart';
import '../../../class_schedule/presentation/widgets/slot_accent.dart';

/// Segmented picker for how the class is delivered.
///
/// Three options laid out at once rather than hidden behind a sheet: the
/// choice decides whether the venue fields appear below, so seeing all of it
/// costs one glance instead of two taps.
class ClassModeSelector extends StatelessWidget {
  const ClassModeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ClassMode value;
  final ValueChanged<ClassMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (index, mode) in ClassMode.values.indexed) ...[
          if (index > 0) AppSpacing.hGapSm,
          Expanded(
            child: _ModeOption(
              mode: mode,
              isSelected: mode == value,
              onTap: () => onChanged(mode),
            ),
          ),
        ],
      ],
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  final ClassMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final foreground = isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Material(
      color: isSelected
          ? colorScheme.primary.withValues(alpha: 0.08)
          : colorScheme.surfaceContainerHighest,
      borderRadius: AppRadius.input,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.input,
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.45)
                  : Colors.transparent,
              width: 1.4,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(mode.icon, size: 20, color: foreground),
              AppSpacing.gapXs,
              Text(
                mode.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
