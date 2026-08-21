import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../../../../shared/widgets/empty_state.dart';
import '../../../../../shared/widgets/error_state.dart';
import '../../../../../shared/widgets/section_header.dart';
import '../../domain/entities/teacher_class_slot.dart';
import '../../domain/entities/teacher_details.dart';
import '../providers/single_teacher_providers.dart';
import '../state/single_teacher_state.dart';
import '../widgets/class_slot_option_card.dart';
import '../widgets/message_action_bar.dart';
import '../widgets/teacher_about_section.dart';
import '../widgets/teacher_details_header.dart';

/// One teacher's profile, with their running classes as the thing to act on:
/// pick a class, then message the teacher about it.
class SingleTeacherDetailsPage extends ConsumerStatefulWidget {
  const SingleTeacherDetailsPage({super.key, required this.teacherId});

  final String teacherId;

  @override
  ConsumerState<SingleTeacherDetailsPage> createState() =>
      _SingleTeacherDetailsPageState();
}

class _SingleTeacherDetailsPageState
    extends ConsumerState<SingleTeacherDetailsPage> {
  @override
  void initState() {
    super.initState();
    // Deferred: the notifier writes state, which cannot happen during build.
    Future.microtask(
      () => ref
          .read(singleTeacherNotifierProvider.notifier)
          .load(widget.teacherId),
    );
  }

  Future<void> _refresh() =>
      ref.read(singleTeacherNotifierProvider.notifier).refresh();

  void _toggleClass(TeacherClassSlot slot) =>
      ref.read(singleTeacherNotifierProvider.notifier).toggleClass(slot.id);

  void _toggleSelectAll() =>
      ref.read(singleTeacherNotifierProvider.notifier).toggleSelectAll();

  /// The one place messaging is wired. There is no messaging endpoint yet, so
  /// the student is told plainly instead of being shown a compose screen that
  /// posts nowhere.
  void _messageTeacher(TeacherDetails teacher, List<TeacherClassSlot> classes) {
    final picked = classes.map((slot) => slot.displayTitle).join(', ');

    AppSnackbar.show(
      context,
      'Messaging opens soon — you picked $picked with ${teacher.displayName}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(singleTeacherNotifierProvider);
    final teacher = state.teacher;

    ref.listen(singleTeacherNotifierProvider, (previous, next) {
      final error = next.error;
      // Only when the profile is still on screen — otherwise the body itself
      // carries the error, and a snackbar would say it twice.
      if (error != null && next.teacher != null && previous?.error != error) {
        AppSnackbar.showError(context, error.message);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(teacher?.displayName ?? 'Teacher'),
        centerTitle: false,
      ),
      body: CenteredConstrainedBox(
        // Narrower than the page default: this is a single column of cards,
        // and full tablet width would stretch every one of them.
        maxWidth: 720,
        child: _body(state),
      ),
      bottomNavigationBar: teacher == null
          ? null
          : MessageActionBar(
              selectedClasses: state.selectedClasses,
              onMessage: state.canMessage
                  ? () => _messageTeacher(teacher, state.selectedClasses)
                  : null,
            ),
    );
  }

  Widget _body(SingleTeacherState state) {
    final teacher = state.teacher;

    // First load: nothing to keep on screen, so the spinner owns the body.
    if (teacher == null && state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (teacher == null) {
      return ErrorState(
        message: state.error?.message ?? 'This teacher could not be loaded.',
        onRetry: _refresh,
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: context.responsivePagePadding.copyWith(
          top: AppSpacing.lg,
          bottom: AppSpacing.xxl,
        ),
        children: [
          TeacherDetailsHeader(teacher: teacher),
          if (teacher.hasAbout) ...[
            AppSpacing.gapLg,
            TeacherAboutSection(teacher: teacher),
          ],
          AppSpacing.gapLg,
          SectionHeader(
            title: 'Available Classes',
            // Nothing to select, nothing to offer — the empty state below
            // carries the message on its own.
            actionLabel: state.availableClasses.isEmpty
                ? null
                : (state.isEverythingSelected ? 'Clear all' : 'Select all'),
            onAction: _toggleSelectAll,
          ),
          AppSpacing.gapMd,
          ..._classList(state),
        ],
      ),
    );
  }

  List<Widget> _classList(SingleTeacherState state) {
    final classes = state.availableClasses;

    if (classes.isEmpty) {
      return const [
        EmptyState(
          icon: AppIcons.schedule,
          title: 'No classes yet',
          message:
              'This teacher has not published a class schedule. '
              'Check back soon.',
        ),
      ];
    }

    return [
      for (final (index, slot) in classes.indexed) ...[
        if (index > 0) AppSpacing.gapMd,
        ClassSlotOptionCard(
          slot: slot,
          isSelected: state.isSelected(slot.id),
          onToggled: () => _toggleClass(slot),
        ),
      ],
    ];
  }
}
