import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/widgets/app_snackbar.dart';
import '../../../shared/domain/entities/profile_step.dart';
import '../../../shared/presentation/mixins/wizard_step_registration.dart';
import '../../../shared/presentation/providers/account_create_providers.dart';
import '../../../shared/presentation/widgets/file_upload_tile.dart';
import '../../../shared/presentation/widgets/wizard_field.dart';
import '../../../shared/presentation/widgets/wizard_info_note.dart';
import '../../../shared/presentation/widgets/wizard_select_field.dart';
import '../../../shared/presentation/widgets/wizard_step_layout.dart';
import '../../domain/entities/teacher_document.dart';

/// Step 5 — the document payload. `fileName`, `mimeType` and `fileSizeBytes`
/// are all derived from the picked file; only `documentType` is chosen.
class DocumentsStep extends ConsumerStatefulWidget {
  const DocumentsStep({super.key});

  @override
  ConsumerState<DocumentsStep> createState() => _DocumentsStepState();
}

class _DocumentsStepState extends ConsumerState<DocumentsStep>
    with WizardStepRegistration {
  final _showErrors = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _showErrors.dispose();
    super.dispose();
  }

  void _pickFile() {
    // TODO(picker): replace with file_picker — it reports name, MIME type and
    // size, which is exactly what the payload needs. fileUrl comes from the
    // upload response.
    final notifier = ref.read(accountCreateNotifierProvider.notifier);
    final current = ref.read(accountCreateNotifierProvider).draft.document;

    notifier.setDocument(
      current.copyWith(
        fileName: 'resume.pdf',
        mimeType: 'application/pdf',
        fileSizeBytes: 123456,
      ),
    );
    AppSnackbar.show(
      context,
      'File picking is not connected yet — attached a placeholder.',
    );
  }

  void _removeFile() {
    final notifier = ref.read(accountCreateNotifierProvider.notifier);
    final current = ref.read(accountCreateNotifierProvider).draft.document;
    notifier.setDocument(current.withoutFile());
  }

  @override
  void submitStep() {
    _showErrors.value = true;

    final document = ref.read(accountCreateNotifierProvider).draft.document;
    if (document.documentType == null) return;

    if (!document.hasFile) {
      AppSnackbar.showError(context, 'Attach a document to finish.');
      return;
    }

    // TODO(api): POST the document payload here, then leave the wizard for the
    // teacher dashboard once it succeeds.
    AppSnackbar.show(context, 'Profile submission is not connected yet.');
  }

  @override
  Widget build(BuildContext context) {
    return WizardStepLayout(
      step: ProfileStep.documents,
      children: [
        WizardField(
          icon: Icons.category_outlined,
          label: 'Document Type',
          child: Consumer(
            builder: (context, ref, _) {
              final type = ref.watch(
                accountCreateNotifierProvider.select(
                  (state) => state.draft.document.documentType,
                ),
              );

              return ValueListenableBuilder<bool>(
                valueListenable: _showErrors,
                builder: (context, showErrors, _) =>
                    WizardSelectField<DocumentType>(
                      hint: 'Select document type',
                      sheetTitle: 'Document type',
                      value: type,
                      options: DocumentType.values,
                      labelOf: _documentTypeLabel,
                      errorText: showErrors && type == null
                          ? 'Document type is required'
                          : null,
                      onSelected: (selected) => ref
                          .read(accountCreateNotifierProvider.notifier)
                          .setDocument(
                            ref
                                .read(accountCreateNotifierProvider)
                                .draft
                                .document
                                .copyWith(documentType: selected),
                          ),
                    ),
              );
            },
          ),
        ),

        WizardField(
          icon: Icons.upload_file_outlined,
          label: 'Upload Document',
          helpText: 'PDF, JPG or PNG up to 5 MB.',
          child: Consumer(
            builder: (context, ref, _) {
              final document = ref.watch(
                accountCreateNotifierProvider.select(
                  (state) => state.draft.document,
                ),
              );

              return FileUploadTile(
                title: document.documentType?.label ?? 'Document',
                hint: 'Upload your document',
                fileName: document.fileName,
                detail: document.hasFile
                    ? '${document.mimeType} · ${document.readableSize}'
                    : null,
                onUpload: _pickFile,
                onRemove: _removeFile,
              );
            },
          ),
        ),

        const WizardInfoNote(
          icon: Icons.info_outline_rounded,
          message: 'Clear scans get approved faster.',
        ),
      ],
    );
  }
}

// Top-level so the closure passed into the field is stable across rebuilds.
String _documentTypeLabel(DocumentType type) => type.label;
