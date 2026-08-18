import 'package:flutter/material.dart';

import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../../class_schedule/domain/entities/class_mode.dart';
import '../../../class_schedule/domain/entities/schedule_day.dart';
import '../../../create_profile_account/shared/domain/entities/reference_data.dart';
import '../../../create_profile_account/shared/presentation/widgets/wizard_date_field.dart';
import '../../../create_profile_account/shared/presentation/widgets/wizard_field.dart';
import '../../../create_profile_account/shared/presentation/widgets/wizard_multi_select_field.dart';
import '../../../create_profile_account/shared/presentation/widgets/wizard_select_field.dart';
import '../controller/class_slot_form_controller.dart';
import 'class_mode_selector.dart';
import 'form_section.dart';
import 'slot_time_field.dart';

class ClassSlotFormFields extends StatelessWidget {
  const ClassSlotFormFields({super.key, required this.controller});

  final ClassSlotFormController controller;

  static DateTime get _today => DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DetailsSection(controller: controller),
          AppSpacing.gapLg,
          _ScheduleSection(controller: controller),
          AppSpacing.gapLg,
          _DeliverySection(controller: controller),
        ],
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  const _DetailsSection({required this.controller});

  final ClassSlotFormController controller;

  @override
  Widget build(BuildContext context) {
    return FormSection(
      icon: AppIcons.classTitle,
      title: 'Class details',
      subtitle: 'What you are teaching, and who it is for.',
      children: [
        WizardField(
          icon: AppIcons.classTitle,
          label: 'Class title',
          child: AppTextField(
            controller: controller.title,
            hint: 'e.g. Class 10 – Mathematics',
            validator: _titleValidator,
            textCapitalization: TextCapitalization.words,
          ),
        ),
        WizardField(
          icon: AppIcons.notes,
          label: 'Description',
          isOptional: true,
          child: AppTextField(
            controller: controller.description,
            hint: 'e.g. Algebra – Linear Equations',
            maxLines: 3,
            maxLength: 200,
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
        WizardField(
          icon: AppIcons.subject,
          label: 'Subjects',
          child: ListenableBuilder(
            listenable: Listenable.merge([
              controller.subjects,
              controller.showErrors,
            ]),
            builder: (context, _) => WizardMultiSelectField(
              hint: 'Select subjects',
              sheetTitle: 'Subjects',
              options: ReferenceData.subjects,
              selected: controller.subjects.value,
              errorText: controller.subjectsError,
              onChanged: (values) => controller.subjects.value = values,
            ),
          ),
        ),
        WizardField(
          icon: AppIcons.studentClass,
          label: 'Classes',
          child: ListenableBuilder(
            listenable: Listenable.merge([
              controller.classes,
              controller.showErrors,
            ]),
            builder: (context, _) => WizardMultiSelectField(
              hint: 'Select classes',
              sheetTitle: 'Classes',
              options: ReferenceData.classes,
              selected: controller.classes.value,
              errorText: controller.classesError,
              onChanged: (values) => controller.classes.value = values,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection({required this.controller});

  final ClassSlotFormController controller;

  @override
  Widget build(BuildContext context) {
    return FormSection(
      icon: AppIcons.schedule,
      title: 'When it runs',
      subtitle: 'The slot repeats on this day and time every week.',
      children: [
        WizardField(
          icon: AppIcons.repeat,
          label: 'Repeats on',
          child: ListenableBuilder(
            listenable: Listenable.merge([
              controller.day,
              controller.showErrors,
            ]),
            builder: (context, _) => WizardSelectField<ScheduleDay>(
              hint: 'Select a day',
              sheetTitle: 'Day of the week',
              value: controller.day.value,
              options: ScheduleDay.values,
              labelOf: _dayLabel,
              errorText: controller.dayError,
              onSelected: (day) => controller.day.value = day,
            ),
          ),
        ),
        WizardField(
          icon: AppIcons.hours,
          label: 'Class time',
          child: ListenableBuilder(
            listenable: Listenable.merge([
              controller.startTime,
              controller.endTime,
              controller.showErrors,
            ]),
            builder: (context, _) => _FieldPair(
              first: SlotTimeField(
                label: 'Starts',
                hint: 'Start time',
                value: controller.startTime.value,
                errorText: controller.startTimeError,
                onSelected: (time) => controller.startTime.value = time,
              ),
              second: SlotTimeField(
                label: 'Ends',
                hint: 'End time',
                value: controller.endTime.value,
                errorText: controller.endTimeError,
                // Opens beside the start rather than at a default hour.
                initialTime: controller.startTime.value,
                onSelected: (time) => controller.endTime.value = time,
              ),
            ),
          ),
        ),
        WizardField(
          icon: AppIcons.birthday,
          label: 'Runs between',
          helpText:
              'Leave the end date empty and the class repeats indefinitely.',
          child: ListenableBuilder(
            listenable: Listenable.merge([
              controller.validFrom,
              controller.validUntil,
              controller.showErrors,
            ]),
            builder: (context, _) => _ValidityFields(controller: controller),
          ),
        ),
      ],
    );
  }
}

/// Start and end date, with the end kept optional and clearable.
class _ValidityFields extends StatelessWidget {
  const _ValidityFields({required this.controller});

  final ClassSlotFormController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = ClassSlotFormFields._today;
    final from = controller.validFrom.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldPair(
          first: WizardDateField(
            label: 'Start date',
            hint: 'First class',
            value: from,
            errorText: controller.validFromError,
            firstDate: today,
            lastDate: DateTime(today.year + 2, today.month, today.day),
            onSelected: (date) {
              controller.validFrom.value = date;
              // A start pushed past the end would leave the pair reading
              // backwards, so the stale end is dropped.
              final until = controller.validUntil.value;
              if (until != null && until.isBefore(date)) {
                controller.validUntil.value = null;
              }
            },
          ),
          second: WizardDateField(
            label: 'End date (optional)',
            hint: 'No end date',
            value: controller.validUntil.value,
            errorText: controller.validUntilError,
            firstDate: from ?? today,
            lastDate: DateTime(today.year + 5, today.month, today.day),
            onSelected: (date) => controller.validUntil.value = date,
          ),
        ),
        if (controller.validUntil.value != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => controller.validUntil.value = null,
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text('Clear end date'),
              style: TextButton.styleFrom(
                textStyle: theme.textTheme.labelMedium,
              ),
            ),
          ),
      ],
    );
  }
}

class _DeliverySection extends StatelessWidget {
  const _DeliverySection({required this.controller});

  final ClassSlotFormController controller;

  @override
  Widget build(BuildContext context) {
    return FormSection(
      icon: AppIcons.address,
      title: 'Where it happens',
      subtitle: 'How the class is delivered, and where students should go.',
      children: [
        ValueListenableBuilder<ClassMode>(
          valueListenable: controller.mode,
          builder: (context, mode, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WizardField(
                icon: AppIcons.classInPerson,
                label: 'Mode',
                child: ClassModeSelector(
                  value: mode,
                  onChanged: (value) => controller.mode.value = value,
                ),
              ),
              // An online class has nowhere to go, so the venue fields are
              // dropped rather than shown greyed out.
              if (mode.hasVenue) ...[
                AppSpacing.gapXl,
                WizardField(
                  icon: AppIcons.classInPerson,
                  label: 'Venue name',
                  child: AppTextField(
                    controller: controller.venueName,
                    hint: 'e.g. Room 3',
                    validator: _venueNameValidator,
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                AppSpacing.gapXl,
                WizardField(
                  icon: AppIcons.address,
                  label: 'Venue address',
                  isOptional: true,
                  child: AppTextField(
                    controller: controller.venueAddress,
                    hint: 'e.g. 2nd Floor, Main Building',
                    maxLines: 2,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Two fields side by side where there is room, stacked where there is not.
///
/// A time or date field needs roughly 160 logical pixels before its value
/// starts truncating, so the pair splits below twice that.
class _FieldPair extends StatelessWidget {
  const _FieldPair({required this.first, required this.second});

  final Widget first;
  final Widget second;

  static const double _minPairWidth = 340;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, _, constraints) {
        if (constraints.maxWidth < _minPairWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [first, AppSpacing.gapLg, second],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            AppSpacing.hGapMd,
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

// Top-level so the closures passed into fields are stable across rebuilds.
String _dayLabel(ScheduleDay day) => day.label;

String? _titleValidator(String? value) =>
    Validators.required(value, field: 'Class title');

String? _venueNameValidator(String? value) =>
    Validators.required(value, field: 'Venue name');
