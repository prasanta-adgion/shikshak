import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/widgets/app_snackbar.dart';
import '../../../shared/domain/entities/profile_step.dart';
import '../../../shared/presentation/mixins/wizard_step_registration.dart';
import '../../../shared/presentation/providers/account_create_providers.dart';
import '../../../shared/presentation/widgets/wizard_add_another_button.dart';
import '../../../shared/presentation/widgets/wizard_step_layout.dart';
import '../controller/experience_form_controller.dart';
import '../providers/experience_providers.dart';
import '../widgets/experience_display_screen.dart';
import '../widgets/experience_form_fields.dart';

class ExperienceStep extends ConsumerStatefulWidget {
  const ExperienceStep({super.key});

  @override
  ConsumerState<ExperienceStep> createState() => _ExperienceStepState();
}

class _ExperienceStepState extends ConsumerState<ExperienceStep>
    with WizardStepRegistration {
  late final ExperienceFormController _form;

  @override
  void initState() {
    super.initState();
    _form = ExperienceFormController(
      initial: ref.read(accountCreateNotifierProvider).draft.experience,
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
    ref.read(experienceListNotifierProvider.notifier).load();
  }

  /// Validates the form and stages it on the draft, ready to be posted.
  bool _stageEntry() {
    FocusScope.of(context).unfocus();
    if (!_form.validate()) return false;

    ref
        .read(accountCreateNotifierProvider.notifier)
        .setExperience(_form.toExperienceInfo());
    return true;
  }

  /// Posts this position, reads the list back, and keeps the teacher here with
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
    final hasSaved = ref.read(experienceListNotifierProvider).items.isNotEmpty;

    // A blank form after at least one position was filed is not an error —
    // there is simply nothing left to send, so move on.
    if (_form.isEmpty && hasSaved) {
      FocusScope.of(context).unfocus();
      notifier.submitCurrentStep();
      return;
    }

    if (!_stageEntry()) return;
    // teachingSubjects and classesTaught come off the draft, not this screen.
    notifier.submitCurrentStep();
  }

  @override
  Widget build(BuildContext context) {
    // Loading and updating the saved list fail independently of the wizard's
    // own save, which the page reports.
    ref.listen(experienceListNotifierProvider.select((state) => state.error), (
      previous,
      next,
    ) {
      if (next == null || next == previous) return;
      AppSnackbar.showError(context, next.message);
    });

    return WizardStepLayout(
      step: ProfileStep.experience,
      children: [
        const SavedExperienceList(),

        ExperienceFormFields(controller: _form),

        WizardAddAnotherButton(
          label: 'Add Another Experience',
          onPressed: _addAnother,
        ),
      ],
    );
  }
}
