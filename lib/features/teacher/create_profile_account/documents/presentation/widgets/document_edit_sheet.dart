import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../shared/widgets/app_loading_button.dart';
import '../../../../../../shared/widgets/app_snackbar.dart';
import '../../data/model/document_response_model.dart';
import '../../domain/params/update_document_params.dart';
import '../controller/document_form_controller.dart';
import '../providers/document_providers.dart';
import 'document_form_fields.dart';

class DocumentEditSheet extends ConsumerStatefulWidget {
  const DocumentEditSheet._({required this.item});

  final DocumentItem item;

  static Future<void> show(BuildContext context, DocumentItem item) {
    return showModalBottomSheet<void>(
      context: context,
      // The form has to clear the keyboard and its own file tile.
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (context) => DocumentEditSheet._(item: item),
    );
  }

  @override
  ConsumerState<DocumentEditSheet> createState() => _DocumentEditSheetState();
}

class _DocumentEditSheetState extends ConsumerState<DocumentEditSheet> {
  late final DocumentFormController _form;

  @override
  void initState() {
    super.initState();
    _form = DocumentFormController(initial: widget.item.toDocument());
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    final id = widget.item.id;
    if (id == null) return;

    FocusScope.of(context).unfocus();
    if (_form.isUploading.value) {
      AppSnackbar.show(context, 'Please wait for the document upload.');
      return;
    }
    if (!_form.validate()) return;

    final updated = await ref
        .read(documentListNotifierProvider.notifier)
        .update(UpdateDocumentParams(id: id, document: _form.toDocument()));

    // A failure keeps the sheet open with the edits intact — the step reports
    // the reason.
    if (!updated || !mounted) return;

    AppSnackbar.showSuccess(context, 'Document updated.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isUpdating = ref.watch(
      documentListNotifierProvider.select((state) => state.isUpdating),
    );

    return ConstrainedBox(
      // Capped so the sheet never swallows the screen; the fields scroll
      // inside it instead.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      child: Padding(
        // Lifts the sheet clear of the keyboard while a field has focus.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                0,
                AppSpacing.sm,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Edit Document',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: isUpdating
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: DocumentFormFields(controller: _form),
              ),
            ),

            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: AppLoadingButton(
                  label: 'Update Document',
                  isLoading: isUpdating,
                  onPressed: _update,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
