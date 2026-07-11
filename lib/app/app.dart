import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import 'router/app_router.dart';

/// Root widget of the Shikshak application.
///
/// Wires the design system ([AppTheme]) and navigation ([AppRouter]) into a
/// [MaterialApp.router]. Kept intentionally thin: all behaviour lives in
/// features, all configuration in `core/`.
class ShikshakApp extends StatelessWidget {
  const ShikshakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
