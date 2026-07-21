import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/adaptive_navigation_scaffold.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/initials_avatar.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/logout_button.dart';
import '../models/tutor_info.dart';
import '../widgets/category_card.dart';
import '../widgets/dashboard_search_bar.dart';
import '../widgets/featured_teacher_card.dart';
import '../widgets/recent_tutor_tile.dart';
import '../widgets/student_welcome_card.dart';

class StudentDashboardPage extends ConsumerStatefulWidget {
  const StudentDashboardPage({super.key});

  @override
  ConsumerState<StudentDashboardPage> createState() =>
      _StudentDashboardPageState();
}

class _StudentDashboardPageState extends ConsumerState<StudentDashboardPage> {
  int _tabIndex = 0;

  static const _destinations = [
    AdaptiveNavigationDestination(
      icon: AppIcons.homeOutlined,
      selectedIcon: AppIcons.home,
      label: 'Home',
    ),
    AdaptiveNavigationDestination(icon: AppIcons.search, label: 'Search'),
    AdaptiveNavigationDestination(
      icon: AppIcons.bookingsOutlined,
      selectedIcon: AppIcons.bookings,
      label: 'Bookings',
    ),
    AdaptiveNavigationDestination(
      icon: AppIcons.materialsOutlined,
      selectedIcon: AppIcons.materials,
      label: 'Materials',
    ),
    AdaptiveNavigationDestination(
      icon: AppIcons.profileOutlined,
      selectedIcon: AppIcons.profile,
      label: 'Profile',
    ),
  ];

  static const _placeholderTabs = [
    (
      title: 'Search Tutors',
      message: 'Tutor discovery with filters is on the way.',
    ),
    (title: 'My Bookings', message: 'Your booked classes will show up here.'),
    (
      title: 'Study Materials',
      message: 'Purchased notes and materials will live here.',
    ),
    (
      title: 'Profile',
      message: 'Manage your account, preferences and payments.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveNavigationScaffold(
      selectedIndex: _tabIndex,
      onDestinationSelected: (index) => setState(() => _tabIndex = index),
      destinations: _destinations,
      body: _tabIndex == 0
          ? const _StudentHomeTab()
          : EmptyState(
              title: _placeholderTabs[_tabIndex - 1].title,
              message: _placeholderTabs[_tabIndex - 1].message,
            ),
    );
  }
}

class _StudentHomeTab extends ConsumerWidget {
  const _StudentHomeTab();

  // Static placeholder content, shown until the discovery API provides
  // real categories and tutors.
  static const _categories = [
    SubjectCategory(
      name: 'Mathematics',
      icon: Icons.calculate_rounded,
      color: Color(0xFF6366F1),
    ),
    SubjectCategory(
      name: 'Science',
      icon: Icons.science_rounded,
      color: Color(0xFF14B8A6),
    ),
    SubjectCategory(
      name: 'English',
      icon: Icons.translate_rounded,
      color: Color(0xFFF59E0B),
    ),
    SubjectCategory(
      name: 'Coding',
      icon: Icons.code_rounded,
      color: Color(0xFF8B5CF6),
    ),
    SubjectCategory(
      name: 'Music',
      icon: Icons.music_note_rounded,
      color: Color(0xFFEC4899),
    ),
    SubjectCategory(
      name: 'Arts',
      icon: Icons.palette_rounded,
      color: Color(0xFFF97316),
    ),
  ];

  static const _featuredTeachers = [
    TutorInfo(
      name: 'Teacher Name',
      subject: 'Mathematics',
      qualification: 'Qualification',
      rating: 4.9,
      reviews: 128,
      experience: '8 yrs',
      feePerHour: 600,
    ),
    TutorInfo(
      name: 'Teacher Name',
      subject: 'Physics',
      qualification: 'Qualification',
      rating: 4.8,
      reviews: 96,
      experience: '6 yrs',
      feePerHour: 750,
    ),
    TutorInfo(
      name: 'Teacher Name',
      subject: 'English',
      qualification: 'Qualification',
      rating: 4.7,
      reviews: 84,
      experience: '5 yrs',
      feePerHour: 450,
    ),
  ];

  static const _recentTutors = [
    TutorInfo(
      name: 'Teacher Name',
      subject: 'Chemistry',
      qualification: 'Qualification',
      rating: 4.6,
      reviews: 58,
      experience: '4 yrs',
      feePerHour: 500,
    ),
    TutorInfo(
      name: 'Teacher Name',
      subject: 'Biology',
      qualification: 'Qualification',
      rating: 4.8,
      reviews: 72,
      experience: '3 yrs',
      feePerHour: 550,
    ),
  ];

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
            padding: context.responsivePagePadding,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                AppSpacing.gapSm,
                StudentWelcomeCard(firstName: firstName),
                AppSpacing.gapXl,
                const DashboardSearchBar(),
                AppSpacing.gapXxl,
                const SectionHeader(
                  title: 'Categories',
                  actionLabel: 'See All',
                ),
                AppSpacing.gapMd,
                GridView.count(
                  crossAxisCount: context.gridColumns(),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  // Cards get narrower as columns grow (3→4→6), so give them a
                  // little more height to keep icon + label balanced.
                  childAspectRatio: context.isDesktop
                      ? 0.95
                      : context.isTabletOrLarger
                      ? 1.1
                      : 1.05,
                  children: [
                    for (final category in _categories)
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
                  height: context.isTabletDevice ? 210 : 190,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _featuredTeachers.length,
                    separatorBuilder: (_, _) => AppSpacing.hGapMd,
                    itemBuilder: (context, index) =>
                        FeaturedTeacherCard(tutor: _featuredTeachers[index]),
                  ),
                ),
                AppSpacing.gapXxl,
                const SectionHeader(title: 'Recent Tutors'),
                AppSpacing.gapMd,
                for (final tutor in _recentTutors) ...[
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
