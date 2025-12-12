import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/pin_text_field.dart';
import 'package:dayfi/features/auth/verify_email/vm/verify_email_viewmodel.dart';
import 'package:flutter_svg/svg.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';

String maskEmail(String email) {
  final parts = email.split('@');
  if (parts.length != 2) return email;
  final name = parts[0];
  final domain = parts[1];
  String maskedName;
  if (name.length <= 2) {
    maskedName = name[0] + '*';
  } else if (name.length <= 4) {
    maskedName = name[0] + '*' * (name.length - 2) + name[name.length - 1];
  } else {
    maskedName =
        name.substring(0, 2) +
        '*' * (name.length - 4) +
        name.substring(name.length - 2);
  }
  final domainParts = domain.split('.');
  if (domainParts.length < 2) return '$maskedName@${domain}';
  final domainName = domainParts[0];
  final domainExt = domainParts.sublist(1).join('.');
  String maskedDomain = domainName[0] + '*' * (domainName.length - 1);
  return '$maskedName@$maskedDomain.$domainExt';
}

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

        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(18.0, 12, 18.0, 40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                    borderRadius: 38,
                    text: isSignUp ? "Verify Account" : "Reset Password",
                    onPressed:
                        verifyState.isFormValid && !verifyState.isVerifying
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
                        verifyState.isFormValid && !verifyState.isVerifying,
                    isLoading: verifyState.isVerifying,
                    backgroundColor:
                        verifyState.isFormValid
                            ? AppColors.purple500ForTheme(context)
                            : AppColors.purple500ForTheme(
                              context,
                            ).withOpacity(.25),
                    height: 48.000.h,
                    textColor:
                        verifyState.isFormValid
                            ? AppColors.neutral0
                            : AppColors.neutral0.withOpacity(.65),
                    fontFamily: 'Karla',
                    letterSpacing: -.8,
                    fontSize: 18,
                    width: 375.w,
                    fullWidth: true,
                  )
                  .animate()
                  .fadeIn(
                    delay: 500.ms,
                    duration: 300.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    delay: 500.ms,
                    duration: 300.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1.0, 1.0),
                    delay: 500.ms,
                    duration: 300.ms,
                    curve: Curves.easeOutCubic,
                  ),
              SizedBox(height: 12.h),

              TextButton(
                    style: TextButton.styleFrom(
                      // padding: EdgeInsets.zero,
                      // minimumSize: Size(50.w, 30.h),
                      splashFactory: NoSplash.splashFactory,
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.transparent,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.center,
                    ),
                    onPressed: null,
                    child: Text(
                      "Open email app",
                      style: TextStyle(
                        fontFamily: 'Karla',
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -.8,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0, delay: 200.ms, duration: 600.ms)
                  .shimmer(
                    delay: 1000.ms,
                    duration: 1500.ms,
                    color: Theme.of(
                      context,
                    ).scaffoldBackgroundColor.withOpacity(0.4),
                    angle: 45,
                  ),
            ],
          ),
        ),

        appBar: AppBar(
          scrolledUnderElevation: .5,
          foregroundColor: Theme.of(context).scaffoldBackgroundColor,
          shadowColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leadingWidth: 72,
          leading: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap:
                () => {
                  verifyNotifier.resetForm(),
                  Navigator.pop(context),
                  FocusScope.of(context).unfocus(),
                },
            child: Stack(
              alignment: AlignmentGeometry.center,
              children: [
                SvgPicture.asset(
                  "assets/icons/svgs/notificationn.svg",
                  height: 40.sp,
                  color: Theme.of(context).colorScheme.surface,
                ),
                SizedBox(
                  height: 40.sp,
                  width: 40.sp,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 20.sp,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                        // size: 20.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        body: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8.h),
                        Text(
                          "Verify email",
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            fontSize: 18.sp,
                            fontFamily: 'Boldonse',
                            letterSpacing: -.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        SizedBox(height: 12.h),

                        // Subtitle
                        Text(
                              isSignUp
                                  ? "We've sent a verification code to ${maskEmail(email)}.\nCheck your email inbox and enter the 6-digit code below to complete your account setup."
                                  : "We've sent a reset code to ${maskEmail(email)}.\nCheck your email inbox and enter the 6-digit code below to reset your password.",
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Karla',
                                letterSpacing: -.6,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.start,
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

                        SizedBox(height: 32.h),

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
                            ),

                        // // Error message
                        // if (verifyState.errorMessage.isNotEmpty)
                        //   Padding(
                        //     padding: EdgeInsets.only(top: 12.h),
                        //     child: Text(
                        //       verifyState.errorMessage ==
                        //                   "OTP verified successfully" ||
                        //               verifyState.errorMessage ==
                        //                   "Password reset successfully"
                        //           ? ""
                        //           : verifyState.errorMessage,
                        //       style: Theme.of(
                        //         context,
                        //       ).textTheme.bodySmall?.copyWith(
                        //         color: Colors.red,
                        //         fontSize: 13.sp,
                        //         fontFamily: 'Karla',
                        //         fontWeight: FontWeight.w500,
                        //       ),
                        //     ),
                        //   )
                        // else
                        //   const SizedBox.shrink(),

                        SizedBox(height: 24.h),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!verifyState.canResend) ...[
                              Icon(
                                Icons.timer_outlined,
                                color: AppColors.neutral400,
                                size: 16.r,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                verifyState.timerText,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Karla',
                                  color: AppColors.neutral400,
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
                                        child:
                                            LoadingAnimationWidget.horizontalRotatingDots(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                              size: 20,
                                            ),
                                      ),
                                      SizedBox(width: 8.w),
                                    ],
                                    Text(
                                      verifyState.isResending
                                          ? "..."
                                          : "Send new code",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        fontFamily: 'Karla',
                                        color:
                                            verifyState.isResending
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.onSurface
                                                : AppColors.purple500ForTheme(
                                                  context,
                                                ),
                                        fontSize:
                                            verifyState.isResending
                                                ? 14.sp
                                                : 16.sp,

                                        decoration:   verifyState.isResending 
                                            ? TextDecoration.none
                                            : TextDecoration.underline,
                                        letterSpacing: -.6,
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

                        SizedBox(height: 300.h),
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
