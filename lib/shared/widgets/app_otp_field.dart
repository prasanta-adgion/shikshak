import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

import '../../core/theme/app_spacing.dart';

/// Themed 6-box OTP entry. Lives in `shared/` because two flows need it: the
/// signup verification screen and the password reset form.
class AppOtpField extends StatelessWidget {
  const AppOtpField({
    super.key,
    required this.controller,
    this.focusNode,
    this.length = 6,
    this.autofocus = false,
    this.onCompleted,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final int length;
  final bool autofocus;
  final ValueChanged<String>? onCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        const separatorWidth = AppSpacing.sm;
        // Boxes share the row, then clamp so they stay tappable on a narrow
        // phone and don't stretch into slabs on a tablet.
        final pinWidth =
            ((constraints.maxWidth - (separatorWidth * (length - 1))) / length)
                .clamp(36.0, 52.0)
                .toDouble();
        final basePinTheme = PinTheme(
          width: pinWidth,
          height: 56,
          textStyle: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.md),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
        );

        return Center(
          child: Pinput(
            length: length,
            controller: controller,
            focusNode: focusNode,
            autofocus: autofocus,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(length),
            ],
            defaultPinTheme: basePinTheme,
            focusedPinTheme: basePinTheme.copyWith(
              decoration: basePinTheme.decoration?.copyWith(
                border: Border.all(color: colorScheme.primary, width: 2),
              ),
            ),
            submittedPinTheme: basePinTheme.copyWith(
              decoration: basePinTheme.decoration?.copyWith(
                color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                border: Border.all(color: colorScheme.primary),
              ),
            ),
            errorPinTheme: basePinTheme.copyWith(
              decoration: basePinTheme.decoration?.copyWith(
                border: Border.all(color: colorScheme.error),
              ),
            ),
            separatorBuilder: (_) => AppSpacing.hGapSm,
            validator: (pin) {
              if (pin == null || pin.length != length) {
                return 'Please enter the complete $length-digit OTP';
              }
              return null;
            },
            onCompleted: onCompleted,
          ),
        );
      },
    );
  }
}
