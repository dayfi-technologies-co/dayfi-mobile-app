import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/input_fields/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stacked/stacked.dart';

import 'verify_phone_viewmodel.dart';

class VerifyPhoneView extends StackedView<VerifyPhoneViewModel> {
  final String phoneNumber;
  final String country;
  final String state;
  final String street;
  final String city;
  final String postalCode;
  final String address;
  final String gender;
  final String dob;

  const VerifyPhoneView({
    super.key,
    required this.phoneNumber,
    required this.country,
    required this.state,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.address,
    required this.gender,
    required this.dob,
  });

  @override
  Widget builder(
    BuildContext context,
    VerifyPhoneViewModel model,
    Widget? child,
  ) {
    return AppScaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color(0xffF6F5FE),
        leading: IconButton(
          onPressed: () => model.navigationService.back(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xff5645F5),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Text(
              "3 of 3",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                height: 1.450,
                color: const Color(0xFF302D53),
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xffF6F5FE),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  verticalSpace(12.h),
                  
                  // Title with smooth entrance
                  Text(
                    "Secure your account",
                    style: TextStyle(
                      fontFamily: 'Boldonse',
                      fontSize: 27.5,
                      height: 1.2,
                      letterSpacing: -0.2,
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
                  Padding(
                    padding: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.25,
                    ),
                    child: Text(
                      "This will take about 4 minutes to complete, we promise :)",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        height: 1.450,
                        color: const Color(0xFF302D53),
                      ),
                      textAlign: TextAlign.start,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                      .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                  
                  verticalSpace(36.h),
                  
                  // BVN input field with animation
                  CustomTextField(
                    label: "BVN",
                    hintText: "",
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.none,
                    maxLength: 11,
                    onChanged: (value) => model.setBvn(
                      value,
                      country: country,
                      state: state,
                      street: street,
                      city: city,
                      postalCode: postalCode,
                      address: address,
                      gender: gender,
                      dob: dob,
                      phoneNumber: phoneNumber,
                    ),
                    suffixIcon: model.isBusy
                        ? Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: CupertinoActivityIndicator(
                              color: const Color(0xff5645F5),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: GestureDetector(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  "Paste",
                                  style: TextStyle(
                                    color: const Color(0xFF302D53),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              onTap: () async {
                                final clipboardData =
                                    await Clipboard.getData('text/plain');
                                if (clipboardData != null &&
                                    clipboardData.text != null) {
                                  model.bvn = clipboardData.text!;
                                  model.setBvn(
                                    clipboardData.text!,
                                    country: country,
                                    state: state,
                                    street: street,
                                    city: city,
                                    postalCode: postalCode,
                                    address: address,
                                    gender: gender,
                                    dob: dob,
                                    phoneNumber: phoneNumber,
                                  );
                                }
                              },
                            ),
                          ),
                    errorText: model.bvnError,
                  )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                      .slideY(begin: 0.3, end: 0, delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                      .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                  verticalSpace(32.h),
                  verticalSpace(40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  VerifyPhoneViewModel viewModelBuilder(BuildContext context) =>
      VerifyPhoneViewModel(phoneNumber: phoneNumber);

  @override
  void onViewModelReady(VerifyPhoneViewModel viewModel) async {
    await viewModel.loadUser();
    super.onViewModelReady(viewModel);
  }
}
