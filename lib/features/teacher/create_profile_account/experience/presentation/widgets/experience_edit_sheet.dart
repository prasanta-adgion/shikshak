import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../shared/widgets/app_loading_button.dart';
import '../../../../../../shared/widgets/app_snackbar.dart';
import '../../../shared/presentation/providers/account_create_providers.dart';
import '../../data/model/experience_response_model.dart';
import '../../domain/params/update_experience_params.dart';
import '../controller/experience_form_controller.dart';
import '../providers/experience_providers.dart';
import 'experience_form_fields.dart';

class ExperienceEditSheet extends ConsumerStatefulWidget {
  const ExperienceEditSheet._({required this.item});

  final ExperienceItem item;

  static Future<void> show(BuildContext context, ExperienceItem item) {
    return showModalBottomSheet<void>(
      context: context,
      // The form is taller than half the screen and has to clear the keyboard.
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (context) => ExperienceEditSheet._(item: item),
    );
  }

  @override
  ConsumerState<ExperienceEditSheet> createState() =>
      _ExperienceEditSheetState();
}

class _ExperienceEditSheetState extends ConsumerState<ExperienceEditSheet> {
  late final ExperienceFormController _form;

  @override
  void initState() {
    super.initState();
    _form = ExperienceFormController(initial: widget.item.toExperienceInfo());
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

    final draft = ref.read(accountCreateNotifierProvider).draft;

    final updated = await ref
        .read(experienceListNotifierProvider.notifier)
        .update(
          UpdateExperienceParams(
            id: id,
            experience: _form.toExperienceInfo(),
            // Both lists ride along with every row. Arriving here without
            // About You filled in would otherwise blank out what the row
            // already has, so the stored values stand in.
            teachingSubjects: draft.teachingSubjects.isEmpty
                ? widget.item.teachingSubjects ?? const []
                : draft.teachingSubjects,
            classesTaught: draft.classesTaught.isEmpty
                ? widget.item.classesTaught ?? const []
                : draft.classesTaught,
          ),
        );

    // A failure keeps the sheet open with the edits intact — the step reports
    // the reason.
    if (!updated || !mounted) return;

    AppSnackbar.showSuccess(context, 'Experience updated.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isUpdating = ref.watch(
      experienceListNotifierProvider.select((state) => state.isUpdating),
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
                      'Edit Experience',
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
                child: ExperienceFormFields(controller: _form),
              ),
            ),

            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: AppLoadingButton(
                  label: 'Update Experience',
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
