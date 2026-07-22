import 'package:Shikshak/core/constants/app_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/constants/app_images_const.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_loading_button.dart';
import '../../../../shared/widgets/app_password_field.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/usecases/register_usecase.dart';
import '../providers/auth_providers.dart';
import '../state/auth_state.dart';
import '../widgets/auth_hero_banner.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/tablet_login_hero.dart';

/// Registration screen collecting only the core account fields.
class RegisterPage extends ConsumerStatefulWidget {
  final UserRole role;
  const RegisterPage({super.key, required this.role});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    context.go(RoutePaths.otpVerify, extra: []);
    return;

    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref
        .read(authNotifierProvider.notifier)
        .register(
          RegisterParams(
            fullName: _nameController.text,
            email: _emailController.text,
            mobileNumber: _mobileController.text,
            password: _passwordController.text,
            role: widget.role,
            city: '',
          ),
        );

    context.go(RoutePaths.otpVerify, extra: []);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSubmitting = ref.watch(
      authNotifierProvider.select((s) => s.isSubmitting),
    );

    // Navigate to the dashboard once the account is created.
    ref.listen(authNotifierProvider.select((s) => s.status), (previous, next) {
      final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
      if (next == AuthStatus.authenticated && isCurrent) {
        final role = ref.read(authNotifierProvider).user?.role ?? widget.role;
        context.go(RoutePaths.dashboardFor(role));
      }
    });

    ref.listen(authNotifierProvider.select((s) => s.errorMessage), (
      previous,
      next,
    ) {
      if (next != null && next != previous) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return AuthScaffold(
      banner: AuthHeroBanner(
        image: AppImagesConst.loginScreenImage,
        headline: 'Join',
        headlineAccent: AppConstants.appName,
        subtitle:
            'Sign in to continue your ${widget.role == UserRole.teacher ? 'teaching' : 'learning'} journey.',
      ),
      tabletBackgroundImage: AppImagesConst.loginBgOfTablet,
      tabletHero: const TabletLoginHero(
        headline: 'Join',
        headlineAccent: AppConstants.appName,
        subtitle: 'Sign in to continue to get started',
      ),
      title: 'Create ${widget.role.label} Account',
      subtitle: 'Create your account to get started',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Full Name',
              hint: 'e.g. Priya Sharma',
              controller: _nameController,
              validator: Validators.fullName,
              prefixIcon: AppIcons.name,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
            ),
            AppSpacing.gapMd,

            AppTextField(
              label: 'Email',
              hint: 'you@example.com',
              controller: _emailController,
              validator: Validators.email,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: AppIcons.email,
              autofillHints: const [AutofillHints.email],
            ),
            AppSpacing.gapMd,

            AppTextField(
              label: 'Mobile Number',
              hint: '10-digit mobile number',
              controller: _mobileController,
              validator: Validators.mobileNumber,
              keyboardType: TextInputType.phone,
              prefixIcon: AppIcons.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              autofillHints: const [AutofillHints.telephoneNumber],
            ),
            AppSpacing.gapMd,

            AppPasswordField(
              controller: _passwordController,
              hint: 'Min 8 characters, letters & numbers',
              validator: Validators.password,
              textInputAction: TextInputAction.next,
            ),
            AppSpacing.gapMd,

            AppPasswordField(
              label: 'Confirm Password',
              controller: _confirmPasswordController,
              hint: 'Re-enter your password',
              validator: (value) =>
                  Validators.confirmPassword(value, _passwordController.text),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
            AppSpacing.gapXxl,
            AppLoadingButton(
              label: 'Create Account',
              isLoading: isSubmitting,
              onPressed: _submit,
              trailingIcon: CupertinoIcons.arrow_right,
            ),
          ],
        ),
      ),
      footer: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Already have an account?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          TextButton(
            onPressed: isSubmitting
                ? null
                : () {
                    context.pop(context);
                  },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
