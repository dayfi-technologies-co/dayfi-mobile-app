import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/pin_text_field.dart';
import 'package:dayfi/features/auth/verify_email/vm/verify_email_viewmodel.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class VerifyEmailView extends ConsumerWidget {
  final bool isSignUp;
  final String email;
  final String password;

  const VerifyEmailView({
    super.key,
    this.isSignUp = false,
    required this.email,
    this.password = "",
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verifyState = ref.watch(verifyEmailProvider);
    final verifyNotifier = ref.read(verifyEmailProvider.notifier);

    // Initialize email when widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (verifyState.email != email) {
        verifyNotifier.setEmail(email);
      }
    });

    return GestureDetector(
      onTap: () {
        // Dismiss keyboard and remove focus from all text fields
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,

        body: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBar(
                    scrolledUnderElevation: 0,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 0,
                    leading: IconButton(
                      onPressed: () {
                        verifyNotifier.resetForm();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                    title: Text(
                      isSignUp ? "Verify your email" : "Verify reset code",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontFamily: 'CabinetGrotesk',
                        fontSize: 28.00,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),

                        // Subtitle
                        Text(
                              isSignUp
                                  ? "We've sent a verification code to your email address ($email).\nPlease check your email inbox and enter the 6-digit code below to complete your account setup."
                                  : "We've sent a reset code to your email address ($email).\nPlease check your email inbox and enter the 6-digit code below to reset your password.",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Karla',
                                letterSpacing: -.6,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            )
                            .animate()
                            .fadeIn(
                              delay: 100.ms,
                              duration: 300.ms,
                              curve: Curves.easeOutCubic,
                            )
                            .slideY(
                              begin: 0.2,
                              end: 0,
                              delay: 100.ms,
                              duration: 300.ms,
                              curve: Curves.easeOutCubic,
                            ),

                        SizedBox(height: 28.h),


                        // PIN field
                        PinTextField(
                              length: 6,
                              onTextChanged: verifyNotifier.setOtpCode,
                              // validator: (value) {
                              //   if (value == null || value.isEmpty) {
                              //     return 'Please enter OTP';
                              //   }
                              //   if (value.length != 6) {
                              //     return 'OTP must be 6 digits';
                              //   }
                              //   return null;
                              // },
                            )
                            .animate()
                            .fadeIn(
                              delay: 200.ms,
                              duration: 300.ms,
                              curve: Curves.easeOutCubic,
                            )
                            .slideY(
                              begin: 0.3,
                              end: 0,
                              delay: 200.ms,
                              duration: 300.ms,
                              curve: Curves.easeOutCubic,
                            )
                            .scale(
                              begin: const Offset(0.98, 0.98),
                              end: const Offset(1.0, 1.0),
                              delay: 200.ms,
                              duration: 300.ms,
                              curve: Curves.easeOutCubic,
                            )
                           ,

                        // Error message
                        if (verifyState.errorMessage.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 12.h),
                            child: Text(
                              verifyState.errorMessage ==
                                          "OTP verified successfully" ||
                                      verifyState.errorMessage ==
                                          "Password reset successfully"
                                  ? ""
                                  : verifyState.errorMessage,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.red,
                                fontSize: 13.sp,
                                fontFamily: 'Karla',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),

                        SizedBox(height: 24.h),

                        // Timer/Resend section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!verifyState.canResend) ...[
                              Icon(
                                Icons.timer_outlined,
                                color: AppColors.neutral500,
                                size: 16.r,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                verifyState.timerText,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Karla',
                                  color: AppColors.neutral500,
                                ),
                              ),
                            ] else ...[
                              GestureDetector(
                                onTap:
                                    verifyState.isResending
                                        ? null
                                        : () => verifyNotifier.resendOTP(
                                          context,
                                          email,
                                        ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (verifyState.isResending) ...[
                                      SizedBox(
                                        width: 20.r,
                                        height: 20.r,
                                        child: LoadingAnimationWidget.horizontalRotatingDots(
                                          color: AppColors.neutral0,
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                    ],
                                    Text(
                                      verifyState.isResending
                                          ? "Sending new code..."
                                          : "Send new code",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontFamily: 'Karla',
                                        color: verifyState.isResending
                                            ? Theme.of(context).colorScheme.onSurface
                                            : AppColors.purple500,
                                        fontSize: verifyState.isResending
                                            ? 14.sp
                                            : 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),

                        SizedBox(height: 40.h),

                        // Submit button
                        PrimaryButton(
                          borderRadius: 38,
                          text:
                              isSignUp
                                  ? "Verify my account"
                                  : "Continue to reset password",
                          onPressed:
                              verifyState.isFormValid &&
                                      !verifyState.isVerifying
                                  ? () =>
                                      isSignUp
                                          ? verifyNotifier.verifySignup(
                                            context,
                                            email,
                                            password,
                                          )
                                          : verifyNotifier.verifyForgotPassword(
                                            context,
                                            email,
                                          )
                                  : null,
                          enabled:
                              verifyState.isFormValid &&
                              !verifyState.isVerifying,
                          isLoading: verifyState.isVerifying,
                          backgroundColor:
                              verifyState.isFormValid
                                  ? AppColors.purple500
                                  : AppColors.purple100,
                          height: 60.h,
                          textColor: AppColors.neutral0,
                          fontFamily: 'Karla',
                          letterSpacing: -.8,
                          fontSize: 18,
                          width: 375.w,
                          fullWidth: true,
                        ),

                        SizedBox(height: 200.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
