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
    this.alignToTop = false,
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

  /// Keeps short auth pages pinned to the top instead of vertically centered.
  final bool alignToTop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: ResponsiveBuilder(
          // Branch on device class (rotation-stable) so a landscape phone keeps
          // the single-column form; still read constraints for the tablet
          // layout's min-height.
          builder: (context, constraints) => context.isTabletDevice
              ? _buildTablet(context, constraints)
              : _buildPhone(),
        ),
      ),
    );
  }

  Widget _buildPhone() {
    return Align(
      key: const Key('auth-phone-layout'),
      alignment: alignToTop ? Alignment.topCenter : Alignment.center,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: CenteredConstrainedBox(
          maxWidth: Breakpoints.formMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (banner != null) banner! else AppSpacing.gapXl,
              _FormContent(pagePadding: AppSpacing.pagePadding, child: this),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTablet(BuildContext context, BoxConstraints constraints) {
    // Fixed-height two-pane: the hero banner fills the viewport via `stretch`
    // while the form pane scrolls on its own. We intentionally avoid
    // IntrinsicHeight here — it can't measure a subtree that contains a
    // LayoutBuilder (e.g. the OTP pin field), which throws during layout.
    return CenteredConstrainedBox(
      key: const Key('auth-tablet-layout'),
      maxWidth: Breakpoints.contentMaxWidth,
      child: SizedBox(
        height: constraints.maxHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 5, child: banner ?? const SizedBox.shrink()),
            Expanded(flex: 6, child: _buildTabletFormPane(context)),
          ],
        ),
      ),
    );
  }

  /// Right-hand form column on tablet: centers the form when it fits, scrolls
  /// when it doesn't. Uses `ConstrainedBox(minHeight)` + `Align` (not
  /// IntrinsicHeight) so any LayoutBuilder inside the form lays out cleanly.
  Widget _buildTabletFormPane(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Align(
            alignment: alignToTop ? Alignment.topCenter : Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Breakpoints.formMaxWidth,
              ),
              child: _FormContent(
                pagePadding: context.responsivePagePadding,
                child: this,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormContent extends StatelessWidget {
  const _FormContent({required this.pagePadding, required this.child});

  final EdgeInsets pagePadding;
  final AuthScaffold child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSpacing.gapXl,
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppHeader(
                  title: child.title,
                  subtitle: child.subtitle,
                  alignment: CrossAxisAlignment.center,
                ),
                AppSpacing.gapXl,
                if (child.roleSelector != null) ...[
                  child.roleSelector!,
                  AppSpacing.gapXl,
                ],
                child.form,
              ],
            ),
          ),
          if (child.footer != null) ...[AppSpacing.gapXl, child.footer!],
          AppSpacing.gapXxl,
        ],
      ),
    );
  }
}
