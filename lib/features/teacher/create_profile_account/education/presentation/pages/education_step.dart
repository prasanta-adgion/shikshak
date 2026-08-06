import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../shared/widgets/app_snackbar.dart';
import '../../../shared/domain/entities/profile_step.dart';
import '../../../shared/presentation/mixins/wizard_step_registration.dart';
import '../../../shared/presentation/providers/account_create_providers.dart';
import '../../../shared/presentation/widgets/wizard_add_another_button.dart';
import '../../../shared/presentation/widgets/wizard_step_layout.dart';
import '../controller/education_form_controller.dart';
import '../providers/education_providers.dart';
import '../widgets/education_display_screen.dart';
import '../widgets/education_form_fields.dart';

/// Step 4 — the education payload: one qualification per POST.
///
/// The qualifications already filed are read back from the server after every
/// save, so the list above the form is the server's, not the draft's.
class EducationStep extends ConsumerStatefulWidget {
  const EducationStep({super.key});

  @override
  ConsumerState<EducationStep> createState() => _EducationStepState();
}

class _EducationStepState extends ConsumerState<EducationStep>
    with WizardStepRegistration {
  late final EducationFormController _form;

  @override
  void initState() {
    super.initState();
    _form = EducationFormController(
      initial: ref.read(accountCreateNotifierProvider).draft.education,
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
    ref.read(educationListNotifierProvider.notifier).load();
  }

  /// Validates the form and stages it on the draft, ready to be posted.
  bool _stageEntry() {
    FocusScope.of(context).unfocus();
    if (_form.isUploading.value) {
      AppSnackbar.show(context, 'Please wait for the certificate upload.');
      return false;
    }
    if (!_form.validate()) return false;

    // The certificate is already uploaded by this point — the entity carries
    // its URL, which is what the payload sends.
    ref
        .read(accountCreateNotifierProvider.notifier)
        .setEducation(_form.toEducation());
    return true;
  }

  /// Posts this qualification, reads the list back, and keeps the teacher here
  /// with an empty form.
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
    final hasSaved = ref.read(educationListNotifierProvider).items.isNotEmpty;

    // A blank form after at least one qualification was filed is not an
    // error — there is nothing left to send, so move on.
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
    ref.listen(educationListNotifierProvider.select((state) => state.error), (
      previous,
      next,
    ) {
      if (next == null || next == previous) return;
      AppSnackbar.showError(context, next.message);
    });

    return WizardStepLayout(
      step: ProfileStep.education,
      children: [
        const SavedEducationList(),

        EducationFormFields(controller: _form),

        WizardAddAnotherButton(
          label: 'Add Another Education',
          onPressed: _addAnother,
        ),
      ],
    );
  }
}
