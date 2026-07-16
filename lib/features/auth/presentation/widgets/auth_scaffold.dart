import 'package:Shikshak/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_header.dart';

/// Shared chrome for login/registration screens: gradient backdrop, back
/// button, hero logo, headline, and a centered card that hosts the form.
/// Keeps auth pages focused purely on their fields.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    this.footer,
    this.roleSelector,
    this.banner,
  });

  final String title;
  final String subtitle;
  final Widget form;

  /// Content below the card (e.g. "New here? Register").
  final Widget? footer;

  /// Content between the title and the form (e.g. a student/teacher toggle).
  final Widget? roleSelector;

  /// Full-bleed hero content shown above the card (e.g. brand + illustration).
  final Widget? banner;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: CenteredConstrainedBox(
              maxWidth: Breakpoints.formMaxWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (banner != null) banner! else AppSpacing.gapXl,
                  Padding(
                    padding: AppSpacing.pagePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppSpacing.gapXl,

                        //white card
                        AppCard(
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppHeader(
                                title: title,
                                subtitle: subtitle,
                                alignment: CrossAxisAlignment.center,
                              ),
                              AppSpacing.gapXl,
                              if (roleSelector != null) ...[
                                roleSelector!,
                                AppSpacing.gapXl,
                              ],
                              form,
                            ],
                          ),
                        ),
                        if (footer != null) ...[AppSpacing.gapXl, footer!],
                        AppSpacing.gapXxl,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
