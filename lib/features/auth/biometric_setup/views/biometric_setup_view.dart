import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:dayfi/features/auth/biometric_setup/vm/biometric_setup_viewmodel.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/routes/route.dart';

class BiometricSetupView extends ConsumerStatefulWidget {
  const BiometricSetupView({super.key});

  @override
  ConsumerState<BiometricSetupView> createState() => _BiometricSetupViewState();
}

class _BiometricSetupViewState extends ConsumerState<BiometricSetupView> {
  @override
  Widget build(BuildContext context) {
    final biometricState = ref.watch(biometricSetupProvider);
    final biometricNotifier = ref.read(biometricSetupProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
            bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),
              _buildContentCard(context, biometricState),
              SizedBox(height: 40.h),
              _buildActionButtons(context, biometricState, biometricNotifier),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, BiometricSetupState state) {
    return Column(
          children: [
            // Biometric icon
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.purple400, AppColors.purple600],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple500ForTheme(
                      context,
                    ).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              // child: Icon(
              //   state.hasBothFaceAndFingerprint
              //       ? Icons.security
              //       : state.biometricType.toLowerCase().contains('face')
              //       ? Icons.face
              //       : Icons.fingerprint,
              //   color: Colors.white,
              //   size: 40.w,
              // ),
            ),

            SizedBox(height: 24.h),

            // Title
            Text(
                  "Enable ${state.biometricDescription}",
                  style: AppTypography.headlineMedium.copyWith(
                    fontFamily: 'CabinetGrotesk',
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                    // height: 1.2,
                    letterSpacing: -.3,
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

            SizedBox(height: 16.h),

            // Subtitle
            Text(
                  state.isAvailable && state.isEnrolled
                      ? state.hasBothFaceAndFingerprint
                          ? "Use your Face ID or Fingerprint to quickly and securely access your account"
                          : "Use your ${state.biometricType.toLowerCase()} to quickly and securely access your account"
                      : state.errorMessage.isNotEmpty
                      ? state.errorMessage
                      : "Setting up biometric authentication...",

                  style: AppTypography.bodyLarge.copyWith(
                    fontFamily: 'Karla',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                    color:
                        state.isAvailable && state.isEnrolled
                            ? Theme.of(
                              context,
                            ).textTheme.bodyLarge!.color!.withOpacity(.75)
                            : AppColors.error500,
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

            if (state.isBusy) ...[
              SizedBox(height: 24.h),
              LoadingAnimationWidget.horizontalRotatingDots(
                color: AppColors.purple500ForTheme(context),
                size: 20,
              ),
            ],
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

  Widget _buildActionButtons(
    BuildContext context,
    BiometricSetupState state,
    BiometricSetupNotifier notifier,
  ) {
    return Column(
      children: [
        // Enable biometrics button
        if (state.isAvailable && state.isEnrolled && !state.isEnabled)
          PrimaryButton(
                text: "Enable ${state.biometricDescription}",
                borderRadius: 38,
                onPressed:
                    state.isBusy
                        ? null
                        : () => notifier.enableBiometrics(context),
                backgroundColor: AppColors.purple500,
                height: 48.000.h,
                textColor: AppColors.neutral0,
                fontFamily: 'Karla',
                letterSpacing: -.8,
                fontSize: 18,
                width: double.infinity,
                fullWidth: true,
              )
              .animate()
              .fadeIn(
                delay: 1000.ms,
                duration: 500.ms,
                curve: Curves.easeOutCubic,
              )
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
              ),

        if (state.isAvailable && state.isEnrolled && !state.isEnabled)
          SizedBox(height: 12.h),

        // Skip button
        SecondaryButton(
              text: state.isBusy ? "Please wait..." : "Do it later",
              borderRadius: 38,
              onPressed:
                  state.isBusy
                      ? null
                      : () => _showSkipDialog(context, notifier, state),
              borderColor: Colors.transparent,
              height: 48.000.h,
              textColor: AppColors.purple500ForTheme(context),
              fontFamily: 'Karla',
              letterSpacing: -.8,
              fontSize: 18,
              width: double.infinity,
              fullWidth: true,
            )
            .animate()
            .fadeIn(
              delay: 1000.ms,
              duration: 500.ms,
              curve: Curves.easeOutCubic,
            )
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
            ),

        // Retry button if there's an error
        if (!state.isAvailable || !state.isEnrolled)
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: TextButton(
              onPressed: state.isBusy ? null : () => notifier.retrySetup(),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Karla',
                  color: AppColors.purple500ForTheme(context),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -.3,
                  height: 1.4,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showSkipDialog(
    BuildContext context,
    BiometricSetupNotifier notifier,
    BiometricSetupState state,
  ) {
    // Capture parent context for use after dialog closes
    final parentContext = context;
    bool dialogLoading = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext dialogContext) => StatefulBuilder(
            builder: (context, setStateSB) {
              return Dialog(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Container(
                  padding: EdgeInsets.all(28.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Success icon with enhanced styling
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.purple400, AppColors.purple600],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.purple500ForTheme(
                                context,
                              ).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.security,
                          color: Colors.white,
                          size: 40.w,
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Title with auth view styling
                      Text(
                        'Do you want to enable ${state.biometricDescription} later?',
                        style: TextStyle(
                          fontFamily: 'CabinetGrotesk',
                           fontSize: 20.sp, // height: 1.6,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 16.h),

                      if (dialogLoading) ...[
                        SizedBox(height: 8.h),
                        LoadingAnimationWidget.horizontalRotatingDots(
                          color: AppColors.purple500ForTheme(context),
                          size: 22,
                        ),
                        SizedBox(height: 16.h),
                      ],

                      // Continue button with auth view styling
                      PrimaryButton(
                        text:
                            dialogLoading
                                ? 'Please wait...'
                                : 'Yes, I\'ll do it later',
                        onPressed:
                            dialogLoading
                                ? null
                                : () async {
                                  setStateSB(() {
                                    dialogLoading = true;
                                  });
                                  // Close dialog first to avoid navigation conflicts
                                  Navigator.of(dialogContext).pop();
                                  // Wait a frame to ensure dialog is fully closed before showing snackbar
                                  await Future.delayed(
                                    const Duration(milliseconds: 100),
                                  );
                                  if (parentContext.mounted) {
                                    await notifier.skipBiometrics(
                                      parentContext,
                                    );
                                    // Navigate after snackbar is shown
                                    await Future.delayed(
                                      const Duration(milliseconds: 500),
                                    );
                                    if (parentContext.mounted) {
                                      appRouter.pushNamed(AppRoute.mainView);
                                    }
                                  }
                                },
                        backgroundColor: AppColors.purple500,
                        textColor: AppColors.neutral0,
                        borderRadius: 38,
                        height: 48.000.h,
                        width: double.infinity,
                        fullWidth: true,
                        fontFamily: 'Karla',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.8,
                      ),
                      SizedBox(height: 12.h),

                      // Cancel button with auth view styling
                      SecondaryButton(
                        text: 'No, enable it now',
                        onPressed:
                            dialogLoading
                                ? null
                                : () {
                                  Navigator.of(dialogContext).pop();
                                  notifier.enableBiometrics(parentContext);
                                },
                        borderColor: Colors.transparent,
                        textColor: AppColors.purple500ForTheme(context),
                        width: double.infinity,
                        fullWidth: true,
                        height: 48.000.h,
                        borderRadius: 38,
                        fontFamily: 'Karla',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.8,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}
