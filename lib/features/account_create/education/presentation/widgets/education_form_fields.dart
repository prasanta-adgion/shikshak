import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../../shared/presentation/widgets/file_upload_tile.dart';
import '../../../shared/presentation/widgets/wizard_checkbox_tile.dart';
import '../../../shared/presentation/widgets/wizard_field.dart';
import '../../../shared/presentation/widgets/wizard_select_field.dart';
import '../../domain/entities/education.dart';
import '../controller/education_form_controller.dart';

class EducationFormFields extends StatelessWidget {
  const EducationFormFields({super.key, required this.controller});

  final EducationFormController controller;

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[
      WizardField(
        icon: AppIcons.qualification,
        label: 'Degree',
        child: ListenableBuilder(
          listenable: Listenable.merge([
            controller.degree,
            controller.showErrors,
          ]),
          builder: (context, _) => WizardSelectField<String>(
            hint: 'Select your degree',
            sheetTitle: 'Degree',
            value: controller.degree.value,
            options: Degrees.all,
            labelOf: _identity,
            errorText:
                controller.showErrors.value && controller.degree.value == null
                ? 'Degree is required'
                : null,
            onSelected: (degree) => controller.degree.value = degree,
          ),
        ),
      ),

      WizardField(
        icon: Icons.menu_book_outlined,
        label: 'Specialization',
        child: AppTextField(
          controller: controller.specialization,
          hint: 'e.g. Mathematics',
          validator: _specializationValidator,
          textCapitalization: TextCapitalization.words,
        ),
      ),

      WizardField(
        icon: Icons.school_outlined,
        label: 'University / College',
        child: AppTextField(
          controller: controller.university,
          hint: 'e.g. University of Delhi',
          validator: _universityValidator,
          textCapitalization: TextCapitalization.words,
        ),
      ),

      WizardField(
        icon: Icons.event_outlined,
        label: 'Year of Passing',
        child: ListenableBuilder(
          listenable: Listenable.merge([
            controller.yearOfPassing,
            controller.showErrors,
          ]),
          builder: (context, _) => WizardSelectField<int>(
            hint: 'Select year',
            sheetTitle: 'Year of passing',
            value: controller.yearOfPassing.value,
            options: EducationFormController.years,
            labelOf: _yearLabel,
            errorText:
                controller.showErrors.value &&
                    controller.yearOfPassing.value == null
                ? 'Year of passing is required'
                : null,
            onSelected: (year) => controller.yearOfPassing.value = year,
          ),
        ),
      ),

      WizardField(
        icon: Icons.grade_outlined,
        label: 'Marks / Grade',
        child: AppTextField(
          controller: controller.marks,
          hint: 'e.g. A or 82%',
          validator: _marksValidator,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.done,
        ),
      ),

      WizardField(
        icon: Icons.upload_file_outlined,
        label: 'Certificate',
        isOptional: true,
        child: _CertificateField(controller: controller),
      ),

      ValueListenableBuilder<bool>(
        valueListenable: controller.isHighest,
        builder: (context, isHighest, _) => WizardCheckboxTile(
          label: 'This is my highest qualification',
          value: isHighest,
          onChanged: (value) => controller.isHighest.value = value,
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

class _CertificateField extends StatelessWidget {
  const _CertificateField({required this.controller});

  final EducationFormController controller;

  void _pick(BuildContext context) {
    // TODO(picker): replace with file_picker. The form holds the file name
    // until an upload turns it into certificateUrl.
    controller.certificateFileName.value = 'certificate.pdf';
    AppSnackbar.show(
      context,
      'File picking is not connected yet — attached a placeholder.',
    );
  }

  void _remove() {
    controller.certificateFileName.value = null;
    controller.certificateLocalPath.value = null;
    controller.certificateUrl.value = null;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        controller.certificateFileName,
        controller.certificateUrl,
      ]),
      builder: (context, _) => FileUploadTile(
        title: 'Degree certificate',
        hint: 'Upload your degree certificate',
        isRequired: false,
        // A stored row has a URL and no picked name, so the tile falls back to
        // the file the URL points at.
        fileName:
            controller.certificateFileName.value ??
            _nameFromUrl(controller.certificateUrl.value),
        onUpload: () => _pick(context),
        onRemove: _remove,
      ),
    );
  }
}

/// `https://host/path/cert.pdf` → `cert.pdf`.
String? _nameFromUrl(String? url) {
  if (url == null || url.isEmpty) return null;

  final path = Uri.tryParse(url)?.pathSegments;
  if (path == null || path.isEmpty) return url;

  return path.last.isEmpty ? url : path.last;
}

// Top-level so the closures passed into fields are stable across rebuilds.
String _identity(String value) => value;

String _yearLabel(int year) => '$year';

String? _specializationValidator(String? value) =>
    Validators.required(value, field: 'Specialization');

String? _universityValidator(String? value) =>
    Validators.required(value, field: 'University or college');

String? _marksValidator(String? value) =>
    Validators.required(value, field: 'Marks or grade');
