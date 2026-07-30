import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';

/// One entry of a repeatable section that has already been saved.
///
/// The row itself only reports: anything acting on the entry goes in
/// [trailing], e.g. the button that opens an experience row for edit.
class SavedEntryCard extends StatelessWidget {
  const SavedEntryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.meta,
    this.trailingNote,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  /// Third line, smaller than [subtitle] — dates or a total, e.g.
  /// "3-5 years · Jul 2026 – Present".
  final String? meta;

  /// Small right-aligned annotation, e.g. "Current". Ignored when [trailing]
  /// is given.
  final String? trailingNote;

  /// Right-aligned action, e.g. an edit button.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Icon(icon, size: 18, color: AppColors.success),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                AppSpacing.gapXs,
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (meta != null) ...[
                  AppSpacing.gapXs,
                  Text(
                    meta!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            AppSpacing.hGapSm,
            trailing!,
          ] else if (trailingNote != null) ...[
            AppSpacing.hGapSm,
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: AppRadius.chip,
              ),
              child: Text(
                trailingNote!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The list of already-saved entries above a repeatable form.
class SavedEntryList extends StatelessWidget {
  const SavedEntryList({super.key, required this.title, required this.cards});

  final String title;
  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$title (${cards.length})',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppSpacing.gapSm,
        for (final card in cards) ...[card, AppSpacing.gapSm],
      ],
    );
  }
}
