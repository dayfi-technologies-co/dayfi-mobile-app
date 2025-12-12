import 'package:dayfi/features/auth/check_email/vm/check_email_viewmodel.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/eye_icon.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/legal/privacy_notice.dart';
import 'package:dayfi/features/legal/terms_of_use.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/features/auth/signup/vm/signup_viewmodel.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignupView extends ConsumerWidget {
  const SignupView({super.key});

  void _assignEmailFromArguments(
    BuildContext context,
    SignupViewArguments? args,
    SignupNotifier signupNotifier,
    TextEditingController emailController,
  ) {
    if (args != null && args.email.isNotEmpty) {
      signupNotifier.setEmail(args.email);
      emailController.text = args.email;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signupState = ref.watch(signupProvider);
    final signupNotifier = ref.read(signupProvider.notifier);
    final emailController = TextEditingController(text: signupState.email);

    // Get arguments from ModalRoute
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    SignupViewArguments? signupArgs;
    if (routeArgs is SignupViewArguments) {
      signupArgs = routeArgs;
    } else if (routeArgs is String) {
      signupArgs = SignupViewArguments(email: routeArgs);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _assignEmailFromArguments(
        context,
        signupArgs,
        signupNotifier,
        emailController,
      );
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
                  signupNotifier.resetForm(),
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

        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(18.0, 12, 18.0, 40.0),
          child: PrimaryButton(
                borderRadius: 38,
                text: "Verify email address",
                onPressed:
                    signupState.isFormValid && !signupState.isBusy
                        ? () => signupNotifier.signup(context)
                        : null,
                enabled: signupState.isFormValid && !signupState.isBusy,
                isLoading: signupState.isBusy,
                backgroundColor:
                    signupState.isFormValid
                        ? AppColors.purple500
                        : AppColors.purple500ForTheme(context).withOpacity(.15),
                height: 48.00000.h,
                textColor:
                    signupState.isFormValid
                        ? AppColors.neutral0
                        : AppColors.neutral0.withOpacity(.35),
                fontFamily: 'Karla',
                letterSpacing: -.70,
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
        ),

        body: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
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
                        "Complete sign up",
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          fontSize: 18.sp,
                          fontFamily: 'Boldonse',
                          letterSpacing: -.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Email field
                      CustomTextField(
                            label: "Email Address",
                            hintText: "Enter your email address here",
                            controller: emailController,
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
                            color: AppColors.purple500ForTheme(
                              context,
                            ).withOpacity(0.1),
                            angle: 15,
                          ),

                      if (signupState.emailError.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, left: 14),
                          child: Text(
                            signupState.emailError,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                              fontFamily: 'Karla',
                              letterSpacing: -.6,
                              fontWeight: FontWeight.w500,
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
                                      maxLength: 50,
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
                                            fontWeight: FontWeight.w500,
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
                                      maxLength: 50,
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
                                            fontWeight: FontWeight.w500,
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
                            color: AppColors.purple500ForTheme(
                              context,
                            ).withOpacity(0.1),
                            angle: 15,
                          ),

                      SizedBox(height: 18.h),

                      // Middle name field
                      CustomTextField(
                            label: "Middle Name (Optional)",
                            hintText:
                                "Enter your middle name (if you have one)",
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            maxLength: 50,
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
                            color: AppColors.purple500ForTheme(
                              context,
                            ).withOpacity(0.1),
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
                            suffixIcon: InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: EyeIcon(
                                isVisible: signupState.isPasswordVisible,
                                color: AppColors.neutral400,
                                size: 20.0,
                              ),
                              onTap:
                                  () =>
                                      signupNotifier.togglePasswordVisibility(),
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
                            color: AppColors.purple500ForTheme(
                              context,
                            ).withOpacity(0.1),
                            angle: 15,
                          ),

                      if (signupState.passwordError.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 16.0),
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
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            fontFamily: 'Karla',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -.6,
                            height: 1.450,
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
                            suffixIcon: InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: EyeIcon(
                                isVisible: signupState.isConfirmPasswordVisible,
                                color: AppColors.neutral400,
                                size: 20.0,
                              ),
                              onTap:
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
                            color: AppColors.purple500ForTheme(
                              context,
                            ).withOpacity(0.1),
                            angle: 15,
                          ),

                      if (signupState.confirmPasswordError.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 16.0),
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

                      SizedBox(height: 20.h),

                      // Optional: Sign In link
                      Text.rich(
                            textAlign: TextAlign.center,
                            TextSpan(
                              text: 'I confirm that I agree to the ',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Karla',
                                letterSpacing: -.6,
                                height: 1.4,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms of Use',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 13.sp,
                                    letterSpacing: -.6,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Karla',
                                    height: 1.4,
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      const TermsOfUseView(),
                                            ),
                                          );
                                        },
                                ),
                                TextSpan(
                                  text: ' and the ',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Karla',
                                    letterSpacing: -.6,
                                    height: 1.4,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Privacy Notice',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 13.sp,
                                    letterSpacing: -.6,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Karla',
                                    height: 1.4,
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      const PrivacyNoticeView(),
                                            ),
                                          );
                                        },
                                ),
                                TextSpan(
                                  text:
                                      ' for more information about how we collect and process your personal data.',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Karla',
                                    letterSpacing: -.6,
                                    height: 1.4,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
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
                            color: AppColors.purple500ForTheme(
                              context,
                            ).withOpacity(0.1),
                            angle: 15,
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
    );
  }

  Widget _buildPasswordRequirement(String text, bool isValid) {
    return Builder(
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Row(
              children: [
                !isValid
                    ? Icon(
                      Icons.circle_outlined,
                      color: AppColors.neutral400,
                      size: 16.r,
                    )
                    : SvgPicture.asset(
                      'assets/icons/svgs/circle-check.svg',
                      color: Colors.green,
                      height: 16.r,
                    ),
                SizedBox(width: 8.w),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        isValid
                            ? null
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontFamily: 'Karla',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -.6,
                    height: 1.450,
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
