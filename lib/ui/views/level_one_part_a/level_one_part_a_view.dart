// import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/input_fields/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/ui/views/home/bottom_sheets/success_bottomsheet.dart';
import 'package:stacked/stacked.dart';

import 'level_one_part_a_viewmodel.dart';

class LevelOnePartAView extends StackedView<LevelOnePartAViewModel> {
  const LevelOnePartAView({super.key});

  @override
  Widget builder(
    BuildContext context,
    LevelOnePartAViewModel model,
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
              "1 of 3",
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
                    label: "Country of origin",
                    hintText: "Select a country",
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    // onChanged: model.setCountryOfOrigin,
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
                          title: "Select country",
                          list: model.countries,
                          onSelected: model.setSelectedCountry,
                        ),
                      );
                    },
                    controller:
                        TextEditingController(text: model.countryOfOrigin),
                    errorText: model.countryOfOriginError,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 12.0),
                      child: SvgPicture.asset(
                        'assets/svgs/stat_minus_1_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                        height: 22,
                        color: const Color(0xff5645F5), // innit
                      ),
                    ),
                  ),
                  verticalSpace(17.5.h),
                  CustomTextField(
                    label: "Residence address",
                    hintText: "Enter full address",
                    keyboardType: TextInputType.streetAddress,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    onChanged: model.setResidenceAddress,
                    errorText: model.residenceAddressError,
                  ),
                  verticalSpace(17.5.h),
                  CustomTextField(
                    label: "City/Town",
                    hintText: "Enter city/town",
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    onChanged: model.setCityTown,
                    errorText: model.cityTownError,
                  ),
                  verticalSpace(17.5.h),
                  CustomTextField(
                    label: "Street",
                    hintText: "Enter street",
                    keyboardType: TextInputType.streetAddress,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    onChanged: model.setStreet,
                    errorText: model.streetError,
                  ),
                  verticalSpace(17.5.h),
                  CustomTextField(
                    label: "Zip code",
                    hintText: "Enter zip code",
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onChanged: model.setZipCode,
                    errorText: model.zipCodeError,
                  ),
                  verticalSpace(17.5.h),
                  CustomTextField(
                    label: "State",
                    hintText: "Select a state",
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.words,
                    // onChanged: model.setCountryOfOrigin,
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
                          title: "Select state",
                          list: model.states,
                          onSelected: model.setSelectedState,
                        ),
                      );
                    },
                    controller: TextEditingController(text: model.state),
                    errorText: model.stateError,
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
                          ? () => model.submitForm(context)
                          : null,
                      text: "Next - Enter contact info",
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
  LevelOnePartAViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LevelOnePartAViewModel();
}

class SelectValueSheet extends StatelessWidget {
  final List<String> list;
  final Function(String?) onSelected;
  final String? title, description;

  const SelectValueSheet({
    required this.list,
    required this.onSelected,
    this.title,
    this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(40)),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 88,
              height: 4,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .color!
                    .withOpacity(0.25),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: SvgPicture.asset(
                'assets/svgs/close_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                color: const Color(0xff5645F5), // innit
                height: 28.00,
              ),
            ),
          ),
          // SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          buildBottomSheetHeader(
            context,
            title: title!,
            subtitle: '',
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemCount: list.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(list[index]),
                onTap: () {
                  onSelected(list[index]);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
