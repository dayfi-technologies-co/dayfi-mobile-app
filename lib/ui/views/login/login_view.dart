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

import 'login_viewmodel.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginViewModel>.reactive(
      viewModelBuilder: () => LoginViewModel(),
      builder:
          (context, model, child) => Stack(
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

              // Background image with enhanced animations
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
                  .fadeIn(duration: 800.ms, curve: Curves.easeOutCubic)
                  .scale(
                    begin: const Offset(1.1, 1.1),
                    end: const Offset(1.0, 1.0),
                    duration: 1000.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .shimmer(
                    duration: 4000.ms,
                    color: Colors.white.withOpacity(0.1),
                    angle: 30,
                  ),

              // Floating particles background
              ...List.generate(12, (index) => _buildFloatingParticle(index)),

              // Floating geometric shapes
              ...List.generate(8, (index) => _buildFloatingShape(index)),

              // Main content with staggered animations
              AppScaffold(
                    backgroundColor: Colors.transparent,
                    body: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          verticalSpace(12.h),

                          // Advanced back button without shadow
                          Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: IconButton(
                                  onPressed:
                                      () => model.navigationService
                                          .clearStackAndShow(
                                            Routes.startupView,
                                          ),
                                  icon: const Icon(
                                    Icons.arrow_back_ios,
                                    color: Color(0xff5645F5),
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(
                                delay: 300.ms,
                                duration: 500.ms,
                                curve: Curves.easeOutCubic,
                              )
                              .slideX(
                                begin: -0.3,
                                end: 0,
                                delay: 300.ms,
                                duration: 500.ms,
                                curve: Curves.easeOutCubic,
                              )
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                end: const Offset(1.0, 1.0),
                                delay: 300.ms,
                                duration: 500.ms,
                                curve: Curves.elasticOut,
                              )
                              .shimmer(
                                delay: 1000.ms,
                                duration: 1500.ms,
                                color: const Color(0xff5645F5).withOpacity(0.3),
                                angle: 30,
                              ),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                verticalSpace(16.h),

                                // Title with smooth entrance
                                Text(
                                      "Sign in to your account",
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
                                      "Enter your login information to sign in and enjoy seamless transactions.",
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

                                _buildAnimatedFormField(
                                  child: CustomTextField(
                                    label: "Password",
                                    hintText: "Password",
                                    errorText: model.passwordError,
                                    onChanged: model.setPassword,
                                    keyboardType: TextInputType.visiblePassword,
                                    textInputAction: TextInputAction.done,
                                  ),
                                  delay: 600.ms,
                                ),

                                verticalSpace(17.5.h),

                                // Forgot password link with animation
                                _buildAnimatedFormField(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text.rich(
                                      textAlign: TextAlign.end,
                                      TextSpan(
                                        text: "I forgot my password!",
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
                                                      model.navigationService
                                                          .navigateToForgotPasswordView(),
                                      ),
                                    ),
                                  ),
                                  delay: 700.ms,
                                ),

                                verticalSpace(72.h),

                                // Login button with enhanced animation
                                _buildAnimatedFormField(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xff5645F5,
                                          ).withOpacity(0.3),
                                          blurRadius: 20,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: FilledBtn(
                                      onPressed:
                                          model.isFormValid && !model.isBusy
                                              ? () => model.login(context)
                                              : null,
                                      text: "Login",
                                      isLoading: model.isBusy,
                                      backgroundColor:
                                          model.isFormValid
                                              ? const Color(0xff5645F5)
                                              : const Color(0xffCAC5FC),
                                      semanticLabel: 'Sign in to your account',
                                    ),
                                  ),
                                  delay: 800.ms,
                                ).animate().shimmer(
                                  delay: 900.ms,
                                  duration: 1000.ms,
                                  color: Colors.white.withOpacity(0.3),
                                ),

                                SizedBox(height: 24.h),

                                // Signup link with final animation
                                _buildAnimatedFormField(
                                  child: Center(
                                    child: Text.rich(
                                      textAlign: TextAlign.end,
                                      TextSpan(
                                        text: "I don't have an account",
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
                                            text: " Signup",
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
                                                              .navigateToSignupView(),
                                          ),
                                        ],
                                      ),
                                      semanticsLabel:
                                          'Sign up link for new users',
                                    ),
                                  ),
                                  delay: 1000.ms,
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
          .moveY(begin: 0, end: -30, duration: 4000.ms, curve: Curves.easeInOut)
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
              shape:
                  shapes[index % shapes.length] == 'circle'
                      ? BoxShape.circle
                      : BoxShape.rectangle,
              borderRadius:
                  shapes[index % shapes.length] == 'circle'
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
          .moveX(begin: 0, end: 20, duration: 6000.ms, curve: Curves.easeInOut)
          .then()
          .moveX(begin: 20, end: 0, duration: 6000.ms, curve: Curves.easeInOut),
    );
  }
}
