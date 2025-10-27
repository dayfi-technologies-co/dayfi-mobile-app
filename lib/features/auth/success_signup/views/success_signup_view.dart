import 'package:dayfi/common/widgets/buttons/buttons.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/notification_service.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/common/constants/storage_keys.dart';
import 'dart:convert';

class SuccessSignupView extends ConsumerWidget {
  const SuccessSignupView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Trigger signup success notification when this view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerSignUpNotification();
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // // Beautiful gradient background
          // _buildGradientBackground(),

          // // Decorative background elements
          // _buildBackgroundElements(context),

          // Main content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 40.h),
                  // _buildSuccessIcon(),
                  // SizedBox(height: 32.h),
                  _buildContentCard(context),
                  SizedBox(height: 40.h),
                  _buildNextStepButton(context),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.purple50,
            AppColors.neutral50,
            AppColors.purple100.withOpacity(0.3),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildBackgroundElements(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Floating circles
          Positioned(
            top: 100.h,
            left: -50.w,
            child: _buildFloatingCircle(
              size: 120.w,
              color: AppColors.purple100.withOpacity(0.3),
            ),
          ),
          Positioned(
            top: 200.h,
            right: -30.w,
            child: _buildFloatingCircle(
              size: 80.w,
              color: AppColors.purple300.withOpacity(0.2),
            ),
          ),
          Positioned(
            bottom: 150.h,
            left: -20.w,
            child: _buildFloatingCircle(
              size: 100.w,
              color: AppColors.purple100.withOpacity(0.4),
            ),
          ),
          Positioned(
            bottom: 250.h,
            right: -40.w,
            child: _buildFloatingCircle(
              size: 60.w,
              color: AppColors.purple100.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCircle({required double size, required Color color}) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(duration: 2000.ms, curve: Curves.easeInOut)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.2, 1.2),
          duration: 3000.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildSuccessIcon() {
    return Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.purple500, AppColors.purple600],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.purple500.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.check_rounded,
            color: AppColors.neutral0,
            size: 60.sp,
          ),
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutCubic)
        .scale(
          begin: const Offset(0.0, 0.0),
          end: const Offset(1.0, 1.0),
          delay: 200.ms,
          duration: 600.ms,
          curve: Curves.elasticOut,
        )
        .then()
        .shimmer(duration: 1000.ms, color: AppColors.neutral0.withOpacity(0.3));
  }

  Widget _buildContentCard(BuildContext context) {
    return Column(
          children: [
            // Celebration emoji
            // Text(
            //   "🎉",
            //   style: TextStyle(fontSize: 48.sp),
            // )
            //     .animate()
            //     .fadeIn(
            //       delay: 400.ms,
            //       duration: 500.ms,
            //       curve: Curves.easeOutCubic,
            //     )
            //     .scale(
            //       begin: const Offset(0.5, 0.5),
            //       end: const Offset(1.0, 1.0),
            //       delay: 400.ms,
            //       duration: 500.ms,
            //       curve: Curves.elasticOut,
            //     ),

            // SizedBox(height: 24.h),

            // Title
            Text(
                  "Welcome onboard!",
                  style: AppTypography.headlineMedium.copyWith(
                    fontFamily: 'CabinetGrotesk',
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.2,
                    letterSpacing: -.6,
                  ),
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(
                  delay: 500.ms,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic,
                )
                .slideY(
                  begin: 0.3,
                  end: 0,
                  delay: 500.ms,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic,
                ),

            SizedBox(height: 12.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Text(
                    "Account created! Start sending money to your loved ones",
                    style: AppTypography.bodyLarge.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  )
                  .animate()
                  .fadeIn(
                    delay: 600.ms,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    delay: 600.ms,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ),

            // SizedBox(height: 32.h),

            // // Features list
            // _buildFeaturesList(),
          ],
        )
        .animate()
        .fadeIn(delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic)
        .slideY(
          begin: 0.4,
          end: 0,
          delay: 300.ms,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildFeaturesList() {
    final features = [
      {"icon": "💸", "text": "Send money instantly"},
      {"icon": "🌍", "text": "Global transfers"},
      {"icon": "🔒", "text": "Secure & encrypted"},
    ];

    return Column(
      children:
          features.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, String> feature = entry.value;

            return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Row(
                    children: [
                      Text(feature["icon"]!, style: TextStyle(fontSize: 20.sp)),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          feature["text"]!,
                          style: AppTypography.bodyMedium.copyWith(
                            fontFamily: 'Karla',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.neutral700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(
                  delay: (700 + (index * 100)).ms,
                  duration: 300.ms,
                  curve: Curves.easeOutCubic,
                )
                .slideX(
                  begin: -0.2,
                  end: 0,
                  delay: (700 + (index * 100)).ms,
                  duration: 300.ms,
                  curve: Curves.easeOutCubic,
                );
          }).toList(),
    );
  }

  Widget _buildNextStepButton(BuildContext context) {
    return PrimaryButton(
          text: "Let's go!",
          borderRadius: 38,

          onPressed:
              () => appRouter.pushNamed(AppRoute.completePersonalInfoView),
          backgroundColor: AppColors.purple500,
          height: 60.h,
          textColor: AppColors.neutral0,
          fontFamily: 'Karla',
          letterSpacing: -.8,
          fontSize: 18,
          width: double.infinity,
          fullWidth: true,
        )
        .animate()
        .fadeIn(delay: 1000.ms, duration: 500.ms, curve: Curves.easeOutCubic)
        .slideY(
          begin: 0.3,
          end: 0,
          delay: 1000.ms,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        )
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
          delay: 1000.ms,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        );
  }

  /// Trigger sign-up success notification for new users
  Future<void> _triggerSignUpNotification() async {
    try {
      // Get user data from storage to get the first name
      final secureStorage = locator<SecureStorageService>();
      final userJson = await secureStorage.read(StorageKeys.user);
      String firstName = 'User'; // Default fallback

      if (userJson.isNotEmpty) {
        try {
          final userData = json.decode(userJson);
          firstName = userData['firstName'] ?? 'User';
        } catch (e) {
          AppLogger.warning('Error parsing user data: $e');
        }
      }

      // Add a small delay to ensure the view is fully loaded
      await Future.delayed(const Duration(milliseconds: 500));

      // Trigger the notification
      await NotificationService().triggerSignUpSuccess(firstName);

      AppLogger.info('Sign-up success notification triggered for: $firstName');
    } catch (e) {
      AppLogger.error('Error triggering sign-up notification: $e');
    }
  }
}
