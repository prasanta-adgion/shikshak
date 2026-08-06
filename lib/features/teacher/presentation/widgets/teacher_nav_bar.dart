import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../shared/widgets/adaptive_navigation_scaffold.dart';

enum TeacherTab {
  home(icon: AppIcons.homeOutlined, activeIcon: AppIcons.home, label: 'Home'),
  schedule(
    icon: AppIcons.scheduleOutlined,
    activeIcon: AppIcons.schedule,
    label: 'Schedule',
  ),
  students(
    icon: AppIcons.studentsOutlined,
    activeIcon: AppIcons.students,
    label: 'Students',
  ),
  earnings(
    icon: AppIcons.earningsOutlined,
    activeIcon: AppIcons.earnings,
    label: 'Earnings',
  ),
  profile(
    icon: AppIcons.profileOutlined,
    activeIcon: AppIcons.profile,
    label: 'Profile',
  );

  const TeacherTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;

  AdaptiveNavigationDestination get destination =>
      AdaptiveNavigationDestination(
        icon: icon,
        selectedIcon: activeIcon,
        label: label,
      );

  /// Built once, in declaration order — the bar rebuilds on every tab change.
  static final List<AdaptiveNavigationDestination> destinations = [
    for (final tab in values) tab.destination,
  ];
}

class TeacherNavBar extends StatefulWidget {
  const TeacherNavBar({
    super.key,
    required this.tabBuilder,
    this.initialTab = TeacherTab.home,
  });

  /// Builds the body for whichever tab is selected.
  final Widget Function(BuildContext context, TeacherTab tab) tabBuilder;

  final TeacherTab initialTab;

  @override
  State<TeacherNavBar> createState() => _TeacherNavBarState();
}

class _TeacherNavBarState extends State<TeacherNavBar> {
  late final ValueNotifier<TeacherTab> _tab = ValueNotifier(widget.initialTab);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TeacherTab>(
      valueListenable: _tab,
      builder: (context, tab, _) => AdaptiveNavigationScaffold(
        selectedIndex: tab.index,
        onDestinationSelected: (index) => _tab.value = TeacherTab.values[index],
        destinations: TeacherTab.destinations,
        body: widget.tabBuilder(context, tab),
      ),
    );
  }
}
