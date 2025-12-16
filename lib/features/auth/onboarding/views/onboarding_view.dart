import 'dart:async';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/widgets.dart';
// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/app_locator.dart';
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
        _pageController.animateToPage(
          _currentPageIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

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

    final currentPage = onboardingState.page;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Opacity(
            opacity: .3,
            child: Image.asset(
              'assets/images/backgrouddd.png',
              fit: BoxFit.cover,
              // color: Colors.black12,
              height: double.infinity,
              width: double.infinity,
            ),
          ),
          SafeArea(
            bottom: false,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  // Page indicators - fixed at top
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                            padding: EdgeInsets.only(
                              top: 24.h,
                              left: 18.w,
                              right: 18.w,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                OnboardingData.pages.length,
                                (index) => AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                      margin: EdgeInsets.only(right: 4.w),
                                      width: index == currentPage ? 24.w : 6.w,
                                      height: 6.w,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        color:
                                            index == currentPage
                                                ? Theme.of(context).colorScheme.shadow.withOpacity(.8)
                                                : Theme.of(context).colorScheme.shadow.withOpacity(.15),
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(
                                      delay: Duration(
                                        milliseconds: 100 * index,
                                      ),
                                    )
                                    .scale(
                                      begin: const Offset(0.8, 0.8),
                                      end: const Offset(1.0, 1.0),
                                      delay: Duration(
                                        milliseconds: 100 * index,
                                      ),
                                      duration: 300.ms,
                                      curve: Curves.elasticOut,
                                    ),
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: -0.2, end: 0, duration: 500.ms),

                      // PageView
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            _currentPageIndex = index;
                            onboardingViewModel.goToPage(index);

                            // If user manually scrolls to the last page, cancel the auto-scroll timer
                            if (index == OnboardingData.pages.length - 1) {
                              _autoScrollTimer?.cancel();
                            } else if (index <
                                OnboardingData.pages.length - 1) {
                              // If user goes back to an earlier page, restart auto-scroll
                              _restartAutoScroll();
                            }
                          },
                          itemCount: OnboardingData.pages.length,
                          itemBuilder: (context, index) {
                            return OnboardingPageWidget(
                              page: OnboardingData.pages[index],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  // Bottom buttons
                  Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: EdgeInsets.all(18.w),
                          child: Column(
                            children: [
                              // Continue with Email
                              PrimaryButton(
                                    text: 'Continue with email address',
                                    onPressed:
                                        onboardingState.isLoading
                                            ? null
                                            : _navigateToCheckEmail,
                                    backgroundColor:
                                        AppColors.purple500ForTheme(context),
                                    textColor: Colors.white,
                                    borderColor: AppColors.purple500ForTheme(
                                      context,
                                    ),
                                    fontFamily: 'Karla',
                                    letterSpacing: -.70,
                                    fontSize: 18,
                                    width: 375.w,
                                    height: 48.00000.h,
                                    borderRadius: 38,
                                    fullWidth: true,
                                  )
                                  .animate()
                                  .fadeIn(delay: 200.ms, duration: 600.ms)
                                  .slideY(
                                    begin: 0.3,
                                    end: 0,
                                    delay: 200.ms,
                                    duration: 600.ms,
                                  )
                                  .shimmer(
                                    delay: 1000.ms,
                                    duration: 1500.ms,
                                    color: Theme.of(
                                      context,
                                    ).scaffoldBackgroundColor.withOpacity(0.4),
                                    angle: 45,
                                  ),

                              SizedBox(height: 12.h),

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
                                        .withOpacity(.15),
                                    borderWidth: 2.w,
                                    borderRadius: 38,
                                    letterSpacing: -.70,
                                    fontSize: 18,
                                    fontFamily: 'Karla',
                                    height: 48.00000.h,
                                    fullWidth: true,
                                    child: Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icons/svgs/google-black-icon.svg",
                                              height: 18.h,
                                              color: Colors.black87,
                                            ),
                                            Expanded(
                                              child: Text(
                                                'Continue with Google',
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 18,
                                                  fontFamily: "Karla",
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.78,
                                                  letterSpacing: -1,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Opacity(
                                              opacity: 0,
                                              child: SvgPicture.asset(
                                                "assets/icons/svgs/google-black-icon.svg",
                                                height: 18.h,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(delay: 350.ms, duration: 600.ms)
                                  .slideY(
                                    begin: 0.3,
                                    end: 0,
                                    delay: 350.ms,
                                    duration: 600.ms,
                                  )
                                  .shimmer(
                                    delay: 1200.ms,
                                    duration: 1500.ms,
                                    color: Theme.of(
                                      context,
                                    ).scaffoldBackgroundColor.withOpacity(0.4),
                                    angle: 45,
                                  ),

                              SizedBox(height: 18.h),

                              // Optional: Sign In link
                              // Text.rich(
                              //       textAlign: TextAlign.center,
                              //       TextSpan(
                              //         text: 'I confirm that I agree to the ',
                              //         style: Theme.of(
                              //           context,
                              //         ).textTheme.bodySmall?.copyWith(
                              //           fontSize: 13.sp,
                              //           fontWeight: FontWeight.w500,
                              //           fontFamily: 'Karla',
                              //           letterSpacing: -.6,
                              //           height: 1.4,
                              //           color:
                              //               Theme.of(
                              //                 context,
                              //               ).colorScheme.onSurface,
                              //         ),
                              //         children: [
                              //           TextSpan(
                              //             text: 'Terms of Use',
                              //             style: Theme.of(
                              //               context,
                              //             ).textTheme.bodySmall?.copyWith(
                              //               color:
                              //                   Theme.of(
                              //                     context,
                              //                   ).colorScheme.primary,
                              //               fontSize: 13.sp,
                              //               letterSpacing: -.6,
                              //               fontWeight: FontWeight.w600,
                              //               fontFamily: 'Karla',
                              //               height: 1.4,
                              //             ),
                              //             recognizer:
                              //                 TapGestureRecognizer()
                              //                   ..onTap = () {
                              //                     Navigator.push(
                              //                       context,
                              //                       MaterialPageRoute(
                              //                         builder:
                              //                             (context) =>
                              //                                 const TermsOfUseView(),
                              //                       ),
                              //                     );
                              //                   },
                              //           ),
                              //           TextSpan(
                              //             text: ' and the ',
                              //             style: Theme.of(
                              //               context,
                              //             ).textTheme.bodySmall?.copyWith(
                              //               fontSize: 13.sp,
                              //               fontWeight: FontWeight.w500,
                              //               fontFamily: 'Karla',
                              //               letterSpacing: -.6,
                              //               height: 1.4,
                              //               color:
                              //                   Theme.of(
                              //                     context,
                              //                   ).colorScheme.onSurface,
                              //             ),
                              //           ),
                              //           TextSpan(
                              //             text: 'Privacy Notice',
                              //             style: Theme.of(
                              //               context,
                              //             ).textTheme.bodySmall?.copyWith(
                              //               color:
                              //                   Theme.of(
                              //                     context,
                              //                   ).colorScheme.primary,
                              //               fontSize: 13.sp,
                              //               letterSpacing: -.6,
                              //               fontWeight: FontWeight.w600,
                              //               fontFamily: 'Karla',
                              //               height: 1.4,
                              //             ),
                              //             recognizer:
                              //                 TapGestureRecognizer()
                              //                   ..onTap = () {
                              //                     Navigator.push(
                              //                       context,
                              //                       MaterialPageRoute(
                              //                         builder:
                              //                             (context) =>
                              //                                 const PrivacyNoticeView(),
                              //                       ),
                              //                     );
                              //                   },
                              //           ),
                              //           TextSpan(
                              //             text:
                              //                 ' for more information about how we collect and process your personal data.',
                              //             style: Theme.of(
                              //               context,
                              //             ).textTheme.bodySmall?.copyWith(
                              //               fontSize: 13.sp,
                              //               fontWeight: FontWeight.w500,
                              //               fontFamily: 'Karla',
                              //               letterSpacing: -.6,
                              //               height: 1.4,
                              //               color:
                              //                   Theme.of(
                              //                     context,
                              //                   ).colorScheme.onSurface,
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //     )
                              //     .animate()
                              //     .fadeIn(
                              //       delay: 700.ms,
                              //       duration: 300.ms,
                              //       curve: Curves.easeOutCubic,
                              //     )
                              //     .slideY(
                              //       begin: 0.2,
                              //       end: 0,
                              //       delay: 700.ms,
                              //       duration: 300.ms,
                              //       curve: Curves.easeOutCubic,
                              //     )
                              //     .scale(
                              //       begin: const Offset(0.98, 0.98),
                              //       end: const Offset(1.0, 1.0),
                              //       delay: 700.ms,
                              //       duration: 300.ms,
                              //       curve: Curves.easeOutCubic,
                              //     )
                              //     .shimmer(
                              //       delay: 900.ms,
                              //       duration: 800.ms,
                              //       color: AppColors.purple500ForTheme(
                              //         context,
                              //       ).withOpacity(0.1),
                              //       angle: 15,
                              //     ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 500.ms)
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        delay: 300.ms,
                        duration: 500.ms,
                      ),
                ],
              ),
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
    );
  }

  void _navigateToCheckEmail() {
    appRouter.pushNamed(AppRoute.checkEmailView, arguments: true);
  }
}
