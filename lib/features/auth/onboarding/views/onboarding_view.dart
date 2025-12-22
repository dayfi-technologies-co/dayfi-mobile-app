import 'dart:async';
import 'dart:io';
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
import '../models/onboarding_data.dart';
import '../vm/onboarding_viewmodel.dart';
import 'onboarding_page_widget.dart';

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  late PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
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

  void _restartAutoScroll() {
    _autoScrollTimer?.cancel();
    _startAutoScroll();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingViewModelProvider);
    final onboardingViewModel = ref.read(onboardingViewModelProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (onboardingState.isSuccess) {
        if (onboardingState.action == 'login') {
          appRouter.pushNamed(AppRoute.createPasscodeView);
        } else {
          appRouter.pushNamed(AppRoute.successSignupView);
        }
        // Optionally, clear the success state after navigation
        ref.read(onboardingViewModelProvider.notifier).goToPage(0);
      } else if (onboardingState.message != null &&
          onboardingState.message!.isNotEmpty &&
          !onboardingState.isSuccess &&
          !onboardingState.isLoading) {
        // Only show error if not loading (i.e., not on field change)
        // log(onboardingState.message!); // Removed for production
        TopSnackbar.show(
          context,
          message: onboardingState.message!,
          isError: true,
        );
        // Clear the error message after showing it once
        ref.read(onboardingViewModelProvider.notifier).clearMessage();
      }
    });

    // final currentPage = onboardingState.page;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SizedBox(
          // height: 400,
          child: Stack(
            children: [
              Opacity(
                opacity: .2,
                child: Image.asset(
                  'assets/images/backgrouddd.png',
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            /// TITLE
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width > 600
                                      ? 600
                                      : MediaQuery.of(context).size.width,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 88),
                                  SizedBox(
                                    height: 400,
                                    child: PageView.builder(
                                      controller: _pageController,
                                      itemCount: OnboardingData.pages.length,
                                      onPageChanged: (index) {
                                        setState(() {
                                          _currentPageIndex = index;
                                        });
                                        ref
                                            .read(
                                              onboardingViewModelProvider
                                                  .notifier,
                                            )
                                            .goToPage(index);
                                        _restartAutoScroll();
                                      },
                                      itemBuilder: (context, index) {
                                        return OnboardingPageWidget(
                                          page: OnboardingData.pages[index],
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      OnboardingData.pages.length,
                                      (index) => AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        width:
                                            _currentPageIndex == index ? 6 : 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color:
                                              _currentPageIndex == index
                                                  ? AppColors.purple400
                                                  : AppColors.purple400
                                                      .withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // const SizedBox(height: 40),

                                  // Image.asset(
                                  //   'assets/images/logo_splash.png',
                                  //   height: 24,
                                  // ),

                                  // const SizedBox(height: 24),

                                  // Text(
                                  //       "Real-time payments for Africa",
                                  //       textAlign: TextAlign.center,
                                  //       style: Theme.of(
                                  //         context,
                                  //       ).textTheme.displayLarge?.copyWith(
                                  //         color:
                                  //             Theme.of(
                                  //               context,
                                  //             ).textTheme.headlineLarge?.color,
                                  //         fontSize:
                                  //             MediaQuery.of(context).size.width >
                                  //                     600
                                  //                 ? 72
                                  //                 : 48,
                                  //         letterSpacing:-.250,
                                  //         fontWeight: FontWeight.w800,
                                  //         // fontWeight: FontWeight.w100,
                                  //         fontFamily: 'Chirp',
                                  //         // letterspacing: 0,
                                  //         height: 1,
                                  //       ),
                                  //     )
                                  //     .animate()
                                  //     .fadeIn(duration: 600.ms)
                                  //     .slideY(
                                  //       begin: 0.25,
                                  //       end: 0,
                                  //       duration: 600.ms,
                                  //     )
                                  //     .then()
                                  //     .shimmer(
                                  //       duration: 1800.ms,
                                  //       color: Theme.of(context)
                                  //           .scaffoldBackgroundColor
                                  //           .withOpacity(0.4),
                                  //       angle: 20,
                                  //     ),

                                  // const SizedBox(height: 24),

                                  // /// SUBTITLE
                                  // SizedBox(
                                  //   width: 300,
                                  //   child: Text(
                                  //         "Pay people, send salaries, and settle across borders instantly",
                                  //         textAlign: TextAlign.center,
                                  //         style: Theme.of(
                                  //           context,
                                  //         ).textTheme.bodyMedium?.copyWith(
                                  //           letterSpacing: -.25,
                                  //           color: Theme.of(context)
                                  //               .textTheme
                                  //               .headlineLarge
                                  //               ?.color!
                                  //               .withOpacity(0.85),
                                  //           fontSize: 18,
                                  //           fontWeight: FontWeight.w400,
                                  //           height: 1.2,
                                  //         ),
                                  //       )
                                  //       .animate()
                                  //       .fadeIn(delay: 150.ms, duration: 600.ms)
                                  //       .slideY(
                                  //         begin: 0.2,
                                  //         end: 0,
                                  //         duration: 600.ms,
                                  //       ),
                                  // ),
                                  // const SizedBox(height: 40),
                                ],
                              ),
                            ),

                            if (MediaQuery.of(context).size.width <= 600)
                              Spacer(),

                            if (MediaQuery.of(context).size.width > 600)
                              const SizedBox(height: 40),

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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Show Apple sign-in button only on iOS or macOS
                                      if (Platform.isIOS || Platform.isMacOS)
                                        Column(
                                          children: [
                                            SecondaryButton(
                                                  text: 'Continue with Apple',
                                                  onPressed:
                                                      onboardingState
                                                              .isLoading
                                                          ? null
                                                          : () {},
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
                                                             letterSpacing: -.4,
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
                                                mainAxisSize: MainAxisSize.max,
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
                                                    textAlign: TextAlign.center,
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
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headlineLarge
                                                    ?.color!
                                                    .withOpacity(0.85),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
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
                                            text: 'Continue with Email Address',
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
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall?.copyWith(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'Chirp',
                                                  // letterspacing: 0,
                                                  height: 1,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(.85),
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: 'Terms of Use',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              Theme.of(context)
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
                                                          color: Theme.of(
                                                                context,
                                                              )
                                                              .colorScheme
                                                              .onSurface
                                                              .withOpacity(.85),
                                                        ),
                                                  ),
                                                  TextSpan(
                                                    text: 'Privacy Notice',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              Theme.of(context)
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
                                                          color: Theme.of(
                                                                context,
                                                              )
                                                              .colorScheme
                                                              .onSurface
                                                              .withOpacity(.85),
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
                                              color:
                                                  AppColors.purple500ForTheme(
                                                    context,
                                                  ).withOpacity(0.1),
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
