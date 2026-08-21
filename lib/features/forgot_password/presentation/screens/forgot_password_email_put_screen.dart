import 'package:Shikshak/app/router/route_paths.dart';
import 'package:Shikshak/core/constants/app_images_const.dart';
import 'package:Shikshak/core/responsive/responsive.dart';
import 'package:Shikshak/core/theme/app_icons.dart';
import 'package:Shikshak/core/theme/app_spacing.dart';
import 'package:Shikshak/core/utils/validators.dart';
import 'package:Shikshak/features/forgot_password/presentation/providers/forgot_password_providers.dart';
import 'package:Shikshak/features/forgot_password/presentation/state/forgot_password_state.dart';
import 'package:Shikshak/features/forgot_password/presentation/widgets/forgot_password_bg.dart';
import 'package:Shikshak/shared/widgets/app_card.dart';
import 'package:Shikshak/shared/widgets/app_loading_button.dart';
import 'package:Shikshak/shared/widgets/app_snackbar.dart';
import 'package:Shikshak/shared/widgets/app_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Step 1 of the reset flow: collect the registered email address.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref
        .read(forgotPasswordNotifierProvider.notifier)
        .requestOtp(_emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(
      forgotPasswordNotifierProvider.select((s) => s.isSubmitting),
    );

    // Advance to step 2 once the code has been sent.
    ref.listen(forgotPasswordNotifierProvider.select((s) => s.stage), (
      previous,
      next,
    ) {
      if (next == PasswordResetStage.resetPassword && previous != next) {
        context.push(RoutePaths.newPasswordSet);
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

    return ForgotPasswordBackground(
      child: _ForgotPasswordCard(
        formKey: _formKey,
        emailController: _emailController,
        isSending: isSubmitting,
        onSubmit: _sendOtp,
      ),
    );
  }
}

class _ForgotPasswordCard extends StatelessWidget {
  const _ForgotPasswordCard({
    required this.formKey,
    required this.emailController,
    required this.isSending,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isSending;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = context.isTabletDevice;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: context.responsiveFormMaxWidth),
      child: AppCard(
        padding: EdgeInsets.all(isTablet ? AppSpacing.xxxl : AppSpacing.xl),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                AppImagesConst.emailIcon,
                height: isTablet ? 110 : 90,
              ),

              isTablet ? AppSpacing.gapXl : AppSpacing.gapLg,

              Text(
                'Reset Your Password',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),

              isTablet ? AppSpacing.gapMd : AppSpacing.gapSm,

              Text(
                "You'll receive a one-time code (OTP) to verify it's you.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              isTablet ? AppSpacing.gapXxxl : AppSpacing.gapXl,

              AppTextField(
                label: 'Email Address',
                hint: 'you@example.com',
                controller: emailController,
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: AppIcons.identifier,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => onSubmit(),
                autofillHints: const [AutofillHints.email],
              ),

              isTablet ? AppSpacing.gapXl : AppSpacing.gapLg,

              AppLoadingButton(
                label: 'Send OTP',
                isLoading: isSending,
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
                  onPressed: isSending ? null : () => Navigator.pop(context),
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
