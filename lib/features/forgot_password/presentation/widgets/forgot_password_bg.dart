import 'package:Shikshak/core/constants/app_images_const.dart';
import 'package:Shikshak/core/theme/app_colors.dart';
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
          Image.asset(AppImagesConst.passwordForgotBg, fit: BoxFit.fill),

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
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Forgot\n',
                            style: TextStyle(
                              fontSize: isTablet ? 50 : 25,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                              height: 1.1,
                            ),
                          ),
                          TextSpan(
                            text: 'Password?',
                            style: TextStyle(
                              fontSize: isTablet ? 50 : 25,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.gapSm,
                    Container(
                      width: 48,
                      height: isTablet ? 5 : 3,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    AppSpacing.gapMd,

                    Text(
                      "No worries! Enter your registered email\nand we'll send you an OTP to reset\nyour password.",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: isTablet ? 20 : 12,
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
