import 'package:Shikshak/app/router/route_paths.dart';
import 'package:Shikshak/core/theme/app_icons.dart';
import 'package:Shikshak/core/theme/app_spacing.dart';
import 'package:Shikshak/core/utils/responsive.dart';
import 'package:Shikshak/core/utils/validators.dart';
import 'package:Shikshak/features/forgot_password/presentation/providers/forgot_password_providers.dart';
import 'package:Shikshak/features/forgot_password/presentation/state/forgot_password_state.dart';
import 'package:Shikshak/features/forgot_password/presentation/widgets/new_password_set_bg.dart';
import 'package:Shikshak/shared/widgets/app_card.dart';
import 'package:Shikshak/shared/widgets/app_loading_button.dart';
import 'package:Shikshak/shared/widgets/app_snackbar.dart';
import 'package:Shikshak/shared/widgets/app_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Step 3 of the reset flow: choose the new password.
class NewPasswordSet extends ConsumerStatefulWidget {
  const NewPasswordSet({super.key});

  @override
  ConsumerState<NewPasswordSet> createState() => _NewPasswordSetState();
}

class _NewPasswordSetState extends ConsumerState<NewPasswordSet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  final ValueNotifier<bool> _obscureNewPassword = ValueNotifier(true);
  final ValueNotifier<bool> _obscureConfirmPassword = ValueNotifier(true);

  @override
  void dispose() {
    _newPassword.dispose();
    _confirmPassword.dispose();
    _obscureNewPassword.dispose();
    _obscureConfirmPassword.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref
        .read(forgotPasswordNotifierProvider.notifier)
        .submitNewPassword(_newPassword.text);
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
        newPassword: _newPassword,
        confirmPassword: _confirmPassword,
        obscureNewPassword: _obscureNewPassword,
        obscureConfirmPassword: _obscureConfirmPassword,
        isLoading: isSubmitting,
        onSubmit: _submit,
      ),
    );
  }
}

class _NewPasswordCard extends StatelessWidget {
  const _NewPasswordCard({
    required this.formKey,
    required this.newPassword,
    required this.confirmPassword,
    required this.obscureNewPassword,
    required this.obscureConfirmPassword,
    required this.isLoading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController newPassword;
  final TextEditingController confirmPassword;
  final ValueNotifier<bool> obscureNewPassword;
  final ValueNotifier<bool> obscureConfirmPassword;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = context.isTabletDevice;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isTablet
            ? Breakpoints.tabletFormMaxWidth
            : Breakpoints.formMaxWidth,
      ),
      child: AppCard(
        padding: EdgeInsets.all(isTablet ? AppSpacing.xxxl : AppSpacing.xl),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: obscureNewPassword,
                builder: (context, obscure, _) {
                  return AppTextField(
                    label: 'New Password',
                    hint: 'Enter new password',
                    controller: newPassword,
                    validator: Validators.password,
                    obscureText: obscure,
                    prefixIcon: AppIcons.password,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure
                            ? AppIcons.passwordHidden
                            : AppIcons.passwordVisible,
                      ),
                      onPressed: () => obscureNewPassword.value = !obscure,
                    ),
                    autofillHints: const [AutofillHints.newPassword],
                  );
                },
              ),
              AppSpacing.gapLg,
              ValueListenableBuilder<bool>(
                valueListenable: obscureConfirmPassword,
                builder: (context, obscure, _) {
                  return AppTextField(
                    label: 'Confirm New Password',
                    hint: 'Confirm new password',
                    controller: confirmPassword,
                    validator: (value) =>
                        Validators.confirmPassword(value, newPassword.text),
                    obscureText: obscure,
                    prefixIcon: AppIcons.password,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure
                            ? AppIcons.passwordHidden
                            : AppIcons.passwordVisible,
                      ),
                      onPressed: () => obscureConfirmPassword.value = !obscure,
                    ),
                    autofillHints: const [AutofillHints.newPassword],
                  );
                },
              ),

              isTablet ? AppSpacing.gapXl : AppSpacing.gapLg,

              AppLoadingButton(
                label: 'Set New Password',
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

              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(CupertinoIcons.arrow_left),
                  label: Text(
                    'Back to Login',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
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
