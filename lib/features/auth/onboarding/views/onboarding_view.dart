import 'dart:async';
import 'dart:developer';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/widgets.dart';
import 'package:dayfi/core/theme/app_typography.dart';
// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/app_locator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import '../models/onboarding_data.dart';
import '../vm/onboarding_viewmodel.dart';
// import 'onboarding_page_widget.dart';

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView>
    with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<Offset> _slideOffset;
  Timer? _autoScrollTimer;
  int _currentPageIndex = 0;
  bool _videoInitialized = false;

  /// True once the decoder has advanced past black frames; poster fades away.
  bool _videoPainted = false;

  void _onVideoUpdate() {
    if (_videoPainted || !mounted) return;
    final c = _videoController;
    if (c == null) return;
    final v = c.value;
    // Do not require isPlaying — opaque-0 VideoPlayer can fail to decode on some devices.
    if (!v.isInitialized || v.hasError) return;
    if (v.position > const Duration(milliseconds: 120)) {
      setState(() => _videoPainted = true);
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // iOS: AVFoundation Pigeon channel is not ready in initState; wait until after
    // the first frame(s) before touching the native video player.
    _scheduleSplashVideo();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideOffset = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();

    _startAutoScroll();
  }

  void _scheduleSplashVideo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(_loadSplashVideo());
      });
    });
  }

  Future<void> _loadSplashVideo() async {
    if (!mounted) return;
    VideoPlayerController? c;
    try {
      c = VideoPlayerController.asset('assets/vid/splash_vid.mp4');
      _videoController = c;
      c.addListener(_onVideoUpdate);
      await c.initialize();
      if (!mounted) {
        c.removeListener(_onVideoUpdate);
        await c.dispose();
        _videoController = null;
        return;
      }
      c.setLooping(true);
      await c.setVolume(0);
      await c.play();
      if (!mounted) return;
      setState(() => _videoInitialized = true);
      Future<void>.delayed(const Duration(milliseconds: 1800), () {
        if (!mounted || _videoPainted) return;
        final vc = _videoController;
        if (vc != null && vc.value.isInitialized && !vc.value.hasError) {
          setState(() => _videoPainted = true);
        }
      });
    } catch (e, st) {
      log('Onboarding splash video failed: $e', stackTrace: st);
      try {
        c?.removeListener(_onVideoUpdate);
      } catch (_) {}
      try {
        await c?.dispose();
      } catch (_) {}
      if (mounted) {
        setState(() {
          _videoController = null;
          _videoInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoUpdate);
    _videoController?.dispose();
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPageIndex < OnboardingData.pages.length - 1) {
        _currentPageIndex++;
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPageIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
        ref
            .read(onboardingViewModelProvider.notifier)
            .goToPage(_currentPageIndex);
      } else {
        // Stop the timer when we reach the last page
        timer.cancel();
      }
    });
  }

  /// After Apple/Google sign-in, [Navigator] can still be locked when the OS
  /// sheet dismisses. Defer push until after the frame + a microtask.
  void _scheduleSocialAuthNavigation(String? action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Future.microtask(() async {
        if (!mounted) return;
        try {
          if (action == 'login') {
            await appRouter.pushNamed(AppRoute.createPasscodeView);
          } else {
            await appRouter.pushNamed(AppRoute.successSignupView);
          }
        } finally {
          if (mounted) {
            ref
                .read(onboardingViewModelProvider.notifier)
                .consumeAuthSuccess();
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingViewModelProvider);
    final onboardingViewModel = ref.read(onboardingViewModelProvider.notifier);

    // Do not use addPostFrameCallback inside build (runs every frame and can
    // call pushNamed while Navigator is locked after Apple/Google sheets).
    ref.listen<OnboardingState>(onboardingViewModelProvider, (prev, next) {
      if (next.isSuccess) {
        if (prev?.isSuccess == true) return;
        _scheduleSocialAuthNavigation(next.action);
        return;
      }
      final msg = next.message;
      if (msg == null || msg.isEmpty || next.isLoading) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.microtask(() {
          if (!context.mounted) return;
          log(msg);
          TopSnackbar.show(context, message: msg, isError: true);
          ref.read(onboardingViewModelProvider.notifier).clearMessage();
        });
      });
    });

    // final currentPage = onboardingState.page;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SizedBox(
          child: Stack(
            children: [
              // ── Poster + video (web-style: poster visible until video has real frames) ──
              Positioned.fill(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Video must stay visible to the compositor so decoding advances; poster fades out on top.
                    if (_videoInitialized)
                      Builder(
                        builder: (context) {
                          final vc = _videoController;
                          if (vc == null) return const SizedBox.shrink();
                          return FittedBox(
                            fit: BoxFit.cover,
                            clipBehavior: Clip.hardEdge,
                            child: SizedBox(
                              width:
                                  vc.value.size.width > 0
                                      ? vc.value.size.width
                                      : 1920,
                              height:
                                  vc.value.size.height > 0
                                      ? vc.value.size.height
                                      : 1080,
                              child: VideoPlayer(vc),
                            ),
                          );
                        },
                      ),
                    AnimatedOpacity(
                      opacity: _videoPainted ? 0 : 1,
                      duration: const Duration(milliseconds: 360),
                      curve: Curves.easeOut,
                      child: Image.asset(
                        "assets/icons/pngs/onboarding_splash_poster.jpg",
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder:
                            (_, __, ___) => Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF0D0D1A),
                                    Color(0xFF1A0533),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              // // ── Dark Overlay ──────────────────────────────────────────────────
              Positioned.fill(
                child: FadeTransition(
                  opacity: _fadeController,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 64,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    'assets/images/logo_splash.png',
                    height: 48,
                  ),
                ),
              ),

              TypewriterText(),

              SlideTransition(
                position: _slideOffset,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: SizedBox(
                        height: constraints.maxHeight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Spacer(),
                              Center(
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width <= 600
                                          ? 350
                                          : 400,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Show Apple sign-in button only on iOS or macOS
                                        if (!kIsWeb &&
                                            (defaultTargetPlatform ==
                                                    TargetPlatform.iOS ||
                                                defaultTargetPlatform ==
                                                    TargetPlatform.macOS))
                                          Column(
                                            children: [
                                              SecondaryButton(
                                                    text: 'Continue with Apple',
                                                    onPressed:
                                                        onboardingState
                                                                .isLoading
                                                            ? null
                                                            : () {
                                                              onboardingViewModel
                                                                  .signInWithApple();
                                                            },
                                                    backgroundColor:
                                                        Colors.black,
                                                    textColor: Colors.white,
                                                    borderColor: Theme.of(
                                                          context,
                                                        )
                                                        .textTheme
                                                        .headlineLarge
                                                        ?.color!
                                                        .withOpacity(.12),
                                                    borderWidth: 2,
                                                    borderRadius: 50,
                                                    fontFamily: 'Chirp',
                                                    fullWidth: true,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 16,
                                                          ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          SvgPicture.asset(
                                                            'assets/icons/svgs/Apple_logo_black.svg',
                                                            color: Colors.white,
                                                            height: 20,
                                                          ),
                                                          const SizedBox(
                                                            width: 12,
                                                          ),
                                                          const Text(
                                                            'Continue with Apple',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,

                                                              fontSize: 16,
                                                              fontFamily:
                                                                  AppTypography
                                                                      .secondaryFontFamily,
                                                              fontWeight:
                                                                  AppTypography
                                                                      .bold,
                                                              height: 1,
                                                              letterSpacing:
                                                                  -.4,
                                                            ),
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                  .animate()
                                                  .fadeIn(
                                                    delay: 200.ms,
                                                    duration: 600.ms,
                                                  )
                                                  .slideY(
                                                    begin: 0.3,
                                                    end: 0,
                                                    delay: 200.ms,
                                                    duration: 600.ms,
                                                  )
                                                  .shimmer(
                                                    delay: 1000.ms,
                                                    duration: 1500.ms,
                                                    color: Theme.of(context)
                                                        .scaffoldBackgroundColor
                                                        .withOpacity(0.4),
                                                    angle: 45,
                                                  ),
                                              SizedBox(height: 8),
                                            ],
                                          ),

                                        // Continue with Google
                                        SecondaryButton(
                                              text: 'Continue with Google',
                                              onPressed:
                                                  onboardingState.isLoading
                                                      ? null
                                                      : () {
                                                        onboardingViewModel
                                                            .signInAndGetGoogleToken();
                                                      },
                                              backgroundColor: Colors.white,
                                              textColor: Colors.black87,
                                              borderColor: Theme.of(context)
                                                  .textTheme
                                                  .headlineLarge
                                                  ?.color!
                                                  .withOpacity(.1),
                                              borderWidth: 2,
                                              borderRadius: 50,
                                              fontFamily: 'Chirp',
                                              fullWidth: true,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                    ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      "assets/images/google_logo.png",
                                                      height: 18,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    const Text(
                                                      'Continue with Google',
                                                      style: TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 16,
                                                        fontFamily:
                                                            AppTypography
                                                                .secondaryFontFamily,
                                                        fontWeight:
                                                            AppTypography.bold,
                                                        height: 1,
                                                        letterSpacing: -.4,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .animate()
                                            .fadeIn(
                                              delay: 350.ms,
                                              duration: 600.ms,
                                            )
                                            .slideY(
                                              begin: 0.3,
                                              end: 0,
                                              delay: 350.ms,
                                              duration: 600.ms,
                                            )
                                            .shimmer(
                                              delay: 1200.ms,
                                              duration: 1500.ms,
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor
                                                  .withOpacity(0.4),
                                              angle: 45,
                                            ),

                                        SizedBox(height: 8),

                                        Row(
                                          children: [
                                            const Expanded(
                                              child: Opacity(
                                                opacity: .25,
                                                child: Divider(),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 4,
                                              ),
                                              child: Text(
                                                'OR',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                               color: Colors.white.withValues(alpha: 0.85),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      height: 1.2,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Expanded(
                                              child: Opacity(
                                                opacity: .25,
                                                child: Divider(),
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 8),

                                        // Continue with Email
                                        PrimaryButton(
                                              text:
                                                  'Continue with Email Address',
                                              onPressed:
                                                  onboardingState.isLoading
                                                      ? null
                                                      : _navigateToCheckEmail,
                                              backgroundColor:
                                                  AppColors.purple500ForTheme(
                                                    context,
                                                  ),
                                              textColor: Colors.white,
                                              letterSpacing: -.4,
                                              borderColor:
                                                  AppColors.purple500ForTheme(
                                                    context,
                                                  ),
                                              fontFamily: 'Chirp',
                                              borderRadius: 50,
                                              fullWidth: true,
                                            )
                                            .animate()
                                            .fadeIn(
                                              delay: 200.ms,
                                              duration: 600.ms,
                                            )
                                            .slideY(
                                              begin: 0.3,
                                              end: 0,
                                              delay: 200.ms,
                                              duration: 600.ms,
                                            )
                                            .shimmer(
                                              delay: 1000.ms,
                                              duration: 1500.ms,
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor
                                                  .withOpacity(0.4),
                                              angle: 45,
                                            ),

                                        SizedBox(height: 18),

                                        // Optional: Sign In link
                                        SizedBox(
                                          width: 300,
                                          child: Text.rich(
                                                textAlign: TextAlign.center,
                                                TextSpan(
                                                  text:
                                                      'I confirm that I agree to the ',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        fontSize: 12.5,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily: 'Chirp',
                                                        // letterspacing: 0,
                                                        height: 1,
                                                        color: Colors.white
                                                            .withValues(
                                                              alpha: 0.85,
                                                            ),
                                                      ),
                                                  children: [
                                                    TextSpan(
                                                      text: 'Terms of Use',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .primary,
                                                            fontSize: 12.5,
                                                            // letterspacing: 0,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily: 'Chirp',
                                                            height: 1,
                                                          ),
                                                      recognizer:
                                                          TapGestureRecognizer()
                                                            ..onTap = () {
                                                              appRouter.pushNamed(
                                                                AppRoute
                                                                    .termsOfUseView,
                                                              );
                                                            },
                                                    ),
                                                    TextSpan(
                                                      text: ' and the ',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            fontSize: 12.5,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily: 'Chirp',
                                                            // letterspacing: 0,
                                                            height: 1,
                                                            color: Colors.white
                                                                .withValues(
                                                                  alpha: 0.85,
                                                                ),
                                                          ),
                                                    ),
                                                    TextSpan(
                                                      text: 'Privacy Notice',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .primary,
                                                            fontSize: 12.5,
                                                            // letterspacing: 0,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily: 'Chirp',
                                                            height: 1,
                                                          ),
                                                      recognizer:
                                                          TapGestureRecognizer()
                                                            ..onTap = () {
                                                              appRouter.pushNamed(
                                                                AppRoute
                                                                    .privacyNoticeView,
                                                              );
                                                            },
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          ' for more information about how we collect and process your personal data.',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            fontSize: 12.5,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily: 'Chirp',
                                                            // letterspacing: 0,
                                                            height: 1,
                                                            color: Colors.white
                                                                .withValues(
                                                                  alpha: 0.85,
                                                                ),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                              .animate()
                                              .fadeIn(
                                                delay: 700.ms,
                                                duration: 300.ms,
                                                curve: Curves.easeOutCubic,
                                              )
                                              .slideY(
                                                begin: 0.2,
                                                end: 0,
                                                delay: 700.ms,
                                                duration: 300.ms,
                                                curve: Curves.easeOutCubic,
                                              )
                                              .scale(
                                                begin: const Offset(0.98, 0.98),
                                                end: const Offset(1.0, 1.0),
                                                delay: 700.ms,
                                                duration: 300.ms,
                                                curve: Curves.easeOutCubic,
                                              )
                                              .shimmer(
                                                delay: 900.ms,
                                                duration: 800.ms,
                                                color: Colors.white.withValues(
                                                  alpha: 0.85,
                                                ),
                                                angle: 15,
                                              ),
                                        ),
                                      ],
                                    ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.2, end: 0, delay: 300.ms, duration: 500.ms),
                                  ),
                                ),
                              ),

                              SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ...existing code...
              if (onboardingState.isLoading)
                Opacity(
                  opacity: 0.5,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black,
                    // child: const Center(
                    //   child: CupertinoActivityIndicator(color: Colors.white),
                    // ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCheckEmail() {
    appRouter.pushNamed(AppRoute.checkEmailView, arguments: true);
  }
}

class TypewriterText extends StatefulWidget {
  const TypewriterText({super.key});

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  final String _fullText = 'Send\nmoney\nin a\nheartbeat';

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32.0, 0, 32.0, 102.0),
        child: Text(
          _fullText,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 72,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.85),
            height: 1,
            fontFamily: 'FunnelDisplay',
            letterSpacing: -1.8,
          ),
        ),
      ),
    );
  }
}
