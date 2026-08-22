import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shiksak/core/theme/app_radius.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_loading_button.dart';
import '../../../../shared/widgets/app_otp_field.dart';
import '../../../../shared/widgets/app_password_field.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../providers/forgot_password_providers.dart';
import '../state/forgot_password_state.dart';
import '../widgets/new_password_set_bg.dart';

/// Step 2 — the last step: the OTP and the new password go up together, since
/// the backend verifies and updates in one call.
class NewPasswordSet extends ConsumerStatefulWidget {
  const NewPasswordSet({super.key});

  @override
  ConsumerState<NewPasswordSet> createState() => _NewPasswordSetState();
}

class _NewPasswordSetState extends ConsumerState<NewPasswordSet> {
  /// How long *Resend* stays locked after a code goes out. The first window
  /// starts on entry, since step 1 just sent one.
  static const _resendCooldown = Duration(seconds: 60);

  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  Timer? _resendTimer;

  /// Seconds left on the resend lock; `0` means *Resend* is tappable. A
  /// notifier rather than plain state, so a tick rebuilds the resend row alone
  /// instead of the whole form.
  final _resendSecondsLeft = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _resendSecondsLeft.dispose();
    _otpController.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    _resendSecondsLeft.value = _resendCooldown.inSeconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _resendSecondsLeft.value -= 1;
      if (_resendSecondsLeft.value == 0) timer.cancel();
    });
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref
        .read(forgotPasswordNotifierProvider.notifier)
        .resetPassword(
          otp: _otpController.text,
          newPassword: _newPassword.text,
          confirmPassword: _confirmPassword.text,
        );
  }

  Future<void> _resendOtp() async {
    if (_resendSecondsLeft.value != 0) return;

    _otpController.clear();
    // Locks on the tap, not on the reply: the point is to stop the endpoint
    // being hammered. A failure still surfaces through the error listener.
    _startResendCooldown();

    final sent = await ref
        .read(forgotPasswordNotifierProvider.notifier)
        .resendOtp();
    if (sent && mounted) {
      AppSnackbar.show(context, 'A new code is on its way.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(
      forgotPasswordNotifierProvider.select((s) => s.isSubmitting),
    );

    // Flow finished — send the user back to sign in with the new password.
    ref.listen(forgotPasswordNotifierProvider.select((s) => s.stage), (
      previous,
      next,
    ) {
      if (next == PasswordResetStage.completed && previous != next) {
        AppSnackbar.showSuccess(
          context,
          'Password updated. Sign in with your new password.',
        );
        ref.read(forgotPasswordNotifierProvider.notifier).reset();
        context.go(RoutePaths.login);
      }
    });

    ref.listen(forgotPasswordNotifierProvider.select((s) => s.errorMessage), (
      previous,
      next,
    ) {
      if (next != null && next != previous) {
        AppSnackbar.showError(context, next);
      }
    });

    return NewPasswordSetBg(
      child: _NewPasswordCard(
        formKey: _formKey,
        otpController: _otpController,
        newPassword: _newPassword,
        confirmPassword: _confirmPassword,
        isLoading: isSubmitting,
        resendSecondsLeft: _resendSecondsLeft,
        onResend: _resendOtp,
        onSubmit: _submit,
      ),
    );
  }
}

class _NewPasswordCard extends StatelessWidget {
  const _NewPasswordCard({
    required this.formKey,
    required this.otpController,
    required this.newPassword,
    required this.confirmPassword,
    required this.isLoading,
    required this.resendSecondsLeft,
    required this.onResend,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController otpController;
  final TextEditingController newPassword;
  final TextEditingController confirmPassword;
  final bool isLoading;
  final ValueNotifier<int> resendSecondsLeft;
  final VoidCallback onResend;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = context.isTabletDevice;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: context.responsiveFormMaxWidth),
      child: AppCard(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xs),
          topRight: Radius.circular(AppRadius.xs),
        ),
        padding: EdgeInsets.all(isTablet ? AppSpacing.xxxl : AppSpacing.xl),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Verification Code',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              AppSpacing.gapSm,
              AppOtpField(controller: otpController),
              AppSpacing.gapSm,
              _ResendRow(
                secondsLeft: resendSecondsLeft,
                isLoading: isLoading,
                onResend: onResend,
              ),

              isTablet ? AppSpacing.gapXl : AppSpacing.gapLg,

              AppPasswordField(
                label: 'New Password',
                hint: 'Enter new password',
                controller: newPassword,
                validator: Validators.password,
                textInputAction: TextInputAction.next,
              ),
              AppSpacing.gapLg,
              AppPasswordField(
                label: 'Confirm New Password',
                hint: 'Confirm new password',
                controller: confirmPassword,
                validator: (value) =>
                    Validators.confirmPassword(value, newPassword.text),
                onFieldSubmitted: (_) => onSubmit(),
              ),

              isTablet ? AppSpacing.gapXl : AppSpacing.gapLg,

              AppLoadingButton(
                label: 'Reset Password',
                isLoading: isLoading,
                onPressed: onSubmit,
                trailingIcon: CupertinoIcons.arrow_right,
              ),

              isTablet ? AppSpacing.gapXxxl : AppSpacing.gapXl,

              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      'OR',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              AppSpacing.gapSm,

              TextButton.icon(
                onPressed: isLoading
                    ? null
                    : () => context.go(RoutePaths.login),
                icon: const Icon(CupertinoIcons.arrow_left),
                label: Text(
                  'Back to Login',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Didn't get the code? Resend in 42s" — rebuilds once a second on its own.
class _ResendRow extends StatelessWidget {
  const _ResendRow({
    required this.secondsLeft,
    required this.isLoading,
    required this.onResend,
  });

  final ValueNotifier<int> secondsLeft;
  final bool isLoading;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<int>(
      valueListenable: secondsLeft,
      builder: (context, seconds, _) {
        final canResend = seconds == 0;

        return Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              "Didn't receive the code?",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.hGapSm,
            TextButton(
              onPressed: isLoading || !canResend ? null : onResend,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                canResend ? 'Resend' : 'Resend in ${seconds}s',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: canResend
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
