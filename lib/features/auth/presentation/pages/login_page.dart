import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shiksak/core/constants/app_constants.dart';
import 'package:shiksak/features/auth/presentation/widgets/google_sign_in_button.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/constants/app_images_const.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_hero_banner.dart';
import '../../../../shared/widgets/app_loading_button.dart';
import '../../../../shared/widgets/app_password_field.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/params/auth_params.dart';
import '../providers_di/auth_providers.dart';
import '../widgets/auth_footer_prompt.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/role_check_dailog.dart';
import '../widgets/tablet_login_hero.dart';

/// Login screen. One form serves both roles; the register flow asks for the
/// role in a dialog.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// The server decides the role, so the dashboard comes from the response
  /// rather than anything chosen on this screen.
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = await ref
        .read(loginNotifierProvider.notifier)
        .login(
          LoginParams(
            identifier: _identifierController.text,
            password: _passwordController.text,
          ),
        );

    if (user != null && mounted) {
      context.go(RoutePaths.dashboardFor(user.role));
    }
  }

  Future<void> _openRegister(BuildContext context) async {
    final role = await showRoleCheckDialog(context);
    if (role == null || !context.mounted) return;
    context.push(RoutePaths.registerFor(role));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSubmitting = ref.watch(
      loginNotifierProvider.select((state) => state.isLoading),
    );

    // The repository funnels every failure through ApiException, so the
    // message is always presentable.
    ref.listen(loginNotifierProvider, (previous, next) {
      if (next case AsyncError(error: final ApiException error)) {
        AppSnackbar.showError(context, error.message);
      }
    });

    return AuthScaffold(
      banner: const AppHeroBanner(
        headline: 'Welcome',
        headlineAccent: 'Back!',
        subtitle: 'Continue your journey with ${AppConstants.appName}.',
        image: AppImagesConst.loginScreenImage,
      ),
      // On tablets, use the immersive branded background with an overlaid hero.
      tabletBackgroundImage: AppImagesConst.loginBgOfTablet,
      tabletHero: const TabletLoginHero(),
      title: 'Hello Again! 👋',
      subtitle: 'Login to continue your journey',
      form: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Email or Mobile Number',
                hint: 'you@example.com or 98XXXXXXXX',
                controller: _identifierController,
                validator: Validators.emailOrMobile,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: AppIcons.identifier,
                autofillHints: const [AutofillHints.username],
              ),
              AppSpacing.gapMd,
              AppPasswordField(
                controller: _passwordController,
                hint: 'Enter your password',
                validator: (value) =>
                    Validators.required(value, field: 'Password'),
                onFieldSubmitted: (_) => _submit(),
              ),

              Align(
                alignment: AlignmentGeometry.topRight,
                child: TextButton(
                  onPressed: () => context.push(RoutePaths.forgotPassword),
                  child: Text(
                    'Forgot Password?',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              AppSpacing.gapMd,
              AppLoadingButton(
                label: 'Login',
                isLoading: isSubmitting,
                onPressed: _submit,
                trailingIcon: CupertinoIcons.arrow_right,
              ),
              AppSpacing.gapXl,
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
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
              AppSpacing.gapXl,

              GoogleLoginButton(
                isSubmitting: isSubmitting,
                onPressed: () {
                  context.go(RoutePaths.createAccountScreenPath);
                },
              ),
            ],
          ),
        ),
      ),
      footer: AuthFooterPrompt(
        question: 'New to ${AppConstants.appName}?',
        actionLabel: 'Register',
        onPressed: isSubmitting ? null : () => _openRegister(context),
      ),
    );
  }
}
