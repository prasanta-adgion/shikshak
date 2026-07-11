import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// "Continue with Google" button (UI only — no OAuth wired yet).
class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Simple multi-colour "G" mark — replaced by a brand asset later.
            Text(
              'G',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF4285F4),
              ),
            ),
            AppSpacing.hGapSm,
            Text(
              'Continue with Google',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
