import 'package:Shikshak/core/constants/app_images_const.dart';
import 'package:Shikshak/core/theme/app_icons.dart';
import 'package:Shikshak/core/theme/app_spacing.dart';
import 'package:Shikshak/core/utils/responsive.dart';
import 'package:Shikshak/core/utils/validators.dart';
import 'package:Shikshak/features/forgot_password/presentation/widgets/password_set_bg.dart';
import 'package:Shikshak/shared/widgets/app_card.dart';
import 'package:Shikshak/shared/widgets/app_loading_button.dart';
import 'package:Shikshak/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PasswordSetBackground(
      child: ResponsiveBuilder(
        builder: (context, constraints) {
          return _buildWhiteContainer(
            context: context,
            theme: theme,
            isTablet: context.isTabletDevice,
            emailController: _emailController,
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
  required TextEditingController emailController,
}) {
  return ConstrainedBox(
    constraints: BoxConstraints(maxWidth: isTablet ? 550 : 420),
    child: AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(AppImagesConst.emailIcon, height: isTablet ? 110 : 90),

          AppSpacing.gapLg,

          Text(
            'Reset Your Password',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),

          AppSpacing.gapSm,

          Text(
            "Enter your registered email address and we'll send you instructions to reset your password.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),

          AppSpacing.gapXl,

          AppTextField(
            label: 'Email Address',
            hint: 'you@example.com',
            controller: emailController,
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: AppIcons.identifier,
            autofillHints: const [AutofillHints.email],
          ),

          AppSpacing.gapLg,

          AppLoadingButton(label: 'Send OTP', isLoading: false),

          AppSpacing.gapXl,

          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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

          AppSpacing.gapXl,

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Back to Login"),
            ),
          ),
        ],
      ),
    ),
  );
}
