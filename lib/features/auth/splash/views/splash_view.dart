import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/services/version_service.dart';
import 'package:dayfi/common/constants/storage_keys.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {
  final SecureStorageService _secureStorage = locator<SecureStorageService>();
  final VersionService _versionService = locator<VersionService>();

  @override
  void initState() {
    super.initState();
    _checkUserStateAndNavigate();
  }

  Future<void> _checkUserStateAndNavigate() async {
    try {
      // First, check if this is a new app version and clear data if needed
      await _versionService.isNewVersion();

      final firstTime = await _secureStorage.read(StorageKeys.isFirstTime);
      final token = await _secureStorage.read(StorageKeys.token);
      final passcode = await _secureStorage.read(StorageKeys.passcode);
      final userData = await _secureStorage.read(StorageKeys.user);

      final bool isFirstTimeUser = firstTime.isEmpty || firstTime == 'true';
      final String userToken = token;
      final String userPasscode = passcode;
      final String userJson = userData;

      // Add a small delay for splash screen effect
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        // Validate data consistency - if we have a token but no user data, something is wrong
        if (userToken.isNotEmpty && userJson.isEmpty) {
          // Clear inconsistent data and redirect to login
          await _clearInconsistentData();
          appRouter.pushLoginAndClearStack(arguments: false);
          return;
        }

        if (isFirstTimeUser && userToken.isEmpty) {
          Navigator.of(context).pushReplacementNamed(AppRoute.onboardingView);
        } else if (userToken.isEmpty) {
          appRouter.pushLoginAndClearStack(arguments: false);
        } else if (userPasscode.isEmpty) {
          appRouter.pushLoginAndClearStack(arguments: false);
        } else {
          // Skip biometric setup for now - go directly to passcode view
          // TODO: Re-enable biometric setup later
          // } else if (!hasCompletedBiometricSetup) {
          //   // If user has token and passcode but hasn't completed biometric setup, go to biometric setup
          //   Navigator.of(context).pushReplacementNamed(AppRoute.biometricSetupView);
          Navigator.of(context).pushReplacementNamed(AppRoute.passcodeView);
        }
      }
    } catch (e) {
      // Navigate to onboarding view as fallback
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoute.onboardingView);
      }
    }
  }

  /// Clear inconsistent data when token exists but user data is missing
  Future<void> _clearInconsistentData() async {
    try {
      await _secureStorage.delete(StorageKeys.token);
      await _secureStorage.delete(StorageKeys.email);
      await _secureStorage.delete(StorageKeys.password);
      await _secureStorage.delete(StorageKeys.passcode);
      await _secureStorage.delete(StorageKeys.user);
    } catch (e) {
      // Log error but don't throw - we want to continue with navigation
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
          Center(
            child: Text(
              "Dayfi App",
              style: TextStyle(
                fontFamily: 'Boldonse',
                fontSize: 28.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral900,
                // height: 1.3,
              ),
            ),
          ),

          // Powered by section at bottom
          // Positioned(
          //   bottom: 60.h,
          //   left: 0,
          //   right: 0,
          //   child: Column(
          //     children: [
          //       Text(
          //         'Powered by',
          //         style: Theme.of(context).textTheme.bodySmall?.copyWith(
          //           color: AppColors.neutral900.withOpacity(.75),
          //           fontSize: 14.sp,
          //           fontWeight: FontWeight.w400,
          //           fontFamily: 'Karla',
          //         ),
          //       ),
          //       SizedBox(height: 4.h),
          //       // Dayfi logo placeholder
          //       Center(
          //         child: Text(
          //           'dayfi',
          //           style: TextStyle(
          //             fontFamily: 'Boldonse',
          //             fontSize: 12.sp,
          //             fontWeight: FontWeight.w500,
          //             color: AppColors.neutral900,
          //             height: 1.3,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
