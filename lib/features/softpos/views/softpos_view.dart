// import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/routes/route.dart';

class SoftposView extends StatelessWidget {
  const SoftposView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
        title: Text(
          "Soft POS (Point of Sale)",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 19.sp, // height: 1.6,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.0.h),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              // Container(
              //   padding: EdgeInsets.all(12.w),
              //   decoration: BoxDecoration(
              //     color: Theme.of(
              //       context,
              //     ).colorScheme.primaryContainer.withOpacity(0.25),
              //     borderRadius: BorderRadius.circular(8.r),
              //   ),
              //   child: Row(
              //     children: [
              //       Padding(
              //         padding: EdgeInsets.all(6.5.w),
              //         child: Image.asset(
              //           "assets/images/idea.png",
              //           height: 20.h,
              //         ),
              //       ),
              //       SizedBox(width: 12.w),
              //       Expanded(
              //         child: Text(
              //           "Accept card payments directly on your phone using NFC. Fast, secure, and no additional devices required.",
              //           style: TextStyle(
              //             fontSize: 14.sp,
              //             fontFamily: 'Karla',
              //             fontWeight: FontWeight.w400,
              //             letterSpacing: -0.4,
              //             height: 1.5,
              //             color: Theme.of(context).colorScheme.primary,
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              SizedBox(height: MediaQuery.of(context).size.height * .4),
              Text(
                'Accept Payments\nwith NFC',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  fontFamily: 'CabinetGrotesk',
                  letterSpacing: 0,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Turn your phone into a payment terminal. Accept contactless card payments instantly using NFC technology—no extra hardware needed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.450,
                    fontFamily: 'Karla',
                    letterSpacing: .2,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.color!.withOpacity(.85),
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              PrimaryButton(
                borderRadius: 38,
                onPressed: () {
                  appRouter.pushNamed(AppRoute.softposInfoView);
                },
                text: 'Get Started with SoftPOS',
                backgroundColor: AppColors.purple500,
                textColor: AppColors.neutral0,
                height: 48.000.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
