import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/buttons/filled_btn_small.dart';
import 'package:dayfi/ui/components/input_fields/custom_text_field.dart';
import 'package:dayfi/ui/views/recipient_details/recipient_details_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'link_a_bank_viewmodel.dart';

class LinkABankView extends StackedView<LinkABankViewModel> {
  const LinkABankView({super.key});

  @override
  Widget builder(
    BuildContext context,
    LinkABankViewModel model,
    Widget? child,
  ) {
    return AppScaffold(
      backgroundColor: const Color(0xffF6F5FE),
      appBar: AppBar(
        backgroundColor: const Color(0xffF6F5FE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xff2A0079)),
          onPressed: () => model.navigationService.back(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: FilledBtnSmall(
              textColor: const Color(0xff5645F5), // innit
              backgroundColor: Colors.white,
              onPressed: () {},
              text: "Need Help?",
            ),
          ),
        ],
      ),
      body: StatefulBuilder(builder: (
        BuildContext context,
        setState,
      ) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          constraints: const BoxConstraints.expand(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    verticalSpace(10),
                    const Text(
                      "Add a Bank",
                      style: TextStyle(
                        fontFamily: 'Boldonse',
                        fontSize: 27.5,
                        height: 1.2,
                        letterSpacing: 0.00,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff2A0079),
                      ),
                      textAlign: TextAlign.start,
                    ).animate().fadeIn(
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    ).slideY(
                      begin: -0.1,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    ).scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    ),
                    verticalSpace(8.h),
                    const Text(
                      "Add a local bank details to withdraw your funds to.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        height: 1.450,
                        color: Color(0xFF302D53),
                      ),
                      textAlign: TextAlign.start,
                    ).animate().fadeIn(
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                      delay: 100.ms,
                    ).slideY(
                      begin: 0.1,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                      delay: 100.ms,
                    ),
                    verticalSpace(36.h),
                  ],
                ),
                CustomTextField(
                  label: "Bank name",
                  hintText: "Select bank",
                  shouldReadOnly: true,
                  suffixIcon: model.isLoading
                      ? model.accountNumber.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 12.0),
                              child: SvgPicture.asset(
                                  height: 22,
                                  'assets/svgs/stat_minus_1_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                                  color: const Color(0xff2A0079)),
                            )
                          : SizedBox(
                              height: 48,
                              width: 48,
                              child: const Center(
                                child: CupertinoActivityIndicator(
                                  color: Color(0xff5645F5), // innit
                                ),
                              ),
                            )
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 12.0),
                          child: SvgPicture.asset(
                              height: 22,
                              'assets/svgs/stat_minus_1_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                              color: const Color(0xff2A0079)),
                        ),
                  onTap: model.isLoading
                      ? null
                      : () {
                          showModalBottomSheet(
                            barrierColor:
                                const Color(0xff2A0079).withOpacity(0.5),
                            context: context,
                            isDismissible: false,
                            enableDrag: false,
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(28.00))),
                            builder: (context) => SelectBankSheet(
                              banks: model.banks,
                              onSelected: (value) {
                                model.accountNam = "";
                                model.notifyListeners();

                                //
                                model.setBankCode(value ?? '');
                                if (model.accountNumber.length == 10 &&
                                    value != null &&
                                    value.isNotEmpty) {
                                  model.resolveAccount(context);
                                }
                              },
                            ),
                          );
                        },
                  controller: TextEditingController(text: model.selectedBank),
                ).animate().fadeIn(
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                  delay: 200.ms,
                ).slideY(
                  begin: 0.1,
                  end: 0,
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                  delay: 200.ms,
                ).scale(
                  begin: const Offset(0.98, 0.98),
                  end: const Offset(1.0, 1.0),
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                  delay: 200.ms,
                ),
                verticalSpace(16.h),
                CustomTextField(
                  label: "Account number",
                  hintText: "Enter your account number",
                  maxLength: 10,
                  minLines: 1,
                  onChanged: (value) {
                    model.setAccountNumber(value);
                    if (value.length == 10 && model.bankCode.isNotEmpty) {
                      model.resolveAccount(context);
                    } else {
                      model.accountNam = "";
                      model.notifyListeners();
                    }
                  },
                  keyboardType: TextInputType.number,
                  suffixIcon: model.isLoading
                      ? model.accountNumber.isEmpty
                          ? const SizedBox()
                          : const CupertinoActivityIndicator(
                              color: Color(0xff5645F5), // innit
                            )
                      : model.accountNumberController.text == ""
                          ? TextButton(
                              onPressed: () async {
                                final clipboardData =
                                    await Clipboard.getData('text/plain');
                                if (clipboardData != null &&
                                    clipboardData.text != null) {
                                  String pastedText =
                                      clipboardData.text!.trim();
                                  pastedText = pastedText.replaceAll('@', '');
                                  model.setAccountNumber(pastedText);
                                  if (pastedText.length == 10 &&
                                      model.bankCode.isNotEmpty) {
                                    model.resolveAccount(context);
                                  }
                                }
                              },
                              style: TextButton.styleFrom(
                                  splashFactory: NoSplash.splashFactory),
                              child: const Text(
                                "Paste",
                                style: TextStyle(
                                  color: Color(0xff2A0079),
                                  fontSize: 16,
                                ),
                              ))
                          : const SizedBox(),
                  errorText: model.showAccountError && !model.isValidAccount
                      ? model.accountNumberController.text.length != 10
                          ? "Account number must be 10 digits"
                          : model.isLoading
                              ? ""
                              : "Invalid bank details"
                      : null,
                  controller: model.accountNumberController,
                ).animate().fadeIn(
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                  delay: 300.ms,
                ).slideY(
                  begin: 0.1,
                  end: 0,
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                  delay: 300.ms,
                ).scale(
                  begin: const Offset(0.98, 0.98),
                  end: const Offset(1.0, 1.0),
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                  delay: 300.ms,
                ),
                if (model.accountName.isNotEmpty && model.isValidAccount)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      model.accountName == "Pastor Bright"
                          ? "Bale Gary"
                          : model.accountName,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.450,
                        letterSpacing: .255,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ).animate().fadeIn(
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                    delay: 400.ms,
                  ).slideX(
                    begin: -0.1,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                    delay: 400.ms,
                  ),
                verticalSpace(48.h),
                FilledBtn(
                  onPressed: () {
                    model.saveAccountToDatabase(context);
                  },
                  text: "Save Bank",
                  backgroundColor: model.isValidAccount
                      ? const Color(0xff5645F5)
                      : const Color(0xffCAC5FC),
                ).animate().fadeIn(
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                  delay: 500.ms,
                ).slideY(
                  begin: 0.1,
                  end: 0,
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                  delay: 500.ms,
                ).shimmer(
                  duration: 2000.ms,
                  color: Colors.white.withOpacity(0.3),
                  delay: 700.ms,
                ),
                verticalSpace(40.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  LinkABankViewModel viewModelBuilder(BuildContext context) =>
      LinkABankViewModel();

  @override
  void onViewModelReady(
    LinkABankViewModel viewModel,
  ) async {
    await viewModel.loadUser();
    await viewModel.loadBanks();
    await viewModel.loadSavedAccounts();
    super.onViewModelReady(viewModel);
  }
}
