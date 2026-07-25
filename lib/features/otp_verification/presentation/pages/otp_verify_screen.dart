import 'package:Shikshak/shared/widgets/app_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_images_const.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/app_hero_banner.dart';
import '../../../../shared/widgets/app_loading_button.dart';

class OtpVerifyScreen extends StatefulWidget {
  /// Masked phone number or email address to which the OTP was sent.
  final String destination;
  final ValueChanged<String>? onVerified;
  final VoidCallback? onResend;
  final bool isLoading;

  const OtpVerifyScreen({
    super.key,
    this.destination = 'your mobile number',
    this.onVerified,
    this.onResend,
    this.isLoading = false,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _pinFocusNode = FocusNode();

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (widget.onVerified != null) {
      widget.onVerified!(_pinController.text);
      return;
    }

    AppSnackbar.show(context, 'OTP verification is not connected yet.');
  }

  void _resendOtp() {
    _pinController.clear();
    _pinFocusNode.requestFocus();
    if (widget.onResend != null) {
      widget.onResend!();
      return;
    }

    AppSnackbar.show(context, 'A new OTP will be available soon.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveBuilder(
        builder: (context, constraints) => context.isTabletDevice
            ? _buildTablet(context)
            : _buildPhone(context),
      ),
    );
  }

  Widget _buildPhone(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: CenteredConstrainedBox(
            maxWidth: Breakpoints.formMaxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppHeroBanner(image: AppImagesConst.otpScreenImage),
                _buildFormCard(context, padding: AppSpacing.pagePadding),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Soft gradient backdrop. Landscape keeps the hero and form card
  /// side-by-side; portrait stacks the illustration, copy, and card.
  Widget _buildTablet(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: theme.brightness == Brightness.dark
            ? AppColors.darkPageGradient
            : AppColors.lightPageGradient,
      ),
      child: SafeArea(
        child: context.orientation == Orientation.landscape
            ? _buildTabletLandscape(context)
            : _buildTabletPortrait(context),
      ),
    );
  }

  Widget _buildTabletLandscape(BuildContext context) {
    return CenteredConstrainedBox(
      maxWidth: Breakpoints.contentMaxWidth,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Expanded(flex: 5, child: _OtpTabletHero()),
          Expanded(
            flex: 6,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: Breakpoints.tabletFormMaxWidth,
                      ),
                      child: _buildFormCard(
                        context,
                        padding: context.responsivePagePadding,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletPortrait(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: CenteredConstrainedBox(
          maxWidth: Breakpoints.formMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.gapXxl,
              const _OtpPortraitHero(),
              _buildFormCard(context, padding: context.responsivePagePadding),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, {required EdgeInsets padding}) {
    return Padding(
      padding: padding,
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
                  title: 'Verify OTP',
                  subtitle:
                      'Enter the 6-digit code sent to ${widget.destination}',
                  alignment: CrossAxisAlignment.center,
                ),
                AppSpacing.gapXl,
                _buildOtpForm(context),
              ],
            ),
          ),
          AppSpacing.gapXxl,
        ],
      ),
    );
  }

  Widget _buildOtpForm(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              const separatorWidth = AppSpacing.sm;
              final pinWidth =
                  ((constraints.maxWidth - (separatorWidth * 5)) / 6)
                      .clamp(36.0, 52.0)
                      .toDouble();
              final basePinTheme = PinTheme(
                width: pinWidth,
                height: 56,
                textStyle: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
              );

              return Center(
                child: Pinput(
                  length: 6,
                  controller: _pinController,
                  focusNode: _pinFocusNode,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  defaultPinTheme: basePinTheme,
                  focusedPinTheme: basePinTheme.copyWith(
                    decoration: basePinTheme.decoration?.copyWith(
                      border: Border.all(color: colorScheme.primary, width: 2),
                    ),
                  ),
                  submittedPinTheme: basePinTheme.copyWith(
                    decoration: basePinTheme.decoration?.copyWith(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.35,
                      ),
                      border: Border.all(color: colorScheme.primary),
                    ),
                  ),
                  errorPinTheme: basePinTheme.copyWith(
                    decoration: basePinTheme.decoration?.copyWith(
                      border: Border.all(color: colorScheme.error),
                    ),
                  ),
                  separatorBuilder: (_) => AppSpacing.hGapSm,
                  validator: (pin) {
                    if (pin == null || pin.length != 6) {
                      return 'Please enter the complete 6-digit OTP';
                    }
                    return null;
                  },
                  onCompleted: (_) => _verifyOtp(),
                ),
              );
            },
          ),
          AppSpacing.gapXxl,
          AppLoadingButton(
            label: 'Verify OTP',
            isLoading: widget.isLoading,
            onPressed: _verifyOtp,
            trailingIcon: CupertinoIcons.arrow_right,
          ),
          AppSpacing.gapMd,
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                "Didn't receive the code?",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              AppSpacing.hGapSm,
              AppButton(
                label: 'Resend',
                expanded: false,
                color: Colors.transparent,
                labelColor: theme.colorScheme.primary,
                onPressed: widget.isLoading ? null : _resendOtp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Stacked hero for portrait tablets: the OTP illustration and reassuring
/// security copy, centered above the floating form card.
class _OtpPortraitHero extends StatelessWidget {
  const _OtpPortraitHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        children: [
          Image.asset(
            AppImagesConst.otpScreenImage,
            fit: BoxFit.contain,
            height: 220,
          ),
          AppSpacing.gapXl,
          Text(
            'Secure Verification',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          AppSpacing.gapSm,
          Container(
            width: 64,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              borderRadius: AppRadius.chip,
            ),
          ),
          AppSpacing.gapMd,
          Text(
            "We take your account security seriously. Enter the code we've "
            "sent to confirm it's really you.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Left-hand hero for the tablet OTP screen: brand mark, the OTP
/// illustration, and reassuring security copy above the floating form card.
class _OtpTabletHero extends StatelessWidget {
  const _OtpTabletHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: Image.asset(AppImagesConst.onlyLogoWithoutText),
              ),
              AppSpacing.hGapSm,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppConstants.appName.toUpperCase(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFamily: 'Audiowide',
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Learn. Grow. Success',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: Image.asset(
              AppImagesConst.otpScreenImage,
              fit: BoxFit.contain,
              height: 280,
            ),
          ),
          AppSpacing.gapXxxl,
          Text(
            'Secure Verification',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              height: 1.05,
            ),
          ),
          AppSpacing.gapSm,
          Container(
            width: 64,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              borderRadius: AppRadius.chip,
            ),
          ),
          AppSpacing.gapLg,
          Text(
            "We take your account security seriously. Enter the code we've "
            "sent to confirm it's really you.",
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
