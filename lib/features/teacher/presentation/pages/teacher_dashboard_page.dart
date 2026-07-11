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
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/logout_button.dart';
import '../widgets/availability_card.dart';
import '../widgets/class_request_tile.dart';
import '../widgets/earnings_card.dart';
import '../widgets/stat_card.dart';

/// Teacher home shell: bottom navigation + tab content.
/// Only the Home tab has real content for now; the rest are placeholders.
class TeacherDashboardPage extends ConsumerStatefulWidget {
  const TeacherDashboardPage({super.key});

  @override
  ConsumerState<TeacherDashboardPage> createState() =>
      _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends ConsumerState<TeacherDashboardPage> {
  int _tabIndex = 0;

  static const _placeholderTabs = [
    (
      title: 'Schedule',
      message: 'Your class calendar and time slots will appear here.'
    ),
    (
      title: 'My Students',
      message: 'All your enrolled students will be listed here.'
    ),
    (
      title: 'Earnings',
      message: 'Detailed payout history and invoices are on the way.'
    ),
    (
      title: 'Profile',
      message: 'Manage your public profile, subjects and pricing.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _tabIndex == 0
            ? const _TeacherHomeTab()
            : EmptyState(
                title: _placeholderTabs[_tabIndex - 1].title,
                message: _placeholderTabs[_tabIndex - 1].message,
              ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(AppIcons.homeOutlined),
            selectedIcon: Icon(AppIcons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.scheduleOutlined),
            selectedIcon: Icon(AppIcons.schedule),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.studentsOutlined),
            selectedIcon: Icon(AppIcons.students),
            label: 'Students',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.earningsOutlined),
            selectedIcon: Icon(AppIcons.earnings),
            label: 'Earnings',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.profileOutlined),
            selectedIcon: Icon(AppIcons.profile),
            label: 'Profile',
          ),
        ],
      ),
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
    final user = ref.watch(authNotifierProvider.select((s) => s.user));
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good ${_daypart()},',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(firstName, style: theme.textTheme.titleMedium),
                  ],
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
            padding: AppSpacing.pagePadding,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                AppSpacing.gapSm,
                _WelcomeBanner(firstName: firstName),
                AppSpacing.gapXl,
                GridView.count(
                  crossAxisCount: context.isTablet ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: context.isTablet ? 1.2 : 1.15,
                  children: [
                    for (final stat in _stats) StatCard(stat: stat),
                  ],
                ),
                AppSpacing.gapXl,
                const EarningsCard(),
                AppSpacing.gapXl,
                const AvailabilityCard(),
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
            child: const Icon(
              AppIcons.schedule,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
