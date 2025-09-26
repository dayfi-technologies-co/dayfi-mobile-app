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
          // Advanced animated background with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xffF6F5FE).withOpacity(0.4),
                  const Color(0xff5645F5).withOpacity(0.1),
                  const Color(0xffF6F5FE).withOpacity(0.6),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          )
          .animate()
          .fadeIn(duration: 1000.ms, curve: Curves.easeOutCubic)
          .scale(
            begin: const Offset(1.1, 1.1),
            end: const Offset(1.0, 1.0),
            duration: 1200.ms,
            curve: Curves.easeOutCubic,
          ),

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
              .scale(begin: const Offset(1.05, 1.05), end: const Offset(1.0, 1.0), duration: 600.ms, curve: Curves.easeOutCubic),

          // Floating particles background
          ...List.generate(10, (index) => _buildFloatingParticle(index)),

          // Floating geometric shapes
          ...List.generate(6, (index) => _buildFloatingShape(index)),

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
                          isSignUp ? "Verify Your Email" : "Reset Your Password",
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
                        
                        // Subtitle with smooth entrance and masked email
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: isSignUp
                                    ? "We've sent a verification code to your email address. Please check your inbox and enter the 6-digit code below to continue with your account setup."
                                    : "We've sent a password reset code to your email address. Please check your inbox and enter the 6-digit code below to reset your password.",
                                style: TextStyle(
                                  fontFamily: 'Karla',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                  height: 1.5,
                                  color: const Color(0xFF302D53),
                                ),
                              ),
                              // TextSpan(
                              //   text: "\n\nEmail: ${_maskEmail(email)}",
                              //   style: TextStyle(
                              //     fontFamily: 'Karla',
                              //     fontSize: 14,
                              //     fontWeight: FontWeight.w600,
                              //     letterSpacing: 0.2,
                              //     height: 1.4,
                              //     color: const Color(0xff5645F5),
                              //   ),
                              // ),
                            ],
                          ),
                          textAlign: TextAlign.start,
                        )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                            .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                        
                        verticalSpace(36.h),
                        
                        // PIN field instruction
                        Text(
                          "Enter the 6-digit verification code:",
                          style: TextStyle(
                            fontFamily: 'Karla',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                            height: 1.4,
                            color: const Color(0xFF302D53),
                          ),
                          textAlign: TextAlign.center,
                        )
                        .animate()
                        .fadeIn(delay: 450.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                        .slideY(begin: 0.2, end: 0, delay: 450.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                        
                        verticalSpace(16.h),
                        
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
                                  "Resend Code",
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
                          text: isSignUp ? "Verify & Complete Setup" : "Verify & Reset Password",
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

  String _maskEmail(String email) {
    if (email.isEmpty) return email;
    
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) {
      return '${username[0]}***@$domain';
    }
    
    final maskedUsername = '${username[0]}${'*' * (username.length - 2)}${username[username.length - 1]}';
    return '$maskedUsername@$domain';
  }

  Widget _buildFloatingParticle(int index) {
    final colors = [
      const Color(0xff5645F5).withOpacity(0.08),
      const Color(0xff7C3AED).withOpacity(0.06),
      const Color(0xffEC4899).withOpacity(0.05),
      const Color(0xff10B981).withOpacity(0.07),
      const Color(0xffF59E0B).withOpacity(0.06),
    ];
    
    return Positioned(
      top: (80 + (index * 60)).h,
      left: (30 + (index * 80)).w,
      child: Container(
        width: (6 + (index % 4) * 3).w,
        height: (6 + (index % 4) * 3).w,
        decoration: BoxDecoration(
          color: colors[index % colors.length],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors[index % colors.length],
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      )
      .animate()
      .fadeIn(
        delay: Duration(milliseconds: 800 + (index * 150)),
        duration: 1200.ms,
        curve: Curves.easeOutCubic,
      )
      .scale(
        begin: const Offset(0.0, 0.0),
        end: const Offset(1.0, 1.0),
        delay: Duration(milliseconds: 800 + (index * 150)),
        duration: 1000.ms,
        curve: Curves.elasticOut,
      )
      .moveY(
        begin: 0,
        end: -30,
        duration: 4000.ms,
        curve: Curves.easeInOut,
      )
      .then()
      .moveY(
        begin: -30,
        end: 0,
        duration: 4000.ms,
        curve: Curves.easeInOut,
      ),
    );
  }

  Widget _buildFloatingShape(int index) {
    final shapes = ['circle', 'square', 'triangle', 'diamond'];
    final colors = [
      const Color(0xff5645F5).withOpacity(0.12),
      const Color(0xff7C3AED).withOpacity(0.10),
      const Color(0xffEC4899).withOpacity(0.08),
      const Color(0xff10B981).withOpacity(0.09),
    ];
    
    return Positioned(
      top: (120 + (index * 90)).h,
      left: (60 + (index * 100)).w,
      child: Container(
        width: (15 + (index * 3)).w,
        height: (15 + (index * 3)).w,
        decoration: BoxDecoration(
          color: colors[index % colors.length],
          shape: shapes[index % shapes.length] == 'circle' 
              ? BoxShape.circle 
              : BoxShape.rectangle,
          borderRadius: shapes[index % shapes.length] == 'circle' 
              ? null 
              : shapes[index % shapes.length] == 'diamond'
                  ? BorderRadius.circular(2)
                  : BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              color: colors[index % colors.length],
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      )
      .animate()
      .fadeIn(
        delay: Duration(milliseconds: 1000 + (index * 200)),
        duration: 1500.ms,
        curve: Curves.easeOutCubic,
      )
      .scale(
        begin: const Offset(0.0, 0.0),
        end: const Offset(1.0, 1.0),
        delay: Duration(milliseconds: 1000 + (index * 200)),
        duration: 1200.ms,
        curve: Curves.elasticOut,
      )
      .rotate(
        begin: 0,
        end: 2 * 3.14159,
        duration: 25000.ms,
        curve: Curves.linear,
      )
      .moveX(
        begin: 0,
        end: 20,
        duration: 6000.ms,
        curve: Curves.easeInOut,
      )
      .then()
      .moveX(
        begin: 20,
        end: 0,
        duration: 6000.ms,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  VerifyEmailViewModel viewModelBuilder(BuildContext context) =>
      VerifyEmailViewModel(emailAddress: email);
}
