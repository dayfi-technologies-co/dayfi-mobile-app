import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/auth/forgot_password/vm/forgot_password_viewmodel.dart';
import 'package:dayfi/routes/route.dart';

class ForgotPasswordView extends ConsumerWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forgotPasswordState = ref.watch(forgotPasswordProvider);
    final forgotPasswordNotifier = ref.read(forgotPasswordProvider.notifier);
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
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                    title: Text(
                      "Reset Password",
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
                        Center(
                              child: Text(
                                "We'll help you create a new password.\nEnter your email address below.",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Karla',
                                  letterSpacing: -.6,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                            .animate()
                            .fadeIn(
                              delay: 200.ms,
                              duration: 400.ms,
                              curve: Curves.easeOutCubic,
                            )
                            .slideY(
                              begin: 0.2,
                              end: 0,
                              delay: 200.ms,
                              duration: 400.ms,
                              curve: Curves.easeOutCubic,
                            ),

                        SizedBox(height: 36.h),

                        // Email field
                        CustomTextField(
                              label: "Email Address",
                              hintText: "Enter your email address here",
                              onChanged: forgotPasswordNotifier.setEmail,
                              keyboardType: TextInputType.emailAddress,
                              textCapitalization: TextCapitalization.none,
                            )
                            .animate()
                            .fadeIn(
                              delay: 400.ms,
                              duration: 400.ms,
                              curve: Curves.easeOutCubic,
                            )
                            .slideY(
                              begin: 0.3,
                              end: 0,
                              delay: 400.ms,
                              duration: 400.ms,
                              curve: Curves.easeOutCubic,
                            )
                            .scale(
                              begin: const Offset(0.98, 0.98),
                              end: const Offset(1.0, 1.0),
                              delay: 400.ms,
                              duration: 400.ms,
                              curve: Curves.easeOutCubic,
                            )
                            .shimmer(
                              delay: 800.ms,
                              duration: 1000.ms,
                              color: AppColors.purple500.withOpacity(0.1),
                              angle: 15,
                            ),

                        if (forgotPasswordState.emailError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, left: 14),
                            child: Text(
                              forgotPasswordState.emailError,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.red,
                                fontSize: 13,
                                fontFamily: 'Karla',
                                letterSpacing: -.6,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        SizedBox(height: 72.h),

                        // Submit button
                        PrimaryButton(
                              borderRadius: 38,
                              text: "Send me reset instructions",
                              onPressed:
                                  forgotPasswordState.isFormValid &&
                                          !forgotPasswordState.isBusy
                                      ? () => forgotPasswordNotifier
                                          .forgotPassword(context)
                                      : null,
                              enabled:
                                  forgotPasswordState.isFormValid &&
                                  !forgotPasswordState.isBusy,
                              isLoading: forgotPasswordState.isBusy,
                              backgroundColor:
                                  forgotPasswordState.isFormValid
                                      ? AppColors.purple500
                                      : AppColors.purple200,
                              height: 60.h,
                              textColor: AppColors.neutral0,
                              fontFamily: 'Karla',
                              letterSpacing: -.8,
                              fontSize: 18,
                              width: 375.w,
                              fullWidth: true,
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
                            )
                            .scale(
                              begin: const Offset(0.95, 0.95),
                              end: const Offset(1.0, 1.0),
                              delay: 600.ms,
                              duration: 400.ms,
                              curve: Curves.easeOutCubic,
                            ),

                        SizedBox(height: 24.h),

                        // Login link
                        Center(
                              child: Text.rich(
                                textAlign: TextAlign.center,
                                TextSpan(
                                  text: "I remember my password now",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontFamily: 'Karla',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -.6,
                                    height: 1.4,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "\nGo back to sign in",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontFamily: 'Karla',
                                        color: AppColors.purple500,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -.6,
                                        height: 1.4,
                                      ),
                                      recognizer:
                                          TapGestureRecognizer()
                                            ..onTap =
                                                () =>
                                                    Navigator.pushReplacementNamed(
                                                      context,
                                                      AppRoute.loginView,
                                                    ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(
                              delay: 800.ms,
                              duration: 400.ms,
                              curve: Curves.easeOutCubic,
                            )
                            .slideY(
                              begin: 0.15,
                              end: 0,
                              delay: 800.ms,
                              duration: 400.ms,
                              curve: Curves.easeOutCubic,
                            ),

                        SizedBox(height: 40.h),
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
