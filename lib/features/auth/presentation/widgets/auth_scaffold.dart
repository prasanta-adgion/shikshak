import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/gradient_background.dart';

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
  });

  final String title;
  final String subtitle;
  final Widget form;

  /// Content below the card (e.g. "New here? Register").
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: CenteredConstrainedBox(
              maxWidth: Breakpoints.formMaxWidth,
              child: Padding(
                padding: AppSpacing.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppSpacing.gapSm,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => context.canPop()
                            ? context.pop()
                            : null,
                        icon: const Icon(AppIcons.back, size: 20),
                        tooltip: 'Back',
                      ),
                    ),
                    AppSpacing.gapSm,
                    const Center(child: AppLogo(size: 64)),
                    AppSpacing.gapXl,
                    AppHeader(
                      title: title,
                      subtitle: subtitle,
                      alignment: CrossAxisAlignment.center,
                    ),
                    AppSpacing.gapXxl,
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: form,
                    ),
                    if (footer != null) ...[
                      AppSpacing.gapXl,
                      footer!,
                    ],
                    AppSpacing.gapXxl,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
