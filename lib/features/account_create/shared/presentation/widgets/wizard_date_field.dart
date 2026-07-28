import 'package:flutter/material.dart';

import '../../../../../core/utils/date_time_picker_func.dart';
import 'field_shell.dart';

class WizardDateField extends StatelessWidget {
  const WizardDateField({
    super.key,
    required this.hint,
    required this.onSelected,
    this.label,
    this.value,
    this.firstDate,
    this.lastDate,
    this.errorText,
    this.monthOnly = false,
    this.enabled = true,
  });

  /// Omitted inside a [WizardFieldCard], which carries the name itself.
  final String? label;

  final String hint;
  final DateTime? value;
  final ValueChanged<DateTime> onSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? errorText;

  /// Displays `Mar 2020` rather than `12 Mar 2020`.
  final bool monthOnly;

  final bool enabled;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final last = lastDate ?? now;

    final picked = await DateTimeUtils.showAppDatePicker(
      context: context,
      initialDate: value ?? last,
      firstDate: firstDate ?? DateTime(now.year - 80),
      lastDate: last,
    );

    if (picked != null) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: IgnorePointer(
        ignoring: !enabled,
        child: FieldShell(
          label: label,
          errorText: errorText,
          trailingIcon: Icons.calendar_today_rounded,
          onTap: () => _pick(context),
          child: FieldShellValue(
            hint: hint,
            value: value == null
                ? null
                : monthOnly
                ? DateTimeUtils.monthYear(value!)
                : DateTimeUtils.dayMonthYear(value!),
          ),
        ),
      ),
    );
  }
}
