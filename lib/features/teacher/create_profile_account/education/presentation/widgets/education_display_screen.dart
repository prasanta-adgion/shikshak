import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/theme/app_icons.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../shared/presentation/widgets/saved_entry_card.dart';
import '../../data/model/education_response_model.dart';
import '../providers/education_providers.dart';
import 'education_edit_sheet.dart';

class SavedEducationList extends ConsumerWidget {
  const SavedEducationList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(educationListNotifierProvider);

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
      title: 'Education added',
      cards: [
        for (final item in state.items)
          SavedEducationCard(key: ValueKey(item.id), item: item),
      ],
    );
  }
}

/// One saved row. Edit opens it in [EducationEditSheet] rather than expanding
/// in place, so the list stays readable however many qualifications were filed.
class SavedEducationCard extends StatelessWidget {
  const SavedEducationCard({super.key, required this.item});

  final EducationItem item;

  @override
  Widget build(BuildContext context) {
    return SavedEntryCard(
      icon: AppIcons.qualification,
      title: _joined([item.degree, item.specialization]) ?? 'Untitled degree',
      subtitle:
          _joined([item.universityCollege, item.yearOfPassing?.toString()]) ??
          '',
      meta: _metaLine(item),
      trailing: TextButton.icon(
        onPressed: item.id == null
            ? null
            : () => EducationEditSheet.show(context, item),
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

/// `Grade A · Highest qualification`, dropping whichever half is missing.
String? _metaLine(EducationItem item) => _joined([
  if (item.marksOrGrade?.isNotEmpty ?? false) 'Grade ${item.marksOrGrade}',
  if (item.isHighestQualification ?? false) 'Highest qualification',
]);

String? _joined(List<String?> parts) {
  final kept = parts
      .where((part) => part != null && part.isNotEmpty)
      .cast<String>();

  return kept.isEmpty ? null : kept.join(' · ');
}
