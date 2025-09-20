// import 'package:google_fonts/google_fonts.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/input_fields/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          Scaffold(
            backgroundColor: Color(0xffF6F5FE),
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
                          Icons.arrow_back,
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
}
