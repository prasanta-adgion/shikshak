import 'package:flutter/material.dart';

/// Checkbox with a label, for the wizard's boolean payload fields
/// (`isCurrent`, `isHighestQualification`).
class WizardCheckboxTile extends StatelessWidget {
  const WizardCheckboxTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (checked) => onChanged(checked ?? false),
          ),
          // Expanded so a long label wraps instead of overflowing the row.
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
