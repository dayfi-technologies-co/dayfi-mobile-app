import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/common/widgets/eye_icon.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/auth/reset_password/vm/reset_password_viewmodel.dart';

class ResetPasswordView extends ConsumerWidget {
  final String email;
  
  const ResetPasswordView({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resetPasswordState = ref.watch(resetPasswordProvider);
    final resetPasswordNotifier = ref.read(resetPasswordProvider.notifier);
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
                      "Create password",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontFamily: 'CabinetGrotesk',
                        fontSize: 30.00,
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
                            "Create a strong password with at least 8 characters, including uppercase, numbers, and special characters",
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

                        SizedBox(height: 36.h),

                        // Password field
                        CustomTextField(
                          label: "New Password",
                            hintText: "Create a strong password",
                          // errorText: resetPasswordState.passwordError,
                          onChanged: resetPasswordNotifier.setPassword,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.none,
                          obscureText: !resetPasswordState.isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: EyeIcon(
                              isVisible: resetPasswordState.isPasswordVisible,
                              color: AppColors.neutral500,
                              size: 20.0,
                            ),
                            onPressed: () => resetPasswordNotifier.togglePasswordVisibility(),
                          ),
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
                        .shimmer(
                          delay: 400.ms,
                          duration: 800.ms,
                          color: AppColors.purple500.withOpacity(0.1),
                          angle: 15,
                        ),

                        // Password error text
                        if (resetPasswordState.passwordError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, left: 14),
                            child: Text(
                              resetPasswordState.passwordError,
                              style: const TextStyle(
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

                        SizedBox(height: 18.h),

                        // Confirm Password field
                        CustomTextField(
                          label: "Confirm new password",
                          hintText: "Type your new password again",
                          // errorText: resetPasswordState.confirmPasswordError,
                          onChanged: resetPasswordNotifier.setConfirmPassword,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          obscureText: !resetPasswordState.isConfirmPasswordVisible,
                          suffixIcon: IconButton(
                            icon: EyeIcon(
                              isVisible: resetPasswordState.isConfirmPasswordVisible,
                              color: AppColors.neutral500,
                              size: 20.0,
                            ),
                            onPressed: () => resetPasswordNotifier.toggleConfirmPasswordVisibility(),
                          ),
                        )
                        .animate()
                        .fadeIn(
                          delay: 300.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          delay: 300.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .scale(
                          begin: const Offset(0.98, 0.98),
                          end: const Offset(1.0, 1.0),
                          delay: 300.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .shimmer(
                          delay: 500.ms,
                          duration: 800.ms,
                          color: AppColors.purple500.withOpacity(0.1),
                          angle: 15,
                        ),

                        // Confirm Password error text
                        if (resetPasswordState.confirmPasswordError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, left: 14),
                            child: Text(
                              resetPasswordState.confirmPasswordError,
                              style: const TextStyle(
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
                          text: "Save my new password",
                          onPressed: resetPasswordState.isFormValid && !resetPasswordState.isBusy
                              ? () => resetPasswordNotifier.resetPassword(email, context)
                              : null,
                          enabled: resetPasswordState.isFormValid && !resetPasswordState.isBusy,
                          isLoading: resetPasswordState.isBusy,
                          backgroundColor: resetPasswordState.isFormValid
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
                          delay: 400.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          delay: 400.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .scale(
                          begin: const Offset(0.95, 0.95),
                          end: const Offset(1.0, 1.0),
                          delay: 400.ms,
                          duration: 300.ms,
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