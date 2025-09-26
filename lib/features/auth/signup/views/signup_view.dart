import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/common/widgets/eye_icon.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/features/auth/signup/vm/signup_viewmodel.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';

class SignupView extends ConsumerWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signupState = ref.watch(signupProvider);
    final signupNotifier = ref.read(signupProvider.notifier);

    return GestureDetector(
      onTap: () {
        // Dismiss keyboard and remove focus from all text fields
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: const Color(0xffFEF9F3),
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
                    backgroundColor: const Color(0xffFEF9F3),
                    elevation: 0,
                    leading: IconButton(
                      onPressed: () {
                        signupNotifier.resetForm();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                    title: Text(
                      "Create account",
                      style: TextStyle(
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
                            "Please fill in your information below to create your new account. We'll need your name, email, and a secure password.",
                            style: TextStyle(
                              color: AppColors.neutral700,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400, //
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

                        SizedBox(height: 32.h),

                        // Email field
                        CustomTextField(
                          label: "Email Address",
                          hintText: "Enter your email address here",
                          onChanged: signupNotifier.setEmail,
                          keyboardType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
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

                        if (signupState.emailError.isNotEmpty)
                          signupState.emailError == "User created successfully"
                              ? const SizedBox.shrink()
                              : Padding(
                                padding: const EdgeInsets.only(
                                  top: 4.0,
                                  left: 14,
                                ),
                                child: Text(
                                  signupState.emailError,
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

                        // Name fields row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextField(
                                    label: "First Name",
                                    hintText: "Enter your first name",
                                    keyboardType: TextInputType.name,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    onChanged: signupNotifier.setFirstName,
                                  ),
                                  if (signupState.firstNameError.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 4.0,
                                        left: 14,
                                      ),
                                      child: Text(
                                        signupState.firstNameError,
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
                                ],
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextField(
                                    label: "Last Name (Surname)",
                                    hintText: "Enter your last name",
                                    keyboardType: TextInputType.name,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    onChanged: signupNotifier.setLastName,
                                  ),

                                  if (signupState.lastNameError.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 4.0,
                                        left: 14,
                                      ),
                                      child: Text(
                                        signupState.lastNameError,
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
                                ],
                              ),
                            ),
                          ],
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

                        SizedBox(height: 18.h),

                        // Middle name field
                        CustomTextField(
                          label: "Middle Name (Optional)",
                          hintText: "Enter your middle name (if you have one)",
                          keyboardType: TextInputType.name,
                          onChanged: signupNotifier.setMiddleName,
                        )
                        .animate()
                        .fadeIn(
                          delay: 400.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          delay: 400.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .scale(
                          begin: const Offset(0.98, 0.98),
                          end: const Offset(1.0, 1.0),
                          delay: 400.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .shimmer(
                          delay: 600.ms,
                          duration: 800.ms,
                          color: AppColors.purple500.withOpacity(0.1),
                          angle: 15,
                        ),

                        SizedBox(height: 18.h),

                        // Password field
                        CustomTextField(
                          label: "Password",
                          hintText: "Create a secure password",
                          onChanged: signupNotifier.setPassword,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: signupState.isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: EyeIcon(
                              isVisible: signupState.isPasswordVisible,
                              color: AppColors.neutral500,
                              size: 20.0,
                            ),
                            onPressed:
                                () => signupNotifier.togglePasswordVisibility(),
                          ),
                        )
                        .animate()
                        .fadeIn(
                          delay: 500.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          delay: 500.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .scale(
                          begin: const Offset(0.98, 0.98),
                          end: const Offset(1.0, 1.0),
                          delay: 500.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .shimmer(
                          delay: 700.ms,
                          duration: 800.ms,
                          color: AppColors.purple500.withOpacity(0.1),
                          angle: 15,
                        ),

                        if (signupState.passwordError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              left: 16.0,
                            ),
                            child: Text(
                              signupState.passwordError,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontFamily: 'Karla',
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),

                        // Password requirements section
                        if (signupState.password.isNotEmpty) ...[
                          SizedBox(height: 18.h),
                          Text(
                            'Your password must include all of these:',
                            style: TextStyle(
                              color: AppColors.neutral700,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Karla',
                            ),
                          ),
                          SizedBox(height: 8.h),
                          _buildPasswordRequirement(
                            'At least 8 characters long',
                            signupState.hasMinLength,
                          ),
                          _buildPasswordRequirement(
                            'One uppercase letter (A-Z)',
                            signupState.hasUppercase,
                          ),
                          _buildPasswordRequirement(
                            'One lowercase letter (a-z)',
                            signupState.hasLowercase,
                          ),
                          _buildPasswordRequirement(
                            'One number (0-9)',
                            signupState.hasNumber,
                          ),
                          _buildPasswordRequirement(
                            'One special character (!@#\$%^&*)',
                            signupState.hasSpecialCharacter,
                          ),
                        ],

                        SizedBox(height: 18.h),

                        // Confirm password field
                        CustomTextField(
                          label: "Confirm Password",
                          hintText: "Type your password again",
                          keyboardType: TextInputType.visiblePassword,
                          onChanged: signupNotifier.setConfirmPassword,
                          obscureText: signupState.isConfirmPasswordVisible,
                          suffixIcon: IconButton(
                            icon: EyeIcon(
                              isVisible: signupState.isConfirmPasswordVisible,
                              color: AppColors.neutral500,
                              size: 20.0,
                            ),
                            onPressed:
                                () =>
                                    signupNotifier
                                        .toggleConfirmPasswordVisibility(),
                          ),
                        )
                        .animate()
                        .fadeIn(
                          delay: 600.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          delay: 600.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .scale(
                          begin: const Offset(0.98, 0.98),
                          end: const Offset(1.0, 1.0),
                          delay: 600.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .shimmer(
                          delay: 800.ms,
                          duration: 800.ms,
                          color: AppColors.purple500.withOpacity(0.1),
                          angle: 15,
                        ),

                        if (signupState.confirmPasswordError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              left: 16.0,
                            ),
                            child: Text(
                              signupState.confirmPasswordError,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontFamily: 'Karla',
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        SizedBox(height: 12.h),

                        // Terms checkbox
                        CheckboxListTile(
                          contentPadding: const EdgeInsets.only(
                            left: -16,
                            right: 0,
                            top: 0,
                            bottom: 0,
                          ),
                          title: Text.rich(
                            TextSpan(
                              text:
                                  'I have read and agree to the ',
                              style: TextStyle(
                                color: AppColors.neutral800,
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Karla',
                                letterSpacing: -.3,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms of Use',
                                  style: TextStyle(
                                    color: const Color.fromARGB(255, 21, 68, 221),
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Karla',
                                    //  letterSpacing: -.6,
                                    height: 1.4,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Opening Terms of Use...',
                                              ),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                ),
                                TextSpan(
                                  text: ' and ',
                                  style: TextStyle(
                                    color: AppColors.neutral800,
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Karla',
                                    letterSpacing: -.3,
                                    height: 1.4,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Privacy policy',
                                  style: TextStyle(
                               color: const Color.fromARGB(255, 21, 68, 221),
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Karla',
                                     letterSpacing: -.6,
                                    height: 1.4,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Opening privacy policy...',
                                              ),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                ),
                                TextSpan(
                                  text: ' for Dayfi.',
                                  style: TextStyle(
                                    color: AppColors.neutral800,
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Karla',
                                    letterSpacing: -.3,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          value: signupState.isAgreed,
                          activeColor: AppColors.purple500,
                          onChanged:
                              (value) =>
                                  signupNotifier.setAgreed(value ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                        )
                        .animate()
                        .fadeIn(
                          delay: 700.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          delay: 700.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .scale(
                          begin: const Offset(0.98, 0.98),
                          end: const Offset(1.0, 1.0),
                          delay: 700.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .shimmer(
                          delay: 900.ms,
                          duration: 800.ms,
                          color: AppColors.purple500.withOpacity(0.1),
                          angle: 15,
                        ),


                        SizedBox(height: 24.h),

                        // Submit button
                        PrimaryButton(
                          borderRadius: 38,
                          text: "Create my account",
                          onPressed:
                              signupState.isFormValid && !signupState.isBusy
                                  ? () => signupNotifier.signup(context)
                                  : null,
                          enabled:
                              signupState.isFormValid && !signupState.isBusy,
                          isLoading: signupState.isBusy,
                          backgroundColor:
                              signupState.isFormValid
                                  ? AppColors.purple500
                                  : AppColors.purple200,
                          height: 60.h,
                          textColor: AppColors.neutral0,
                          fontFamily: 'Karla',
                          letterSpacing: -.48,
                          fontSize: 18,
                          width: 375.w,
                          fullWidth: true,
                        )
                        .animate()
                        .fadeIn(
                          delay: 800.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          delay: 800.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .scale(
                          begin: const Offset(0.95, 0.95),
                          end: const Offset(1.0, 1.0),
                          delay: 800.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        ),

                        SizedBox(height: 24.h),

                        // Login link
                        Center(
                          child: Text.rich(
                            textAlign: TextAlign.center,
                            TextSpan(
                              text: "I already have an account",
                              style: TextStyle(
                                fontFamily: 'Karla',
                                color: AppColors.neutral800,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                                letterSpacing: -.6,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(
                                  text: "\nSign in",
                                  style: TextStyle(
                                    fontFamily: 'Karla',
                                    color: AppColors.purple500,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -.6,
                                    height: 1.4,
                                    // decoration: TextDecoration.underline,
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = () {
                                          // Navigate to login
                                          // signupNotifier.resetForm();
                                          signupNotifier.navigateToLogin();
                                        },
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(
                          delay: 900.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          delay: 900.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
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

  Widget _buildPasswordRequirement(String text, bool isValid) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.circle_outlined,
            color: isValid ? Colors.green : AppColors.neutral400,
            size: 16.r,
          ),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              color: isValid ? AppColors.neutral700 : AppColors.neutral500,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              fontFamily: 'Karla',
            ),
          ),
        ],
      ),
    );
  }
}
