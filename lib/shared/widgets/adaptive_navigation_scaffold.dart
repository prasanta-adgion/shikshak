import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';

class AdaptiveNavigationDestination {
  const AdaptiveNavigationDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  NavigationDestination toBottomDestination() => NavigationDestination(
    icon: Icon(icon),
    selectedIcon: Icon(selectedIcon ?? icon),
    label: label,
  );

  NavigationRailDestination toRailDestination() => NavigationRailDestination(
    icon: Icon(icon),
    selectedIcon: Icon(selectedIcon ?? icon),
    label: Text(label),
  );
}

/// Phone uses bottom navigation; wider windows use a persistent side rail.
class AdaptiveNavigationScaffold extends StatelessWidget {
  const AdaptiveNavigationScaffold({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AdaptiveNavigationDestination> destinations;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    // Classify by device, not available width, so a phone in landscape keeps
    // the bottom bar instead of flipping to a side rail.
    final useRail = context.isTabletDevice;

    return Scaffold(
      body: useRail
          ? SafeArea(
              child: Row(
                children: [
                  NavigationRail(
                    key: const Key('tablet-navigation-rail'),
                    selectedIndex: selectedIndex,
                    onDestinationSelected: onDestinationSelected,
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      for (final destination in destinations)
                        destination.toRailDestination(),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: body),
                ],
              ),
            )
          : SafeArea(child: body),
      bottomNavigationBar: useRail
          ? null
          : NavigationBar(
              key: const Key('phone-bottom-navigation'),
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: [
                for (final destination in destinations)
                  destination.toBottomDestination(),
              ],
            ),
    );
  }
}
