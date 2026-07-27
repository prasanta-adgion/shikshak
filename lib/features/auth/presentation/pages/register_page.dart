import 'package:Shikshak/core/constants/app_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
import '../../domain/entities/user_role.dart';
import '../../domain/params/auth_params.dart';
import '../providers_di/auth_providers.dart';
import '../widgets/auth_footer_prompt.dart';
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

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    final succeeded = await ref
        .read(registerNotifierProvider.notifier)
        .register(
          RegisterParams(
            fullName: _nameController.text,
            email: email,
            mobileNumber: _mobileController.text,
            password: _passwordController.text,
            role: widget.role,
          ),
        );

    if (succeeded && mounted) {
      context.push(RoutePaths.signupOtp, extra: email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(
      registerNotifierProvider.select((state) => state.isLoading),
    );

    // The repository funnels every failure through ApiException, so the
    // message is always presentable.
    ref.listen(registerNotifierProvider, (previous, next) {
      if (next case AsyncError(error: final ApiException error)) {
        AppSnackbar.showError(context, error.message);
      }
    });

    return AuthScaffold(
      banner: AppHeroBanner(
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
      footer: AuthFooterPrompt(
        question: 'Already have an account?',
        actionLabel: 'Login',
        onPressed: isSubmitting ? null : context.pop,
      ),
    );
  }
}
