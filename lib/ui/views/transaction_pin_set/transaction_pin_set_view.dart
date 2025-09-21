// import 'package:google_fonts/google_fonts.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/views/transaction_pin_set/transaction_pin_set_viewmodel.dart';
import 'package:stacked/stacked.dart';

class TransactionPinSetView extends StackedView<TransactionPinSetViewModel> {
  const TransactionPinSetView({super.key});

  @override
  Widget builder(
    BuildContext context,
    TransactionPinSetViewModel viewModel,
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
            Icons.arrow_back_ios,
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
                "Reset transaction PIN",
                style: TextStyle(
                  fontFamily: 'Boldonse',
                  fontSize: 27.5,
                  height: 1.2,
                  letterSpacing: 0.00,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff2A0079),
                  // color: Color( 0xff5645F5), // innit
                ),
                textAlign: TextAlign.start,
              ),
              verticalSpace(12),
              Text(
                "To reset your transaction PIN, we'll email you a secure one-time password (OTP) for verification.",
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
              verticalSpace(54),
              // Padding(
              //   padding: EdgeInsets.symmetric(
              //       horizontal: MediaQuery.of(context).size.width * .125),
              //   child: Column(
              //     children: [
              //       Column(
              //         // crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text(
              //             "Transaction PIN",
              //             style: TextStyle(
              //               fontFamily: 'Karla',
              //               fontSize: 14,
              //               fontWeight: FontWeight.w600,
              //               letterSpacing: -.1,
              //               height: 1.450,
              //               color: Theme.of(context)
              //                   .textTheme
              //                   .bodyLarge!
              //                   .color!
              //                   .withOpacity(.95),
              //             ),
              //             textAlign: TextAlign.start,
              //           ),
              //           verticalSpace(10),
              //           PinTextField(
              //             length: 4,
              //             obscureText: true,
              //             controller: viewModel.pinTextEditingController,
              //             textInputAction: TextInputAction.next,
              //             onTextChanged: (value) {
              //               if (value.length != 4) {
              //               } else {}
              //             },
              //           ),
              //         ],
              //       ),
              //       verticalSpace(17.5),
              //       Column(
              //         // crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text(
              //             "Confirm Transaction PIN",
              //             style: TextStyle(
              //               fontFamily: 'Karla',
              //               fontSize: 14,
              //               fontWeight: FontWeight.w600,
              //               letterSpacing: -.1,
              //               height: 1.450,
              //               color: Theme.of(context)
              //                   .textTheme
              //                   .bodyLarge!
              //                   .color!
              //                   .withOpacity(.95),
              //             ),
              //             textAlign: TextAlign.start,
              //           ),
              //           verticalSpace(10),
              //           PinTextField(
              //             length: 4,
              //             obscureText: true,
              //             controller: viewModel.confirmPinTextEditingController,
              //             onTextChanged: (value) {
              //               if (value.length != 6) {
              //               } else {}
              //             },
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              // verticalSpace(24),
              SizedBox(
                child: FilledBtn(
                  onPressed: () {
                    viewModel.navigationService
                        .navigateToVerifyEmailView(email: '');
                  },
                  text: "Request Email Code",
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
  TransactionPinSetViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      TransactionPinSetViewModel();
}
