import 'package:Shikshak/core/constants/app_images_const.dart';
import 'package:Shikshak/core/theme/app_colors.dart';
import 'package:Shikshak/core/theme/app_radius.dart';
import 'package:Shikshak/core/theme/app_spacing.dart';
import 'package:Shikshak/core/utils/responsive.dart';
import 'package:flutter/material.dart';

class ForgotPasswordBackground extends StatelessWidget {
  final Widget child;

  const ForgotPasswordBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = context.isTabletDevice;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Background
          Image.asset(AppImagesConst.passwordForgotBg, fit: BoxFit.cover),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: CenteredConstrainedBox(
                maxWidth: isTablet
                    ? Breakpoints.tabletFormMaxWidth
                    : Breakpoints.formMaxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Heading
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Forgot\n',
                            style: TextStyle(color: theme.colorScheme.onSurface),
                          ),
                          TextSpan(
                            text: 'Password?',
                            style: TextStyle(color: theme.colorScheme.primary),
                          ),
                        ],
                      ),
                      style:
                          (isTablet
                                  ? theme.textTheme.displayLarge
                                  : theme.textTheme.headlineLarge)
                              ?.copyWith(height: 1.1),
                    ),
                    AppSpacing.gapSm,
                    Container(
                      width: 48,
                      height: isTablet ? 5 : 3,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: AppRadius.chip,
                      ),
                    ),

                    AppSpacing.gapMd,

                    // No hard line breaks — the copy wraps to whatever width
                    // the device gives it.
                    Text(
                      'No worries! Enter your registered email and we\'ll send '
                      'you an OTP to reset your password.',
                      style:
                          (isTablet
                                  ? theme.textTheme.titleMedium
                                  : theme.textTheme.bodySmall)
                              ?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                    ),

                    isTablet ? AppSpacing.gapXxxl : AppSpacing.gapSm,

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
