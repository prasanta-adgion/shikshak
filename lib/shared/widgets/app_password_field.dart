import 'package:flutter/material.dart';

import '../../core/theme/app_icons.dart';
import 'app_text_field.dart';

/// Password input with a visibility toggle.
///
/// Owns only the obscure/reveal state; everything else is delegated to
/// [AppTextField] so styling stays consistent.
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    this.label = 'Password',
    this.controller,
    this.hint,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      controller: widget.controller,
      hint: widget.hint,
      validator: widget.validator,
      obscureText: _obscured,
      prefixIcon: AppIcons.password,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: const [AutofillHints.password],
      onFieldSubmitted: widget.onFieldSubmitted,
      suffixIcon: IconButton(
        onPressed: () => setState(() => _obscured = !_obscured),
        icon: Icon(
          _obscured ? AppIcons.passwordHidden : AppIcons.passwordVisible,
          size: 22,
        ),
        tooltip: _obscured ? 'Show password' : 'Hide password',
      ),
    );
  }
}
