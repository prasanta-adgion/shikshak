import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/date_time_picker_func.dart';
import '../../../../../shared/widgets/app_card.dart';
import '../../../../../shared/widgets/app_popover_menu.dart';
import '../../domain/entities/class_slot.dart';
import 'schedule_chips.dart';
import 'slot_accent.dart';

class ClassSlotCard extends StatelessWidget {
  const ClassSlotCard({
    super.key,
    required this.slot,
    this.isToggling = false,
    this.onTap,
    this.onMessage,
    this.onEdit,
    this.onDelete,
    this.onToggleActive,
  });

  final ClassSlot slot;

  /// True while this slot's active/paused PATCH is in flight — the switch
  /// stops accepting taps until it lands.
  final bool isToggling;

  final VoidCallback? onTap;
  final VoidCallback? onMessage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final accent = SlotAccent.of(slot.colorTag, colorScheme);

    final dormancy = slot.dormancy();

    return Opacity(
      opacity: dormancy == null ? 1 : 0.7,
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Full-height accent rail.
              Container(width: 4, color: accent),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // -----------------------------------------------------
                      // HEADER
                      // -----------------------------------------------------
                      _HeaderRow(
                        slot: slot,
                        accent: accent,
                        dormancy: dormancy,
                        onMessage: onMessage,
                        onEdit: onEdit,
                        onDelete: onDelete,
                        onToggleActive: onToggleActive,
                      ),

                      AppSpacing.gapMd,

                      // -----------------------------------------------------
                      // TITLE
                      // -----------------------------------------------------
                      Text(
                        slot.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),

                      // -----------------------------------------------------
                      // DESCRIPTION
                      // -----------------------------------------------------
                      if (slot.description?.trim().isNotEmpty ?? false) ...[
                        AppSpacing.gapXs,
                        Text(
                          slot.description!.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],

                      // -----------------------------------------------------
                      // SUBJECT / CLASS TAGS
                      // -----------------------------------------------------
                      if (slot.subjects.isNotEmpty ||
                          slot.classes.isNotEmpty) ...[
                        AppSpacing.gapMd,
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            for (final subject in slot.subjects)
                              SlotTag(label: subject, color: accent),
                            for (final className in slot.classes)
                              SlotTag(
                                label: className,
                                color: colorScheme.onSurfaceVariant,
                              ),
                          ],
                        ),
                      ],

                      AppSpacing.gapMd,

                      Divider(height: 1, color: colorScheme.outlineVariant),

                      AppSpacing.gapMd,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(child: _FooterRows(slot: slot)),

                          const SizedBox(width: AppSpacing.md),

                          _SlotActiveSwitch(
                            isActive: slot.isActive,
                            onToggle: isToggling ? null : onToggleActive,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.slot,
    required this.accent,
    required this.dormancy,
    this.onMessage,
    this.onEdit,
    this.onDelete,
    this.onToggleActive,
  });

  final ClassSlot slot;
  final Color accent;
  final SlotDormancy? dormancy;

  final VoidCallback? onMessage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final duration = slot.durationLabel;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time + duration + status
        Expanded(
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TimeRangePill(
                label: slot.timeRangeLabel,
                accent: accent,
                icon: AppIcons.hours,
              ),

              if (duration.isNotEmpty)
                Text(
                  duration,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

              // Only show badge for exceptional states.
              if (dormancy case final reason?)
                StatusBadge(
                  label: reason.label,
                  icon: reason == SlotDormancy.paused
                      ? AppIcons.inactive
                      : AppIcons.schedule,
                  color: reason == SlotDormancy.ended
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),

        const SizedBox(width: AppSpacing.xs),

        // ---------------------------------------------------------------
        // MORE BUTTON
        // ---------------------------------------------------------------
        _SlotMoreButton(
          slot: slot,
          onMessage: onMessage,
          onEdit: onEdit,
          onDelete: onDelete,
          onToggleActive: onToggleActive,
        ),
      ],
    );
  }
}

