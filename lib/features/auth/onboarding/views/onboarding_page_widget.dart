import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:dayfi/core/theme/app_colors.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import '../models/onboarding_page.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const OnboardingPageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 0, 32.w, 0),
            child: Column(
              children: [
                SizedBox(height: 32.h),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                                 SizedBox(
                        height: MediaQuery.of(context).size.height * 0.08,
                      ),
                    
                      // ILLUSTRATION
                      Center(
                            child:
                                page.illustrationPath.endsWith('.png')
                                    ? Image.asset(
                                      page.illustrationPath,
                                      width:
                                          MediaQuery.of(context).size.width *
                                          .5,
                                    )
                                    : SvgPicture.asset(
                                      page.illustrationPath,
                                      width:
                                          MediaQuery.of(context).size.width *
                                          .5,
                                    ),
                          )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 600.ms)
                          .slideY(begin: 0.18, end: 0, duration: 600.ms)
                          .scale(
                            begin: const Offset(.98, .98),
                            duration: 500.ms,
                          ),

                               SizedBox(
                        height: MediaQuery.of(context).size.height * 0.06,
                      ),

                      /// TITLE
                      Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.displayLarge?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).textTheme.headlineLarge?.color,
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w900,
                              // fontWeight: FontWeight.w100,
                              fontFamily: 'Boldonse',
                              letterSpacing: -.6,
                              height: 1.6,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: 0.25, end: 0, duration: 600.ms)
                          .then()
                          .shimmer(
                            duration: 1800.ms,
                            color: Theme.of(
                              context,
                            ).scaffoldBackgroundColor.withOpacity(0.4),
                            angle: 20,
                          ),

                      SizedBox(height: 18.h),

                      /// SUBTITLE
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.08),
                        child: Text(
                              page.subtitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.color!
                                    .withOpacity(0.85),
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                                height: 1.45,
                                letterSpacing: -.6,
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 150.ms, duration: 600.ms)
                            .slideY(begin: 0.2, end: 0, duration: 600.ms),
                      ),

                   
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 450.ms)
        .blurXY(begin: 4, end: 0, duration: 450.ms);
  }
}
