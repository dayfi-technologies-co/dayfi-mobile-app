import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';

class SuccessSignupView extends ConsumerWidget {
  const SuccessSignupView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).scaffoldBackgroundColor,
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
          ),

          // Decorative background elements
          // _buildBackgroundElements(context),

          // Main content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * .05),
              _buildBody(context),
              SizedBox(height: 32.h),
              _buildNextStepButton(context),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildBackgroundElements(BuildContext context) {
  //   return Positioned.fill(
  //     child: Stack(
  //       children: [
  //         // Top left decorative elements
  //         Positioned(
  //           top: 80.h,
  //           left: 20.w,
  //           child: _buildDecorativeShape(
  //             color: const Color(0xFFFFB3BA),
  //             size: 40.w,
  //           ),
  //         ),
  //         Positioned(
  //           top: 120.h,
  //           left: 40.w,
  //           child: _buildDecorativeShape(
  //             color: const Color(0xFFFFD1DC),
  //             size: 25.w,
  //           ),
  //         ),
  //         Positioned(
  //           top: 100.h,
  //           left: 60.w,
  //           child: _buildDecorativeShape(
  //             color: const Color(0xFFFF6B6B),
  //             size: 30.w,
  //           ),
  //         ),

  //         // Top right decorative elements
  //         Positioned(
  //           top: 90.h,
  //           right: 30.w,
  //           child: _buildDecorativeShape(
  //             color: const Color(0xFFFFD1DC),
  //             size: 35.w,
  //           ),
  //         ),
  //         Positioned(
  //           top: 130.h,
  //           right: 50.w,
  //           child: _buildDecorativeShape(
  //             color: const Color(0xFF90EE90),
  //             size: 28.w,
  //           ),
  //         ),
  //         Positioned(
  //           top: 110.h,
  //           right: 20.w,
  //           child: _buildDecorativeShape(
  //             color: const Color(0xFFFF6B6B),
  //             size: 32.w,
  //           ),
  //         ),

  //         // Bottom left decorative elements
  //         Positioned(
  //           bottom: 200.h,
  //           left: 25.w,
  //           child: _buildDecorativeShape(
  //             color: const Color(0xFF90EE90),
  //             size: 38.w,
  //           ),
  //         ),
  //         Positioned(
  //           bottom: 180.h,
  //           left: 50.w,
  //           child: _buildDecorativeShape(
  //             color: const Color(0xFFFFD1DC),
  //             size: 26.w,
  //           ),
  //         ),

  //         // Bottom right decorative elements
  //         Positioned(
  //           bottom: 190.h,
  //           right: 30.w,
  //           child: _buildDecorativeShape(
  //             color: const Color(0xFFFF6B6B),
  //             size: 34.w,
  //           ),
  //         ),
  //         Positioned(
  //           bottom: 170.h,
  //           right: 55.w,
  //           child: _buildDecorativeShape(
  //             color: const Color(0xFFFFB3BA),
  //             size: 29.w,
  //           ),
  //         ),
  //         Positioned(
  //           bottom: 210.h,
  //           right: 15.w,
  //           child: _buildDecorativeShape(
  //             color: const Color(0xFFFFD700),
  //             size: 31.w,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildDecorativeShape({required Color color, required double size}) {
  //   return Container(
  //     width: size,
  //     height: size,
  //     decoration: BoxDecoration(
  //       color: color.withOpacity(0.3),
  //       shape: BoxShape.circle,
  //       boxShadow: [
  //         BoxShadow(
  //           color: color.withOpacity(0.2),
  //           blurRadius: 8,
  //           spreadRadius: 2,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        // Success icon
        // Container(
        //   width: 88.w,
        //   height: 88.w,
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     shape: BoxShape.circle,
        //     boxShadow: [
        //       BoxShadow(
        //         color: Colors.black.withOpacity(0.1),
        //         blurRadius: 20,
        //         spreadRadius: 2,
        //         offset: const Offset(0, 4),
        //       ),
        //     ],
        //   ),
        //   // child: const Icon(
        //   //   Icons.check_rounded,
        //   //   color: Color(0xff5645F5),
        //   //   size: 48,
        //   // ),
        // )
        // .animate()
        // .fadeIn(
        //   delay: 100.ms,
        //   duration: 400.ms,
        //   curve: Curves.easeOutCubic,
        // )
        // .scale(
        //   begin: const Offset(0.0, 0.0),
        //   end: const Offset(1.0, 1.0),
        //   delay: 100.ms,
        //   duration: 400.ms,
        //   curve: Curves.elasticOut,
        // ),

        // SizedBox(height: 18.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text(
                      "Welcome onboard!",
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontFamily: 'CabinetGrotesk',
                        fontSize: 28.sp,
                        height: 1.15,
                        letterSpacing: 0.00,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                  .animate()
                  .fadeIn(
                    delay: 200.ms,
                    duration: 300.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    delay: 200.ms,
                    duration: 300.ms,
                    curve: Curves.easeOutCubic,
                  ),

              SizedBox(height: 10.h),

              // Subtitle
              Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Text(
                      "Account created! Start sending money to your loved ones",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Karla',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400, //
                        letterSpacing: -.6,
                        height: 1.4,
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(
                    delay: 300.ms,
                    duration: 300.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    delay: 300.ms,
                    duration: 300.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextStepButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
      child: SizedBox(
        child: PrimaryButton(
              onPressed: () {
                // Navigate to main view leaving the all route memory behind, so as when user presses back button, it will not go back to the signup view
                appRouter.pushReplacementNamed(AppRoute.mainView);
              },
              text: "Let's go!",
              backgroundColor: AppColors.purple500,
              // textColor: const Color(0xff5645F5),
              borderRadius: 38,
              height: 60.h,
              width: 375.w,
              fullWidth: true,
              fontFamily: 'Karla',
              fontSize: 18,
              fontWeight: FontWeight.w400,
              letterSpacing: -.8,
            )
            .animate()
            .fadeIn(delay: 400.ms, duration: 300.ms, curve: Curves.easeOutCubic)
            .slideY(
              begin: 0.2,
              end: 0,
              delay: 400.ms,
              duration: 300.ms,
              curve: Curves.easeOutCubic,
            )
            .scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1.0, 1.0),
              delay: 400.ms,
              duration: 300.ms,
              curve: Curves.easeOutCubic,
            ),
      ),
    );
  }
}
