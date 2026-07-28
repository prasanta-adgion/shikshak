import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_spacing.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.prefixIcon,
    this.prefixImage,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofillHints,
    this.onFieldSubmitted,
  });

  final String? label;
  final TextEditingController? controller;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final IconData? prefixIcon;

  /// Asset path for a custom leading image (e.g. a brand icon), used instead
  /// of [prefixIcon] when set.
  final String? prefixImage;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final int maxLines;

  /// Caps the entry and renders the `0/500` counter beneath the box.
  final int? maxLength;

  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final field = TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      autofillHints: autofillHints,
      onFieldSubmitted: onFieldSubmitted,
      style: theme.textTheme.bodyLarge,
      autovalidateMode: AutovalidateMode.onUserInteraction,

      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: _buildPrefix(),
        suffixIcon: suffixIcon,
        counterStyle: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );

    if (label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        AppSpacing.gapSm,
        field,
      ],
    );
  }

  Widget? _buildPrefix() {
    if (prefixImage != null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Image.asset(prefixImage!, fit: BoxFit.contain),
      );
    }
    if (prefixIcon != null) {
      return Icon(prefixIcon, size: 22);
    }
    return null;
  }
}