class _SlotMoreButton extends StatelessWidget {
  const _SlotMoreButton({
    required this.slot,
    this.onMessage,
    this.onEdit,
    this.onDelete,
    this.onToggleActive,
  });

  final ClassSlot slot;

  final VoidCallback? onMessage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleActive;

  Future<void> _showActions(BuildContext context) async {
    final result = await showAppPopoverMenu<_SlotAction>(
      context: context,
      items: [
        const AppPopoverMenuItem(
          value: _SlotAction.message,
          icon: AppIcons.students,
          label: 'All Students',
          color: AppColors.success,
        ),

        // const AppPopoverMenuItem(
        //   value: _SlotAction.message,
        //   icon: AppIcons.message,
        //   label: 'Message',
        //   color: AppColors.success,
        // ),
        const AppPopoverMenuItem(
          value: _SlotAction.edit,
          icon: Icons.edit_outlined,
          label: 'Edit',
          color: AppColors.primary,
        ),

        const AppPopoverMenuItem(
          value: _SlotAction.delete,
          icon: Icons.delete_outline,
          label: 'Delete',
          color: AppColors.error,
        ),

        AppPopoverMenuItem(
          value: _SlotAction.toggle,
          icon: slot.isActive
              ? Icons.toggle_on_outlined
              : Icons.toggle_off_outlined,
          label: slot.isActive ? 'Deactivate' : 'Activate',
        ),
      ],
    );

    switch (result) {
      case _SlotAction.message:
        onMessage?.call();
      case _SlotAction.edit:
        onEdit?.call();
      case _SlotAction.delete:
        onDelete?.call();
      case _SlotAction.toggle:
        onToggleActive?.call();
      case _SlotAction.students:
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'More options',
      visualDensity: VisualDensity.compact,
      icon: const Icon(Icons.more_vert),
      onPressed: () => _showActions(context),
    );
  }
}

enum _SlotAction { message, edit, delete, toggle, students }

/// Footer control that flips the slot between active and paused.
///
/// The switch is the tap target — [onToggle] fires on either polarity, since
/// the caller already knows the current value from [ClassSlot.isActive].
class _SlotActiveSwitch extends StatelessWidget {
  const _SlotActiveSwitch({required this.isActive, this.onToggle});

  final bool isActive;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final tint = isActive
        ? AppColors.success
        : theme.colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isActive ? 'Active' : 'Inactive',
          style: theme.textTheme.labelLarge?.copyWith(color: tint),
        ),

        AppSpacing.hGapXs,

        Switch(
          value: isActive,
          onChanged: onToggle == null ? null : (_) => onToggle!(),
          activeThumbColor: Colors.white,
          activeTrackColor: AppColors.success,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}

class _FooterRows extends StatelessWidget {
  const _FooterRows({required this.slot});

  final ClassSlot slot;

  static String validityLabel(ClassSlot slot) {
    final from = slot.validFrom;
    final until = slot.validUntil;

    if (from != null && until != null) {
      return '${DateTimeUtils.dayMonthYear(from)} – '
          '${DateTimeUtils.dayMonthYear(until)}';
    }

    if (from != null) {
      return 'From ${DateTimeUtils.dayMonthYear(from)}';
    }

    if (until != null) {
      return 'Until ${DateTimeUtils.dayMonthYear(until)}';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final mode = slot.mode;
    final venue = slot.venueLabel;
    final validity = validityLabel(slot);

    final rows = <Widget>[
      if (mode != null)
        _MetaLine(
          icon: mode.icon,
          text: venue.isEmpty ? mode.label : '${mode.label} · $venue',
        ),

      if (validity.isNotEmpty)
        _MetaLine(icon: AppIcons.schedule, text: validity),
    ];

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, row) in rows.indexed) ...[
          if (index > 0) AppSpacing.gapXs,
          row,
        ],
      ],
    );
  }
}

///
/// Metadata row.
///
/// Expanded is safe here because _FooterRows is now inside the
/// Expanded child of the outer Row.
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
