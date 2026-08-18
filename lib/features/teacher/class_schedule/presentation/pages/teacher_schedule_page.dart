import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/route_paths.dart';
import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../providers/class_schedule_providers.dart';
import 'class_slots_tab.dart';
import 'schedule_calendar_tab.dart';

/// Header width at which the title and the Create Class button stop sharing a
/// line — a small phone in portrait, roughly.
const double _stackedHeaderWidth = 300;

/// The Schedule tab of the teacher dashboard, split in two.
///
/// **Calendar** answers "what am I teaching this week" from the dated
/// occurrences the server expands; **All Slots** answers "what have I set up"
/// from the recurrence rules themselves. They are separate endpoints and
/// separate notifiers, so each tab loads independently the first time it is
/// opened.
class TeacherSchedulePage extends ConsumerWidget {
  const TeacherSchedulePage({super.key});

  /// Opens the form and, if it comes back having created a slot, re-reads both
  /// tabs — the new recurrence belongs in the week and in the list.
  Future<void> _openCreateForm(BuildContext context, WidgetRef ref) async {
    final created = await context.push<bool>(RoutePaths.createClassSlot);
    if (created != true) return;

    ref.read(classScheduleNotifierProvider.notifier).refresh();
    ref.read(classSlotsNotifierProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: ResponsiveBuilder(
              builder: (context, _, constraints) {
                final title = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Schedule',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge,
                    ),
                    AppSpacing.gapXs,
                    Text(
                      'Stay organized and never miss a class',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );

                final isStacked = constraints.maxWidth < _stackedHeaderWidth;

                final action = AppButton(
                  label: 'Create Class',
                  icon: AppIcons.addClass,
                  expanded: isStacked,
                  onPressed: () => _openCreateForm(context, ref),
                );

                if (isStacked) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [title, AppSpacing.gapMd, action],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: title),
                    AppSpacing.hGapMd,
                    SizedBox(width: 170, height: 45, child: action),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: AppSpacing.pagePadding,
            child: TabBar(
              indicator: _ActiveTabIndicator(
                surface: colorScheme.surface,
                accent: colorScheme.primary,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              // The card behind the active tab is the separator; a divider
              // line under it would cut the shape in half.
              dividerHeight: 0,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              labelStyle: theme.textTheme.titleSmall,
              unselectedLabelStyle: theme.textTheme.titleSmall,
              splashBorderRadius: _ActiveTabIndicator.cardRadius,
              tabs: [
                _iconTab(AppIcons.schedule, 'Calendar'),
                _iconTab(AppIcons.allSlots, 'All Slots'),
              ],
            ),
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

/// A tab whose icon sits beside the label rather than above it — `Tab.icon`
/// stacks them vertically and doubles the bar's height.
///
/// The icon and text take their color from the [TabBar]'s label colors, which
/// reach here as the ambient `IconTheme` and `DefaultTextStyle`.
Tab _iconTab(IconData icon, String label) {
  return Tab(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        AppSpacing.hGapSm,
        Flexible(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    ),
  );
}

/// Indicator for the active tab: a raised card the width of the tab, with an
/// accent underline centred beneath the label.
///
/// Two shapes, so [BoxDecoration] cannot express it — a `borderRadius` there
/// asserts that the border is uniform on all four sides.
class _ActiveTabIndicator extends Decoration {
  static const BorderRadius cardRadius = BorderRadius.vertical(
    top: Radius.circular(AppRadius.sm),
  );

  /// Card behind the active tab; follows the surface, so it is white in light
  /// mode and dark in dark mode.
  final Color surface;

  /// Underline color.
  final Color accent;

  const _ActiveTabIndicator({required this.surface, required this.accent});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _ActiveTabPainter(this);
}

class _ActiveTabPainter extends BoxPainter {
  static const double _underlineHeight = 3;
  static const double _underlineInset = AppSpacing.xxl;

  final _ActiveTabIndicator decoration;

  _ActiveTabPainter(this.decoration);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final rect = offset & configuration.size!;

    canvas.drawRRect(
      _ActiveTabIndicator.cardRadius.toRRect(rect),
      Paint()..color = decoration.surface,
    );

    // Clamped so the underline keeps a visible width on a narrow phone, where
    // half the tab bar is barely wider than two insets.
    final inset = math.min(_underlineInset, rect.width / 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          rect.left + inset,
          rect.bottom - _underlineHeight,
          rect.right - inset,
          rect.bottom,
        ),
        const Radius.circular(_underlineHeight),
      ),
      Paint()..color = decoration.accent,
    );
  }
}
