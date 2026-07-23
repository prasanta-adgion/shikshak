import 'package:Shikshak/core/constants/app_images_const.dart';
import 'package:Shikshak/core/theme/app_spacing.dart';
import 'package:Shikshak/core/utils/responsive.dart';
import 'package:flutter/material.dart';

class NewPasswordSetBg extends StatelessWidget {
  final Widget child;

  const NewPasswordSetBg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = context.isTabletDevice;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Background
          Image.asset(AppImagesConst.passwordForgotBg, fit: BoxFit.fill),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: CenteredConstrainedBox(
                maxWidth: isTablet
                    ? Breakpoints.tabletFormMaxWidth
                    : Breakpoints.formMaxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppImagesConst.newPasswordSet,
                      width: isTablet ? 250 : 150,
                      height: isTablet ? 250 : 150,
                    ),
                    Text(
                      'Set New Password',
                      style: theme.textTheme.headlineSmall,
                    ),
                    AppSpacing.gapSm,

                    Text(
                      'Your new password must be different from previously used passwords.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: isTablet ? 20 : 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    isTablet ? AppSpacing.gapXxxl : AppSpacing.gapLg,

                    /// Form Card
                    Center(child: child),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
