import 'package:dayfi/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dayfi/services/local/local_cache.dart';
import 'package:dayfi/app_locator.dart';

class ResetTransactionPinIntroView extends ConsumerWidget {
  const ResetTransactionPinIntroView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.purple500,
        body: SafeArea(
            bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: 24.h, width: 24.w),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Image.asset(
                        "assets/icons/pngs/cancelicon.png",
                        height: 24.h,
                        width: 24.w,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),

                // Lock Icon
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/svgs/security-safe.svg',
                      height: MediaQuery.of(context).size.width * 0.5,
                      width: MediaQuery.of(context).size.width * 0.5,
                      color: AppColors.warning500,
                    ),
                  ],
                ),
                Text(
                  "Reset Your\nTransaction PIN",
                  style: AppTypography.headlineLarge.copyWith(
                 fontFamily: 'CabinetGrotesk',
                    fontSize: 28.sp, height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral0,
                    // height: 1.2,
                    letterSpacing: -0.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "We'll verify your identity via OTP sent to your registered email, then you can create a new transaction PIN.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Karla',
                    color: AppColors.neutral50,
                    letterSpacing: -.3,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.h),
                PrimaryButton(
                  borderRadius: 38,
                  text: "Continue",
                  onPressed: () async {
                    // Get user email from local cache
                    final localCache = locator<LocalCache>();
                    final userMap = await localCache.getUser();
                    final email = userMap['email'] ?? '';

                    if (email.isNotEmpty) {
                      appRouter.pushNamed(
                        AppRoute.resetTransactionPinOtpView,
                        arguments: email,
                      );
                    }
                  },
                  backgroundColor: AppColors.neutral0,
                  height: 48.000.h,
                  textColor: AppColors.purple500ForTheme(context),
                  fontFamily: 'Karla',
                  letterSpacing: -.8,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  width: double.infinity,
                  fullWidth: true,
                ),
                SizedBox(height: 50.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
