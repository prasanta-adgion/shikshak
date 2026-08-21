import 'package:Shikshak/core/constants/app_images_const.dart';
import 'package:Shikshak/core/responsive/responsive.dart';
import 'package:Shikshak/core/theme/app_spacing.dart';
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
          Image.asset(AppImagesConst.passwordForgotBg, fit: BoxFit.cover),

          SafeArea(
            child: SingleChildScrollView(
              //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: CenteredConstrainedBox(
                maxWidth: context.responsiveFormMaxWidth,
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
                      'Enter the code we emailed you and choose a new password.',
                      textAlign: TextAlign.center,
                      style:
                          (isTablet
                                  ? theme.textTheme.titleMedium
                                  : theme.textTheme.bodySmall)
                              ?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
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
