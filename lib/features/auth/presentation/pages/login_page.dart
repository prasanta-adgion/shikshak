import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_loading_button.dart';
import '../../../../shared/widgets/app_password_field.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/user_role.dart';
import '../providers/auth_providers.dart';
import '../state/auth_state.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/social_login_button.dart';

/// Role-aware login screen — the same page serves teachers and students,
/// adapting its copy from [role].
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, required this.role});

  final UserRole role;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref
        .read(authNotifierProvider.notifier)
        .login(
          identifier: _identifierController.text,
          password: _passwordController.text,
          role: widget.role,
          rememberMe: _rememberMe,
        );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature is coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSubmitting = ref.watch(
      authNotifierProvider.select((s) => s.isSubmitting),
    );

    // Navigate to the dashboard on successful login. The isCurrent check
    // keeps this page from also reacting when the register page (pushed on
    // top of it) completes the auth flow.
    ref.listen(authNotifierProvider.select((s) => s.status), (previous, next) {
      final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
      if (next == AuthStatus.authenticated && isCurrent) {
        final role = ref.read(authNotifierProvider).user?.role ?? widget.role;
        context.go(RoutePaths.dashboardFor(role));
      }
    });

    // Surface auth errors as a snackbar exactly once per failure.
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
      title: 'Welcome Back, ${widget.role.label}',
      subtitle:
          'Log in to continue your ${widget.role == UserRole.teacher ? 'teaching' : 'learning'} journey',
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
                inputFormatters: [],
              ),
              AppSpacing.gapXl,
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
                  onPressed: () => _showComingSoon('Password reset'),
                  child: const Text('Forgot Password?'),
                ),
              ),
              AppSpacing.gapMd,
              AppLoadingButton(
                label: 'Login',
                isLoading: isSubmitting,
                onPressed: _submit,
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
                onPressed: () => _showComingSoon('Google login'),
              ),
            ],
          ),
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'New to Shikshak?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          TextButton(
            onPressed: isSubmitting
                ? null
                : () => context.push(RoutePaths.registerFor(widget.role)),
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}
