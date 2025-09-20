// import 'package:google_fonts/google_fonts.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
// import 'package:dayfi/ui/common/buttons/filled_btn.dart';
// import 'package:dayfi/ui/common/textfields/textfield_cus.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart' show FilledBtn;
import 'package:dayfi/ui/components/input_fields/custom_text_field.dart';
// import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/views/password_change/password_change_viewmodel.dart';
import 'package:stacked/stacked.dart';

class PasswordChangeView extends StackedView<PasswordChangeViewModel> {
  const PasswordChangeView({super.key});

  @override
  Widget builder(
    BuildContext context,
    PasswordChangeViewModel viewModel,
    Widget? child,
  ) {
    return AppScaffold(
      backgroundColor: const Color(0xffF6F5FE),
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Color(0xffF6F5FE),
        leading: IconButton(
          onPressed: () => viewModel.navigationService.back(),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xff5645F5), // innit
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        constraints: BoxConstraints.expand(),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpace(10),
              Text(
                "Change your password",
                style: TextStyle(
                  fontFamily: 'Boldonse',
                  fontSize: 27.5,
                  height: 1.2,
                  letterSpacing: 0.00,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff2A0079),
                  // color: Color( 0xff5645F5), // innit
                ),
                textAlign: TextAlign.center,
              ),
              verticalSpace(12),
              Text(
                "Set a new password to protect and manage your dayfi account safely.",
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
              verticalSpace(40),
              CustomTextField(
                controller: viewModel.currentPasswordController,
                label: "Old Password",
                hintText: "  ",
              ),
              verticalSpace(17.5),
              CustomTextField(
                controller: viewModel.newPasswordController,
                label: "New Password",
                hintText: "  ",
              ),
              verticalSpace(17.5),
              CustomTextField(
                controller: viewModel.verifyPasswordController,
                label: "Verify New Password",
                hintText: "  ",
              ),
              verticalSpace(72),
              SizedBox(
                child: FilledBtn(
                  onPressed: () {},
                  text: "Next - Update",
                  // textColor: Colors.white,
                  backgroundColor: Color(0xff5645F5),
                ),
              ),
              verticalSpace(40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  PasswordChangeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      PasswordChangeViewModel();
}
