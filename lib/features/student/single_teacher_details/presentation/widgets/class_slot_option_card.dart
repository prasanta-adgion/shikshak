import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../domain/entities/teacher_class_slot.dart';
import 'teacher_tag.dart';

/// One class the student can pick.
///
/// Selection is the whole point of the card, so the tap target is the card
/// itself and the state is carried three ways — the mark, the border and the
/// tint — rather than by colour alone.
class ClassSlotOptionCard extends StatelessWidget {
  const ClassSlotOptionCard({
    super.key,
    required this.slot,
    required this.isSelected,
    required this.onToggled,
  });

  final TeacherClassSlot slot;
  final bool isSelected;
  final VoidCallback onToggled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final schedule = slot.scheduleLabel;
    final venue = slot.venueLabel;
    final price = slot.priceLabel;
    final mode = slot.mode;

    return Semantics(
      checked: isSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.06)
              : colorScheme.surface,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: AppShadows.soft(theme.brightness),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.card,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onToggled,
            borderRadius: AppRadius.card,
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // A box, not a radio: several classes can be picked at
                      // once, and the shape is what says so before the first
                      // tap.
                      Icon(
                        isSelected
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        size: 22,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outline,
                      ),
                      AppSpacing.hGapMd,
                      Expanded(
                        child: Text(
                          slot.displayTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      if (price != null) ...[
                        AppSpacing.hGapSm,
                        Text(
                          price,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (schedule.isNotEmpty) ...[
                    AppSpacing.gapSm,
                    _MetaLine(icon: AppIcons.hours, text: schedule),
                  ],
                  if (mode != null) ...[
                    AppSpacing.gapXs,
                    _MetaLine(
                      icon: mode == ClassSlotMode.online
                          ? AppIcons.classOnline
                          : AppIcons.classInPerson,
                      text: venue.isEmpty
                          ? mode.label
                          : '${mode.label} · $venue',
                    ),
                  ],
                  if (slot.subjects.isNotEmpty || slot.classes.isNotEmpty) ...[
                    AppSpacing.gapMd,
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final subject in slot.subjects)
                          TeacherTag(label: subject),
                        for (final className in slot.classes)
                          TeacherTag(label: className, muted: true),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: colorScheme.onSurfaceVariant),
        AppSpacing.hGapSm,
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
