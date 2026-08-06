import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/initials_avatar.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../auth/presentation/providers_di/auth_providers.dart';
import '../../../auth/presentation/widgets/logout_button.dart';
import '../../class_schedule/presentation/pages/teacher_schedule_page.dart';
import '../../profile/presentation/pages/teacher_profile_page.dart';
import '../widgets/availability_card.dart';
import '../widgets/class_request_tile.dart';
import '../widgets/earnings_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/teacher_nav_bar.dart';

class TeacherDashboardPage extends StatelessWidget {
  const TeacherDashboardPage({super.key});

  // Keyed by tab, not by position: a list would silently shift every time one
  // of these placeholders is replaced by a real screen.
  static const _placeholderTabs = {
    TeacherTab.students: (
      title: 'My Students',
      message: 'All your enrolled students will be listed here.',
    ),
    TeacherTab.earnings: (
      title: 'Earnings',
      message: 'Detailed payout history and invoices are on the way.',
    ),
  };

  @override
  Widget build(BuildContext context) {
    return TeacherNavBar(
      tabBuilder: (context, tab) => switch (tab) {
        TeacherTab.home => const _TeacherHomeTab(),
        TeacherTab.schedule => const TeacherSchedulePage(),
        TeacherTab.profile => const TeacherProfilePage(),
        _ => EmptyState(
          title: _placeholderTabs[tab]!.title,
          message: _placeholderTabs[tab]!.message,
        ),
      },
    );
  }
}

class _TeacherHomeTab extends ConsumerWidget {
  const _TeacherHomeTab();

  // Static placeholder content, shown until the analytics and bookings
  // APIs provide real numbers and requests.
  static const _stats = [
    DashboardStat(
      label: 'Total Students',
      value: '0',
      icon: AppIcons.students,
      color: AppColors.primary,
    ),
    DashboardStat(
      label: 'Classes This Week',
      value: '0',
      icon: AppIcons.schedule,
      color: AppColors.tertiary,
    ),
    DashboardStat(
      label: 'Average Rating',
      value: '—',
      icon: AppIcons.rating,
      color: AppColors.secondary,
    ),
    DashboardStat(
      label: 'Hours Taught',
      value: '0',
      icon: AppIcons.hours,
      color: AppColors.info,
    ),
  ];

  static const _recentRequests = [
    ClassRequest(
      studentName: 'Student Name',
      subject: 'Subject',
      grade: 'Class',
      schedule: 'Schedule',
      mode: 'Online',
    ),
    ClassRequest(
      studentName: 'Student Name',
      subject: 'Subject',
      grade: 'Class',
      schedule: 'Schedule',
      mode: 'Home Visit',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateNotifierProvider.select((s) => s.user));
    final firstName = user?.firstName ?? 'Teacher';

    return CenteredConstrainedBox(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            automaticallyImplyLeading: false,
            titleSpacing: AppSpacing.xl,
            title: Row(
              children: [
                InitialsAvatar(name: user?.fullName ?? 'Teacher', size: 42),
                AppSpacing.hGapMd,
                // Expanded + ellipsis: long names must not overflow the bar
                // on narrow phones.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good ${_daypart()},',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        firstName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(AppIcons.notifications),
                tooltip: 'Notifications',
              ),
              const LogoutButton(),
              AppSpacing.hGapMd,
            ],
          ),
          SliverPadding(
            padding: context.responsivePagePadding,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                AppSpacing.gapSm,
                _WelcomeBanner(firstName: firstName),
                AppSpacing.gapXl,
                GridView.count(
                  crossAxisCount: context.isTabletDevice ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: context.isTabletDevice ? 1.2 : 1.15,
                  children: [for (final stat in _stats) StatCard(stat: stat)],
                ),
                AppSpacing.gapXl,
                const _TeacherSummaryCards(),
                AppSpacing.gapXxl,
                const SectionHeader(
                  title: 'Recent Requests',
                  actionLabel: 'See All',
                ),
                AppSpacing.gapMd,
                for (final request in _recentRequests) ...[
                  ClassRequestTile(request: request),
                  AppSpacing.gapMd,
                ],
                AppSpacing.gapXxl,
              ]),
            ),
          ),
        ],
      ),
    );
  }

  static String _daypart() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

class _TeacherSummaryCards extends StatelessWidget {
  const _TeacherSummaryCards();

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < Breakpoints.tablet) {
          return const Column(
            children: [EarningsCard(), AppSpacing.gapXl, AvailabilityCard()],
          );
        }

        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: EarningsCard()),
            AppSpacing.hGapXl,
            Expanded(child: AvailabilityCard()),
          ],
        );
      },
    );
  }
}

/// Slim gradient banner under the app bar summarising today's schedule.
class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      gradient: AppColors.primaryGradient,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $firstName!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                AppSpacing.gapXs,
                Text(
                  "Here's an overview of your teaching activity.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.hGapMd,
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: const BorderRadius.all(
                Radius.circular(AppRadius.sm),
              ),
            ),
            child: const Icon(AppIcons.schedule, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}
