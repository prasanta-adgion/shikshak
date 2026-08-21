import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_text_field.dart';

/// The list's one input: free text, with the filter sheet's entry point living
/// inside the same field so searching and narrowing read as one control.
class TeachersSearchField extends StatelessWidget {
  const TeachersSearchField({
    super.key,
    required this.controller,
    required this.activeFilterCount,
    required this.onFilterPressed,
    required this.onClear,
  });

  final TextEditingController controller;

  /// Drives the badge over the filter button — 0 hides it.
  final int activeFilterCount;

  final VoidCallback onFilterPressed;

  /// Clears the text only. Filters are cleared from inside the sheet.
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFilters = activeFilterCount > 0;

    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, _) => AppTextField(
        controller: controller,
        hint: 'Search teachers',
        prefixIcon: AppIcons.search,
        textInputAction: TextInputAction.search,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value.text.isNotEmpty)
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Clear search',
                visualDensity: VisualDensity.compact,
              ),
            IconButton(
              onPressed: onFilterPressed,
              // Once the sheet is closed the badge is the only sign filters
              // are on, so the icon takes the accent colour with it.
              color: hasFilters ? theme.colorScheme.primary : null,
              tooltip: hasFilters
                  ? '$activeFilterCount filters applied'
                  : 'Filters',
              visualDensity: VisualDensity.compact,
              icon: Badge.count(
                count: activeFilterCount,
                isLabelVisible: hasFilters,
                child: const Icon(AppIcons.filter),
              ),
            ),
            AppSpacing.hGapXs,
          ],
        ),
      ),
    );
  }
}
