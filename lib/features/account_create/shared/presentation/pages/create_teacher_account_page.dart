import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/route_paths.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../../../../shared/widgets/gradient_background.dart';
import '../../../about_you/presentation/pages/about_you_step.dart';
import '../../../basic_info/presentation/pages/basic_info_step.dart';
import '../../../documents/presentation/pages/documents_step.dart';
import '../../../education/presentation/pages/education_step.dart';
import '../../../experience/presentation/pages/experience_step.dart';
import '../../domain/entities/profile_step.dart';
import '../providers/account_create_providers.dart';
import '../widgets/step_timeline.dart';
import '../widgets/wizard_action_bar.dart';

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
  Future<void> _handleBack() async {
    final notifier = ref.read(accountCreateNotifierProvider.notifier);
    final step = ref.read(accountCreateNotifierProvider).step;

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
    print('build');
    final step = ref.watch(
      accountCreateNotifierProvider.select((state) => state.step),
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

    final maxWidth = context.isTabletDevice
        ? Breakpoints.tabletFormMaxWidth
        : Breakpoints.formMaxWidth;

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
    required this.onBack,
  });

  final ProfileStep step;
  final double maxWidth;
  final bool isVisible;
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
      continueButtonOnpressed: ref.read(wizardStepControllerProvider).submit,
    );
  }
}
