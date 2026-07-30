import 'package:flutter/material.dart';

import '../../core/media/picked_media.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

/// Asks whether a photo should come from the camera or the gallery.
///
/// Returns `null` when the sheet is dismissed, which callers treat the same
/// as cancelling the pick.
abstract final class MediaSourceSheet {
  static Future<ImagePickSource?> show(
    BuildContext context, {
    String title = 'Add photo',
  }) {
    return showModalBottomSheet<ImagePickSource>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (context) => _SourceOptions(title: title),
    );
  }
}

class _SourceOptions extends StatelessWidget {
  const _SourceOptions({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              0,
              AppSpacing.xxl,
              AppSpacing.sm,
            ),
            child: Text(title, style: theme.textTheme.titleLarge),
          ),
          const _SourceTile(
            icon: Icons.photo_camera_outlined,
            label: 'Take a photo',
            source: ImagePickSource.camera,
          ),
          const _SourceTile(
            icon: Icons.photo_library_outlined,
            label: 'Choose from gallery',
            source: ImagePickSource.gallery,
          ),
          AppSpacing.gapLg,
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.source,
  });

  final IconData icon;
  final String label;
  final ImagePickSource source;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        height: 38,
        width: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        child: Icon(icon, size: 20, color: theme.colorScheme.primary),
      ),
      title: Text(label, style: theme.textTheme.bodyLarge),
      onTap: () => Navigator.of(context).pop(source),
    );
  }
}
