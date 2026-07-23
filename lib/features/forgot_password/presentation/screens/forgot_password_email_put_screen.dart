import 'package:Shikshak/core/constants/app_images_const.dart';
import 'package:Shikshak/core/theme/app_icons.dart';
import 'package:Shikshak/core/theme/app_spacing.dart';
import 'package:Shikshak/core/utils/responsive.dart';
import 'package:Shikshak/core/utils/validators.dart';
import 'package:Shikshak/features/forgot_password/presentation/widgets/forgot_password_bg.dart';
import 'package:Shikshak/shared/widgets/app_card.dart';
import 'package:Shikshak/shared/widgets/app_loading_button.dart';
import 'package:Shikshak/shared/widgets/app_text_field.dart';
import 'package:flutter/cupertino.dart';
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

    return ForgotPasswordBackground(
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
      padding: EdgeInsets.all(isTablet ? AppSpacing.xxxl : AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(AppImagesConst.emailIcon, height: isTablet ? 110 : 90),

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
            style: theme.textTheme.bodyMedium,
          ),

          isTablet ? AppSpacing.gapXxxl : AppSpacing.gapXl,

          AppTextField(
            label: 'Email Address',
            hint: 'you@example.com',
            controller: emailController,
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: AppIcons.identifier,

            autofillHints: const [AutofillHints.email],
          ),

          isTablet ? AppSpacing.gapXl : AppSpacing.gapLg,

          AppLoadingButton(label: 'Send OTP', isLoading: false),

          isTablet ? AppSpacing.gapXxxl : AppSpacing.gapXl,

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
  );
}
