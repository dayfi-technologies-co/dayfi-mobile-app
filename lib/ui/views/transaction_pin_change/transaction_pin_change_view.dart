import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/input_fields/pin_text_field.dart';
import 'package:stacked/stacked.dart';

import 'transaction_pin_change_viewmodel.dart';

class TransactionPinChangeView
    extends StackedView<TransactionPinChangeViewModel> {
  const TransactionPinChangeView({super.key});

  @override
  Widget builder(
    BuildContext context,
    TransactionPinChangeViewModel viewModel,
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
                "Old PIN",
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
                "Enter your old pin",
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
              verticalSpace(48),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * .125),
                child: Column(
                  children: [
                    PinTextField(
                      length: 4,
                      obscureText: true,
                      controller: viewModel.pinTextEditingController,
                      textInputAction: TextInputAction.next,
                      onTextChanged: (value) {
                        if (value.length != 4) {
                        } else {}
                      },
                    ),
                  ],
                ),
              ),
              verticalSpace(MediaQuery.of(context).size.height * .2),
              SizedBox(
                child: FilledBtn(
                  onPressed: () {},
                  text: "Next - New PIN",
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
  TransactionPinChangeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      TransactionPinChangeViewModel();
}
