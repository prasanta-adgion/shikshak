import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../domain/entities/teacher_profile.dart';

/// One uploaded document: type, file name, size, and verification state.
class ProfileDocumentTile extends StatelessWidget {
  const ProfileDocumentTile({super.key, required this.document, this.onView});

  final ProfileDocument document;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = document.isVerified ? AppColors.success : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
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
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Icon(_iconFor(document.mimeType), size: 18, color: accent),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.typeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                AppSpacing.gapXs,
                Text(
                  document.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                AppSpacing.gapXs,
                // Size sits beside the pill, not after the file name: names
                // are long enough that an ellipsis would always eat it.
                // Wrap, not Row — the pair drops to a second line on a narrow
                // phone instead of overflowing.
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: AppRadius.chip,
                      ),
                      child: Text(
                        document.isVerified
                            ? 'Verified'
                            : 'Pending verification',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: accent,
                        ),
                      ),
                    ),
                    if (document.readableSize.isNotEmpty)
                      Text(
                        document.readableSize,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (onView != null) ...[
            AppSpacing.hGapSm,
            IconButton(
              onPressed: onView,
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              tooltip: 'View document',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ],
      ),
    );
  }

  static IconData _iconFor(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file_outlined;
    if (mimeType.startsWith('image/')) return Icons.image_outlined;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf_outlined;
    return Icons.insert_drive_file_outlined;
  }
}
