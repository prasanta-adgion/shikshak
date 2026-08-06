import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/utils/validators.dart';
import '../../../../../../shared/widgets/app_snackbar.dart';
import '../../../../../../shared/widgets/app_text_field.dart';
import '../../../shared/domain/entities/profile_step.dart';
import '../../../shared/domain/entities/reference_data.dart';
import '../../../shared/presentation/mixins/wizard_step_registration.dart';
import '../../../shared/presentation/providers/account_create_providers.dart';
import '../../../shared/presentation/widgets/subject_select_tile.dart';
import '../../../shared/presentation/widgets/wizard_field.dart';
import '../../../shared/presentation/widgets/wizard_multi_select_field.dart';
import '../../../shared/presentation/widgets/wizard_step_layout.dart';
import '../../../shared/presentation/widgets/wizard_step_loading.dart';
import '../../domain/entities/about_you.dart';
import '../providers/about_you_providers.dart';

/// Step 2 — the about-you payload. Subjects and classes are captured here
/// only; the experience payload reuses them.
class AboutYouStep extends ConsumerStatefulWidget {
  const AboutYouStep({super.key});

  @override
  ConsumerState<AboutYouStep> createState() => _AboutYouStepState();
}

class _AboutYouStepState extends ConsumerState<AboutYouStep>
    with WizardStepRegistration {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _shortBioController;
  late final TextEditingController _teachingApproachController;
  late final TextEditingController _uniqueController;

  final _subjects = ValueNotifier<List<String>>(const []);
  final _classes = ValueNotifier<List<String>>(const []);
  final _languages = ValueNotifier<List<String>>(const []);
  final _showErrors = ValueNotifier<bool>(false);

  static const int _proseLimit = 500;

  @override
  void initState() {
    super.initState();
    final about = ref.read(accountCreateNotifierProvider).draft.aboutYou;
    _shortBioController = TextEditingController(text: about.shortBio);
    _teachingApproachController = TextEditingController(
      text: about.teachingApproach,
    );
    _uniqueController = TextEditingController(text: about.whatMakesYouUnique);
    _subjects.value = about.subjectsTaught;
    _classes.value = about.classesTaught;
    _languages.value = about.languagesKnown;

    // Deferred: loading writes to provider state, which cannot happen while
    // the step is still being built into the tree.
    Future.microtask(_loadSaved);
  }

  /// Reads back what the teacher has already filed and puts it in the form.
  Future<void> _loadSaved() async {
    if (!mounted) return;
    await ref.read(aboutYouNotifierProvider.notifier).load();
    if (!mounted) return;

    final saved = ref.read(aboutYouNotifierProvider).about;
    if (saved == null) return;

    // The draft is seeded too, so the next save updates this section instead
    // of creating a second one.
    ref.read(accountCreateNotifierProvider.notifier).hydrateAboutYou(saved);
    _fillForm(saved);
  }

  void _fillForm(AboutYou about) {
    _shortBioController.text = about.shortBio;
    _teachingApproachController.text = about.teachingApproach;
    _uniqueController.text = about.whatMakesYouUnique;
    _subjects.value = about.subjectsTaught;
    _classes.value = about.classesTaught;
    _languages.value = about.languagesKnown;
  }

  @override
  void dispose() {
    _shortBioController.dispose();
    _teachingApproachController.dispose();
    _uniqueController.dispose();
    _subjects.dispose();
    _classes.dispose();
    _languages.dispose();
    _showErrors.dispose();
    super.dispose();
  }

  void _toggleSubject(String subject) {
    final updated = [..._subjects.value];
    if (!updated.remove(subject)) updated.add(subject);
    _subjects.value = updated;
  }

  @override
  void submitStep() {
    FocusScope.of(context).unfocus();
    if (ref.read(aboutYouNotifierProvider).isLoading) return;
    _showErrors.value = true;

    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    if (_subjects.value.isEmpty) {
      AppSnackbar.showError(context, 'Select at least one subject you teach.');
      return;
    }
    if (_classes.value.isEmpty || _languages.value.isEmpty) return;

    final notifier = ref.read(accountCreateNotifierProvider.notifier);
    final current = ref.read(accountCreateNotifierProvider).draft.aboutYou;

    notifier.setAboutYou(
      current.copyWith(
        shortBio: _shortBioController.text.trim(),
        teachingApproach: _teachingApproachController.text.trim(),
        whatMakesYouUnique: _uniqueController.text.trim(),
        subjectsTaught: _subjects.value,
        classesTaught: _classes.value,
        languagesKnown: _languages.value,
      ),
    );

    // Editing PATCHes this one section and pops; onboarding advances.
    if (ref.read(accountCreateNotifierProvider).isEditing) {
      notifier.submitEdit();
      return;
    }
    notifier.submitCurrentStep();
  }

  @override
  Widget build(BuildContext context) {
    // Reading the saved section fails independently of the wizard's own save,
    // which the page reports.
    ref.listen(aboutYouNotifierProvider.select((state) => state.error), (
      previous,
      next,
    ) {
      if (next == null || next == previous) return;
      AppSnackbar.showError(context, next.message);
    });

    final isLoading = ref.watch(
      aboutYouNotifierProvider.select((state) => state.isLoading),
    );

    if (isLoading) {
      return const WizardStepLayout(
        step: ProfileStep.aboutYou,
        children: [WizardStepLoading()],
      );
    }

    return Form(
      key: _formKey,
      child: WizardStepLayout(
        step: ProfileStep.aboutYou,
        children: [
          WizardField(
            icon: Icons.person_outline_rounded,
            label: 'Short Bio',
            helpText: 'One or two lines students see first on your profile.',
            child: AppTextField(
              controller: _shortBioController,
              hint: 'e.g. Experienced mathematics teacher',
              maxLines: 3,
              maxLength: _proseLimit,
              validator: _bioValidator,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),

          WizardField(
            icon: Icons.menu_book_outlined,
            label: 'Teaching Approach',
            helpText: 'How you run a lesson, in your own words.',
            child: AppTextField(
              controller: _teachingApproachController,
              hint: 'e.g. Conceptual learning with practice',
              maxLines: 3,
              maxLength: _proseLimit,
              validator: _approachValidator,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),

          WizardField(
            icon: Icons.star_outline_rounded,
            label: 'What Makes You Unique',
            helpText:
                'What a student gets from you that they would not '
                'get elsewhere.',
            child: AppTextField(
              controller: _uniqueController,
              hint: 'e.g. Focus on clarity and problem solving',
              maxLines: 3,
              maxLength: _proseLimit,
              validator: _uniqueValidator,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
            ),
          ),

          WizardField(
            icon: Icons.functions_rounded,
            label: 'Subjects Taught',
            child: ValueListenableBuilder<List<String>>(
              valueListenable: _subjects,
              builder: (context, selected, _) =>
                  _SubjectGrid(selected: selected, onToggle: _toggleSubject),
            ),
          ),

          WizardField(
            icon: Icons.class_outlined,
            label: 'Classes Taught',
            child: ListenableBuilder(
              listenable: Listenable.merge([_classes, _showErrors]),
              builder: (context, _) => WizardMultiSelectField(
                hint: 'Select the classes you teach',
                sheetTitle: 'Classes taught',
                options: ReferenceData.classes,
                selected: _classes.value,
                errorText: _showErrors.value && _classes.value.isEmpty
                    ? 'Select at least one class'
                    : null,
                onChanged: (values) => _classes.value = values,
              ),
            ),
          ),

          WizardField(
            icon: Icons.translate_rounded,
            label: 'Languages Known',
            child: ListenableBuilder(
              listenable: Listenable.merge([_languages, _showErrors]),
              builder: (context, _) => WizardMultiSelectField(
                hint: 'Select the languages you speak',
                sheetTitle: 'Languages known',
                options: ReferenceData.languages,
                selected: _languages.value,
                errorText: _showErrors.value && _languages.value.isEmpty
                    ? 'Select at least one language'
                    : null,
                onChanged: (values) => _languages.value = values,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rebuilds only when the selection changes — the tiles themselves are cheap,
/// but there are sixteen of them.
class _SubjectGrid extends StatelessWidget {
  const _SubjectGrid({required this.selected, required this.onToggle});

  final List<String> selected;
  final ValueChanged<String> onToggle;

  static const double _spacing = AppSpacing.md;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          selected.isEmpty
              ? 'You can select multiple subjects'
              : '${selected.length} selected',
          style: theme.textTheme.bodySmall?.copyWith(
            color: selected.isEmpty
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.primary,
          ),
        ),
        AppSpacing.gapMd,
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 420 ? 3 : 2;
            final tileWidth =
                (constraints.maxWidth - _spacing * (columns - 1)) / columns;

            return Wrap(
              spacing: _spacing,
              runSpacing: _spacing,
              children: [
                for (final subject in ReferenceData.subjects)
                  SizedBox(
                    width: tileWidth,
                    child: SubjectSelectTile(
                      subject: subject,
                      isSelected: selected.contains(subject),
                      onTap: () => onToggle(subject),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// Top-level so the closures passed into fields are stable across rebuilds.
String? _bioValidator(String? value) =>
    Validators.required(value, field: 'Short bio');

String? _approachValidator(String? value) =>
    Validators.required(value, field: 'Teaching approach');

String? _uniqueValidator(String? value) =>
    Validators.required(value, field: 'This field');
