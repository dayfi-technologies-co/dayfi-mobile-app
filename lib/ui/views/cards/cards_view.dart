import 'package:dayfi/app/app.router.dart';
import 'package:flutter/material.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:stacked/stacked.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'cards_viewmodel.dart';

class CardsView extends StackedView<CardsViewModel> {
  const CardsView({super.key});

  @override
  Widget builder(
    BuildContext context,
    CardsViewModel model,
    Widget? child,
  ) {
    return AppScaffold(
      backgroundColor: const Color(0xffF7F7F7),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Level Up',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        fontFamily: 'Boldonse',
                        letterSpacing: -0.2,
                        color: Color(0xff011B33),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * .14,
              ),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * .15),
                  Text(
                    'Run Stablecoins Like a Pro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.450,
                      fontFamily: 'Boldonse',
                      letterSpacing: 0,
                      color: Color(0xff011B33),
                    ),
                  ),
                  verticalSpace(12.h),
                  Text(
                    'Stack stablecoins like USDT or USDC with max security and low-key fees. Instant moves, no stress.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.450,
                      fontFamily: 'Karla',
                      letterSpacing: .2,
                      color: Color(0xff302D53),
                    ),
                  ),
                  verticalSpace(24.h),
                ],
              ),
            ),
            verticalSpace(24.h),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 18.0,
              ),
              child: Column(
                children: [
                  FilledBtn(
                    onPressed: () => {
                      model.navigationService.navigateToPrepaidInfoView(
                          // coinId: coin['id']?.toString() ?? '',
                          // coinName: coin['name']?.toString() ?? 'Unknown',
                          // coinPrice: _parseNum(coin['price_usd']) ?? 0.0,
                          // priceChange:
                          //     (_parseNum(coin['price_change']) ?? 0).toDouble(),
                          // marketCap: coin['market_cap']?.toString() ?? '0',
                          // popularity: coin['popularity']?.toString() ?? '#N/A',
                          ),
                    },
                    text: 'Cop a Stablecoin',
                    backgroundColor: Color(0xff011B33),
                    textColor: Colors.white,
                  ),
                  verticalSpace(16.h),
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
                        Padding(
                          padding: const EdgeInsets.all(6.5),
                          child: Image.asset(
                            "assets/images/idea.png",
                            height: 22,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Be part of the 6% that own digital assets, all in a few steps, with the best rates",
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
                ],
              ),
            ),
          ],
        ),
      ),
    );

    //    AppScaffold(
    //     backgroundColor: const Color(0xffF7F7F7),
    //     body: Container(
    //       height: MediaQuery.of(context).size.height,
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: [
    //           Padding(
    //             padding: const EdgeInsets.symmetric(horizontal: 24.0),
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 SizedBox(height: 24.h),
    //                 Align(
    //                   alignment: Alignment.topLeft,
    //                   child: Text(
    //                     'dayfi Virtual cards',
    //                     style: TextStyle(
    //                       fontSize: 30,
    //                       fontWeight: FontWeight.w600,
    //                       height: 1.2,
    //                       fontFamily: 'Boldonse',
    //                       letterSpacing: -0.2,
    //                       color: Color(0xff011B33),
    //                     ),
    //                   ),
    //                 ),
    //                 SizedBox(height: 12.h),
    //                 // _buildDescription(context),
    //                 SizedBox(height: 40.h),
    //                 // _buildProfileHeader(viewModel, wallet),
    //                 SizedBox(height: 30.h),
    //               ],
    //             ),
    //           ),
    //           Container(
    //             padding: EdgeInsets.symmetric(
    //               horizontal: MediaQuery.of(context).size.width * .14,
    //             ),
    //             child: Column(
    //               children: [
    //                 SizedBox(height: MediaQuery.of(context).size.height * .15),
    //                 Text(
    //                   'Create, customise and utilize dayfi virtual cards',
    //                   textAlign: TextAlign.center,
    //                   style: TextStyle(
    //                     fontSize: 17.sp,
    //                     fontWeight: FontWeight.w600,
    //                     height: 1.450,
    //                     fontFamily: 'Boldonse',
    //                     letterSpacing: -0.2,
    //                     color: Color(0xff011B33),
    //                   ),
    //                 ),
    //                 verticalSpace(12.h),
    //                 Text(
    //                   'Instant and ready-to-use cards for online payment, shopping, subscription, and lots more.',
    //                   textAlign: TextAlign.center,
    //                   style: TextStyle(
    //                     fontSize: 14.sp,
    //                     fontWeight: FontWeight.w600,
    //                     height: 1.450,
    //                     fontFamily: 'Karla',
    //                     letterSpacing: -.1,
    //                     color: Color(0xff011B33),
    //                   ),
    //                 ),
    //                 verticalSpace(24.h),
    //               ],
    //             ),
    //           ),
    //           verticalSpace(24.h),
    //           Padding(
    //             padding: const EdgeInsets.symmetric(
    //               horizontal: 24.0,
    //               vertical: 18.0,
    //             ),
    //             child: FilledBtn(
    //               onPressed: () => {},
    //               text: 'Coming soon - Learn more',
    //               backgroundColor: const Color(0xff5645F5),
    //               textColor: Colors.white,
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
  }

  @override
  CardsViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      CardsViewModel();
}
