import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../create_profile_account/shared/domain/entities/profile_step.dart';

/// The profile's sections, in the order they are filled in.
///
/// Each one carries the wizard step it edits, so the page wires every tab's
/// Edit button the same way instead of naming a step per section.
enum ProfileTab {
  basicInfo('Basic Info', AppIcons.identifier, ProfileStep.basicInfo),
  aboutYou('About You', AppIcons.about, ProfileStep.aboutYou),
  experience('Experience', AppIcons.experience, ProfileStep.experience),
  education('Education', AppIcons.education, ProfileStep.education),
  documents('Documents', AppIcons.documents, ProfileStep.documents);

  const ProfileTab(this.label, this.icon, this.step);

  final String label;
  final IconData icon;
  final ProfileStep step;
}

/// Picks which profile section is on screen.
///
/// Stateless on purpose: the selection belongs to the page, which holds it in
/// a `ValueNotifier` so choosing a tab repaints the strip and the one section
/// below it rather than the whole profile.
class ProfileTabBar extends StatelessWidget {
  const ProfileTabBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ProfileTab selected;
  final ValueChanged<ProfileTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          // Expanded, so five tabs share the width evenly however narrow the
          // phone is, instead of scrolling sideways.
          for (final tab in ProfileTab.values)
            Expanded(
              child: _TabItem(
                tab: tab,
                isSelected: tab == selected,
                onTap: () => onSelected(tab),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  final ProfileTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tint = isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Semantics(
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSpacing.gapMd,
            Icon(tab.icon, size: 22, color: tint),
            AppSpacing.gapXs,
            Text(
              tab.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(color: tint),
            ),
            AppSpacing.gapSm,
            // Drawn even when unselected, so switching tabs does not shift the
            // strip's height by the thickness of the underline.
            Container(
              height: 2.5,
              color: isSelected ? colorScheme.primary : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
