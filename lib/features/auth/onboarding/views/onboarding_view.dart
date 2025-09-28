import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/app_locator.dart';
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
        // Update the viewmodel to reflect the current page
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
    final currentPage = ref.watch(onboardingViewModelProvider);
    final onboardingViewModel = ref.read(onboardingViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFFFD800), // Bright yellow background
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // Page indicators - fixed at top
              Column(
                children: [
                  Padding(
                        padding: EdgeInsets.only(
                          top: 24.h,
                          left: 24.w,
                          right: 24.w,
                        ),
                        child: Row(
                          children: List.generate(
                            OnboardingData.pages.length,
                            (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  margin: EdgeInsets.only(right: 4.w),
                                  width: index == currentPage ? 24.w : 8.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.r),
                                    color:
                                        index == currentPage
                                            ? AppColors.neutral700
                                            : AppColors.neutral300,
                                  ),
                                )
                                .animate()
                                .fadeIn(
                                  delay: Duration(milliseconds: 100 * index),
                                )
                                .scale(
                                  begin: const Offset(0.8, 0.8),
                                  end: const Offset(1.0, 1.0),
                                  delay: Duration(milliseconds: 100 * index),
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
                        } else if (index < OnboardingData.pages.length - 1) {
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
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        children: [
                          // Sign Up button
                          PrimaryButton(
                                text: 'Create account',
                                onPressed: _navigateToSignUp,
                                backgroundColor: AppColors.purple500,
                                textColor: AppColors.neutral0,
                                fontFamily: 'Karla',
                                letterSpacing: -.8,
                                fontSize: 18,
                                width: 375.w,
                                height: 60.h,
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
                                color: Colors.white.withOpacity(0.3),
                                angle: 45,
                              ),

                          SizedBox(height: 12.h),

                          // Sign In button
                          SecondaryButton(
                                text: 'Sign in',
                                onPressed: _navigateToSignIn,
                                backgroundColor: Colors.transparent,
                                textColor: AppColors.purple500,
                                borderColor: AppColors.purple500,
                                borderWidth: 2.w,
                                borderRadius: 38,
                                letterSpacing: -.8,
                                fontFamily: 'Karla',
                                height: 60.h,
                                fullWidth: true,
                              )
                              .animate()
                              .fadeIn(delay: 400.ms, duration: 600.ms)
                              .slideY(
                                begin: 0.3,
                                end: 0,
                                delay: 400.ms,
                                duration: 600.ms,
                              )
                              .shimmer(
                                delay: 1200.ms,
                                duration: 1500.ms,
                                color: AppColors.purple500.withOpacity(0.2),
                                angle: 45,
                              ),
                        ],
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSignUp() {
    appRouter.pushNamed(AppRoute.signupView);
  }

  void _navigateToSignIn() {
    appRouter.pushNamed(AppRoute.loginView, arguments: true);
  }
}
