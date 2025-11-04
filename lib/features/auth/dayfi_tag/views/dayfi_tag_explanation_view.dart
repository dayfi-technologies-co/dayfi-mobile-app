import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/routes/route.dart';

class DayfiTagExplanationView extends ConsumerWidget {
  const DayfiTagExplanationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async => false, // Disable device back button
      child: Scaffold(
        backgroundColor: AppColors.purple500,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
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
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
                Padding(
                  padding: EdgeInsets.only(left: 28.w),
                  child: Image.asset(
                    'assets/images/upload_doc.png',
                    width: MediaQuery.of(context).size.width * 0.5,
                  ),
                ),
                Text(
                  "Your DayFi Tag is a unique identifier that makes it easy for friends and family to send you money. Share your tag with anyone, and they can instantly transfer funds to your wallet.\n\nNote: DayFi Tag transfers are only available for NGN (Nigerian Naira).",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Karla',
                    color: AppColors.neutral50,
                    letterSpacing: -.6,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                // SizedBox(height: 24.h),
                // Text(
                //   "Benefits:\n• Easy to share - just your unique tag\n• Instant transfers\n• No bank details needed\n• Free to use",
                //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                //     fontSize: 14.sp,
                //     fontWeight: FontWeight.w400,
                //     fontFamily: 'Karla',
                //     color: AppColors.neutral50.withOpacity(0.9),
                //     letterSpacing: -.6,
                //     height: 1.5,
                //   ),
                //   textAlign: TextAlign.center,
                // ),
                SizedBox(height: 40.h),
                PrimaryButton(
                  borderRadius: 38,
                  text: "Create DayFi Tag",
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      AppRoute.createDayfiTagView,
                    );
                    if (result != null && result is String) {
                      Navigator.pop(context, result);
                    }
                  },
                  backgroundColor: AppColors.neutral0,
                  height: 60.h,
                  textColor: AppColors.purple500,
                  fontFamily: 'Karla',
                  letterSpacing: -.8,
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
