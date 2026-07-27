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
    this.banner,
    this.tabletBackgroundImage,
    this.tabletHero,
  });

  final String title;
  final String subtitle;
  final Widget form;

  final Widget? footer;

  final Widget? banner;

  final String? tabletBackgroundImage;
  final Widget? tabletHero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveBuilder(
        builder: (context, constraints) => context.isTabletDevice
            ? _buildTablet(context, constraints)
            : _buildPhone(),
      ),
    );
  }

  Widget _buildPhone() {
    return SafeArea(
      child: Align(
        key: const Key('auth-phone-layout'),
        alignment: Alignment.center,
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
      ),
    );
  }

  Widget _buildTablet(BuildContext context, BoxConstraints constraints) {
    if (tabletBackgroundImage != null) {
      return _buildTabletImmersive(context);
    }

    return SafeArea(
      child: CenteredConstrainedBox(
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
      ),
    );
  }

  /// Immersive tablet layout: a full-bleed background image with the hero
  /// overlaid on the left and the floating form card on the right.
  Widget _buildTabletImmersive(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(tabletBackgroundImage!, fit: BoxFit.cover),
        SafeArea(
          child: CenteredConstrainedBox(
            key: const Key('auth-tablet-layout'),
            maxWidth: Breakpoints.contentMaxWidth,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: tabletHero ?? banner ?? const SizedBox.shrink(),
                ),
                Expanded(flex: 6, child: _buildTabletFormPane(context)),
              ],
            ),
          ),
        ),
      ],
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
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Breakpoints.tabletFormMaxWidth,
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
