import 'package:flutter/material.dart';

import '../../../../../core/theme/app_spacing.dart';

/// One cell of a [ProfileStatStrip].
class ProfileStat {
  const ProfileStat({required this.label, required this.value, this.color});

  final String label;
  final String value;

  /// Tints the value only — used to carry the verification state.
  final Color? color;
}

/// The three at-a-glance facts under the identity block, split by hairlines.
///
/// Every cell is [Expanded], so the strip divides whatever width it is given
/// evenly instead of overflowing a small phone.
class ProfileStatStrip extends StatelessWidget {
  const ProfileStatStrip({super.key, required this.stats});

  final List<ProfileStat> stats;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < stats.length; index++) ...[
            if (index > 0)
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: colorScheme.outlineVariant,
              ),
            Expanded(child: _Cell(stat: stats[index])),
          ],
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.stat});

  final ProfileStat stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            stat.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(color: stat.color),
          ),
          AppSpacing.gapXs,
          Text(
            stat.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
