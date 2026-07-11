import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';

/// Weekly availability overview with toggleable day chips (local UI state
/// only — persistence comes with the availability feature).
class AvailabilityCard extends StatefulWidget {
  const AvailabilityCard({super.key});

  @override
  State<AvailabilityCard> createState() => _AvailabilityCardState();
}

class _AvailabilityCardState extends State<AvailabilityCard> {
  // Static initial selection, shown until the availability API exists.
  final Map<String, bool> _days = {
    'Mon': true,
    'Tue': true,
    'Wed': false,
    'Thu': true,
    'Fri': true,
    'Sat': true,
    'Sun': false,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeDays = _days.values.where((v) => v).length;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.availability,
                color: theme.colorScheme.primary,
                size: 22,
              ),
              AppSpacing.hGapSm,
              Text('Availability', style: theme.textTheme.titleMedium),
              const Spacer(),
              Text(
                '$activeDays days/week',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          AppSpacing.gapLg,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final day in _days.keys)
                FilterChip(
                  label: Text(day),
                  selected: _days[day]!,
                  onSelected: (selected) =>
                      setState(() => _days[day] = selected),
                ),
            ],
          ),
          AppSpacing.gapLg,
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('Manage time slots'),
            ),
          ),
        ],
      ),
    );
  }
}
