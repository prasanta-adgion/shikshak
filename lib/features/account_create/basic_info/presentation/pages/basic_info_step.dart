import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/validators.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../../../auth/presentation/providers_di/auth_providers.dart';
import '../../../shared/domain/entities/profile_step.dart';
import '../../../shared/presentation/mixins/wizard_step_registration.dart';
import '../../../shared/presentation/providers/account_create_providers.dart';
import '../../../shared/presentation/widgets/wizard_date_field.dart';
import '../../../shared/presentation/widgets/wizard_field.dart';
import '../../../shared/presentation/widgets/wizard_info_note.dart';
import '../../../shared/presentation/widgets/wizard_select_field.dart';
import '../../../shared/presentation/widgets/wizard_step_layout.dart';
import '../../domain/entities/gender.dart';
import '../widgets/profile_photo_picker.dart';

/// Step 1 — the basic-info payload: photo, gender, date of birth and address.
class BasicInfoStep extends ConsumerStatefulWidget {
  const BasicInfoStep({super.key});

  @override
  ConsumerState<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends ConsumerState<BasicInfoStep>
    with WizardStepRegistration {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _countryController;
  late final TextEditingController _postalCodeController;

  // Notifiers rather than fields + setState: picking a gender repaints one
  // field instead of the whole step.
  final _gender = ValueNotifier<Gender?>(null);
  final _dateOfBirth = ValueNotifier<DateTime?>(null);
  final _photoPath = ValueNotifier<String?>(null);

  /// Flipped on the first submit, so the pickers only show their errors after
  /// a real attempt — matching how the text fields behave.
  final _showErrors = ValueNotifier<bool>(false);

  /// 18 years is the floor for a teaching account.
  static final DateTime _latestBirthDate = DateTime(
    DateTime.now().year - 18,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  void initState() {
    super.initState();
    // Seeded from the draft so returning to this step restores every answer.
    final info = ref.read(accountCreateNotifierProvider).draft.basicInfo;
    _addressLine1Controller = TextEditingController(text: info.addressLine1);
    _addressLine2Controller = TextEditingController(text: info.addressLine2);
    _cityController = TextEditingController(text: info.city);
    _stateController = TextEditingController(text: info.state);
    _countryController = TextEditingController(text: info.country);
    _postalCodeController = TextEditingController(text: info.postalCode);
    _gender.value = info.gender;
    _dateOfBirth.value = info.dateOfBirth;
    _photoPath.value = info.localPhotoPath;
  }

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _gender.dispose();
    _dateOfBirth.dispose();
    _photoPath.dispose();
    _showErrors.dispose();
    super.dispose();
  }

  @override
  void submitStep() {
    FocusScope.of(context).unfocus();
    _showErrors.value = true;

    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid || _dateOfBirth.value == null || _gender.value == null) {
      return;
    }

    final notifier = ref.read(accountCreateNotifierProvider.notifier);
    final current = ref.read(accountCreateNotifierProvider).draft.basicInfo;

    notifier.setBasicInfo(
      current.copyWith(
        gender: _gender.value,
        dateOfBirth: _dateOfBirth.value,
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        country: _countryController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
      ),
    );
    notifier.submitCurrentStep();
  }

  String? _validatePostalCode(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return 'Postal code is required';
    if (trimmed.length != 6) return 'Enter all 6 digits';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: WizardStepLayout(
        step: ProfileStep.basicInfo,
        children: [
          // The verified account, as typed on the register form: name and
          // email come back with the session, the phone is carried over from
          // signup.
          Consumer(
            builder: (context, ref, _) {
              final user = ref.watch(
                authStateNotifierProvider.select((state) => state.user),
              );

              return ValueListenableBuilder<String?>(
                valueListenable: _photoPath,
                builder: (context, path, _) => ProfilePhotoPicker(
                  photoPath: path,
                  name: user?.fullName ?? '',
                  email: user?.email ?? '',
                  phoneNumber: user?.mobileNumber ?? '',
                  // TODO(picker): needs image_picker. The entity already holds
                  // a localPhotoPath, uploaded later into profilePhotoUrl.
                  onTap: () => AppSnackbar.show(
                    context,
                    'Photo upload is not connected yet.',
                  ),
                ),
              );
            },
          ),

          WizardField(
            icon: Icons.people_outline_rounded,
            label: 'Gender',
            child: ListenableBuilder(
              listenable: Listenable.merge([_gender, _showErrors]),
              builder: (context, _) => WizardSelectField<Gender>(
                hint: 'Select your gender',
                sheetTitle: 'Gender',
                value: _gender.value,
                options: Gender.values,
                labelOf: _genderLabel,
                errorText: _showErrors.value && _gender.value == null
                    ? 'Gender is required'
                    : null,
                onSelected: (gender) => _gender.value = gender,
              ),
            ),
          ),

          WizardField(
            icon: Icons.calendar_month_outlined,
            label: 'Date of Birth',
            child: ListenableBuilder(
              listenable: Listenable.merge([_dateOfBirth, _showErrors]),
              builder: (context, _) => WizardDateField(
                hint: 'Select your date of birth',
                value: _dateOfBirth.value,
                lastDate: _latestBirthDate,
                errorText: _showErrors.value && _dateOfBirth.value == null
                    ? 'Date of birth is required'
                    : null,
                onSelected: (date) => _dateOfBirth.value = date,
              ),
            ),
          ),

          WizardField(
            icon: Icons.location_on_outlined,
            label: 'Address Line 1',
            child: AppTextField(
              controller: _addressLine1Controller,
              hint: 'House / street',
              validator: _addressValidator,
              textCapitalization: TextCapitalization.words,
            ),
          ),

          WizardField(
            icon: Icons.apartment_rounded,
            label: 'Address Line 2',
            isOptional: true,
            child: AppTextField(
              controller: _addressLine2Controller,
              hint: 'Landmark (optional)',
              textCapitalization: TextCapitalization.words,
            ),
          ),

          WizardField(
            icon: Icons.location_city_rounded,
            label: 'City',
            child: AppTextField(
              controller: _cityController,
              hint: 'Enter your city',
              validator: Validators.city,
              textCapitalization: TextCapitalization.words,
            ),
          ),

          WizardField(
            icon: Icons.map_outlined,
            label: 'State',
            child: AppTextField(
              controller: _stateController,
              hint: 'Enter your state',
              validator: _stateValidator,
              textCapitalization: TextCapitalization.words,
            ),
          ),

          WizardField(
            icon: Icons.public_rounded,
            label: 'Country',
            child: AppTextField(
              controller: _countryController,
              hint: 'Enter your country',
              validator: _countryValidator,
              textCapitalization: TextCapitalization.words,
            ),
          ),

          WizardField(
            icon: Icons.markunread_mailbox_outlined,
            label: 'Postal Code',
            child: AppTextField(
              controller: _postalCodeController,
              hint: '6-digit PIN code',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              validator: _validatePostalCode,
            ),
          ),

          const WizardInfoNote(
            message: 'Your information is secure and will be used only to '
                'enhance your teaching experience.',
          ),
        ],
      ),
    );
  }
}

// Top-level so the closures passed into fields are stable across rebuilds.
String _genderLabel(Gender gender) => gender.label;

String? _addressValidator(String? value) =>
    Validators.required(value, field: 'Address');

String? _stateValidator(String? value) =>
    Validators.required(value, field: 'State');

String? _countryValidator(String? value) =>
    Validators.required(value, field: 'Country');
