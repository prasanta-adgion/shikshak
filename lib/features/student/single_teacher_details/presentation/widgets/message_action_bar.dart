import 'package:flutter/material.dart';

import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../domain/entities/teacher_class_slot.dart';

class MessageActionBar extends StatelessWidget {
  const MessageActionBar({
    super.key,
    required this.selectedClasses,
    required this.onMessage,
  });

  final List<TeacherClassSlot> selectedClasses;

  final VoidCallback? onMessage;

  String get _summary => switch (selectedClasses.length) {
    0 => 'Select one or more classes to message this teacher',
    1 => selectedClasses.single.displayTitle,
    final count =>
      '$count classes  ·  '
          '${selectedClasses.map((slot) => slot.displayTitle).join(', ')}',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasSelection = selectedClasses.isNotEmpty;

    return Material(
      color: colorScheme.surface,
      child: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          ),
          child: Padding(
            padding: context.responsivePagePadding.copyWith(
              top: AppSpacing.md,
              bottom: AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      hasSelection
                          ? AppIcons.preferenceOn
                          : AppIcons.studentClass,
                      size: 16,
                      color: hasSelection
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    AppSpacing.hGapSm,
                    Expanded(
                      child: Text(
                        _summary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: hasSelection
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapSm,
                AppButton(
                  label: selectedClasses.length > 1
                      ? 'Message about ${selectedClasses.length} classes'
                      : 'Message teacher',
                  icon: AppIcons.message,
                  onPressed: onMessage,
                  disabledColor: colorScheme.onSurface.withValues(alpha: 0.12),
                  disabledLabelColor: colorScheme.onSurfaceVariant,
                  disabledForegroundColor: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
