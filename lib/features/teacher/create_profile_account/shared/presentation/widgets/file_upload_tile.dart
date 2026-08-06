import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';

/// An upload slot. Shows the file name (and any extra detail such as type and
/// size) with a green tick once something is attached, the remove action
/// replacing the upload button.
class FileUploadTile extends StatelessWidget {
  const FileUploadTile({
    super.key,
    required this.title,
    required this.hint,
    required this.onUpload,
    required this.onRemove,
    this.fileName,
    this.detail,
    this.isRequired = true,
  });

  final String title;

  /// Shown while nothing is attached.
  final String hint;

  final String? fileName;

  /// Secondary line once a file is attached, e.g. `application/pdf · 1.2 MB`.
  final String? detail;

  final bool isRequired;
  final VoidCallback onUpload;
  final VoidCallback onRemove;

  bool get _hasFile => fileName != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: _hasFile ? AppColors.success : colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    if (!isRequired) ...[
                      AppSpacing.hGapXs,
                      Text(
                        '(Optional)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
                AppSpacing.gapXs,
                Row(
                  children: [
                    if (_hasFile) ...[
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: AppColors.success,
                      ),
                      AppSpacing.hGapXs,
                    ],
                    Flexible(
                      child: Text(
                        fileName ?? hint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _hasFile
                              ? AppColors.success
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_hasFile && detail != null) ...[
                  AppSpacing.gapXs,
                  Text(
                    detail!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          AppSpacing.hGapSm,
          _ActionButton(
            icon: _hasFile
                ? Icons.delete_outline_rounded
                : Icons.file_upload_outlined,
            color: _hasFile ? colorScheme.error : colorScheme.primary,
            tooltip: _hasFile ? 'Remove $title' : 'Upload $title',
            onPressed: _hasFile ? onRemove : onUpload,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.xs),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      ),
    );
  }
}
