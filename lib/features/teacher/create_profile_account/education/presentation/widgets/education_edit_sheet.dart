import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../shared/widgets/app_loading_button.dart';
import '../../../../../../shared/widgets/app_snackbar.dart';
import '../../data/model/education_response_model.dart';
import '../../domain/params/update_education_params.dart';
import '../controller/education_form_controller.dart';
import '../providers/education_providers.dart';
import 'education_form_fields.dart';

class EducationEditSheet extends ConsumerStatefulWidget {
  const EducationEditSheet._({required this.item});

  final EducationItem item;

  static Future<void> show(BuildContext context, EducationItem item) {
    return showModalBottomSheet<void>(
      context: context,
      // The form is taller than half the screen and has to clear the keyboard.
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (context) => EducationEditSheet._(item: item),
    );
  }

  @override
  ConsumerState<EducationEditSheet> createState() => _EducationEditSheetState();
}

class _EducationEditSheetState extends ConsumerState<EducationEditSheet> {
  late final EducationFormController _form;

  @override
  void initState() {
    super.initState();
    _form = EducationFormController(initial: widget.item.toEducation());
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    final id = widget.item.id;
    if (id == null) return;

    FocusScope.of(context).unfocus();
    if (!_form.validate()) return;

    final updated = await ref
        .read(educationListNotifierProvider.notifier)
        .update(UpdateEducationParams(id: id, education: _form.toEducation()));

    // A failure keeps the sheet open with the edits intact — the step reports
    // the reason.
    if (!updated || !mounted) return;

    AppSnackbar.showSuccess(context, 'Education updated.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isUpdating = ref.watch(
      educationListNotifierProvider.select((state) => state.isUpdating),
    );

    return ConstrainedBox(
      // Capped so the sheet never swallows the screen; the fields scroll
      // inside it instead.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      child: Padding(
        // Lifts the sheet clear of the keyboard while a field has focus.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                0,
                AppSpacing.sm,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Edit Education',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: isUpdating
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: EducationFormFields(controller: _form),
              ),
            ),

            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: AppLoadingButton(
                  label: 'Update Education',
                  isLoading: isUpdating,
                  onPressed: _update,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
