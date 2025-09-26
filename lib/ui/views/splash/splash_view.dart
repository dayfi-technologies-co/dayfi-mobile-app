import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stacked/stacked.dart';
import 'splash_viewmodel.dart';

class SplashView extends StackedView<SplashViewModel> {
  const SplashView({super.key});

  @override
  void onViewModelReady(SplashViewModel viewModel) {
    super.onViewModelReady(viewModel);
    viewModel.initializeApp();
  }

  @override
  Widget builder(
    BuildContext context,
    SplashViewModel viewModel,
    Widget? child,
  ) {
    return AppScaffold(
      backgroundColor: const Color(0xff5645F5),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Main content centered
          // Center(
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       // SEND APP text with glow effects
          //     ],
          //   ),
          // ),

          // Powered by section at bottom
          Positioned(
            bottom: 60.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Powered by',
                  style: TextStyle(
                    // color: AppColors.neutral500,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    fontFamily: 'Karla',
                  ),
                ),
                SizedBox(height: 8.h),

                // Dayfi logo placeholder
                // Center(
                //   child: Text(
                //     'flutterwave',
                //     style: TextStyle(
                //       color: AppColors.neutral0,
                //       fontSize: 16.sp,
                //       fontWeight: FontWeight.w600,
                //       fontFamily: 'ReadexPro',
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  SplashViewModel viewModelBuilder(BuildContext context) => SplashViewModel();
}
