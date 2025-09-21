import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/buttons/outlined_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stacked/stacked.dart';

import 'wallet_address_info_viewmodel.dart';

class WalletAddressInfoView extends StatelessWidget {
  final String address;
  final String currency;
  final String network;

  WalletAddressInfoView(
      {required this.address, required this.currency, required this.network});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WalletAddressInfoViewModel>.reactive(
      viewModelBuilder: () => WalletAddressInfoViewModel(
          address: address, currency: currency, network: network),
      builder: (context, model, child) => AppScaffold(
        backgroundColor: Color(0xffF6F5FE),
        appBar: AppBar(
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Color(0xffF6F5FE),
          leading: IconButton(
            onPressed: () => model.navigationService.back(),
            icon: const Icon(
              Icons.arrow_back_ios,
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
                  "Fund $currency via $network",
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
                  'Share the wallet address generated to receive $currency via the $network network.',
                  style: TextStyle(
                    fontSize: 15,
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
                Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 245, 252, 254),
                    borderRadius: BorderRadius.circular(4.0),
                    border: Border.all(
                      color: Color.fromARGB(255, 26, 77, 104),
                    ),
                  ),
                  child: Row(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/images/idea.png",
                        height: 22,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Only send $currency via the $network blockchain to this wallet address. Using any other method will result in loss of funds.',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Karla',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            height: 1.450,
                            color: Color.fromARGB(255, 26, 77, 104),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Wallet address',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    fontFamily: 'Karla',
                    letterSpacing: 0.3,
                    height: 1.450,
                    color: Color.fromARGB(255, 26, 77, 104),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                  margin: const EdgeInsets.symmetric(vertical: 6),
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
                        child: Text(
                          model.address,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.450,
                            fontFamily: 'Boldonse',
                            letterSpacing: .255,
                            color: Color(0xff2A0079),
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * .1),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(
                            text: model.address,
                          ));
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Color(0xff5645F5).withOpacity(.1),
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "copy",
                                style: TextStyle(
                                  fontFamily: 'Karla',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  letterSpacing: 0.00,
                                  height: 1.450,
                                  color: Color(0xff5645F5), // innit
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.copy,
                                color: Color(0xff5645F5), // innit
                                size: 17,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    'OR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xff5645F5),
                      fontSize: 15.sp,
                      height: 1.450,
                      fontFamily: 'Boldonse',
                      letterSpacing: .255,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    'Scan QR Code',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      fontFamily: 'Karla',
                      letterSpacing: 0.3,
                      height: 1.450,
                      color: Color.fromARGB(255, 26, 77, 104),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Center(
                    child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(24),
                        child: QrImageView(data: model.address, size: 200))),
                SizedBox(height: 40),
                SizedBox(
                  child: FilledBtn(
                    onPressed: model.shareAddress,
                    text: "Share Wallet address",
                    // backgroundColor: Colors.white,
                    // textColor: const Color(0xff5645F5),
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  child: OutlineBtn(
                    onPressed: () => Navigator.pop(context),
                    text: "Close, I'm done",
                    backgroundColor: Colors.white,
                    textColor: const Color(0xff5645F5),
                    borderColor: const Color(0xff5645F5),
                  ),
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
