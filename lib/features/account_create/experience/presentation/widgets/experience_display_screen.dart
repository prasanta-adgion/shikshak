import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/date_time_picker_func.dart';
import '../../../shared/presentation/widgets/saved_entry_card.dart';
import '../../data/model/experience_response_model.dart';
import '../providers/experience_providers.dart';
import 'experience_edit_sheet.dart';

/// The experience rows the server has, listed above the create form.
///
/// Everything here comes from the `GET` — the wizard's local draft is not
/// consulted, so a row only appears once it exists on the server.
class SavedExperienceList extends ConsumerWidget {
  const SavedExperienceList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(experienceListNotifierProvider);

    // Only the first load has nothing to show; later refreshes keep the list on
    // screen so it does not flicker after every save.
    if (state.isLoading && state.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Center(
          child: SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    }

    return SavedEntryList(
      title: 'Experience added',
      cards: [
        for (final item in state.items)
          SavedExperienceCard(key: ValueKey(item.id), item: item),
      ],
    );
  }
}

/// One saved row. Edit opens it in [ExperienceEditSheet] rather than expanding
/// in place, so the list stays readable however many positions were filed.
class SavedExperienceCard extends StatelessWidget {
  const SavedExperienceCard({super.key, required this.item});

  final ExperienceItem item;

  @override
  Widget build(BuildContext context) {
    return SavedEntryCard(
      icon: AppIcons.experience,
      title: item.currentJobTitle?.trim().isNotEmpty == true
          ? item.currentJobTitle!
          : 'Untitled position',
      subtitle: item.currentInstitution ?? '',
      meta: _metaLine(item),
      trailing: TextButton.icon(
        onPressed: item.id == null
            ? null
            : () => ExperienceEditSheet.show(context, item),
        icon: const Icon(Icons.edit_outlined, size: 16),
        label: const Text('Edit'),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

/// `3-5 years · Jul 2026 – Present`, dropping whichever half is missing.
String? _metaLine(ExperienceItem item) {
  final parts = <String>[
    if (item.totalTeachingExperience?.isNotEmpty ?? false)
      item.totalTeachingExperience!,
    ?_period(item),
  ];

  return parts.isEmpty ? null : parts.join(' · ');
}

String? _period(ExperienceItem item) {
  final start = item.startDateTime;
  if (start == null) return null;

  final end = item.endDateTime;
  final until = (item.isCurrent ?? false) || end == null
      ? 'Present'
      : DateTimeUtils.monthYear(end);

  return '${DateTimeUtils.monthYear(start)} – $until';
}
