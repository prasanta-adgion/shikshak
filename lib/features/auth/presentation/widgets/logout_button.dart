import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_icons.dart';
import '../providers/auth_providers.dart';

/// App-bar logout action with a confirmation dialog.
/// Shared by both dashboards. Clears the session, then returns to the
/// role-selection screen.
class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Log out?'),
            content: const Text('You will need to log in again to continue.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Log out'),
              ),
            ],
          ),
        );
        if (confirmed ?? false) {
          await ref.read(authNotifierProvider.notifier).logout();
          if (context.mounted) {
            context.go(RoutePaths.roleSelection);
          }
        }
      },
      icon: const Icon(AppIcons.logout),
      tooltip: 'Log out',
    );
  }
}
