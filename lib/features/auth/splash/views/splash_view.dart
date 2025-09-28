import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/local/secure_storage.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {
  final SecureStorageService _secureStorage = locator<SecureStorageService>();

  @override
  void initState() {
    super.initState();
    _checkUserStateAndNavigate();
  }

  Future<void> _checkUserStateAndNavigate() async {
    try {
      final firstTime = await _secureStorage.read('first_time_user');
      final token = await _secureStorage.read('user_token');
      final passcode = await _secureStorage.read('user_passcode');

      final bool isFirstTimeUser = firstTime.isEmpty || firstTime == 'true';
      final String userToken = token;
      final String userPasscode = passcode;

      print("Navigating with: $isFirstTimeUser, $userToken, $userPasscode");

      // Add a small delay for splash screen effect
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        if (isFirstTimeUser && userToken.isEmpty) {
          Navigator.of(context).pushReplacementNamed(AppRoute.onboardingView);
        } else if (userToken.isEmpty) {
          Navigator.of(context).pushReplacementNamed(AppRoute.loginView, arguments: false);
        } else if (userPasscode.isEmpty) {
          Navigator.of(context).pushReplacementNamed(AppRoute.loginView, arguments: false);
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoute.passcodeView);
        }
      }
    } catch (e) {
      print('Error checking user state: $e');
      // Navigate to onboarding view as fallback
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoute.onboardingView);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD800), // Bright yellow background
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral500,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
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
                //       fontWeight: FontWeight.w400,
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
}
