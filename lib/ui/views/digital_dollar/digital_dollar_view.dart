import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/views/home/bottom_sheets/success_bottomsheet.dart';
import 'package:dayfi/ui/views/wallet_address_info/wallet_address_info_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stacked/stacked.dart';

import 'digital_dollar_viewmodel.dart';

class DigitalDollarView extends StatefulWidget {
  @override
  State<DigitalDollarView> createState() => _DigitalDollarViewState();
}

class _DigitalDollarViewState extends State<DigitalDollarView> {
  // final DigitalDollarViewModel viewM = DigitalDollarViewModel();

  // @override
  // void initState() {
  //   Future.delayed(Duration(milliseconds: 500),
  //       () => _showCurrencyBottomSheet(context, viewM));
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DigitalDollarViewModel>.reactive(
        viewModelBuilder: () => DigitalDollarViewModel(),
        builder: (context, model, child) {
          return AppScaffold(
            backgroundColor: Color(0xffF6F5FE),
            bottomNavigation: _buildProceedButton(context, model),
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
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    verticalSpace(10),
                    Text(
                      "Via Digital Dollars",
                      style: TextStyle(
                        fontFamily: 'Boldonse',
                        fontSize: 27.5,
                        height: 1.2,
                        letterSpacing: -0.2,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff2A0079),
                      ),
                    ),
                    verticalSpace(10),
                    Text(
                      "Select wallet address or generate new",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        height: 1.450,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .color!
                            .withOpacity(.85),
                      ),
                    ),
                    verticalSpace(24.h),
                    Text(
                      'Recent address',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "SpaceGrotesk",
                        color: Color(0xff2A0079),
                        letterSpacing: -.02,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    model.recentAddresses.isEmpty
                        ? Text('')
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: model.recentAddresses.length,
                            itemBuilder: (context, index) {
                              final addr = model.recentAddresses[index];
                              return InkWell(
                                onTap: () => model.navigationService
                                    .navigateToView(WalletAddressInfoView(
                                        address: addr['address']!,
                                        currency: addr['currency']!,
                                        network: addr['network']!)),
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 16, 8, 16),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: .2500,
                                      color: Color(0xff5645F5).withOpacity(1.0),
                                    ),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${addr['currency']} via ${addr['network']}',
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                                height: 1.450,
                                                fontFamily: 'Boldonse',
                                                letterSpacing: .255,
                                                color: Color(0xff2A0079),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    addr['address']!,
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      height: 1.450,
                                                      fontFamily: 'Karla',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      letterSpacing: .1,
                                                      color: Color(0xff304463),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Icon(
                                                  Icons.copy,
                                                  color: Color(
                                                      0xff5645F5), // innit
                                                  size: 20,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .15),
                                      Transform.rotate(
                                        angle: 4.74,
                                        child: SvgPicture.asset(
                                          'assets/svgs/stat_minus_1_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                                          height: 22,
                                          color: const Color(0xff5645F5),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                    .animate(
                                      key: ValueKey(1 + index),
                                    )
                                    .fadeIn(
                                        duration: 320.00.ms,
                                        curve: Curves.easeInOutCirc)
                                    .slideY(
                                        begin: 0.45,
                                        end: 0,
                                        duration:
                                            (600 + (50 * (index + 1))).ms),
                              );
                            },
                          ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildProceedButton(
      BuildContext context, DigitalDollarViewModel model) {
    return Container(
      padding:
          EdgeInsets.only(bottom: 24.h, top: 12.h, left: 24.w, right: 24.w),
      child: FilledBtn(
        onPressed: () => _showCurrencyBottomSheet(context, model),
        backgroundColor: const Color(0xff5645F5),
        text: "Generate New Address",
        // textColor: Colors.white,
      ),
    );
  }

  void _showCurrencyBottomSheet(
      BuildContext context, DigitalDollarViewModel model) {
    showModalBottomSheet(
      barrierColor: const Color(0xff5645F5).withOpacity(0.5),
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      enableDrag: false,
      elevation: 0,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.00))),
      builder: (context) => StatefulBuilder(builder: (
        BuildContext context,
        StateSetter setState,
      ) {
        return SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * .6,
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28.00),
                topRight: Radius.circular(28.00),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      onTap: () => model.navigationService.back(),
                      child: SvgPicture.asset(
                        'assets/svgs/close_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                        color: const Color(0xff5645F5), // innit
                        height: 28,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildBottomSheetHeader(
                        context,
                        title: "Select Digital Dollars",
                        subtitle: "What currency do you want to fund from?",
                      ),
                      const SizedBox(height: 24),
                      InkWell(
                        onTap: () {
                          model.selectCurrency('USDT');
                          _showNetworkBottomSheet(context, model, 'USDT');
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xff5645F5).withOpacity(.35),
                              width: 1.0,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor:
                                          Color(0xff5645F5).withOpacity(.05),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: Image.asset(
                                          "assets/images/tether-usdt-logo.png",
                                          height: 22,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text("USDT",
                                                    style: TextStyle(
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        height: 1.450,
                                                        fontFamily:
                                                            'SpaceGrotesk',
                                                        letterSpacing: .255,
                                                        color:
                                                            Color(0xff2A0079),
                                                        overflow: TextOverflow
                                                            .ellipsis)),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .05),
                                            child: Text(
                                              "Click here to select the currency",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600,
                                                height: 1.450,
                                                fontFamily: 'Karla',
                                                letterSpacing: .1,
                                                color: Color(0xff304463),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          model.selectCurrency('USDC');
                          _showNetworkBottomSheet(context, model, 'USDC');
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xff5645F5).withOpacity(.35),
                              width: 1.0,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor:
                                          Color(0xff5645F5).withOpacity(.05),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: Image.asset(
                                          "assets/images/usdc.png",
                                          height: 22,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text("USDC",
                                                    style: TextStyle(
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        height: 1.450,
                                                        fontFamily:
                                                            'SpaceGrotesk',
                                                        letterSpacing: .255,
                                                        color:
                                                            Color(0xff2A0079),
                                                        overflow: TextOverflow
                                                            .ellipsis)),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .05),
                                            child: Text(
                                              "Click here to select the currency",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600,
                                                height: 1.450,
                                                fontFamily: 'Karla',
                                                letterSpacing: .1,
                                                color: Color(0xff304463),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void _showNetworkBottomSheet(
    BuildContext context,
    DigitalDollarViewModel model,
    String selectedNetwork,
  ) {
    showModalBottomSheet(
      barrierColor: const Color(0xff5645F5).withOpacity(0.5),
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      enableDrag: false,
      elevation: 0,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.00))),
      builder: (context) => StatefulBuilder(builder: (
        BuildContext context,
        StateSetter setState,
      ) {
        return SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * .6,
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28.00),
                topRight: Radius.circular(28.00),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      onTap: () => model.navigationService.back(),
                      child: SvgPicture.asset(
                        'assets/svgs/close_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                        color: const Color(0xff5645F5), // innit
                        height: 28,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildBottomSheetHeader(
                        context,
                        title: "Select Network",
                        subtitle: "What network do you want to fund from?",
                      ),
                      const SizedBox(height: 24),
                      InkWell(
                        onTap: () {
                          model.selectNetwork(
                              selectedNetwork == "USDT" ? "SOL" : 'Stellar');
                          model.generateNewAddress();
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xff5645F5).withOpacity(.35),
                              width: 1.0,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor:
                                          Color(0xff5645F5).withOpacity(.05),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: Image.asset(
                                          selectedNetwork == "USDT"
                                              ? ""
                                              : "assets/images/stellar-xlm-logo.png",
                                          height: 22,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                    selectedNetwork == "USDT"
                                                        ? "Solana"
                                                        : "Stellar",
                                                    style: TextStyle(
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        height: 1.450,
                                                        fontFamily:
                                                            'SpaceGrotesk',
                                                        letterSpacing: .255,
                                                        color:
                                                            Color(0xff2A0079),
                                                        overflow: TextOverflow
                                                            .ellipsis)),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .05),
                                            child: Text(
                                              "Click here to select the network",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600,
                                                height: 1.450,
                                                fontFamily: 'Karla',
                                                letterSpacing: .1,
                                                color: Color(0xff304463),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
