// import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/input_fields/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/ui/views/level_one_part_a/level_one_part_a_view.dart';
import 'package:stacked/stacked.dart';

import 'level_one_part_b_viewmodel.dart';

class LevelOnePartBView extends StackedView<LevelOnePartBViewModel> {
  final String country;
  final String state;
  final String street;
  final String city;
  final String postalCode;
  final String address;
  const LevelOnePartBView({
    super.key,
    required this.country,
    required this.state,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.address,
  });

  @override
  Widget builder(
    BuildContext context,
    LevelOnePartBViewModel model,
    Widget? child,
  ) {
    return AppScaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Color(0xffF6F5FE),
        leading: IconButton(
          onPressed: () => model.navigationService.back(),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xff5645F5), // innit
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Text(
              "2 of 3",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                height: 1.450,
                color: Color(0xFF302D53),
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xffF6F5FE),
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
                  Text(
                    "Level One",
                    style: TextStyle(
                      fontFamily: 'Boldonse', //
                      fontSize: 27.5,
                      height: 1.2,
                      letterSpacing: -0.2,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff2A0079),
                    ),
                    textAlign: TextAlign.start,
                  ),
                  verticalSpace(8.h),
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
                        color: Color(0xFF302D53),
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  verticalSpace(24.h),
                  CustomTextField(
                    label: "Phone Number",
                    hintText: "E.g. 9027382921",
                    // maxLength: 1,
                    minLines: 1,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.none,
                    onChanged: model.setPhoneNumber,
                    errorText: model.phoneNumberError,
                  ),
                  verticalSpace(17.5.h),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: "Date of Birth",
                          hintText: "DD",
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          onChanged: model.setDobDay,
                          // maxLength: 1,
                          minLines: 1,
                          // onChanged: model.setCountryOfOrigin,
                          shouldReadOnly: true,
                          onTap: () {
                            showModalBottomSheet(
                              barrierColor:
                                  const Color(0xff2A0079).withOpacity(0.5),
                              context: context,
                              isDismissible: false,
                              // isScrollControlled: true,
                              enableDrag: false,
                              elevation: 0,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(28.00))),
                              builder: (context) => SelectValueSheet(
                                title: "Select day",
                                list: model.days,
                                onSelected: model.setDobDay,
                              ),
                            );
                          },
                          controller: TextEditingController(text: model.dobDay),
                          errorText: model.dobDayError,
                          suffixIcon: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 12.0),
                            child: SvgPicture.asset(
                                height: 22,
                                'assets/svgs/stat_minus_1_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                                color: const Color(0xff2A0079)),
                          ),
                        ),
                      ),
                      horizontalSpaceSmall,
                      Expanded(
                        child: CustomTextField(
                          label: "hidden",
                          hintText: "MM",
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          onChanged: model.setDobMonth,
                          shouldReadOnly: true,
                          // maxLength: 1,
                          minLines: 1,
                          onTap: () {
                            showModalBottomSheet(
                              barrierColor:
                                  const Color(0xff2A0079).withOpacity(0.5),
                              context: context,
                              isDismissible: false,
                              // isScrollControlled: true,
                              enableDrag: false,
                              elevation: 0,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(28.00))),
                              builder: (context) => SelectValueSheet(
                                title: "Select month",
                                list: model.months,
                                onSelected: model.setDobMonth,
                              ),
                            );
                          },
                          controller:
                              TextEditingController(text: model.dobMonth),
                          errorText: model.dobMonthError,
                          suffixIcon: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 12.0),
                            child: SvgPicture.asset(
                                height: 22,
                                'assets/svgs/stat_minus_1_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                                color: const Color(0xff2A0079)),
                          ),
                        ),
                      ),
                      horizontalSpaceSmall,
                      Expanded(
                        child: CustomTextField(
                          label: "hidden",
                          hintText: "YYYY",
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          onChanged: model.setDobYear,
                          errorText: model.dobYearError,
                          shouldReadOnly: true,
                          // maxLength: 1,
                          minLines: 1,
                          onTap: () {
                            showModalBottomSheet(
                              barrierColor:
                                  const Color(0xff2A0079).withOpacity(0.5),
                              context: context,
                              isDismissible: false,
                              // isScrollControlled: true,
                              enableDrag: false,
                              elevation: 0,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(28.00))),
                              builder: (context) => SelectValueSheet(
                                title: "Select year",
                                list: model.years,
                                onSelected: model.setDobYear,
                              ),
                            );
                          },
                          controller:
                              TextEditingController(text: model.dobYear),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 12.0),
                            child: SvgPicture.asset(
                                height: 22,
                                'assets/svgs/stat_minus_1_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                                color: const Color(0xff2A0079)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  verticalSpace(17.5.h),
                  CustomTextField(
                    label: "Gender",
                    maxLength: 1,
                    minLines: 1,
                    hintText: "Select gender",
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    onChanged: model.setGender,
                    errorText: model.genderError,
                    shouldReadOnly: true,
                    onTap: () {
                      showModalBottomSheet(
                        barrierColor: const Color(0xff2A0079).withOpacity(0.5),
                        context: context,
                        isDismissible: false,
                        // isScrollControlled: true,
                        enableDrag: false,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(28.00))),
                        builder: (context) => SelectValueSheet(
                          title: "Select gender",
                          list: model.genders,
                          onSelected: model.setGender,
                        ),
                      );
                    },
                    controller: TextEditingController(text: model.gender),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 12.0),
                      child: SvgPicture.asset(
                          height: 22,
                          'assets/svgs/stat_minus_1_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                          color: const Color(0xff2A0079)),
                    ),
                  ),
                  verticalSpace(32.h),
                  SizedBox(
                    child: FilledBtn(
                      onPressed: model.isFormValid && !model.isBusy
                          ? () => model.submitForm(
                                context,
                                country: country,
                                state: state,
                                street: street,
                                city: city,
                                postalCode: postalCode,
                                address: address,
                              )
                          : null,
                      text: "Next - Enter BVN",
                      isLoading: model.isBusy,
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
    );
  }

  @override
  LevelOnePartBViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LevelOnePartBViewModel();
}
