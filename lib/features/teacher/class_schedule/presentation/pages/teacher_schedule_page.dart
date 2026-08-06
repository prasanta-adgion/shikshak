import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/route_paths.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_button.dart';
import 'class_slots_tab.dart';
import 'schedule_calendar_tab.dart';

/// The Schedule tab of the teacher dashboard, split in two.
///
/// **Calendar** answers "what am I teaching this week" from the dated
/// occurrences the server expands; **All Slots** answers "what have I set up"
/// from the recurrence rules themselves. They are separate endpoints and
/// separate notifiers, so each tab loads independently the first time it is
/// opened.
class TeacherSchedulePage extends StatelessWidget {
  const TeacherSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                // Expanded + ellipsis: the title must not push the action off
                // a narrow phone.
                Expanded(
                  child: Text(
                    'My Schedule',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                AppSpacing.hGapSm,
                AppButton(
                  label: 'Create Class',
                  icon: AppIcons.addClass,
                  expanded: false,
                  // Opens the form. Nothing is saved yet — the create endpoint
                  // is still to come.
                  onPressed: () => context.push(RoutePaths.createClassSlot),
                ),
              ],
            ),
          ),
          const TabBar(
            tabs: [
              Tab(text: 'Calendar'),
              Tab(text: 'All Slots'),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [ScheduleCalendarTab(), ClassSlotsTab()],
            ),
          ),
        ],
      ),
    );
  }
}
