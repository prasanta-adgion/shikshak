import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../domain/entities/profile_step.dart';

class StepTimeline extends StatelessWidget {
  final ProfileStep current;
  final ValueChanged<ProfileStep>? onStepTapped;

  static const double _railHeight = 68;
  static const double _dotSize = 26;

  const StepTimeline({super.key, required this.current, this.onStepTapped});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      // A horizontal FixedTimeline needs a bounded cross axis.
      height: _railHeight,
      child: LayoutBuilder(
        builder: (context, constraints) => FixedTimeline.tileBuilder(
          theme: TimelineThemeData(
            direction: Axis.horizontal,
            connectorTheme: ConnectorThemeData(
              thickness: 2,
              color: colorScheme.outlineVariant,
            ),
            indicatorTheme: const IndicatorThemeData(size: _dotSize),
          ),
          builder: TimelineTileBuilder.connected(
            connectionDirection: ConnectionDirection.before,
            itemCount: ProfileStep.count,
            // Extent comes from the rail's own width, not the window, so the
            // dots stay centred inside the page gutters.
            itemExtentBuilder: (_, _) =>
                constraints.maxWidth / ProfileStep.count,
            indicatorBuilder: _buildIndicator,
            connectorBuilder: (context, index, _) => SolidLineConnector(
              // Connector `index` sits before step `index`, so it is complete
              // once that step has been reached.
              color: index <= current.index
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
            contentsBuilder: (context, index) {
              final step = ProfileStep.values[index];
              final isPast = index <= current.index;

              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  step.shortLabel,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isPast
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(BuildContext context, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final step = ProfileStep.values[index];

    final isDone = index < current.index;
    final isCurrent = index == current.index;

    // DotIndicator drops its child straight into a fixed-size Container with
    // no alignment, so the glyph lands top-left. Center() is what actually
    // centres it — textAlign only ever fixed the horizontal axis.
    final Widget indicator = isDone || isCurrent
        ? DotIndicator(
            size: _dotSize,
            color: colorScheme.primary,
            child: Center(
              child: isDone
                  ? Icon(
                      Icons.check_rounded,
                      size: 15,
                      color: colorScheme.onPrimary,
                    )
                  : Text(
                      '${step.number}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        height: 1,
                        color: colorScheme.onPrimary,
                      ),
                    ),
            ),
          )
        : OutlinedDotIndicator(
            size: _dotSize,
            borderWidth: 2,
            color: colorScheme.outlineVariant,
            backgroundColor: colorScheme.surface,
            child: Center(
              child: Text(
                '${step.number}',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  height: 1,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );

    final canTap = isDone && onStepTapped != null;

    return Semantics(
      label: 'Step ${step.number}, ${step.shortLabel}',
      selected: isCurrent,
      button: canTap,
      child: GestureDetector(
        onTap: canTap ? () => onStepTapped!(step) : null,
        child: indicator,
      ),
    );
  }
}
