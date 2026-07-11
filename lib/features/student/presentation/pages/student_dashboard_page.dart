import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/initials_avatar.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/logout_button.dart';
import '../dummy/student_dummy_data.dart';
import '../widgets/category_card.dart';
import '../widgets/dashboard_search_bar.dart';
import '../widgets/featured_teacher_card.dart';
import '../widgets/recent_tutor_tile.dart';
import '../widgets/student_welcome_card.dart';

/// Student home shell: bottom navigation + tab content.
/// Only the Home tab has real content for now; the rest are placeholders.
class StudentDashboardPage extends ConsumerStatefulWidget {
  const StudentDashboardPage({super.key});

  @override
  ConsumerState<StudentDashboardPage> createState() =>
      _StudentDashboardPageState();
}

class _StudentDashboardPageState extends ConsumerState<StudentDashboardPage> {
  int _tabIndex = 0;

  static const _placeholderTabs = [
    (
      title: 'Search Tutors',
      message: 'Tutor discovery with filters is on the way.'
    ),
    (
      title: 'My Bookings',
      message: 'Your booked classes will show up here.'
    ),
    (
      title: 'Study Materials',
      message: 'Purchased notes and materials will live here.'
    ),
    (
      title: 'Profile',
      message: 'Manage your account, preferences and payments.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _tabIndex == 0
            ? const _StudentHomeTab()
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
            icon: Icon(AppIcons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.bookingsOutlined),
            selectedIcon: Icon(AppIcons.bookings),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.materialsOutlined),
            selectedIcon: Icon(AppIcons.materials),
            label: 'Materials',
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

class _StudentHomeTab extends ConsumerWidget {
  const _StudentHomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider.select((s) => s.user));
    final firstName = user?.firstName ?? 'Student';

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
                InitialsAvatar(name: user?.fullName ?? 'Student', size: 42),
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
                StudentWelcomeCard(firstName: firstName),
                AppSpacing.gapXl,
                const DashboardSearchBar(),
                AppSpacing.gapXxl,
                const SectionHeader(title: 'Categories', actionLabel: 'See All'),
                AppSpacing.gapMd,
                GridView.count(
                  crossAxisCount: context.gridColumns(),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.05,
                  children: [
                    for (final category in StudentDummyData.categories)
                      CategoryCard(category: category),
                  ],
                ),
                AppSpacing.gapXxl,
                const SectionHeader(
                  title: 'Featured Teachers',
                  actionLabel: 'See All',
                ),
                AppSpacing.gapMd,
                SizedBox(
                  height: 190,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: StudentDummyData.featuredTeachers.length,
                    separatorBuilder: (_, _) => AppSpacing.hGapMd,
                    itemBuilder: (context, index) => FeaturedTeacherCard(
                      tutor: StudentDummyData.featuredTeachers[index],
                    ),
                  ),
                ),
                AppSpacing.gapXxl,
                const SectionHeader(title: 'Recent Tutors'),
                AppSpacing.gapMd,
                for (final tutor in StudentDummyData.recentTutors) ...[
                  RecentTutorTile(tutor: tutor),
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
