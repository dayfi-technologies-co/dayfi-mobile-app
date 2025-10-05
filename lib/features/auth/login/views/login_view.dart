import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/common/widgets/eye_icon.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/features/auth/login/vm/login_viewmodel.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';

class LoginView extends ConsumerStatefulWidget {
  final bool showBackButton;
  
  const LoginView({
    super.key,
    this.showBackButton = true,
  });

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  @override
  void initState() {
    super.initState();
    // Reset form when view is initialized (handles logout navigation)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loginProvider.notifier).resetForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final loginNotifier = ref.read(loginProvider.notifier);

    return PopScope(
      canPop: widget.showBackButton, // Only allow back if showBackButton is true
      onPopInvoked: (didPop) {
        if (widget.showBackButton) {
          // Reset form when back button is pressed
          loginNotifier.resetForm();
        }
      },
      child: GestureDetector(
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
                    leading: widget.showBackButton ? IconButton(
                      onPressed: () {
                        loginNotifier.resetForm();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ) : const SizedBox.shrink(),
                    title: Text(
                      "Sign in",
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
                            "Please enter your email and password\nto access your account",
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

                        // Email field
                        CustomTextField(
                          label: "Email Address",
                          hintText: "Enter your email address here",
                          onChanged: loginNotifier.setEmail,
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

                        if (loginState.emailError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, left: 14),
                            child: Text(
                              loginState.emailError,
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

                        SizedBox(height: 17.5.h),

                        // Password field
                        CustomTextField(
                          label: "Password",
                          hintText: "Enter your password here",
                          onChanged: loginNotifier.setPassword,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: loginState.isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: EyeIcon(
                              isVisible: loginState.isPasswordVisible,
                              color: AppColors.neutral500,
                              size: 20.0,
                            ),
                            onPressed:
                                () => loginNotifier.togglePasswordVisibility(),
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

                        if (loginState.passwordError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, left: 14),
                            child: Text(
                              loginState.passwordError,
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

                        SizedBox(height: 17.5.h),

                        // Forgot password link
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text.rich(
                            textAlign: TextAlign.end,
                            TextSpan(
                              text: "I forgot my password!",
                              style: TextStyle(
                                fontFamily: 'Karla',
                                color: AppColors.purple500,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -.3,
                                height: 1.4,
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap =
                                        () =>
                                            loginNotifier
                                                .navigateToForgotPassword(),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(
                          delay: 400.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          delay: 400.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        ),

                        SizedBox(height: 72.h),

                        // Login button
                        PrimaryButton(
                          borderRadius: 38,
                          text: "Sign in",
                          onPressed:
                              loginState.isFormValid && !loginState.isBusy
                                  ? () => loginNotifier.login(context)
                                  : null,
                          enabled: loginState.isFormValid && !loginState.isBusy,
                          isLoading: loginState.isBusy,
                          backgroundColor:
                              loginState.isFormValid
                                  ? AppColors.purple500
                                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
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

                        SizedBox(height: 24.h),

                        // Signup link
                        Center(
                          child: Text.rich(
                            textAlign: TextAlign.center,
                            TextSpan(
                              text: "I don't have an account",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontFamily: 'Karla',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -.6,
                                    height: 1.4,
                                  ),
                              children: [
                                TextSpan(
                                  text: "\nCreate account",
                                  style: TextStyle(
                                    fontFamily: 'Karla',
                                    color: AppColors.purple500,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -.3,
                                    height: 1.4,
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap =
                                            () =>
                                                loginNotifier
                                                    .navigateToSignup(),
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(
                          delay: 600.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          delay: 600.ms,
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
    ),
    );
  }
}
