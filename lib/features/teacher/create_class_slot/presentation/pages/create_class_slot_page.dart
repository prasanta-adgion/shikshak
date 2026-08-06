import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_outlined_button.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../controller/class_slot_form_controller.dart';
import '../widgets/class_slot_form_fields.dart';

/// Form for creating a recurring class slot.
///
/// UI only: the fields, their validation and the layout are complete, but
/// there is no create endpoint yet, so submitting validates and stops there.
/// The controller already holds the values in the shapes the payload wants.
class CreateClassSlotPage extends StatefulWidget {
  const CreateClassSlotPage({super.key});

  @override
  State<CreateClassSlotPage> createState() => _CreateClassSlotPageState();
}

class _CreateClassSlotPageState extends State<CreateClassSlotPage> {
  final _controller = ClassSlotFormController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_controller.validate()) {
      // The invalid fields now carry their own messages; the first one is
      // usually above the fold, so there is nothing more to say.
      AppSnackbar.showError(context, 'Please fix the highlighted fields.');
      return;
    }

    AppSnackbar.show(
      context,
      'Class details are complete. Saving turns on with the create endpoint.',
    );
  }

  /// Guards a half-typed form against a stray back gesture.
  Future<void> _handlePop(bool didPop) async {
    if (didPop) return;

    final shouldLeave = !_controller.isDirty || await _confirmDiscard();
    if (shouldLeave && mounted) Navigator.of(context).pop();
  }

  Future<bool> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard this class?'),
        content: const Text('The details you have entered will not be kept.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return discard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      // Always intercepted: `isDirty` changes as the teacher types, and a
      // precomputed `canPop` would be stale by the time they leave.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _handlePop(didPop),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Create Class', style: theme.textTheme.titleLarge),
          leading: IconButton(
            onPressed: () => _handlePop(false),
            icon: const Icon(AppIcons.back, size: 18),
            tooltip: 'Back',
          ),
        ),
        body: CenteredConstrainedBox(
          maxWidth: Breakpoints.tabletFormMaxWidth,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: context.responsivePagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSpacing.gapLg,
                const AppHeader(
                  title: 'New class slot',
                  subtitle:
                      'Set it up once and it repeats on the same day every '
                      'week, until you end it.',
                ),
                AppSpacing.gapXl,
                ClassSlotFormFields(controller: _controller),
                AppSpacing.gapXxxl,
              ],
            ),
          ),
        ),
        bottomNavigationBar: _ActionBar(
          onCancel: () => _handlePop(false),
          onSubmit: _submit,
        ),
      ),
    );
  }
}

/// Pinned footer, so the primary action stays reachable however long the form
/// scrolls.
class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.onCancel, required this.onSubmit});

  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          // Align with heightFactor, not CenteredConstrainedBox: the Scaffold
          // hands this bar loose constraints, and a bare Center would grow to
          // the full screen height and cover the form behind it.
          child: Align(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Breakpoints.tabletFormMaxWidth,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppOutlinedButton(
                      label: 'Cancel',
                      onPressed: onCancel,
                    ),
                  ),
                  AppSpacing.hGapMd,
                  // Wider than Cancel: this is the action the screen exists for.
                  // No icon — the footer is unambiguous, and dropping it leaves
                  // the label room to render in full on a narrow phone.
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: 'Create Class',
                      onPressed: onSubmit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
