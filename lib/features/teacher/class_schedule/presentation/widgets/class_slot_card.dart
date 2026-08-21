import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/date_time_picker_func.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_card.dart';
import '../../domain/entities/class_slot.dart';
import 'schedule_chips.dart';
import 'slot_accent.dart';

class ClassSlotCard extends StatelessWidget {
  const ClassSlotCard({
    super.key,
    required this.slot,
    this.onTap,
    this.onMessage,
    this.onEdit,
    this.onDelete,
    this.onToggleActive,
  });

  final ClassSlot slot;

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

                          SizedBox(
                            height: 40,
                            child: AppButton(
                              color: AppColors.success,
                              foregroundColor: Colors.white,
                              disabledColor: AppColors.success,
                              disabledForegroundColor: Colors.white,
                              icon: CupertinoIcons.chat_bubble_text_fill,
                              label: 'Message',
                              onPressed: onMessage,
                              expanded: false,
                            ),
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

///
/// Header
///
/// Contains:
/// - Time
/// - Duration
/// - Dormancy status
/// - More menu
///
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
    final buttonContext = context;

    final RenderBox button = buttonContext.findRenderObject()! as RenderBox;

    final RenderBox overlay =
        Overlay.of(buttonContext).context.findRenderObject()! as RenderBox;

    final buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);

    final buttonBottomRight = button.localToGlobal(
      button.size.bottomRight(Offset.zero),
      ancestor: overlay,
    );

    final position = RelativeRect.fromRect(
      Rect.fromPoints(buttonPosition, buttonBottomRight),
      Offset.zero & overlay.size,
    );

    final result = await showMenu<String>(
      context: context,
      position: position,
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      items: [
        // ---------------------------------------------------------------
        // MESSAGE
        // ---------------------------------------------------------------
        const PopupMenuItem<String>(
          value: 'message',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.message_outlined),
            title: Text('Message'),
          ),
        ),

        // ---------------------------------------------------------------
        // EDIT
        // ---------------------------------------------------------------
        const PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.edit_outlined),
            title: Text('Edit'),
          ),
        ),

        // ---------------------------------------------------------------
        // DELETE
        // ---------------------------------------------------------------
        const PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_outline),
            title: Text('Delete'),
          ),
        ),

        // ---------------------------------------------------------------
        // ACTIVE / DEACTIVE
        // ---------------------------------------------------------------
        PopupMenuItem<String>(
          value: 'toggle',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              slot.isActive
                  ? Icons.toggle_on_outlined
                  : Icons.toggle_off_outlined,
            ),
            title: Text(slot.isActive ? 'Deactivate' : 'Activate'),
          ),
        ),
      ],
    );

    switch (result) {
      case 'message':
        onMessage?.call();
        break;

      case 'edit':
        onEdit?.call();
        break;

      case 'delete':
        onDelete?.call();
        break;

      case 'toggle':
        onToggleActive?.call();
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
