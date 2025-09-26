// import 'package:google_fonts/google_fonts.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/input_fields/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stacked/stacked.dart';

import 'reset_password_viewmodel.dart';

class ResetPasswordView extends StatelessWidget {
  final String email;
  const ResetPasswordView({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ResetPasswordViewModel>.reactive(
      viewModelBuilder: () => ResetPasswordViewModel(),
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

          // Floating particles background
          ...List.generate(10, (index) => _buildFloatingParticle(index)),

          // Floating geometric shapes
          ...List.generate(6, (index) => _buildFloatingShape(index)),

          // Main content
          Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: Opacity(
              opacity: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/backgroud.png',
                  fit: BoxFit.cover,
                  // color: Colors.OrangeAccent.shade200,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
            ),
          ),
          AppScaffold(
            // isModelBusy: model.isBusy,
            // resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  verticalSpace(12.h),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: IconButton(
                        onPressed: () {
                          model.navigationService.back();
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xff5645F5), // innit
                        )),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    // decoration: const BoxDecoration(
                    //     image: DecorationImage(
                    //         image: AssetImage("assets/images/IMG-20250508-WA0030.png"))),
                    // constraints: const BoxConstraints.expand(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        verticalSpace(16.h),
                        Text(
                          "Set your new password",
                          style: TextStyle(
                            fontSize: 22.00,
                            height: 1.2,
                            fontFamily: 'Karla',
                            letterSpacing: 0.00,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff2A0079),
                            // color: Color( 0xff5645F5), // innit
                          ),
                          textAlign: TextAlign.start,
                        ),
                        verticalSpace(8.h),
                        Text(
                          "Create a new password for your dayfi account and get back in!",
                          style: TextStyle(
                            fontFamily: 'Karla',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            height: 1.450,
                            color: Color(0xFF302D53),
                          ),
                          textAlign: TextAlign.start,
                        ),
                        verticalSpace(36.h),
                        CustomTextField(
                          label: "Password",
                          hintText: "Password",
                          errorText: model.passwordError,
                          onChanged: model.setPassword,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.none,
                        ),
                        verticalSpace(17.5.h),
                        CustomTextField(
                          label: "Confirm Password",
                          hintText: "Password",
                          errorText: model.confirmPasswordError,
                          onChanged: model.setConfirmPassword,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                        ),
                        verticalSpace(72.h),
                        SizedBox(
                          child: FilledBtn(
                            onPressed: model.isFormValid && !model.isBusy
                                ? () => model.resetPassword(email, context)
                                : null,
                            text: "Complete",
                            isLoading: model.isBusy,
                            // textColor: Colors.white,
                            backgroundColor: model.isFormValid
                                ? const Color(0xff5645F5)
                                : const Color(0xffCAC5FC),
                          ),
                        ),
                        verticalSpace(40.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
}
