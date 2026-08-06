import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../domain/entities/class_mode.dart';

/// Maps the server's `colorTag` onto the app's own palette.
///
/// The tags are Tailwind-style names (`amber`, `emerald`, ...) chosen by the
/// backend, and the app never paints a raw hex of its own — so each family is
/// folded onto the nearest semantic or scheme colour. The violet/indigo family
/// is the primary itself, which is also where anything unrecognised lands.
abstract final class SlotAccent {
  static Color of(String? colorTag, ColorScheme colorScheme) =>
      switch (colorTag?.trim().toLowerCase()) {
        'amber' || 'yellow' || 'orange' => AppColors.warning,
        'emerald' || 'green' || 'lime' || 'teal' => AppColors.success,
        'sky' || 'blue' || 'cyan' => AppColors.info,
        'rose' || 'red' || 'pink' => colorScheme.error,
        _ => colorScheme.primary,
      };
}

extension ClassModeIcon on ClassMode {
  IconData get icon => switch (this) {
    ClassMode.online => AppIcons.classOnline,
    ClassMode.offline => AppIcons.classInPerson,
    ClassMode.hybrid => AppIcons.classHybrid,
  };
}
