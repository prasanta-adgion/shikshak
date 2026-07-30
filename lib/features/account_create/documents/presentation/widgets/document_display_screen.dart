import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../shared/presentation/widgets/saved_entry_card.dart';
import '../../data/model/document_response_model.dart';
import '../../domain/entities/teacher_document.dart';
import '../providers/document_providers.dart';
import 'document_edit_sheet.dart';

class SavedDocumentList extends ConsumerWidget {
  const SavedDocumentList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(documentListNotifierProvider);

    // Only the first load has nothing to show; later refreshes keep the list
    // on screen so it does not flicker after every save.
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
      title: 'Documents added',
      cards: [
        for (final item in state.items)
          SavedDocumentCard(key: ValueKey(item.id), item: item),
      ],
    );
  }
}

/// One saved row. Edit opens it in [DocumentEditSheet] rather than expanding
/// in place, so the list stays readable however many documents were filed.
class SavedDocumentCard extends StatelessWidget {
  const SavedDocumentCard({super.key, required this.item});

  final DocumentItem item;

  @override
  Widget build(BuildContext context) {
    return SavedEntryCard(
      icon: Icons.description_outlined,
      title: DocumentTypeX.tryParse(item.documentType)?.label ?? 'Document',
      subtitle: item.fileName ?? '',
      meta: _metaLine(item),
      trailing: TextButton.icon(
        onPressed: item.id == null
            ? null
            : () => DocumentEditSheet.show(context, item),
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

/// `application/pdf · 1.2 MB`, dropping whichever half is missing.
String? _metaLine(DocumentItem item) {
  final size = item.fileSizeBytes;
  final parts = [
    if (item.mimeType?.isNotEmpty ?? false) item.mimeType!,
    if (size != null && size > 0) _readableSize(size),
  ];

  return parts.isEmpty ? null : parts.join(' · ');
}

String _readableSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
