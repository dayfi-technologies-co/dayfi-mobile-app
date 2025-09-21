import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/input_fields/custom_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stacked/stacked.dart';

import 'forgot_password_viewmodel.dart';

class ForgotPasswordView extends StackedView<ForgotPasswordViewModel> {
  const ForgotPasswordView({super.key});

  @override
  Widget builder(
    BuildContext context,
    ForgotPasswordViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
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
                      onPressed: () => viewModel.navigationService.back(),
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
                        verticalSpace(16.h),
                        
                        // Title with smooth entrance
                        Text(
                          "Forgot password",
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
                            .fadeIn(delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                            .slideY(begin: 0.3, end: 0, delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                            .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                        
                        verticalSpace(8.h),
                        
                        // Subtitle with smooth entrance
                        Text(
                          "Reset your password by entering your dayfi account email.",
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
                        
                        // Email field with animation
                        CustomTextField(
                          label: "Email Address",
                          hintText: "dayfi@example.com",
                          errorText: viewModel.emailError,
                          onChanged: viewModel.setEmail,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.none,
                        )
                            .animate()
                            .fadeIn(delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                            .slideY(begin: 0.3, end: 0, delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                            .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                        
                        verticalSpace(72.h),
                        
                        // Submit button with enhanced animation
                        FilledBtn(
                          onPressed: viewModel.isFormValid && !viewModel.isBusy
                              ? () => viewModel.forgotPassword(context)
                              : null,
                          text: "Next - Receive Reset Code",
                          isLoading: viewModel.isBusy,
                          backgroundColor: viewModel.isFormValid
                              ? const Color(0xff5645F5)
                              : const Color(0xffCAC5FC),
                          semanticLabel: 'Send password reset code',
                        )
                            .animate()
                            .fadeIn(delay: 600.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                            .slideY(begin: 0.3, end: 0, delay: 600.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                            .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: 600.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                            .shimmer(delay: 700.ms, duration: 1000.ms, color: Colors.white.withOpacity(0.3)),
                        
                        SizedBox(height: 24.h),
                        
                        // Login link with final animation
                        Center(
                          child: Text.rich(
                            textAlign: TextAlign.end,
                            TextSpan(
                              text: "I know my password",
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
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => viewModel.navigationService.navigateToLoginView(),
                                )
                              ],
                            ),
                            semanticsLabel: 'Log in link for users who remember their password',
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 700.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                            .slideY(begin: 0.2, end: 0, delay: 700.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                        
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
  ForgotPasswordViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ForgotPasswordViewModel();
}
