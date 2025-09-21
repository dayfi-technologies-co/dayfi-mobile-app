import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/views/signup/signup_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stacked/stacked.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/input_fields/custom_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SignupViewModel>.reactive(
      viewModelBuilder: () => SignupViewModel(),
      builder:
          (context, model, child) => Stack(
            children: [
              // Background with entrance animation
              Scaffold(
                    backgroundColor: const Color(0xffF6F5FE),
                    resizeToAvoidBottomInset: false,
                    body: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/images/backgroud.png',
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, curve: Curves.easeOutCubic)
                  .scale(
                    begin: const Offset(1.05, 1.05),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.easeOutCubic,
                  ),

              // Main content with staggered animations
              AppScaffold(
                    backgroundColor: Colors.transparent,
                    body: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          verticalSpace(12.h),

                          // // Back button with subtle animation
                          // Padding(
                          //   padding: const EdgeInsets.only(left: 8.0),
                          //   child: IconButton(
                          //     onPressed: () => model.navigationService.clearStackAndShow(Routes.startupView),
                          //     icon: const Icon(
                          //       Icons.arrow_back_ios,
                          //       color: Color(0xff5645F5),
                          //     ),
                          //   ),
                          // )
                          //     .animate()
                          //     .fadeIn(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutCubic)
                          //     .slideX(begin: -0.2, end: 0, delay: 200.ms, duration: 400.ms, curve: Curves.easeOutCubic),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                verticalSpace(16.h),

                                // Title with smooth entrance
                                Text(
                                      "Get started",
                                      style: TextStyle(
                                        fontFamily: 'Boldonse',
                                        fontSize: 22.00,
                                        height: 1.2,
                                        letterSpacing: 0.00,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xff2A0079),
                                      ),
                                      textAlign: TextAlign.start,
                                    )
                                    .animate()
                                    .fadeIn(
                                      delay: 300.ms,
                                      duration: 500.ms,
                                      curve: Curves.easeOutCubic,
                                    )
                                    .slideY(
                                      begin: 0.3,
                                      end: 0,
                                      delay: 300.ms,
                                      duration: 500.ms,
                                      curve: Curves.easeOutCubic,
                                    )
                                    .scale(
                                      begin: const Offset(0.95, 0.95),
                                      end: const Offset(1.0, 1.0),
                                      delay: 300.ms,
                                      duration: 500.ms,
                                      curve: Curves.easeOutCubic,
                                    ),

                                verticalSpace(8.h),

                                // Subtitle with smooth entrance
                                Text(
                                      "Let's begin by requesting your fundamental details to get started.",
                                      style: TextStyle(
                                        fontFamily: 'Karla',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                        height: 1.450,
                                        color: const Color(0xFF302D53),
                                      ),
                                      textAlign: TextAlign.start,
                                    )
                                    .animate()
                                    .fadeIn(
                                      delay: 400.ms,
                                      duration: 500.ms,
                                      curve: Curves.easeOutCubic,
                                    )
                                    .slideY(
                                      begin: 0.2,
                                      end: 0,
                                      delay: 400.ms,
                                      duration: 500.ms,
                                      curve: Curves.easeOutCubic,
                                    ),

                                verticalSpace(36.h),

                                // Form fields with staggered animations
                                _buildAnimatedFormField(
                                  child: CustomTextField(
                                    label: "Email Address",
                                    hintText: "dayfi@example.com",
                                    errorText: model.emailError,
                                    onChanged: model.setEmail,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    textCapitalization: TextCapitalization.none,
                                  ),
                                  delay: 500.ms,
                                ),

                                verticalSpace(17.5.h),

                                // Name fields row
                                _buildAnimatedFormField(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: CustomTextField(
                                          label: "First Name",
                                          hintText: "Sade",
                                          keyboardType: TextInputType.name,
                                          textInputAction: TextInputAction.next,
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'First name is required';
                                            }
                                            if (!RegExp(
                                              r'^[a-zA-Z\s-]+$',
                                            ).hasMatch(value.trim())) {
                                              return 'Invalid characters';
                                            }
                                            return null;
                                          },
                                          errorText: model.firstNameError,
                                          onChanged: model.setFirstName,
                                        ),
                                      ),
                                      horizontalSpaceSmall,
                                      Expanded(
                                        child: CustomTextField(
                                          label: "Last Name (Surname)",
                                          hintText: "Olukoya",
                                          keyboardType: TextInputType.name,
                                          textInputAction: TextInputAction.next,
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'Last name is required';
                                            }
                                            if (!RegExp(
                                              r'^[a-zA-Z\s-]+$',
                                            ).hasMatch(value.trim())) {
                                              return 'Invalid characters';
                                            }
                                            return null;
                                          },
                                          errorText: model.lastNameError,
                                          onChanged: model.setLastName,
                                        ),
                                      ),
                                    ],
                                  ),
                                  delay: 600.ms,
                                ),

                                verticalSpace(17.5.h),

                                _buildAnimatedFormField(
                                  child: CustomTextField(
                                    label: "Middle Name (Optional)",
                                    hintText: "Ejiro",
                                    keyboardType: TextInputType.name,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) {
                                      if (value != null &&
                                          value.trim().isNotEmpty &&
                                          !RegExp(
                                            r'^[a-zA-Z\s-]+$',
                                          ).hasMatch(value.trim())) {
                                        return 'Invalid characters';
                                      }
                                      return null;
                                    },
                                    onChanged: model.setMiddleName,
                                  ),
                                  delay: 700.ms,
                                ),

                                verticalSpace(17.5.h),

                                _buildAnimatedFormField(
                                  child: CustomTextField(
                                    label: "Password",
                                    hintText: "Password",
                                    errorText: model.passwordError,
                                    onChanged: model.setPassword,
                                    keyboardType: TextInputType.visiblePassword,
                                    textInputAction: TextInputAction.done,
                                  ),
                                  delay: 800.ms,
                                ),

                                verticalSpace(17.5.h),

                                _buildAnimatedFormField(
                                  child: CustomTextField(
                                    label: "Verify Password",
                                    hintText: "Password",
                                    keyboardType: TextInputType.visiblePassword,
                                    textInputAction: TextInputAction.done,
                                    onChanged: model.setConfirmPassword,
                                    errorText: model.confirmPasswordError,
                                  ),
                                  delay: 900.ms,
                                ),

                                verticalSpace(17.5.h),

                                // Terms checkbox with animation
                                _buildAnimatedFormField(
                                  child: CheckboxListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      'I understand and agree to the Terms of Use and Privacy Policy',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -.04,
                                        height: 1.450,
                                        color: const Color(0xff304463),
                                      ),
                                    ),
                                    value: model.isAgreed,
                                    activeColor: const Color(0xff5645F5),
                                    onChanged:
                                        (value) =>
                                            model.setAgreed(value ?? false),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                  ),
                                  delay: 1000.ms,
                                ),

                                verticalSpace(8.h),

                                // Submit button with enhanced animation
                                _buildAnimatedFormField(
                                  child: FilledBtn(
                                    onPressed:
                                        model.isFormValid && !model.isBusy
                                            ? () => model.signup(context)
                                            : null,
                                    text: "Next - Email verification",
                                    isLoading: model.isBusy,
                                    backgroundColor:
                                        model.isFormValid
                                            ? const Color(0xff5645F5)
                                            : const Color(0xffCAC5FC),
                                    semanticLabel:
                                        'Proceed to email verification',
                                  ),
                                  delay: 1100.ms,
                                ).animate().shimmer(
                                  delay: 1200.ms,
                                  duration: 1000.ms,
                                  color: Colors.white.withOpacity(0.3),
                                ),

                                SizedBox(height: 24.h),

                                // Login link with final animation
                                _buildAnimatedFormField(
                                  child: Center(
                                    child: Text.rich(
                                      textAlign: TextAlign.end,
                                      TextSpan(
                                        text: "I have an account",
                                        style: TextStyle(
                                          fontFamily: 'Karla',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: -.04,
                                          height: 1.450,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .color!
                                              .withOpacity(.85),
                                        ),
                                        children: [
                                          TextSpan(
                                            text: " Log in",
                                            style: const TextStyle(
                                              fontFamily: 'Karla',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: -.04,
                                              height: 1.450,
                                              color: Color(0xff5645F5),
                                            ),
                                            recognizer:
                                                TapGestureRecognizer()
                                                  ..onTap =
                                                      () =>
                                                          model
                                                              .navigationService
                                                              .navigateToLoginView(),
                                          ),
                                        ],
                                      ),
                                      semanticsLabel:
                                          'Log in link for existing users',
                                    ),
                                  ),
                                  delay: 1200.ms,
                                ),

                                verticalSpace(40.h),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(
                    delay: 100.ms,
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .slideY(
                    begin: 0.1,
                    end: 0,
                    delay: 100.ms,
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ],
          ),
    );
  }

  /// Helper method to create consistently animated form fields
  Widget _buildAnimatedFormField({
    required Widget child,
    required Duration delay,
  }) {
    return child
        .animate()
        .fadeIn(delay: delay, duration: 500.ms, curve: Curves.easeOutCubic)
        .slideY(
          begin: 0.3,
          end: 0,
          delay: delay,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        )
        .scale(
          begin: const Offset(0.98, 0.98),
          end: const Offset(1.0, 1.0),
          delay: delay,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
