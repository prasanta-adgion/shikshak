import 'package:Shikshak/core/theme/app_icons.dart';
import 'package:Shikshak/core/theme/app_spacing.dart';
import 'package:Shikshak/core/utils/responsive.dart';
import 'package:Shikshak/core/utils/validators.dart';
import 'package:Shikshak/features/forgot_password/presentation/widgets/new_password_set_bg.dart';
import 'package:Shikshak/shared/widgets/app_card.dart';
import 'package:Shikshak/shared/widgets/app_loading_button.dart';
import 'package:Shikshak/shared/widgets/app_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewPasswordSet extends StatefulWidget {
  const NewPasswordSet({super.key});

  @override
  State<NewPasswordSet> createState() => _NewPasswordSetState();
}

class _NewPasswordSetState extends State<NewPasswordSet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  final ValueNotifier<bool> _obscureNewPassword = ValueNotifier(true);
  final ValueNotifier<bool> _obscureConfirmPassword = ValueNotifier(true);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  @override
  void dispose() {
    _newPassword.dispose();
    _confirmPassword.dispose();
    _obscureNewPassword.dispose();
    _obscureConfirmPassword.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    _isLoading.value = true;
    // TODO: call the set-new-password API.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NewPasswordSetBg(
      child: ResponsiveBuilder(
        builder: (context, constraints) {
          return _buildWhiteContainer(
            context: context,
            theme: theme,
            isTablet: context.isTabletDevice,
            formKey: _formKey,
            newPassword: _newPassword,
            confirmPassword: _confirmPassword,
            obscureNewPassword: _obscureNewPassword,
            obscureConfirmPassword: _obscureConfirmPassword,
            isLoading: _isLoading,
            onSubmit: _submit,
          );
        },
      ),
    );
  }
}

Widget _buildWhiteContainer({
  required BuildContext context,
  required ThemeData theme,
  required bool isTablet,
  required GlobalKey<FormState> formKey,
  required TextEditingController newPassword,
  required TextEditingController confirmPassword,
  required ValueNotifier<bool> obscureNewPassword,
  required ValueNotifier<bool> obscureConfirmPassword,
  required ValueNotifier<bool> isLoading,
  required VoidCallback onSubmit,
}) {
  return ConstrainedBox(
    constraints: BoxConstraints(maxWidth: isTablet ? 550 : 420),
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

            ValueListenableBuilder<bool>(
              valueListenable: isLoading,
              builder: (context, loading, _) {
                return AppLoadingButton(
                  label: 'Set New Password',
                  isLoading: loading,
                  onPressed: onSubmit,
                );
              },
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
