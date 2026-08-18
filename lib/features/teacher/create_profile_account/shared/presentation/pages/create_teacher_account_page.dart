import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../app/router/route_paths.dart';
import '../../../../../../core/responsive/responsive.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../shared/widgets/app_button.dart';
import '../../../../../../shared/widgets/app_snackbar.dart';
import '../../../../../../shared/widgets/gradient_background.dart';
import '../../../about_you/presentation/pages/about_you_step.dart';
import '../../../basic_info/presentation/pages/basic_info_step.dart';
import '../../../documents/presentation/pages/documents_step.dart';
import '../../../education/presentation/pages/education_step.dart';
import '../../../experience/presentation/pages/experience_step.dart';
import '../../domain/entities/profile_step.dart';
import '../../domain/entities/wizard_mode.dart';
import '../providers/account_create_providers.dart';
import '../widgets/step_timeline.dart';
import '../widgets/wizard_action_bar.dart';

/// The five-step onboarding wizard, and — when [AccountCreateState.mode] is
/// [WizardMode.edit] — the single-step editor the profile screen opens for one
/// section.
///
/// Which section, and which mode, come from [accountCreateNotifierProvider].
/// The edit route overrides that provider in a nested `ProviderScope`, so the
/// very first build is already on the right step: seeding it afterwards would
/// mount the default step just long enough to start a request, then dispose it
/// mid-flight.
class CreateTeacherAccountPage extends ConsumerStatefulWidget {
  const CreateTeacherAccountPage({super.key});

  @override
  ConsumerState<CreateTeacherAccountPage> createState() =>
      _CreateTeacherAccountPageState();
}

class _CreateTeacherAccountPageState
    extends ConsumerState<CreateTeacherAccountPage> {
  final _scrollController = ScrollController();

  final _actionsVisible = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _scrollController.dispose();
    _actionsVisible.dispose();
    super.dispose();
  }

  Widget _stepView(ProfileStep step) => switch (step) {
    ProfileStep.basicInfo => const BasicInfoStep(),
    ProfileStep.aboutYou => const AboutYouStep(),
    ProfileStep.experience => const ExperienceStep(),
    ProfileStep.education => const EducationStep(),
    ProfileStep.documents => const DocumentsStep(),
  };

  bool _onScroll(UserScrollNotification notification) {
    if (notification.depth != 0) return false;

    _actionsVisible.value = switch (notification.direction) {
      ScrollDirection.reverse => false,
      ScrollDirection.forward => true,
      ScrollDirection.idle => _actionsVisible.value,
    };
    return false;
  }

  /// Back means "previous step" everywhere except the first, where it means
  /// leaving the wizard — which throws away the draft, so it asks first.
  ///
  /// Editing has neither: one section, and nothing unsaved worth warning about
  /// beyond the field currently being typed into.
  Future<void> _handleBack() async {
    final notifier = ref.read(accountCreateNotifierProvider.notifier);
    final state = ref.read(accountCreateNotifierProvider);
    final step = state.step;

    if (state.isEditing) {
      Navigator.of(context).pop();
      return;
    }

    if (!step.isFirst) {
      notifier.previous();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave profile setup?'),
        content: const Text(
          'Your progress will be lost and you will need to start again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep editing'),
          ),
          AppButton(
            label: 'Leave',
            expanded: false,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(
      accountCreateNotifierProvider.select((state) => state.step),
    );
    final isEditing = ref.watch(
      accountCreateNotifierProvider.select((state) => state.isEditing),
    );

    ref.listen(accountCreateNotifierProvider.select((state) => state.step), (
      previous,
      next,
    ) {
      if (previous == next) return;
      _actionsVisible.value = true;
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    });

    // Save failures surface here rather than in all five steps.
    ref.listen(accountCreateNotifierProvider.select((state) => state.error), (
      previous,
      next,
    ) {
      if (next == null || next == previous) return;
      AppSnackbar.showError(context, next.message);
    });

    // The final section landed — the profile is live.
    ref.listen(
      accountCreateNotifierProvider.select((state) => state.isComplete),
      (previous, next) {
        if (!next || previous == next) return;
        context.go(RoutePaths.teacherDashboard);
      },
    );

    // An edit saved — hand control back to the profile screen, which refreshes.
    ref.listen(
      accountCreateNotifierProvider.select((state) => state.isEditSaved),
      (previous, next) {
        if (!next || previous == next) return;
        Navigator.of(context).pop(true);
      },
    );

    final maxWidth = context.responsiveFormMaxWidth;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        body: GradientBackground(
          child: SafeArea(
            child: Column(
              children: [
                // Editing is one section — there is no progression to show.
                if (!isEditing)
                  CenteredConstrainedBox(
                    maxWidth: maxWidth,
                    child: Padding(
                      padding: context.responsivePagePadding.copyWith(
                        top: 0,
                        bottom: AppSpacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          RepaintBoundary(
                            child: StepTimeline(
                              current: step,
                              onStepTapped: ref
                                  .read(accountCreateNotifierProvider.notifier)
                                  .goTo,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: Stack(
                    children: [
                      NotificationListener<UserScrollNotification>(
                        onNotification: _onScroll,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          child: CenteredConstrainedBox(
                            maxWidth: maxWidth,
                            child: Padding(
                              padding: context.responsivePagePadding,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 260),
                                    switchInCurve: Curves.easeOut,
                                    switchOutCurve: Curves.easeIn,

                                    layoutBuilder:
                                        (currentChild, previousChildren) =>
                                            Stack(
                                              alignment: Alignment.topCenter,
                                              children: [
                                                ...previousChildren,
                                                ?currentChild,
                                              ],
                                            ),
                                    transitionBuilder: (child, animation) =>
                                        FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0.06, 0),
                                              end: Offset.zero,
                                            ).animate(animation),
                                            child: child,
                                          ),
                                        ),
                                    child: KeyedSubtree(
                                      key: ValueKey(step),
                                      child: _stepView(step),
                                    ),
                                  ),
                                  AppSpacing.gapSm,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: RepaintBoundary(
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _actionsVisible,
                            builder: (context, isVisible, _) => _ActionBar(
                              step: step,
                              maxWidth: maxWidth,
                              isVisible: isVisible,
                              isEditing: isEditing,
                              onBack: _handleBack,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionBar extends ConsumerWidget {
  const _ActionBar({
    required this.step,
    required this.maxWidth,
    required this.isVisible,
    required this.isEditing,
    required this.onBack,
  });

  final ProfileStep step;
  final double maxWidth;
  final bool isVisible;
  final bool isEditing;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubmitting = ref.watch(
      accountCreateNotifierProvider.select((state) => state.isSubmitting),
    );

    return WizardActionBar(
      step: step,
      maxWidth: maxWidth,
      isVisible: isVisible,
      isSubmitting: isSubmitting,
      onBack: onBack,
      // Editing always offers a way out: there is no app bar behind this.
      showBack: isEditing || !step.isFirst,
      backLabel: isEditing ? 'Cancel' : 'Back',
      showForwardIcon: !isEditing,
      primaryLabel: isEditing ? 'Update' : null,
      continueButtonOnpressed: ref.read(wizardStepControllerProvider).submit,
    );
  }
}
