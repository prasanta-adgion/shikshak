import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_icons.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/utils/validators.dart';
import '../../../../../../shared/widgets/app_text_field.dart';
import '../../../shared/presentation/widgets/wizard_checkbox_tile.dart';
import '../../../shared/presentation/widgets/wizard_date_field.dart';
import '../../../shared/presentation/widgets/wizard_field.dart';
import '../../../shared/presentation/widgets/wizard_select_field.dart';
import '../../domain/entities/experience_info.dart';
import '../controller/experience_form_controller.dart';

/// The experience payload's fields, driven by [ExperienceFormController].
///
/// Carries its own [Form] so the create form and an expanded saved row
/// validate independently — a blank row being edited must not block the entry
/// being added, and the other way round.
class ExperienceFormFields extends StatelessWidget {
  const ExperienceFormFields({super.key, required this.controller});

  final ExperienceFormController controller;

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[
      WizardField(
        icon: AppIcons.experience,
        label: 'Total Teaching Experience',
        child: ListenableBuilder(
          listenable: Listenable.merge([
            controller.totalExperience,
            controller.showErrors,
          ]),
          builder: (context, _) => WizardSelectField<String>(
            hint: 'Select experience',
            sheetTitle: 'Total teaching experience',
            value: controller.totalExperience.value,
            options: ExperienceRanges.all,
            labelOf: _identity,
            errorText:
                controller.showErrors.value &&
                    controller.totalExperience.value == null
                ? 'Total experience is required'
                : null,
            onSelected: (range) => controller.totalExperience.value = range,
          ),
        ),
      ),

      WizardField(
        icon: Icons.work_outline_rounded,
        label: 'Job Title',
        child: AppTextField(
          controller: controller.jobTitle,
          hint: 'e.g. Mathematics Teacher',
          validator: _jobTitleValidator,
          textCapitalization: TextCapitalization.words,
        ),
      ),

      WizardField(
        icon: Icons.apartment_rounded,
        label: 'Institution',
        child: AppTextField(
          controller: controller.institution,
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
          controller: controller.details,
          hint: 'Briefly describe your teaching experience',
          maxLines: 4,
          maxLength: ExperienceFormController.detailsLimit,
          validator: _detailsValidator,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
        ),
      ),

      WizardField(
        icon: Icons.event_outlined,
        label: 'Start Date',
        child: ListenableBuilder(
          listenable: Listenable.merge([
            controller.startDate,
            controller.showErrors,
          ]),
          builder: (context, _) => WizardDateField(
            hint: 'Select start date',
            value: controller.startDate.value,
            errorText:
                controller.showErrors.value &&
                    controller.startDate.value == null
                ? 'Start date is required'
                : null,
            onSelected: (date) => controller.startDate.value = date,
          ),
        ),
      ),

      ValueListenableBuilder<bool>(
        valueListenable: controller.isCurrent,
        builder: (context, isCurrent, _) => WizardCheckboxTile(
          label: 'I currently work here',
          value: isCurrent,
          onChanged: (value) => controller.isCurrent.value = value,
        ),
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

// Top-level so the closures passed into fields are stable across rebuilds.
String _identity(String value) => value;

String? _jobTitleValidator(String? value) =>
    Validators.required(value, field: 'Job title');

String? _institutionValidator(String? value) =>
    Validators.required(value, field: 'Institution');

String? _detailsValidator(String? value) =>
    Validators.required(value, field: 'Experience details');
