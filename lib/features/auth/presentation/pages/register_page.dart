import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_loading_button.dart';
import '../../../../shared/widgets/app_password_field.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/usecases/register_usecase.dart';
import '../providers/auth_providers.dart';
import '../state/auth_state.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/subject_chips_field.dart';

/// Role-aware registration screen.
///
/// Common fields are shared; teacher/student sections are appended based on
/// [role], all inside a single [Form] so validation runs together.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key, required this.role});

  final UserRole role;

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  static const _subjectOptions = [
    'Mathematics',
    'Science',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'Hindi',
    'Computer Science',
  ];

  static const _experienceOptions = [
    '0–1 years',
    '1–3 years',
    '3–5 years',
    '5–10 years',
    '10+ years',
  ];

  static final _classOptions =
      List.generate(12, (index) => 'Class ${index + 1}');

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _cityController = TextEditingController();
  final _qualificationController = TextEditingController();

  String? _experience;
  String? _studentClass;
  Set<String> _subjects = const {};

  bool get _isTeacher => widget.role == UserRole.teacher;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cityController.dispose();
    _qualificationController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref.read(authNotifierProvider.notifier).register(
          RegisterParams(
            fullName: _nameController.text,
            email: _emailController.text,
            mobileNumber: _mobileController.text,
            password: _passwordController.text,
            role: widget.role,
            city: _cityController.text,
            qualification: _isTeacher ? _qualificationController.text : null,
            experience: _isTeacher ? _experience : null,
            subjects: _isTeacher ? _subjects.toList() : const [],
            studentClass: _isTeacher ? null : _studentClass,
            preferredSubjects: _isTeacher ? const [] : _subjects.toList(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSubmitting =
        ref.watch(authNotifierProvider.select((s) => s.isSubmitting));

    // Navigate to the dashboard once the account is created.
    ref.listen(authNotifierProvider.select((s) => s.status),
        (previous, next) {
      final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
      if (next == AuthStatus.authenticated && isCurrent) {
        final role = ref.read(authNotifierProvider).user?.role ?? widget.role;
        context.go(RoutePaths.dashboardFor(role));
      }
    });

    ref.listen(authNotifierProvider.select((s) => s.errorMessage),
        (previous, next) {
      if (next != null && next != previous) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return AuthScaffold(
      title: 'Create ${widget.role.label} Account',
      subtitle: _isTeacher
          ? 'Share your knowledge and grow your teaching business'
          : 'Start learning with the best tutors around you',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Full Name',
              hint: 'e.g. Priya Sharma',
              controller: _nameController,
              validator: Validators.fullName,
              prefixIcon: AppIcons.name,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
            ),
            AppSpacing.gapXl,
            AppTextField(
              label: 'Email',
              hint: 'you@example.com',
              controller: _emailController,
              validator: Validators.email,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: AppIcons.email,
              autofillHints: const [AutofillHints.email],
            ),
            AppSpacing.gapXl,
            AppTextField(
              label: 'Mobile Number',
              hint: '10-digit mobile number',
              controller: _mobileController,
              validator: Validators.mobileNumber,
              keyboardType: TextInputType.phone,
              prefixIcon: AppIcons.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              autofillHints: const [AutofillHints.telephoneNumber],
            ),
            AppSpacing.gapXl,
            AppPasswordField(
              controller: _passwordController,
              hint: 'Min 8 characters, letters & numbers',
              validator: Validators.password,
              textInputAction: TextInputAction.next,
            ),
            AppSpacing.gapXl,
            AppPasswordField(
              label: 'Confirm Password',
              controller: _confirmPasswordController,
              hint: 'Re-enter your password',
              validator: (value) => Validators.confirmPassword(
                value,
                _passwordController.text,
              ),
              textInputAction: TextInputAction.next,
            ),
            AppSpacing.gapXl,
            if (_isTeacher)
              ..._teacherFields(theme)
            else
              ..._studentFields(theme),
            AppSpacing.gapXl,
            AppTextField(
              label: 'City',
              hint: 'e.g. Kolkata',
              controller: _cityController,
              validator: Validators.city,
              prefixIcon: AppIcons.city,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
            AppSpacing.gapXxl,
            AppLoadingButton(
              label: 'Create Account',
              isLoading: isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _teacherFields(ThemeData theme) => [
        AppTextField(
          label: 'Qualification',
          hint: 'e.g. M.Sc. Mathematics, B.Ed.',
          controller: _qualificationController,
          validator: (value) =>
              Validators.required(value, field: 'Qualification'),
          prefixIcon: AppIcons.qualification,
          textCapitalization: TextCapitalization.words,
        ),
        AppSpacing.gapXl,
        _LabeledDropdown(
          label: 'Experience',
          hint: 'Select your experience',
          icon: AppIcons.experience,
          value: _experience,
          items: _experienceOptions,
          onChanged: (value) => setState(() => _experience = value),
          validator: (value) =>
              Validators.required(value, field: 'Experience'),
        ),
        AppSpacing.gapXl,
        SubjectChipsField(
          label: 'Subjects You Teach',
          options: _subjectOptions,
          onChanged: (selected) => _subjects = selected,
        ),
      ];

  List<Widget> _studentFields(ThemeData theme) => [
        _LabeledDropdown(
          label: 'Class',
          hint: 'Select your class',
          icon: AppIcons.studentClass,
          value: _studentClass,
          items: _classOptions,
          onChanged: (value) => setState(() => _studentClass = value),
          validator: (value) => Validators.required(value, field: 'Class'),
        ),
        AppSpacing.gapXl,
        SubjectChipsField(
          label: 'Preferred Subjects',
          options: _subjectOptions,
          onChanged: (selected) => _subjects = selected,
        ),
      ];
}

/// Dropdown styled to match [AppTextField] (external label + themed input).
class _LabeledDropdown extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.hint,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  final String label;
  final String hint;
  final IconData icon;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        AppSpacing.gapSm,
        DropdownButtonFormField<String>(
          initialValue: value,
          validator: validator,
          onChanged: onChanged,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 22),
          ),
          items: [
            for (final item in items)
              DropdownMenuItem(value: item, child: Text(item)),
          ],
        ),
      ],
    );
  }
}
