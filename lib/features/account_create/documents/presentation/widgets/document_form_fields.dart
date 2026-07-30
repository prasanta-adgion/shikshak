import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/core_providers.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../shared/presentation/widgets/file_upload_tile.dart';
import '../../../shared/presentation/widgets/wizard_field.dart';
import '../../../shared/presentation/widgets/wizard_info_note.dart';
import '../../../shared/presentation/widgets/wizard_select_field.dart';
import '../../domain/entities/teacher_document.dart';
import '../controller/document_form_controller.dart';

/// The document form, shared by the step and the edit sheet.
class DocumentFormFields extends StatelessWidget {
  const DocumentFormFields({super.key, required this.controller});

  final DocumentFormController controller;

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[
      WizardField(
        icon: Icons.category_outlined,
        label: 'Document Type',
        child: ListenableBuilder(
          listenable: Listenable.merge([
            controller.documentType,
            controller.showErrors,
          ]),
          builder: (context, _) => WizardSelectField<DocumentType>(
            hint: 'Select document type',
            sheetTitle: 'Document type',
            value: controller.documentType.value,
            options: DocumentType.values,
            labelOf: _documentTypeLabel,
            errorText:
                controller.showErrors.value &&
                    controller.documentType.value == null
                ? 'Document type is required'
                : null,
            onSelected: (type) => controller.documentType.value = type,
          ),
        ),
      ),

      WizardField(
        icon: Icons.upload_file_outlined,
        label: 'Upload Document',
        helpText: 'PDF, JPG, PNG or Word, up to 5 MB.',
        child: _DocumentFileField(controller: controller),
      ),

      const WizardInfoNote(
        icon: Icons.info_outline_rounded,
        message: 'Clear scans get approved faster.',
      ),
    ];

    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < fields.length; i++) ...[
            if (i > 0) AppSpacing.gapXl,
            fields[i],
          ],
        ],
      ),
    );
  }
}

class _DocumentFileField extends ConsumerWidget {
  const _DocumentFileField({required this.controller});

  final DocumentFormController controller;

  Future<void> _pick(WidgetRef ref) async {
    final picked = await ref.read(mediaPickerProvider).pickDocument();
    if (picked == null) return;

    controller.attach(picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        controller.documentType,
        controller.fileName,
        controller.fileUrl,
        controller.fileSizeBytes,
        controller.showErrors,
      ]),
      builder: (context, _) {
        // A stored row has a URL and no picked name, so the tile falls back to
        // the file the URL points at.
        final name =
            controller.fileName.value ?? _nameFromUrl(controller.fileUrl.value);

        return FileUploadTile(
          title: controller.documentType.value?.label ?? 'Document',
          hint: 'Choose a file',
          fileName: name,
          detail: _detailLine(controller),
          onUpload: () => _pick(ref),
          onRemove: controller.removeFile,
        );
      },
    );
  }
}

/// `application/pdf · 1.2 MB`, dropping whichever half is missing.
String? _detailLine(DocumentFormController controller) {
  final size = controller.fileSizeBytes.value;
  final parts = [
    if (controller.mimeType.value?.isNotEmpty ?? false)
      controller.mimeType.value!,
    if (size != null && size > 0) _readableSize(size),
  ];

  return parts.isEmpty ? null : parts.join(' · ');
}

String _readableSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

/// `https://host/path/resume.pdf` → `resume.pdf`.
String? _nameFromUrl(String? url) {
  if (url == null || url.isEmpty) return null;

  final path = Uri.tryParse(url)?.pathSegments;
  if (path == null || path.isEmpty) return url;

  return path.last.isEmpty ? url : path.last;
}

// Top-level so the closure passed into the field is stable across rebuilds.
String _documentTypeLabel(DocumentType type) => type.label;
