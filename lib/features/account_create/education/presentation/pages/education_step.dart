import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../../shared/domain/entities/profile_step.dart';
import '../../../shared/presentation/mixins/wizard_step_registration.dart';
import '../../../shared/presentation/providers/account_create_providers.dart';
import '../../../shared/presentation/widgets/file_upload_tile.dart';
import '../../../shared/presentation/widgets/wizard_checkbox_tile.dart';
import '../../../shared/presentation/widgets/wizard_field.dart';
import '../../../shared/presentation/widgets/wizard_select_field.dart';
import '../../../shared/presentation/widgets/wizard_step_layout.dart';

import '../../domain/entities/education.dart';

/// Step 4 — the education payload: one qualification per POST.
class EducationStep extends ConsumerStatefulWidget {
  const EducationStep({super.key});

  @override
  ConsumerState<EducationStep> createState() => _EducationStepState();
}

class _EducationStepState extends ConsumerState<EducationStep>
    with WizardStepRegistration {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _specializationController;
  late final TextEditingController _universityController;
  late final TextEditingController _marksController;

  final _degree = ValueNotifier<String?>(null);
  final _yearOfPassing = ValueNotifier<int?>(null);
  final _isHighest = ValueNotifier<bool>(true);
  final _showErrors = ValueNotifier<bool>(false);

  /// This year back to 1970, newest first. Built once — the list never
  /// changes while the step is on screen.
  static final List<int> _years = [
    for (var year = DateTime.now().year; year >= 1970; year--) year,
  ];

  @override
  void initState() {
    super.initState();
    final education = ref.read(accountCreateNotifierProvider).draft.education;
    _specializationController = TextEditingController(
      text: education.specialization,
    );
    _universityController = TextEditingController(
      text: education.universityCollege,
    );
    _marksController = TextEditingController(text: education.marksOrGrade);
    _degree.value = education.degree;
    _yearOfPassing.value = education.yearOfPassing;
    _isHighest.value = education.isHighestQualification;
  }

  @override
  void dispose() {
    _specializationController.dispose();
    _universityController.dispose();
    _marksController.dispose();
    _degree.dispose();
    _yearOfPassing.dispose();
    _isHighest.dispose();
    _showErrors.dispose();
    super.dispose();
  }

  void _pickCertificate() {
    // TODO(picker): replace with file_picker. The entity holds the file name
    // until an upload turns it into certificateUrl.
    final notifier = ref.read(accountCreateNotifierProvider.notifier);
    final current = ref.read(accountCreateNotifierProvider).draft.education;
    notifier.setEducation(
      current.copyWith(certificateFileName: 'certificate.pdf'),
    );
    AppSnackbar.show(
      context,
      'File picking is not connected yet — attached a placeholder.',
    );
  }

  void _removeCertificate() {
    final notifier = ref.read(accountCreateNotifierProvider.notifier);
    final current = ref.read(accountCreateNotifierProvider).draft.education;
    notifier.setEducation(
      Education(
        degree: current.degree,
        specialization: current.specialization,
        universityCollege: current.universityCollege,
        yearOfPassing: current.yearOfPassing,
        marksOrGrade: current.marksOrGrade,
        isHighestQualification: current.isHighestQualification,
      ),
    );
  }

  @override
  void submitStep() {
    FocusScope.of(context).unfocus();
    _showErrors.value = true;

    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid || _degree.value == null || _yearOfPassing.value == null) {
      return;
    }

    final notifier = ref.read(accountCreateNotifierProvider.notifier);
    final current = ref.read(accountCreateNotifierProvider).draft.education;

    notifier.setEducation(
      current.copyWith(
        degree: _degree.value,
        specialization: _specializationController.text.trim(),
        universityCollege: _universityController.text.trim(),
        yearOfPassing: _yearOfPassing.value,
        marksOrGrade: _marksController.text.trim(),
        isHighestQualification: _isHighest.value,
      ),
    );
    // TODO(api): POST the education payload here, then advance on success.
    notifier.next();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: WizardStepLayout(
        step: ProfileStep.education,
        children: [
          WizardField(
            icon: AppIcons.qualification,
            label: 'Degree',
            child: ListenableBuilder(
              listenable: Listenable.merge([_degree, _showErrors]),
              builder: (context, _) => WizardSelectField<String>(
                hint: 'Select your degree',
                sheetTitle: 'Degree',
                value: _degree.value,
                options: Degrees.all,
                labelOf: _identity,
                errorText: _showErrors.value && _degree.value == null
                    ? 'Degree is required'
                    : null,
                onSelected: (degree) => _degree.value = degree,
              ),
            ),
          ),

          WizardField(
            icon: Icons.menu_book_outlined,
            label: 'Specialization',
            child: AppTextField(
              controller: _specializationController,
              hint: 'e.g. Mathematics',
              validator: _specializationValidator,
              textCapitalization: TextCapitalization.words,
            ),
          ),

          WizardField(
            icon: Icons.school_outlined,
            label: 'University / College',
            child: AppTextField(
              controller: _universityController,
              hint: 'e.g. University of Delhi',
              validator: _universityValidator,
              textCapitalization: TextCapitalization.words,
            ),
          ),

          WizardField(
            icon: Icons.event_outlined,
            label: 'Year of Passing',
            child: ListenableBuilder(
              listenable: Listenable.merge([_yearOfPassing, _showErrors]),
              builder: (context, _) => WizardSelectField<int>(
                hint: 'Select year',
                sheetTitle: 'Year of passing',
                value: _yearOfPassing.value,
                options: _years,
                labelOf: _yearLabel,
                errorText: _showErrors.value && _yearOfPassing.value == null
                    ? 'Year of passing is required'
                    : null,
                onSelected: (year) => _yearOfPassing.value = year,
              ),
            ),
          ),

          WizardField(
            icon: Icons.grade_outlined,
            label: 'Marks / Grade',
            child: AppTextField(
              controller: _marksController,
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
            child: Consumer(
              builder: (context, ref, _) {
                final fileName = ref.watch(
                  accountCreateNotifierProvider.select(
                    (state) => state.draft.education.certificateFileName,
                  ),
                );

                return FileUploadTile(
                  title: 'Degree certificate',
                  hint: 'Upload your degree certificate',
                  isRequired: false,
                  fileName: fileName,
                  onUpload: _pickCertificate,
                  onRemove: _removeCertificate,
                );
              },
            ),
          ),

          ValueListenableBuilder<bool>(
            valueListenable: _isHighest,
            builder: (context, isHighest, _) => WizardCheckboxTile(
              label: 'This is my highest qualification',
              value: isHighest,
              onChanged: (value) => _isHighest.value = value,
            ),
          ),
        ],
      ),
    );
  }
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
