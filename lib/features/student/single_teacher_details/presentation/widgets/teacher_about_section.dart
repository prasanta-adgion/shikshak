import 'package:flutter/material.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_card.dart';
import '../../domain/entities/teacher_details.dart';

/// The teacher in their own words. Collapses to nothing when they wrote
/// nothing, rather than leaving an empty card behind.
class TeacherAboutSection extends StatelessWidget {
  const TeacherAboutSection({super.key, required this.teacher});

  final TeacherDetails teacher;

  @override
  Widget build(BuildContext context) {
    final blocks = <({String label, String text})>[
      if (teacher.shortBio case final bio?) (label: 'About', text: bio),
      if (teacher.teachingApproach case final approach?)
        (label: 'Teaching approach', text: approach),
      if (teacher.whatMakesYouUnique case final unique?)
        (label: 'What makes them different', text: unique),
    ];

    if (blocks.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, block) in blocks.indexed) ...[
            if (index > 0) AppSpacing.gapLg,
            Text(
              block.label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            AppSpacing.gapXs,
            Text(
              block.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
