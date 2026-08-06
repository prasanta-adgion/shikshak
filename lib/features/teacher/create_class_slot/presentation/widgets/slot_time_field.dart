import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/utils/date_time_picker_func.dart';
import '../../../create_profile_account/shared/presentation/widgets/field_shell.dart';

/// Time-of-day picker styled as a form field.
///
/// The wizard ships a date field but no time one; this is its counterpart,
/// built on the same [FieldShell] so the two sit flush beside each other.
class SlotTimeField extends StatelessWidget {
  const SlotTimeField({
    super.key,
    required this.hint,
    required this.onSelected,
    this.label,
    this.value,
    this.errorText,
    this.initialTime,
  });

  final String? label;
  final String hint;
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onSelected;
  final String? errorText;

  /// Where the picker opens when the field is still empty — the end-time field
  /// passes the start time so the teacher lands beside it rather than at 9 AM.
  final TimeOfDay? initialTime;

  Future<void> _pick(BuildContext context) async {
    final picked = await DateTimeUtils.showAppTimePicker(
      context: context,
      initialTime: value ?? initialTime ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (picked != null) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    return FieldShell(
      label: label,
      errorText: errorText,
      trailingIcon: AppIcons.hours,
      onTap: () => _pick(context),
      child: FieldShellValue(
        hint: hint,
        value: value == null ? null : DateTimeUtils.timeOfDay(value!),
      ),
    );
  }
}
