import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../../shared/domain/entities/profile_step.dart';
import '../../../shared/presentation/mixins/wizard_step_registration.dart';
import '../../../shared/presentation/providers/account_create_providers.dart';
import '../../../shared/presentation/widgets/wizard_checkbox_tile.dart';
import '../../../shared/presentation/widgets/wizard_date_field.dart';
import '../../../shared/presentation/widgets/wizard_field.dart';
import '../../../shared/presentation/widgets/wizard_select_field.dart';
import '../../../shared/presentation/widgets/wizard_step_layout.dart';
import '../../domain/entities/experience_info.dart';

/// Step 3 — the experience payload.
///
/// `teachingSubjects` and `classesTaught` are shown read-only: About You
/// already captured them, and asking twice for the same answer is a good way
/// to collect two different ones.
class ExperienceStep extends ConsumerStatefulWidget {
  const ExperienceStep({super.key});

  @override
  ConsumerState<ExperienceStep> createState() => _ExperienceStepState();
}

class _ExperienceStepState extends ConsumerState<ExperienceStep>
    with WizardStepRegistration {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _jobTitleController;
  late final TextEditingController _institutionController;
  late final TextEditingController _detailsController;

  final _totalExperience = ValueNotifier<String?>(null);
  final _startDate = ValueNotifier<DateTime?>(null);
  final _isCurrent = ValueNotifier<bool>(true);
  final _showErrors = ValueNotifier<bool>(false);

  static const int _detailsLimit = 500;

  @override
  void initState() {
    super.initState();
    final experience = ref.read(accountCreateNotifierProvider).draft.experience;
    _jobTitleController = TextEditingController(
      text: experience.currentJobTitle,
    );
    _institutionController = TextEditingController(
      text: experience.currentInstitution,
    );
    _detailsController = TextEditingController(
      text: experience.experienceDetails,
    );
    _totalExperience.value = experience.totalTeachingExperience;
    _startDate.value = experience.startDate;
    _isCurrent.value = experience.isCurrent;
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _institutionController.dispose();
    _detailsController.dispose();
    _totalExperience.dispose();
    _startDate.dispose();
    _isCurrent.dispose();
    _showErrors.dispose();
    super.dispose();
  }

  @override
  void submitStep() {
    FocusScope.of(context).unfocus();
    _showErrors.value = true;

    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid ||
        _totalExperience.value == null ||
        _startDate.value == null) {
      return;
    }

    final notifier = ref.read(accountCreateNotifierProvider.notifier);
    final current = ref.read(accountCreateNotifierProvider).draft.experience;

    notifier.setExperience(
      current.copyWith(
        totalTeachingExperience: _totalExperience.value,
        currentJobTitle: _jobTitleController.text.trim(),
        currentInstitution: _institutionController.text.trim(),
        experienceDetails: _detailsController.text.trim(),
        isCurrent: _isCurrent.value,
        startDate: _startDate.value,
      ),
    );
    // teachingSubjects and classesTaught come off the draft, not this screen.
    notifier.submitCurrentStep();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: WizardStepLayout(
        step: ProfileStep.experience,
        children: [
          const _CarriedOverCard(),

          WizardField(
            icon: AppIcons.experience,
            label: 'Total Teaching Experience',
            child: ListenableBuilder(
              listenable: Listenable.merge([_totalExperience, _showErrors]),
              builder: (context, _) => WizardSelectField<String>(
                hint: 'Select experience',
                sheetTitle: 'Total teaching experience',
                value: _totalExperience.value,
                options: ExperienceRanges.all,
                labelOf: _identity,
                errorText: _showErrors.value && _totalExperience.value == null
                    ? 'Total experience is required'
                    : null,
                onSelected: (range) => _totalExperience.value = range,
              ),
            ),
          ),

          WizardField(
            icon: Icons.work_outline_rounded,
            label: 'Current Job Title',
            child: AppTextField(
              controller: _jobTitleController,
              hint: 'e.g. Mathematics Teacher',
              validator: _jobTitleValidator,
              textCapitalization: TextCapitalization.words,
            ),
          ),

          WizardField(
            icon: Icons.apartment_rounded,
            label: 'Current Institution',
            child: AppTextField(
              controller: _institutionController,
              hint: 'e.g. Delhi Public School',
              validator: _institutionValidator,
              textCapitalization: TextCapitalization.words,
            ),
          ),

          WizardField(
            icon: Icons.notes_rounded,
            label: 'Experience Details',
            helpText: 'What you have taught, and to whom.',
            child: AppTextField(
              controller: _detailsController,
              hint: 'Briefly describe your teaching experience',
              maxLines: 4,
              maxLength: _detailsLimit,
              validator: _detailsValidator,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
            ),
          ),

          WizardField(
            icon: Icons.event_outlined,
            label: 'Start Date',
            child: ListenableBuilder(
              listenable: Listenable.merge([_startDate, _showErrors]),
              builder: (context, _) => WizardDateField(
                hint: 'Select start date',
                value: _startDate.value,
                errorText: _showErrors.value && _startDate.value == null
                    ? 'Start date is required'
                    : null,
                onSelected: (date) => _startDate.value = date,
              ),
            ),
          ),

          ValueListenableBuilder<bool>(
            valueListenable: _isCurrent,
            builder: (context, isCurrent, _) => WizardCheckboxTile(
              label: 'I currently work here',
              value: isCurrent,
              onChanged: (value) => _isCurrent.value = value,
            ),
          ),
        ],
      ),
    );
  }
}

/// Read-only recap of what About You captured, with a way back to change it.
class _CarriedOverCard extends ConsumerWidget {
  const _CarriedOverCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watches only the two lists it renders, so typing elsewhere in the
    // wizard never rebuilds this card.
    final subjects = ref.watch(
      accountCreateNotifierProvider.select(
        (state) => state.draft.teachingSubjects,
      ),
    );
    final classes = ref.watch(
      accountCreateNotifierProvider.select(
        (state) => state.draft.classesTaught,
      ),
    );

    return WizardField(
      icon: Icons.checklist_rounded,
      label: 'From your profile',
      helpText: 'Sent with this step. Edit it back in About You.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryLine(label: 'Subjects', values: subjects),
          AppSpacing.gapXs,
          _SummaryLine(label: 'Classes', values: classes),
          AppSpacing.gapSm,
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => ref
                  .read(accountCreateNotifierProvider.notifier)
                  .goTo(ProfileStep.aboutYou),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Edit in About You'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.values});

  final String label;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = values.isEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 68,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        AppSpacing.hGapSm,
        Expanded(
          child: Text(
            isEmpty ? 'None selected yet' : values.join(', '),
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: isEmpty ? FontStyle.italic : null,
              color: isEmpty
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

// Top-level so the closures passed into fields are stable across rebuilds.
String _identity(String value) => value;

String? _jobTitleValidator(String? value) =>
    Validators.required(value, field: 'Job title');

String? _institutionValidator(String? value) =>
    Validators.required(value, field: 'Institution');

String? _detailsValidator(String? value) =>
    Validators.required(value, field: 'Experience details');
