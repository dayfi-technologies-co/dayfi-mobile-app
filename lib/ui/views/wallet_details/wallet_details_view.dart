import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/data/models/wallet_reponse.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/buttons/filled_btn_small.dart';
import 'package:stacked/stacked.dart';

import 'wallet_details_viewmodel.dart';

class WalletDetailsView extends StackedView<WalletDetailsViewModel> {
  const WalletDetailsView({
    super.key,
    required this.wallet,
  });

  final Wallet wallet;

  @override
  Widget builder(
    BuildContext context,
    WalletDetailsViewModel viewModel,
    Widget? child,
  ) {
    return AppScaffold(
      backgroundColor: const Color(0xffF6F5FE),
      appBar: AppBar(
        backgroundColor: const Color(0xffF6F5FE),
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff2A0079)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: FilledBtnSmall(
              textColor: Color(0xff5645F5), // innit
              backgroundColor: Colors.white,
              onPressed: () {},
              text: "Need Help?",
            ),
          ),
        ],
      ),
      body: _buildBody(context, wallet),
    );
  }

  Widget _buildBody(
    BuildContext context,
    Wallet wallet,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpace(8.h),
          const Text(
            "Wallet bank details",
            style: TextStyle(
              fontSize: 27.5,
              fontFamily: "SpaceGrotesk",
              height: 1.2,
              letterSpacing: 0.00,
              fontWeight: FontWeight.w600,
              color: Color(0xff2A0079),
            ),
          ),
          verticalSpace(6.h),
          const Text(
            "Copy and share your wallet details easily",
            style: TextStyle(
              fontFamily: 'Karla',
              fontWeight: FontWeight.w600,
              letterSpacing: .3,
              height: 1.450,
              color: Color(0xFF302D53),
            ),
          ),
          verticalSpace(24.h),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xff5645F5).withOpacity(.08),
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(
                    color: Color(0xff5645F5).withOpacity(.5),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wallet.accountNumber,
                              style: TextStyle(
                                fontFamily: 'Boldonse',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                letterSpacing: 0.00,
                                height: 1.450,
                                color: Color(0xff2A0079),
                              ),
                            ),
                            Text(
                              'Account number',
                              style: TextStyle(
                                fontFamily: 'Karla',
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.00,
                                height: 1.450,
                                color: Color(0xFF302D53),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: wallet.accountNumber));
                          },
                          child: Row(
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
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wallet.accountName,
                              style: TextStyle(
                                fontFamily: 'Boldonse',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                letterSpacing: 0.00,
                                height: 1.450,
                                color: Color(0xff2A0079),
                              ),
                            ),
                            Text(
                              'Account name',
                              style: TextStyle(
                                fontFamily: 'Karla',
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.00,
                                height: 1.450,
                                color: Color(0xFF302D53),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: wallet.accountName));
                          },
                          child: Row(
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
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wallet.bankName,
                              style: TextStyle(
                                fontFamily: 'Boldonse',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                letterSpacing: 0.00,
                                height: 1.450,
                                color: Color(0xff2A0079),
                              ),
                            ),
                            Text(
                              'Bank name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.00,
                                height: 1.450,
                                color: Color(0xFF302D53),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: wallet.bankName));
                          },
                          child: Row(
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
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wallet.currency,
                              style: TextStyle(
                                fontFamily: 'Boldonse',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                letterSpacing: 0.00,
                                height: 1.450,
                                color: Color(0xff2A0079),
                              ),
                            ),
                            Text(
                              'Currency',
                              style: TextStyle(
                                fontFamily: 'Karla',
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.00,
                                height: 1.450,
                                color: Color(0xFF302D53),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: wallet.currency));
                          },
                          child: Row(
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
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 245, 252, 254),
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: Color.fromARGB(255, 26, 77, 104)),
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
                        'Charge for funding your NGN wallet is 1% capped at 50.00',
                        style: TextStyle(
                          fontSize: 14,
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
            ],
          ),
          SizedBox(height: 24),
          FilledBtn(
            onPressed: () => {},
            text: 'Share details',
            backgroundColor: const Color(0xff5645F5),
          ),
          verticalSpace(40.h),
        ],
      ),
    );
  }

  @override
  WalletDetailsViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      WalletDetailsViewModel();
}
