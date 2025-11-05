import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/onboarding_page.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const OnboardingPageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
          color: const Color(0xFFFFD800), // Bright yellow background
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 32.w, 0),
              child: Column(
                children: [
                  SizedBox(height: 32.h),

                  // Main content
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                              page.title,
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: AppColors.neutral900,
                                fontSize: 60.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'CabinetGrotesk',
                                letterSpacing: -1.2,
                                height: .95,
                              ),
                            )
                            .animate()
                            .fadeIn(
                              duration: 600.ms,
                              curve: Curves.easeOutCubic,
                            )
                            .slideY(
                              begin: 0.2,
                              end: 0,
                              duration: 600.ms,
                              curve: Curves.easeOutCubic,
                            )
                            .shimmer(
                              delay: 1000.ms,
                              duration: 2000.ms,
                              color: AppColors.purple500ForTheme(context).withOpacity(0.2),
                              angle: 45,
                            ),

                        SizedBox(height: 14.h),

                        // Subtitle
                        Text(
                              page.subtitle,
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.neutral900.withOpacity(.85),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Karla',
                                letterSpacing: -.6,
                                height: 1.4,
                              ),
                            )
                            .animate()
                            .fadeIn(
                              delay: 200.ms,
                              duration: 600.ms,
                              curve: Curves.easeOutCubic,
                            )
                            .slideY(
                              begin: 0.15,
                              end: 0,
                              delay: 200.ms,
                              duration: 600.ms,
                              curve: Curves.easeOutCubic,
                            ),

                        SizedBox(height: 24.h),

                        // Illustration placeholder
                        Center(child: SvgPicture.asset(page.illustrationPath))
                            .animate()
                            .fadeIn(
                              delay: 200.ms,
                              duration: 600.ms,
                              curve: Curves.easeOutCubic,
                            )
                            .slideY(
                              begin: 0.15,
                              end: 0,
                              delay: 200.ms,
                              duration: 600.ms,
                              curve: Curves.easeOutCubic,
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
        .scale(
          begin: const Offset(0.98, 0.98),
          end: const Offset(1.0, 1.0),
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
