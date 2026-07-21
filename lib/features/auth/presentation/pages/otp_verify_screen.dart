import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/constants/app_images_const.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_loading_button.dart';
import '../widgets/auth_hero_banner.dart';
import '../widgets/auth_scaffold.dart';

class OtpVerifyScreen extends StatefulWidget {
  /// Masked phone number or email address to which the OTP was sent.
  final String destination;
  final ValueChanged<String>? onVerified;
  final VoidCallback? onResend;
  final bool isLoading;

  const OtpVerifyScreen({
    super.key,
    this.destination = 'your mobile number',
    this.onVerified,
    this.onResend,
    this.isLoading = false,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _pinFocusNode = FocusNode();

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (widget.onVerified != null) {
      widget.onVerified!(_pinController.text);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP verification is not connected yet.')),
    );
  }

  void _resendOtp() {
    _pinController.clear();
    _pinFocusNode.requestFocus();
    if (widget.onResend != null) {
      widget.onResend!();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('A new OTP will be available soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AuthScaffold(
      alignToTop: true,
      banner: const AuthHeroBanner(image: AppImagesConst.otpScreenImage),
      title: 'Verify OTP',
      subtitle: 'Enter the 6-digit code sent to ${widget.destination}',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                const separatorWidth = AppSpacing.sm;
                final pinWidth =
                    ((constraints.maxWidth - (separatorWidth * 5)) / 6)
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
                    length: 6,
                    controller: _pinController,
                    focusNode: _pinFocusNode,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    defaultPinTheme: basePinTheme,
                    focusedPinTheme: basePinTheme.copyWith(
                      decoration: basePinTheme.decoration?.copyWith(
                        border: Border.all(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    submittedPinTheme: basePinTheme.copyWith(
                      decoration: basePinTheme.decoration?.copyWith(
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.35,
                        ),
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
                      if (pin == null || pin.length != 6) {
                        return 'Please enter the complete 6-digit OTP';
                      }
                      return null;
                    },
                    onCompleted: (_) => _verifyOtp(),
                  ),
                );
              },
            ),
            AppSpacing.gapXxl,
            AppLoadingButton(
              label: 'Verify OTP',
              isLoading: widget.isLoading,
              onPressed: _verifyOtp,
              trailingIcon: CupertinoIcons.arrow_right,
            ),
            AppSpacing.gapMd,
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  "Didn't receive the code?",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                AppSpacing.hGapSm,
                AppButton(
                  label: 'Resend',
                  expanded: false,
                  color: Colors.transparent,
                  labelColor: theme.colorScheme.primary,
                  onPressed: widget.isLoading ? null : _resendOtp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
