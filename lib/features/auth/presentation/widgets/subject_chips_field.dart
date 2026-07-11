import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// Multi-select subject picker rendered as filter chips, wrapped in a
/// [FormField] so it validates alongside the text fields.
class SubjectChipsField extends StatelessWidget {
  const SubjectChipsField({
    super.key,
    required this.label,
    required this.options,
    this.onChanged,
    this.validationMessage = 'Select at least one subject',
  });

  final String label;
  final List<String> options;

  /// Reports the current selection so the page can read it on submit.
  final ValueChanged<Set<String>>? onChanged;

  final String validationMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormField<Set<String>>(
      initialValue: const <String>{},
      validator: (selected) =>
          (selected == null || selected.isEmpty) ? validationMessage : null,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            AppSpacing.gapSm,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final subject in options)
                  FilterChip(
                    label: Text(subject),
                    selected: field.value!.contains(subject),
                    onSelected: (selected) {
                      final next = {...field.value!};
                      selected ? next.add(subject) : next.remove(subject);
                      field.didChange(next);
                      onChanged?.call(next);
                    },
                  ),
              ],
            ),
            if (field.hasError) ...[
              AppSpacing.gapSm,
              Text(
                field.errorText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
