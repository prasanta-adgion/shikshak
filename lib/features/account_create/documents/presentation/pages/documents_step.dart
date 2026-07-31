import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/widgets/app_snackbar.dart';
import '../../../shared/domain/entities/profile_step.dart';
import '../../../shared/presentation/mixins/wizard_step_registration.dart';
import '../../../shared/presentation/providers/account_create_providers.dart';
import '../../../shared/presentation/widgets/wizard_add_another_button.dart';
import '../../../shared/presentation/widgets/wizard_step_layout.dart';
import '../controller/document_form_controller.dart';
import '../providers/document_providers.dart';
import '../widgets/document_display_screen.dart';
import '../widgets/document_form_fields.dart';

/// Step 5 — the document payload: one POST per file.
///
/// The documents already filed are read back from the server after every
/// save, so the list above the form is the server's, not the draft's.
class DocumentsStep extends ConsumerStatefulWidget {
  const DocumentsStep({super.key});

  @override
  ConsumerState<DocumentsStep> createState() => _DocumentsStepState();
}

class _DocumentsStepState extends ConsumerState<DocumentsStep>
    with WizardStepRegistration {
  late final DocumentFormController _form;

  @override
  void initState() {
    super.initState();
    _form = DocumentFormController(
      initial: ref.read(accountCreateNotifierProvider).draft.document,
    );

    // Deferred: reading the list mutates provider state, which cannot happen
    // while the step is still being built into the tree.
    Future.microtask(_loadSaved);
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  void _loadSaved() {
    if (!mounted) return;
    ref.read(documentListNotifierProvider.notifier).load();
  }

  /// Validates the form and stages it on the draft, ready to be posted.
  bool _stageEntry() {
    FocusScope.of(context).unfocus();
    if (_form.isUploading.value) {
      AppSnackbar.show(context, 'Please wait for the document upload.');
      return false;
    }
    if (!_form.validate()) {
      // The type has its own inline error; a missing file has nowhere to show
      // one, so it is called out instead.
      if (_form.documentType.value != null && !_form.hasFile) {
        AppSnackbar.showError(context, 'Attach a file for this document.');
      }
      return false;
    }

    // The whole entity, file included: the section uploads whatever local
    // path it finds here before the body is built.
    ref
        .read(accountCreateNotifierProvider.notifier)
        .setDocument(_form.toDocument());
    return true;
  }

  /// Posts this document, reads the list back, and keeps the teacher here with
  /// an empty form.
  Future<void> _addAnother() async {
    if (!_stageEntry()) return;

    final saved = await ref
        .read(accountCreateNotifierProvider.notifier)
        .submitEntry();
    if (!saved || !mounted) return;

    _form.reset();
    _loadSaved();
  }

  @override
  void submitStep() {
    final notifier = ref.read(accountCreateNotifierProvider.notifier);
    final hasSaved = ref.read(documentListNotifierProvider).items.isNotEmpty;

    // A blank form after at least one document was filed is not an error —
    // there is nothing left to send, so finish.
    if (_form.isEmpty && hasSaved) {
      FocusScope.of(context).unfocus();
      notifier.submitCurrentStep();
      return;
    }

    if (!_stageEntry()) return;
    notifier.submitCurrentStep();
  }

  @override
  Widget build(BuildContext context) {
    // Loading and updating the saved list fail independently of the wizard's
    // own save, which the page reports.
    ref.listen(documentListNotifierProvider.select((state) => state.error), (
      previous,
      next,
    ) {
      if (next == null || next == previous) return;
      AppSnackbar.showError(context, next.message);
    });

    return WizardStepLayout(
      step: ProfileStep.documents,
      children: [
        const SavedDocumentList(),

        DocumentFormFields(controller: _form),

        WizardAddAnotherButton(
          label: 'Add Another Document',
          onPressed: _addAnother,
        ),
      ],
    );
  }
}
