import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../domain/entities/user_role.dart';
import '../providers/auth_providers.dart';
import '../widgets/role_card.dart';

/// Mandatory first decision screen: continue as Teacher or Student.
///
/// The chosen role is stored in [AuthState.selectedRole] and carried through
/// the login/registration flow via the `:role` route parameter.
class RoleSelectionPage extends ConsumerStatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  ConsumerState<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends ConsumerState<RoleSelectionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(UserRole role) {
    ref.read(authNotifierProvider.notifier).selectRole(role);
    context.push(RoutePaths.loginFor(role));
  }

  /// Fade + rise entrance, staggered by [start] within the intro timeline.
  Widget _animated({required double start, required Widget child}) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, (start + 0.55).clamp(0, 1), curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = context.isTablet;

    final teacherCard = _animated(
      start: 0.2,
      child: RoleCard(
        role: UserRole.teacher,
        icon: AppIcons.teacher,
        gradient: AppColors.teacherGradient,
        subtitle:
            'Teach students, manage your availability, upload study materials, '
            'and grow your teaching business.',
        onSelected: () => _select(UserRole.teacher),
      ),
    );

    final studentCard = _animated(
      start: 0.35,
      child: RoleCard(
        role: UserRole.student,
        icon: AppIcons.student,
        gradient: AppColors.studentGradient,
        subtitle:
            'Find experienced tutors, book classes, learn online, and purchase '
            'study materials.',
        onSelected: () => _select(UserRole.student),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: CenteredConstrainedBox(
              maxWidth: 940,
              child: Padding(
                padding: AppSpacing.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppSpacing.gapXxxl,
                    _animated(
                      start: 0,
                      child: const Center(child: AppLogo(size: 72)),
                    ),
                    AppSpacing.gapXxl,
                    _animated(
                      start: 0.1,
                      child: const AppHeader(
                        title: 'Welcome to ${AppConstants.appName}',
                        subtitle: 'Choose how you want to continue',
                        alignment: CrossAxisAlignment.center,
                      ),
                    ),
                    AppSpacing.gapXxxl,
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: teacherCard),
                          AppSpacing.hGapXl,
                          Expanded(child: studentCard),
                        ],
                      )
                    else ...[
                      teacherCard,
                      AppSpacing.gapXl,
                      studentCard,
                    ],
                    AppSpacing.gapXxxl,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
