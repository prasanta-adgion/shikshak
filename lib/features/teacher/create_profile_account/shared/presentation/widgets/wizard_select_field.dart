import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import 'field_shell.dart';

class WizardSelectField<T> extends StatelessWidget {
  const WizardSelectField({
    super.key,
    required this.hint,
    required this.options,
    required this.labelOf,
    required this.onSelected,
    required this.sheetTitle,
    this.label,
    this.value,
    this.errorText,
  });

  /// Omitted inside a [WizardFieldCard]; [sheetTitle] names the sheet instead.
  final String? label;
  final String hint;
  final T? value;
  final List<T> options;
  final String Function(T option) labelOf;
  final ValueChanged<T> onSelected;
  final String? errorText;

  /// Heading inside the sheet.
  final String sheetTitle;

  Future<void> _openSheet(BuildContext context) async {
    final selected = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (context) => _OptionSheet<T>(
        title: sheetTitle,
        options: options,
        labelOf: labelOf,
        selected: value,
      ),
    );

    if (selected != null) onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    return FieldShell(
      label: label,
      errorText: errorText,
      onTap: () => _openSheet(context),
      child: FieldShellValue(
        hint: hint,
        value: value == null ? null : labelOf(value as T),
      ),
    );
  }
}

class _OptionSheet<T> extends StatelessWidget {
  const _OptionSheet({
    required this.title,
    required this.options,
    required this.labelOf,
    this.selected,
  });

  final String title;
  final List<T> options;
  final String Function(T option) labelOf;
  final T? selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      // Caps the sheet at 70% so a long list scrolls instead of swallowing
      // the screen.
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                0,
                AppSpacing.xxl,
                AppSpacing.md,
              ),
              child: Text(title, style: theme.textTheme.titleLarge),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = option == selected;

                  return ListTile(
                    title: Text(
                      labelOf(option),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : null,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(option),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
