import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/input_fields/pin_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stacked/stacked.dart';

import 'verify_email_viewmodel.dart';

class VerifyEmailView extends StackedView<VerifyEmailViewModel> {
  final bool isSignUp;
  final String email;
  final String password;
  // final bool notActivated;
  const VerifyEmailView({
    super.key,
    this.isSignUp = false,
    required this.email,
    this.password = "",
    // this.notActivated = false,
  });

  @override
  Widget builder(
    BuildContext context,
    VerifyEmailViewModel model,
    Widget? child,
  ) {
    // print("password: $password");
    return ViewModelBuilder<VerifyEmailViewModel>.reactive(
      viewModelBuilder: () => VerifyEmailViewModel(),
      builder: (context, model, child) => Stack(
        children: [
          // Background with entrance animation
          Scaffold(
            backgroundColor: const Color(0xffF6F5FE),
            resizeToAvoidBottomInset: false,
            body: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Opacity(
                opacity: .1,
                child: Image.asset(
                  'assets/images/background.png',
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, curve: Curves.easeOutCubic)
              .scale(begin: const Offset(1.05, 1.05), end: const Offset(1.0, 1.0), duration: 600.ms, curve: Curves.easeOutCubic),
          // Main content with staggered animations
          AppScaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  verticalSpace(12.h),
                  
                  // Back button with subtle animation
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: IconButton(
                      onPressed: () => model.navigationService.back(),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xff5645F5),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutCubic)
                      .slideX(begin: -0.2, end: 0, delay: 200.ms, duration: 400.ms, curve: Curves.easeOutCubic),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        verticalSpace(24.h),
                        
                        // Title with smooth entrance
                        Text(
                          isSignUp ? "Verify OTP" : "Reset OTP",
                          style: TextStyle(
                            fontSize: 22.00,
                            fontFamily: 'Boldonse',
                            height: 1.2,
                            letterSpacing: 0.00,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff2A0079),
                          ),
                          textAlign: TextAlign.start,
                        )
                            .animate()
                            .fadeIn(delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                            .slideY(begin: 0.3, end: 0, delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                            .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                        
                        verticalSpace(8.h),
                        
                        // Subtitle with smooth entrance
                        Text(
                          isSignUp
                              ? "We've sent you verify codes to your email. Please, check your inbox, copy the codes from the email, and paste them here."
                              : "We've sent you reset codes to your email. Please, check your inbox, copy the codes from the email, and paste them here.",
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
                            .fadeIn(delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                            .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                        
                        verticalSpace(36.h),
                        
                        // PIN field with animation
                        PinTextField(
                          length: 6,
                          onTextChanged: model.setOtpCode,
                        )
                            .animate()
                            .fadeIn(delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                            .slideY(begin: 0.3, end: 0, delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                            .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                        
                        verticalSpace(17.5.h),
                        
                        // Timer/Resend section with animation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            model.canResend
                                ? const SizedBox.shrink()
                                : Text(
                                    model.timerText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -.04,
                                      height: 1.450,
                                      color: model.canResend
                                          ? const Color(0xff5645F5)
                                          : Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .color!
                                              .withOpacity(.85),
                                    ),
                                  ),
                            if (model.canResend) ...[
                              horizontalSpaceTiny,
                              GestureDetector(
                                onTap: model.isBusy
                                    ? null
                                    : () => model.resendOTP(context, email),
                                child: const Text(
                                  "Resend",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff5645F5),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        )
                            .animate()
                            .fadeIn(delay: 600.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                            .slideY(begin: 0.2, end: 0, delay: 600.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                        
                        verticalSpace(32.h),
                        
                        // Submit button with enhanced animation
                        FilledBtn(
                          onPressed: model.isFormValid && !model.isBusy
                              ? () => isSignUp
                                  ? model.verifySignup(context, email, password)
                                  : model.verifyForgotPassword(context, email)
                              : null,
                          text: isSignUp ? "Complete" : "Next - Reset New Password",
                          isLoading: model.isBusy,
                          backgroundColor: model.isFormValid
                              ? const Color(0xff5645F5)
                              : const Color(0xffCAC5FC),
                          semanticLabel: isSignUp ? 'Complete email verification' : 'Reset password with OTP',
                        )
                            .animate()
                            .fadeIn(delay: 700.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                            .slideY(begin: 0.3, end: 0, delay: 700.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                            .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: 700.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                            .shimmer(delay: 800.ms, duration: 1000.ms, color: Colors.white.withOpacity(0.3)),
                        
                        verticalSpace(40.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 500.ms, curve: Curves.easeOutCubic)
              .slideY(begin: 0.1, end: 0, delay: 100.ms, duration: 500.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  @override
  VerifyEmailViewModel viewModelBuilder(BuildContext context) =>
      VerifyEmailViewModel(emailAddress: email);
}
