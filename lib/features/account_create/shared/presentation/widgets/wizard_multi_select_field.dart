import 'package:flutter/material.dart';

import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import 'field_shell.dart';

/// Multi-choice picker: a [FieldShell] that opens a checkbox sheet and renders
/// the chosen values as chips beneath itself.
///
/// Backs the payload fields that are string arrays — `classesTaught`,
/// `languagesKnown`.
class WizardMultiSelectField extends StatelessWidget {
  const WizardMultiSelectField({
    super.key,
    required this.hint,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.sheetTitle,
    this.label,
    this.errorText,
  });

  /// Omitted inside a [WizardFieldCard], which carries the name itself.
  final String? label;

  final String hint;
  final List<String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;
  final String? errorText;

  /// Heading inside the sheet.
  final String sheetTitle;

  Future<void> _openSheet(BuildContext context) async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (context) => _MultiOptionSheet(
        title: sheetTitle,
        options: options,
        selected: selected,
      ),
    );

    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldShell(
          label: label,
          errorText: errorText,
          onTap: () => _openSheet(context),
          child: FieldShellValue(
            hint: hint,
            value: selected.isEmpty
                ? null
                : '${selected.length} selected',
          ),
        ),
        if (selected.isNotEmpty) ...[
          AppSpacing.gapSm,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final value in selected)
                Chip(
                  label: Text(value),
                  labelStyle: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.08,
                  ),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.35),
                  ),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  deleteIcon: const Icon(Icons.close_rounded, size: 14),
                  deleteIconColor: theme.colorScheme.primary,
                  onDeleted: () =>
                      onChanged([...selected]..remove(value)),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _MultiOptionSheet extends StatefulWidget {
  const _MultiOptionSheet({
    required this.title,
    required this.options,
    required this.selected,
  });

  final String title;
  final List<String> options;
  final List<String> selected;

  @override
  State<_MultiOptionSheet> createState() => _MultiOptionSheetState();
}

class _MultiOptionSheetState extends State<_MultiOptionSheet> {
  late final Set<String> _selected = {...widget.selected};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
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
              child: Row(
                children: [
                  Expanded(
                    child: Text(widget.title, style: theme.textTheme.titleLarge),
                  ),
                  TextButton(
                    // Pops with the working set: the sheet is the editor, the
                    // field only stores the result.
                    onPressed: () =>
                        Navigator.of(context).pop(_selected.toList()),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                itemCount: widget.options.length,
                itemBuilder: (context, index) {
                  final option = widget.options[index];
                  final isSelected = _selected.contains(option);

                  return CheckboxListTile(
                    value: isSelected,
                    title: Text(option, style: theme.textTheme.bodyLarge),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (checked) => setState(() {
                      if (checked ?? false) {
                        _selected.add(option);
                      } else {
                        _selected.remove(option);
                      }
                    }),
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
