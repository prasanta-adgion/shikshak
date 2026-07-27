import 'package:flutter/material.dart';

/// "Already have an account? Login" prompt shown under the auth card.
class AuthFooterPrompt extends StatelessWidget {
  const AuthFooterPrompt({
    super.key,
    required this.question,
    required this.actionLabel,
    required this.onPressed,
  });

  final String question;
  final String actionLabel;

  /// `null` disables the action — used while a submit is in flight.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          question,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(onPressed: onPressed, child: Text(actionLabel)),
      ],
    );
  }
}
