import 'package:Shikshak/app/router/route_paths.dart';
import 'package:Shikshak/core/constants/app_constants.dart';
import 'package:Shikshak/core/constants/app_images_const.dart';
import 'package:Shikshak/features/splash/presentation/widgets/section_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/state/auth_state.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _indicatorFade;
  late final Animation<Offset> _rightIndicatorSlide;
  late final Animation<Offset> _leftIndicatorSlide;
  late final Animation<double> _bottomTextFade;
  late final Animation<Offset> _bottomTextSlide;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.45, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.55, curve: Curves.elasticOut),
      ),
    );
    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
          ),
        );
    _indicatorFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 1, curve: Curves.easeOut),
    );
    _rightIndicatorSlide =
        Tween<Offset>(begin: const Offset(3.5, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.55, 1, curve: Curves.easeOutCubic),
          ),
        );
    _leftIndicatorSlide =
        Tween<Offset>(begin: const Offset(-3.5, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.55, 1, curve: Curves.easeOutCubic),
          ),
        );
    _bottomTextFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.65, 1, curve: Curves.easeOut),
    );
    _bottomTextSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.65, 1, curve: Curves.easeOutCubic),
          ),
        );

    _controller.forward();

    // Start the session check once the first frame is up; the ref.listen in
    // build() navigates when the state resolves.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).checkAuthStatus();
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Navigate as soon as the session check completes.
    ref.listen(authNotifierProvider.select((s) => s.status), (previous, next) {
      switch (next) {
        case AuthStatus.authenticated:
          final role =
              ref.read(authNotifierProvider).selectedRole ?? UserRole.student;
          context.go(RoutePaths.dashboardFor(role));
        case AuthStatus.unauthenticated:
          context.go(RoutePaths.login);
        case AuthStatus.checking:
          break;
      }
    });

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // cover, not fill: fill stretches the artwork at tablet aspect ratios.
          Image.asset(AppImagesConst.splashScreen, fit: BoxFit.cover),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: context.responsivePagePadding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      context.isTabletDevice
                          ? AppSpacing.gapXl
                          : const SizedBox.shrink(),
                      FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: AppLogo(
                            image: AppImagesConst.onlyLogoWithoutText,
                            size: context.isTabletDevice ? 144 : 116,
                          ),
                        ),
                      ),

                      //app name
                      FadeTransition(
                        opacity: _textFade,
                        child: SlideTransition(
                          position: _textSlide,
                          child: Column(
                            children: [
                              Text(
                                AppConstants.appName.toUpperCase(),
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontFamily: 'Audiowide',
                                ),
                              ),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        // fontWeight: FontWeight.w800,
                                        height: 1.2,
                                        fontSize: 18,
                                      ),
                                  children: const [
                                    TextSpan(
                                      text: 'Learn. ',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Grow. ',
                                      style: TextStyle(
                                        color: AppColors.success,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Succeed.',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      context.isTabletDevice
                          ? AppSpacing.gapXl
                          : AppSpacing.gapSm,
                      //tagline
                      FadeTransition(
                        opacity: _indicatorFade,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SlideTransition(
                              position: _leftIndicatorSlide,
                              child: const SectionIndicator(),
                            ),
                            AppSpacing.hGapSm,
                            // Flexible: the tagline is multi-line, so it must
                            // shrink rather than overflow the indicator row.
                            Flexible(
                              child: Text(
                                AppConstants.tagline,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFF5B6EF5),
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            AppSpacing.hGapSm,
                            SlideTransition(
                              position: _rightIndicatorSlide,
                              child: const SectionIndicator(reversed: true),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Breakpoints.phonePadding,
                  0,
                  Breakpoints.phonePadding,
                  context.isTabletDevice ? 72 : 50,
                ),
                child: FadeTransition(
                  opacity: _bottomTextFade,
                  child: SlideTransition(
                    position: _bottomTextSlide,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        children: const [
                          TextSpan(text: 'Your journey to '),
                          TextSpan(
                            text: 'knowledge',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(text: ' begins here.'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
